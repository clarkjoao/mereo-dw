"""Restore local backup (output/backups) → simulador MSSQL_*."""

from __future__ import annotations

import argparse
import base64
import gzip
import json
import re
import sys
import time
from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal
from pathlib import Path
from typing import Any, Iterator

from mereo_tools import db
from mereo_tools.config import load_mssql_config
from mereo_tools.db import use_database
from mereo_tools.ddl_extract import TableDef, extract_database_ddl
from mereo_tools.clone_sim import (
    _create_database,
    _drop_database,
    _enable_cdc,
    _execute,
    _insert_batch,
    _set_foreign_keys_enabled,
    _truncate_table,
)

PILOT_DATABASES = ("MereoGR-Afya", "MereoGR-Staging", "MereoGR-Allos")
DEFAULT_IN = Path("output/backups")


@dataclass
class RestoreOptions:
    databases: list[str]
    in_dir: Path
    batch_size: int
    pause_table: float
    pause_db: float
    skip_drop: bool
    enable_cdc: bool
    resume: bool


def _table_data_path(out_db: Path, schema: str, table: str) -> Path:
    safe = f"{schema}__{table}".replace("/", "_")
    return out_db / "data" / f"{safe}.jsonl.gz"


def _progress_path(out_db: Path) -> Path:
    return out_db / "restore_progress.json"


def _load_progress(path: Path) -> set[str]:
    if not path.exists():
        return set()
    return set(json.loads(path.read_text()).get("completed_tables", []))


def _save_progress(path: Path, completed: set[str]) -> None:
    path.write_text(json.dumps({"completed_tables": sorted(completed)}, indent=2))


def _deserialize_value(value: Any) -> Any:
    if isinstance(value, dict) and "__binary__" in value:
        return base64.b64decode(value["__binary__"])
    if isinstance(value, str):
        try:
            return datetime.fromisoformat(value.replace("Z", "+00:00"))
        except ValueError:
            pass
        try:
            return Decimal(value)
        except Exception:
            return value
    return value


def _deserialize_row(row: dict[str, Any]) -> dict[str, Any]:
    return {k: _deserialize_value(v) for k, v in row.items()}


def _iter_jsonl_gz(path: Path) -> Iterator[dict[str, Any]]:
    with gzip.open(path, "rt", encoding="utf-8") as gz:
        for line in gz:
            line = line.strip()
            if line:
                yield _deserialize_row(json.loads(line))


def _has_backup_rows(path: Path) -> bool:
    if not path.exists() or path.stat().st_size <= 22:
        return False
    with gzip.open(path, "rb") as gz:
        chunk = gz.read(64)
    return bool(chunk.strip())


def _strip_sql_comments(sql: str) -> str:
    lines = [line for line in sql.splitlines() if not line.strip().startswith("--")]
    return "\n".join(lines).strip()


def _apply_schema_sql(conn, database: str, schema_path: Path) -> None:
    content = schema_path.read_text(encoding="utf-8")
    batches = re.split(r"^\s*GO\s*$", content, flags=re.MULTILINE | re.IGNORECASE)
    with use_database(conn, database):
        for batch in batches:
            stmt = _strip_sql_comments(batch)
            if not stmt:
                continue
            _execute(conn, stmt, autocommit=True)


def _insert_from_backup(
    conn,
    database: str,
    table: TableDef,
    data_path: Path,
    *,
    batch_size: int,
) -> int:
    _truncate_table(conn, database, table.schema, table.name)
    batch: list[dict[str, Any]] = []
    total = 0
    identity_on = table.has_identity
    col_names = [c.name for c in table.select_columns]

    for row in _iter_jsonl_gz(data_path):
        db_row = {col: row.get(col) for col in col_names if col in row}
        batch.append(db_row)
        if len(batch) >= batch_size:
            _insert_batch(conn, database, table, batch, identity_on=identity_on)
            total += len(batch)
            batch = []
    if batch:
        _insert_batch(conn, database, table, batch, identity_on=identity_on)
        total += len(batch)
    return total


def restore_database(conn, database: str, *, options: RestoreOptions) -> dict[str, Any]:
    in_db = options.in_dir / database
    schema_sql = in_db / "schema" / "schema.sql"
    if not schema_sql.exists():
        raise FileNotFoundError(f"Schema não encontrado: {schema_sql}")

    progress = _progress_path(in_db)
    completed = _load_progress(progress) if options.resume else set()

    print(f"\n{'=' * 60}")
    print(f"Banco: {database}")
    print(f"  origem: {in_db}")

    if not options.skip_drop:
        print("  Recriando banco...")
        _drop_database(conn, database)
        _create_database(conn, database)

    print("  Aplicando schema...")
    _apply_schema_sql(conn, database, schema_sql)

    ddl = extract_database_ddl(conn, database)
    print(f"  tabelas: {len(ddl.tables)} | restore dados...")

    _set_foreign_keys_enabled(conn, database, enabled=False)

    stats = {"database": database, "tables": len(ddl.tables), "rows": 0, "loaded": 0}
    for i, table in enumerate(ddl.tables, 1):
        full = f"{table.schema}.{table.name}"
        if options.resume and full in completed:
            continue
        data_path = _table_data_path(in_db, table.schema, table.name)
        if not _has_backup_rows(data_path):
            completed.add(full)
            _save_progress(progress, completed)
            continue
        print(f"  [{i}/{len(ddl.tables)}] {full}...", end=" ", flush=True)
        rows = _insert_from_backup(
            conn, database, table, data_path, batch_size=options.batch_size
        )
        stats["rows"] += rows
        stats["loaded"] += 1
        print(f"{rows:,} linhas")
        completed.add(full)
        _save_progress(progress, completed)
        if options.pause_table > 0:
            time.sleep(options.pause_table)

    _set_foreign_keys_enabled(conn, database, enabled=True)

    if options.enable_cdc:
        print("  Habilitando CDC em dbo.COLABORADOR...")
        _enable_cdc(conn, database)

    if not options.resume:
        progress.unlink(missing_ok=True)

    print(
        f"  Concluído {database}: {stats['loaded']} tbl com dados, "
        f"{stats['rows']:,} linhas restauradas"
    )
    return stats


def run_restore(options: RestoreOptions) -> int:
    print("Origem: backup local")
    print(f"Destino: MSSQL_* (simulador)")
    print(f"Bancos: {', '.join(options.databases)}")
    print(f"resume={options.resume} skip_drop={options.skip_drop} cdc={options.enable_cdc}")
    print()

    conn = db.connect(config=load_mssql_config())
    manifests: list[dict[str, Any]] = []
    try:
        for i, database in enumerate(options.databases):
            manifests.append(restore_database(conn, database, options=options))
            if i < len(options.databases) - 1 and options.pause_db > 0:
                print(f"Pausa {options.pause_db}s antes do próximo banco...")
                time.sleep(options.pause_db)
    finally:
        conn.close()

    summary_path = options.in_dir / "restore_summary.json"
    summary_path.write_text(json.dumps(manifests, indent=2), encoding="utf-8")
    print(f"\nRestore concluído. Resumo: {summary_path}")
    for m in manifests:
        print(f"  {m['database']}: {m['loaded']} tbl, {m['rows']:,} linhas")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Restore de output/backups/ para o SQL Server sim (MSSQL_*)"
    )
    parser.add_argument(
        "--databases",
        default=",".join(PILOT_DATABASES),
        help="Bancos separados por vírgula",
    )
    parser.add_argument(
        "--in-dir",
        default=str(DEFAULT_IN),
        help="Diretório base do backup (padrão: output/backups)",
    )
    parser.add_argument("--batch-size", type=int, default=500, help="Linhas por INSERT batch")
    parser.add_argument("--pause-table", type=float, default=0.1, help="Pausa entre tabelas (s)")
    parser.add_argument("--pause-db", type=float, default=5.0, help="Pausa entre bancos (s)")
    parser.add_argument(
        "--skip-drop",
        action="store_true",
        help="Não dropar/recriar banco (só schema+ dados em banco existente)",
    )
    parser.add_argument(
        "--enable-cdc",
        action="store_true",
        default=True,
        help="Habilitar CDC em dbo.COLABORADOR após restore",
    )
    parser.add_argument(
        "--no-enable-cdc",
        action="store_false",
        dest="enable_cdc",
        help="Não habilitar CDC",
    )
    parser.add_argument("--resume", action="store_true", help="Retomar tabelas já restauradas")
    args = parser.parse_args(argv)

    options = RestoreOptions(
        databases=[d.strip() for d in args.databases.split(",") if d.strip()],
        in_dir=Path(args.in_dir),
        batch_size=args.batch_size,
        pause_table=args.pause_table,
        pause_db=args.pause_db,
        skip_drop=args.skip_drop,
        enable_cdc=args.enable_cdc,
        resume=args.resume,
    )
    try:
        return run_restore(options)
    except KeyboardInterrupt:
        print("\nInterrompido — use --resume para continuar.", file=sys.stderr)
        return 130
    except Exception as exc:
        print(f"Erro: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
