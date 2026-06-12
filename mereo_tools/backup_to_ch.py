"""Carga bulk output/backups → ClickHouse raw.{schema}__{table} (modelagem dbt)."""

from __future__ import annotations

import argparse
import base64
import gzip
import json
import os
import re
import sys
from dataclasses import dataclass
from datetime import date, datetime
from decimal import Decimal
from pathlib import Path
from typing import Any, Iterator

PILOT_DATABASES = ("MereoGR-Afya", "MereoGR-Staging", "MereoGR-Allos")
DEFAULT_IN = Path("output/backups")
TENANT_SLUG: dict[str, str] = {
    "MereoGR-Afya": "afya",
    "MereoGR-Staging": "staging",
    "MereoGR-Allos": "allos",
}

CREATE_TABLE_RE = re.compile(
    r"CREATE TABLE \[([^\]]+)\]\.\[([^\]]+)\]\s*\((.*?)\);",
    re.DOTALL | re.IGNORECASE,
)
COL_LINE_RE = re.compile(
    r"^\s*\[([^\]]+)\]\s+(\w+(?:\([^)]*\))?(?:\s+\w+)*)",
    re.IGNORECASE | re.MULTILINE,
)
PK_RE = re.compile(
    r"CONSTRAINT\s+\[[^\]]+\]\s+PRIMARY KEY[^\(]*\(([^\)]+)\)",
    re.IGNORECASE,
)


@dataclass
class ColumnDef:
    name: str
    ch_type: str


@dataclass
class TableDef:
    schema: str
    name: str
    columns: list[ColumnDef]
    pk_columns: list[str]


@dataclass
class BackupToChOptions:
    databases: list[str]
    in_dir: Path
    batch_size: int
    resume: bool
    truncate: bool
    exclude_patterns: list[str]
    max_tables: int | None
    ch_host: str
    ch_port: int
    ch_user: str
    ch_password: str


def _deserialize_value(value: Any) -> Any:
    if isinstance(value, dict) and "__binary__" in value:
        raw = value["__binary__"]
        if isinstance(raw, bytes):
            return base64.b64encode(raw).decode("ascii")
        return raw
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


def _mssql_type_to_ch(mssql_type: str, *, nullable: bool) -> str:
    raw = mssql_type.strip().lower()
    base = raw.split()[0]
    null_wrap = lambda t: f"Nullable({t})" if nullable else t

    if base in ("int", "smallint", "tinyint", "bigint"):
        return null_wrap("Int64")
    if base == "bit":
        return null_wrap("UInt8")
    if base in ("float", "real"):
        return null_wrap("Float64")
    if base.startswith("decimal") or base.startswith("numeric"):
        return null_wrap("Float64")
    if base in ("money", "smallmoney"):
        return null_wrap("Float64")
    if base in ("datetime", "datetime2", "smalldatetime", "date", "datetimeoffset"):
        return null_wrap("DateTime64(3)")
    if base in ("uniqueidentifier",):
        return null_wrap("String")
    if base in ("varbinary", "binary", "image"):
        return null_wrap("String")
    if base in ("nvarchar", "varchar", "nchar", "char", "text", "ntext", "xml"):
        return null_wrap("String")
    return null_wrap("String")


def _parse_schema_sql(schema_path: Path) -> dict[tuple[str, str], TableDef]:
    content = schema_path.read_text(encoding="utf-8")
    tables: dict[tuple[str, str], TableDef] = {}
    for match in CREATE_TABLE_RE.finditer(content):
        schema, name, body = match.group(1), match.group(2), match.group(3)
        pk_cols: list[str] = []
        pk_match = PK_RE.search(body)
        if pk_match:
            pk_cols = [
                c.strip().strip("[]")
                for c in pk_match.group(1).split(",")
            ]
        columns: list[ColumnDef] = []
        for line in body.splitlines():
            line = line.strip().rstrip(",")
            if not line.startswith("["):
                continue
            m = COL_LINE_RE.match(line)
            if not m:
                continue
            col_name, type_rest = m.group(1), m.group(2)
            if col_name.upper() in ("CONSTRAINT",):
                continue
            nullable = "NOT NULL" not in line.upper()
            ch_type = _mssql_type_to_ch(type_rest, nullable=nullable)
            columns.append(ColumnDef(name=col_name, ch_type=ch_type))
        if columns:
            tables[(schema, name)] = TableDef(
                schema=schema, name=name, columns=columns, pk_columns=pk_cols
            )
    return tables


def _ch_table_name(schema: str, table: str) -> str:
    return f"{schema}__{table}".replace("/", "_").replace("\\", "_")


def _ch_table_id(schema: str, table: str) -> str:
    return f"raw.`{_ch_table_name(schema, table)}`"


def _data_path(out_db: Path, schema: str, table: str) -> Path:
    safe = f"{schema}__{table}".replace("/", "_")
    return out_db / "data" / f"{safe}.jsonl.gz"


def _has_rows(path: Path) -> bool:
    if not path.exists() or path.stat().st_size <= 22:
        return False
    with gzip.open(path, "rb") as gz:
        return bool(gz.read(64).strip())


def _iter_rows(path: Path) -> Iterator[dict[str, Any]]:
    with gzip.open(path, "rt", encoding="utf-8") as gz:
        for line in gz:
            line = line.strip()
            if line:
                yield _deserialize_row(json.loads(line))


def _progress_path(out_db: Path) -> Path:
    return out_db / "ch_load_progress.json"


def _load_progress(path: Path) -> set[str]:
    if not path.exists():
        return set()
    return set(json.loads(path.read_text()).get("completed_tables", []))


def _save_progress(path: Path, completed: set[str]) -> None:
    path.write_text(json.dumps({"completed_tables": sorted(completed)}, indent=2))


def _matches_exclude(schema: str, table: str, patterns: list[str]) -> bool:
    full = f"{schema}.{table}"
    for pat in patterns:
        if pat in full or pat in table or pat in schema:
            return True
    return False


def _coerce_for_ch(value: Any, ch_type: str) -> Any:
    if value is None:
        return None
    if isinstance(value, bytes):
        if "String" in ch_type:
            return base64.b64encode(value).decode("ascii")
        return base64.b64encode(value).decode("ascii")
    if "String" in ch_type:
        return str(value)
    if isinstance(value, bool) or ch_type.startswith("UInt8"):
        return 1 if value in (True, 1, "1", "true", "True") else 0
    if isinstance(value, Decimal):
        return float(value)
    if isinstance(value, (datetime, date)) or "DateTime" in ch_type:
        if isinstance(value, (datetime, date)):
            return value
        return str(value)
    if "Int" in ch_type or "Float" in ch_type:
        if isinstance(value, (int, float, Decimal)):
            return float(value) if "Float" in ch_type else int(value)
        try:
            return float(value) if "Float" in ch_type else int(value)
        except (TypeError, ValueError):
            return None
    return value


def _create_ch_table(client, table_def: TableDef) -> None:
    order_cols = table_def.pk_columns or [table_def.columns[0].name]
    order_expr = ", ".join(f"`{c}`" for c in ["tenant_slug", *order_cols])
    col_defs = ["`tenant_slug` String"]
    for c in table_def.columns:
        col_defs.append(f"`{c.name}` {c.ch_type}")
    col_defs.extend(["`_ts_ms` UInt64 DEFAULT 0", "`_deleted` UInt8 DEFAULT 0"])
    ddl = (
        f"CREATE TABLE IF NOT EXISTS {_ch_table_id(table_def.schema, table_def.name)} (\n"
        + ",\n".join(col_defs)
        + f"\n) ENGINE = MergeTree()\nORDER BY ({order_expr})\n"
        + "SETTINGS allow_nullable_key = 1"
    )
    client.command(ddl)


def _purge_tenant(client, ch_table: str, tenant_slug: str) -> None:
    """Remove linhas do tenant antes de recarga (multi-tenant na mesma tabela raw)."""
    client.command(
        f"ALTER TABLE raw.`{ch_table}` DELETE WHERE tenant_slug = '{tenant_slug}' "
        "SETTINGS mutations_sync = 1"
    )


def _load_table(
    client,
    *,
    tenant_slug: str,
    table_def: TableDef,
    data_path: Path,
    batch_size: int,
    drop_table: bool,
) -> int:
    ch_table = _ch_table_name(table_def.schema, table_def.name)
    if drop_table:
        client.command(f"DROP TABLE IF EXISTS raw.`{ch_table}`")
        _create_ch_table(client, table_def)
    else:
        _create_ch_table(client, table_def)
        _purge_tenant(client, ch_table, tenant_slug)

    col_names = ["tenant_slug"] + [c.name for c in table_def.columns]
    batch: list[list[Any]] = []
    total = 0

    for row in _iter_rows(data_path):
        values: list[Any] = [tenant_slug]
        for c in table_def.columns:
            values.append(_coerce_for_ch(row.get(c.name), c.ch_type))
        batch.append(values)
        if len(batch) >= batch_size:
            client.insert(
                ch_table, batch, column_names=col_names, database="raw"
            )
            total += len(batch)
            batch = []
    if batch:
        client.insert(ch_table, batch, column_names=col_names, database="raw")
        total += len(batch)
    return total


def load_database(
    client,
    database: str,
    *,
    options: BackupToChOptions,
    is_first_database: bool,
) -> dict[str, Any]:
    out_db = options.in_dir / database
    schema_sql = out_db / "schema" / "schema.sql"
    if not schema_sql.exists():
        raise FileNotFoundError(f"Schema não encontrado: {schema_sql}")

    tenant_slug = TENANT_SLUG.get(database, database.lower())
    ddl_map = _parse_schema_sql(schema_sql)
    progress = _progress_path(out_db)
    completed = _load_progress(progress) if options.resume else set()

    print(f"\n{'=' * 60}")
    print(f"Banco: {database} → tenant_slug={tenant_slug}")

    stats = {"database": database, "loaded": 0, "rows": 0, "skipped": 0}
    data_dir = out_db / "data"
    files = sorted(data_dir.glob("*.jsonl.gz"))
    loaded_count = 0

    for data_path in files:
        if options.max_tables is not None and stats["loaded"] >= options.max_tables:
            break
        stem = data_path.name.replace(".jsonl.gz", "")
        if "__" not in stem:
            continue
        schema, table = stem.split("__", 1)
        full = f"{schema}.{table}"
        if options.resume and full in completed:
            continue
        if _matches_exclude(schema, table, options.exclude_patterns):
            stats["skipped"] += 1
            completed.add(full)
            _save_progress(progress, completed)
            continue
        if not _has_rows(data_path):
            stats["skipped"] += 1
            completed.add(full)
            _save_progress(progress, completed)
            continue

        table_def = ddl_map.get((schema, table))
        if not table_def:
            print(f"  AVISO: DDL ausente para {full}, pulando")
            stats["skipped"] += 1
            continue

        print(f"  [{stats['loaded'] + 1}] {full}...", end=" ", flush=True)
        try:
            drop_table = options.truncate and is_first_database
            rows = _load_table(
                client,
                tenant_slug=tenant_slug,
                table_def=table_def,
                data_path=data_path,
                batch_size=options.batch_size,
                drop_table=drop_table,
            )
            print(f"{rows:,} linhas → {_ch_table_id(schema, table)}")
            stats["rows"] += rows
            stats["loaded"] += 1
            loaded_count += 1
        except Exception as exc:
            print(f"ERRO: {exc}")
            raise
        completed.add(full)
        _save_progress(progress, completed)

    if not options.resume:
        progress.unlink(missing_ok=True)

    print(f"  Concluído {database}: {stats['loaded']} tbl, {stats['rows']:,} linhas")
    return stats


def run_backup_to_ch(options: BackupToChOptions) -> int:
    try:
        import clickhouse_connect
    except ImportError as exc:
        print("Instale clickhouse-connect: uv add clickhouse-connect", file=sys.stderr)
        raise SystemExit(1) from exc

    print("Origem: backup local → ClickHouse raw.*")
    print(f"CH: {options.ch_host}:{options.ch_port} user={options.ch_user}")
    print(f"Bancos: {', '.join(options.databases)}")
    print(f"resume={options.resume} truncate={options.truncate}")
    print()

    client = clickhouse_connect.get_client(
        host=options.ch_host,
        port=options.ch_port,
        username=options.ch_user,
        password=options.ch_password,
        secure=False,
    )
    client.command("CREATE DATABASE IF NOT EXISTS raw")

    manifests: list[dict[str, Any]] = []
    for idx, database in enumerate(options.databases):
        manifests.append(
            load_database(
                client,
                database,
                options=options,
                is_first_database=idx == 0,
            )
        )

    summary_path = options.in_dir / "ch_load_summary.json"
    summary_path.write_text(json.dumps(manifests, indent=2), encoding="utf-8")
    print(f"\nResumo: {summary_path}")
    for m in manifests:
        print(f"  {m['database']}: {m['loaded']} tbl, {m['rows']:,} linhas")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Carga bulk de output/backups/ para ClickHouse raw (ERP modelagem)"
    )
    parser.add_argument(
        "--databases",
        default=",".join(PILOT_DATABASES),
        help="Bancos separados por vírgula",
    )
    parser.add_argument("--in-dir", default=str(DEFAULT_IN), help="Base do backup")
    parser.add_argument("--batch-size", type=int, default=5000, help="Linhas por insert")
    parser.add_argument("--resume", action="store_true", help="Retomar tabelas concluídas")
    parser.add_argument(
        "--no-truncate",
        action="store_false",
        dest="truncate",
        help="Não truncar antes de inserir",
    )
    parser.set_defaults(truncate=True)
    parser.add_argument(
        "--exclude",
        default="",
        help="Substrings para pular (ex: HangFire,AbpEntity)",
    )
    parser.add_argument("--max-tables", type=int, default=None, help="Limite (teste)")
    parser.add_argument("--ch-host", default=os.environ.get("CH_HOST", "127.0.0.1"))
    parser.add_argument("--ch-port", type=int, default=int(os.environ.get("CH_PORT", "18123")))
    parser.add_argument("--ch-user", default=os.environ.get("CH_USER", "dbt"))
    parser.add_argument(
        "--ch-password",
        default=os.environ.get("CH_DBT_PASSWORD") or os.environ.get("CH_PASSWORD", ""),
    )
    args = parser.parse_args(argv)

    options = BackupToChOptions(
        databases=[d.strip() for d in args.databases.split(",") if d.strip()],
        in_dir=Path(args.in_dir),
        batch_size=args.batch_size,
        resume=args.resume,
        truncate=args.truncate,
        exclude_patterns=[p.strip() for p in args.exclude.split(",") if p.strip()],
        max_tables=args.max_tables,
        ch_host=args.ch_host,
        ch_port=args.ch_port,
        ch_user=args.ch_user,
        ch_password=args.ch_password,
    )
    if not options.ch_password:
        pw_path = Path("analytics/.ch-dbt-password")
        if pw_path.exists():
            options.ch_password = pw_path.read_text().strip()

    try:
        return run_backup_to_ch(options)
    except KeyboardInterrupt:
        print("\nInterrompido — use --resume", file=sys.stderr)
        return 130
    except Exception as exc:
        print(f"Erro: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
