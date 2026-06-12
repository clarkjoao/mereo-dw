"""Clona banco(s) piloto do cliente (MEREO_*) para o simulador (MSSQL_*) — schema + dados."""

from __future__ import annotations

import argparse
import json
import re
import sys
import time
import uuid
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from mereo_tools import db
from mereo_tools.config import load_mereo_config, load_mssql_config
from mereo_tools.db import use_database
from mereo_tools.ddl_extract import (
    DatabaseDdl,
    TableDef,
    extract_database_ddl,
    render_add_foreign_key,
    render_create_schema,
    render_create_table,
)

PILOT_DATABASES = ("MereoGR-Afya", "MereoGR-Staging", "MereoGR-Allos")
CDC_TABLE = ("dbo", "COLABORADOR")

GUID_RE = re.compile(
    r"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
)
_STRING_TYPES = frozenset(
    {"char", "nchar", "varchar", "nvarchar", "text", "ntext", "sysname"}
)
_MSSQL_MAX_PARAMS = 2100
# pymssql desalinha parâmetros em INSERT multi-row acima disso (~155 linhas × 12 cols).
_PYMSSQL_MULTIROW_MAX_PARAMS = 1860


@dataclass
class CloneOptions:
    databases: list[str]
    batch_size: int
    pause_batch: float
    pause_table: float
    pause_db: float
    dry_run: bool
    schema_only: bool
    skip_drop: bool
    enable_cdc: bool
    resume: bool
    state_dir: Path


def _coerce_value(value: Any, type_name: str) -> Any:
    if value is None:
        return None
    if type_name == "uniqueidentifier":
        text = str(value).strip()
        if not text or not GUID_RE.match(text):
            try:
                uuid.UUID(text)
            except ValueError:
                return None
        return text
    if type_name == "bit":
        return 1 if value in (True, 1, "1", "true", "True") else 0
    if type_name in _STRING_TYPES:
        return str(value)
    return value


def _execute(conn, sql: str, *, autocommit: bool = False) -> None:
    prev = conn.autocommit_state
    if autocommit:
        conn.autocommit(True)
    try:
        cur = conn.cursor()
        cur.execute(sql)
        if not autocommit and not conn.autocommit_state:
            conn.commit()
    finally:
        if autocommit:
            conn.autocommit(prev)


def _drop_database(conn, database: str) -> None:
    safe = database.replace("]", "]]")
    _execute(
        conn,
        f"""
        IF DB_ID(N'{safe}') IS NOT NULL
        BEGIN
            ALTER DATABASE [{safe}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
            DROP DATABASE [{safe}];
        END
        """,
        autocommit=True,
    )


def _create_database(conn, database: str) -> None:
    safe = database.replace("]", "]]")
    _execute(
        conn,
        f"IF DB_ID(N'{safe}') IS NULL CREATE DATABASE [{safe}];",
        autocommit=True,
    )


def _apply_schema(dst_conn, ddl: DatabaseDdl) -> None:
    with use_database(dst_conn, ddl.database):
        for schema in ddl.schemas:
            _execute(dst_conn, render_create_schema(schema))
        for table in ddl.tables:
            _execute(dst_conn, render_create_table(table))
        for fk in ddl.foreign_keys:
            _execute(dst_conn, render_add_foreign_key(fk))
        for fk in ddl.foreign_keys:
            fk_name = fk.name.replace("]", "]]")
            ps = fk.parent_schema.replace("]", "]]")
            pt = fk.parent_table.replace("]", "]]")
            _execute(
                dst_conn,
                f"ALTER TABLE [{ps}].[{pt}] CHECK CONSTRAINT [{fk_name}];",
            )


def _row_count_hint(database: str, schema: str, table: str, *, state_dir: Path) -> int | None:
    """Usa inventário local se existir — evita COUNT(*) em prod no dry-run."""
    tables_file = state_dir.parent / "databases" / database / "tables.jsonl"
    if not tables_file.exists():
        return None
    for line in tables_file.open(encoding="utf-8"):
        row = json.loads(line)
        if row.get("schema") == schema and row.get("table") == table:
            return int(row.get("row_count") or 0)
    return 0


def _count_rows_live(src_conn, database: str, schema: str, table: str) -> int:
    with use_database(src_conn, database):
        row = db.fetchone(
            src_conn,
            f"SELECT COUNT_BIG(*) AS n FROM [{schema}].[{table}] WITH (NOLOCK)",
        )
    return int(row["n"]) if row else 0


def _estimate_or_count(
    src_conn,
    database: str,
    schema: str,
    table: str,
    *,
    state_dir: Path,
    use_live_count: bool,
) -> int:
    hint = _row_count_hint(database, schema, table, state_dir=state_dir)
    if hint is not None and not use_live_count:
        return hint
    return _count_rows_live(src_conn, database, schema, table)


def _fetch_batch(
    src_conn,
    database: str,
    table: TableDef,
    *,
    batch_size: int,
    offset: int,
    retries: int = 3,
    reconnect_src=None,
) -> list[dict[str, Any]]:
    insert_cols = table.select_columns
    col_list = ", ".join(f"[{c.name}]" for c in insert_cols)
    schema = table.schema.replace("]", "]]")
    name = table.name.replace("]", "]]")

    if table.pk_columns:
        order = ", ".join(f"[{c}]" for c in table.pk_columns)
        sql = (
            f"SELECT {col_list} FROM [{schema}].[{name}] WITH (NOLOCK) "
            f"ORDER BY {order} OFFSET {offset} ROWS FETCH NEXT {batch_size} ROWS ONLY"
        )
    else:
        sql = (
            f"SELECT {col_list} FROM [{schema}].[{name}] WITH (NOLOCK) "
            f"ORDER BY (SELECT NULL) OFFSET {offset} ROWS FETCH NEXT {batch_size} ROWS ONLY"
        )

    last_exc: Exception | None = None
    conn = src_conn
    for attempt in range(1, retries + 1):
        try:
            with use_database(conn, database):
                return db.fetchall(conn, sql)
        except Exception as exc:
            last_exc = exc
            msg = str(exc).lower()
            if reconnect_src and ("not connected" in msg or "20004" in msg or "timed out" in msg):
                print(f"\n    reconectando MEREO_* (tentativa {attempt})...", flush=True)
                conn = reconnect_src()
            if attempt < retries:
                wait = 5 * attempt
                print(f"    retry {attempt}/{retries} ({wait}s)...", flush=True)
                time.sleep(wait)
            else:
                raise last_exc
    raise last_exc  # type: ignore[misc]


def _insert_batch(
    dst_conn,
    database: str,
    table: TableDef,
    rows: list[dict[str, Any]],
    *,
    identity_on: bool,
) -> None:
    if not rows:
        return
    insert_cols = table.select_columns
    if not insert_cols:
        return
    ncols = len(insert_cols)
    col_list = ", ".join(f"[{c.name}]" for c in insert_cols)
    schema = table.schema.replace("]", "]]")
    name = table.name.replace("]", "]]")
    row_placeholder = "(" + ", ".join(["%s"] * ncols) + ")"
    chunk_size = max(
        1,
        min(_MSSQL_MAX_PARAMS // ncols, _PYMSSQL_MULTIROW_MAX_PARAMS // ncols),
    )

    with use_database(dst_conn, database):
        prev = dst_conn.autocommit_state
        dst_conn.autocommit(True)
        try:
            cur = dst_conn.cursor()
            if identity_on:
                cur.execute(f"SET IDENTITY_INSERT [{schema}].[{name}] ON")
            for start in range(0, len(rows), chunk_size):
                chunk = rows[start : start + chunk_size]
                placeholders = ", ".join([row_placeholder] * len(chunk))
                insert_sql = (
                    f"INSERT INTO [{schema}].[{name}] ({col_list}) VALUES {placeholders}"
                )
                values: list[Any] = []
                for row in chunk:
                    values.extend(
                        _coerce_value(row[c.name], c.type_name) for c in insert_cols
                    )
                cur.execute(insert_sql, tuple(values))
            if identity_on:
                cur.execute(f"SET IDENTITY_INSERT [{schema}].[{name}] OFF")
        finally:
            dst_conn.autocommit(prev)


def _set_foreign_keys_enabled(dst_conn, database: str, *, enabled: bool) -> None:
    with use_database(dst_conn, database):
        rows = db.fetchall(
            dst_conn,
            """
            SELECT s.name AS schema_name, t.name AS table_name, fk.name AS fk_name
            FROM sys.foreign_keys fk
            INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id
            INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
            """,
        )
    failed = 0
    for row in rows:
        schema = row["schema_name"].replace("]", "]]")
        table = row["table_name"].replace("]", "]]")
        fk_name = row["fk_name"].replace("]", "]]")
        if enabled:
            sql = f"ALTER TABLE [{schema}].[{table}] WITH NOCHECK CHECK CONSTRAINT [{fk_name}]"
        else:
            sql = f"ALTER TABLE [{schema}].[{table}] NOCHECK CONSTRAINT [{fk_name}]"
        try:
            _execute(dst_conn, sql, autocommit=True)
        except Exception:
            failed += 1
    if enabled and failed:
        print(f"  AVISO: {failed} FK(s) com dados órfãos — permanecem NOCHECK (igual tolerância prod)")


def _truncate_table(dst_conn, database: str, schema: str, table: str) -> None:
    schema_safe = schema.replace("]", "]]")
    table_safe = table.replace("]", "]]")
    with use_database(dst_conn, database):
        prev = dst_conn.autocommit_state
        dst_conn.autocommit(True)
        try:
            cur = dst_conn.cursor()
            try:
                cur.execute(f"TRUNCATE TABLE [{schema_safe}].[{table_safe}]")
            except Exception:
                cur.execute(f"DELETE FROM [{schema_safe}].[{table_safe}]")
        finally:
            dst_conn.autocommit(prev)


def _copy_table_data(
    src_conn,
    dst_conn,
    database: str,
    table: TableDef,
    *,
    options: CloneOptions,
    reconnect_src=None,
) -> dict[str, Any]:
    schema = table.schema
    name = table.name
    full_name = f"{schema}.{name}"

    if options.dry_run:
        row_count = _count_rows(src_conn, database, schema, name)
        return {"table": full_name, "rows": row_count, "dry_run": True}

    _truncate_table(dst_conn, database, schema, name)

    copied = 0
    offset = 0
    identity_on = table.has_identity
    while True:
        rows = _fetch_batch(
            src_conn,
            database,
            table,
            batch_size=options.batch_size,
            offset=offset,
            reconnect_src=reconnect_src,
        )
        if not rows:
            break
        _insert_batch(dst_conn, database, table, rows, identity_on=identity_on)
        copied += len(rows)
        offset += len(rows)
        if options.pause_batch > 0:
            time.sleep(options.pause_batch)

    return {"table": full_name, "rows": copied, "skipped": copied == 0}


def _enable_cdc(dst_conn, database: str) -> None:
    schema, table = CDC_TABLE
    with use_database(dst_conn, database):
        db_info = db.fetchone(
            dst_conn,
            "SELECT is_cdc_enabled FROM sys.databases WHERE name = DB_NAME()",
        )
        if not db_info or not db_info.get("is_cdc_enabled"):
            _execute(dst_conn, "EXEC sys.sp_cdc_enable_db")
        exists = db.fetchone(
            dst_conn,
            f"""
            SELECT 1 AS ok FROM cdc.change_tables
            WHERE source_object_id = OBJECT_ID(N'[{schema}].[{table}]')
            """,
        )
        if not exists:
            _execute(
                dst_conn,
                f"""
                EXEC sys.sp_cdc_enable_table
                    @source_schema = N'{schema}',
                    @source_name   = N'{table}',
                    @role_name     = NULL,
                    @supports_net_changes = 1
                """,
            )


def _state_path(options: CloneOptions, database: str) -> Path:
    return options.state_dir / f"{database}.json"


def _load_state(path: Path) -> dict[str, Any]:
    if path.exists():
        return json.loads(path.read_text())
    return {"completed_tables": []}


def _save_state(path: Path, state: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(state, indent=2))


def clone_database(
    src_conn,
    dst_conn,
    ddl: DatabaseDdl,
    *,
    options: CloneOptions,
    reconnect_src=None,
) -> dict[str, Any]:
    database = ddl.database
    state_path = _state_path(options, database)
    state = _load_state(state_path) if options.resume else {"completed_tables": []}
    completed = set(state.get("completed_tables", []))

    print(f"\n{'=' * 60}")
    print(f"Banco: {database}")
    print(f"  schemas={len(ddl.schemas)} tables={len(ddl.tables)} fks={len(ddl.foreign_keys)}")

    if options.dry_run:
        nonempty = 0
        total_rows = 0
        for table in ddl.tables:
            n = _estimate_or_count(
                src_conn,
                database,
                table.schema,
                table.name,
                state_dir=options.state_dir,
                use_live_count=False,
            )
            if n > 0:
                nonempty += 1
                total_rows += n
        print(f"  [dry-run] tabelas com dados: {nonempty}, linhas totais (inventário): {total_rows:,}")
        return {"database": database, "dry_run": True, "nonempty_tables": nonempty, "total_rows": total_rows}

    if options.resume and not options.skip_drop:
        print("  --resume: mantendo banco existente (sem DROP)")
        options.skip_drop = True

    if not options.skip_drop:
        print("  Drop + create database no sim...")
        _drop_database(dst_conn, database)
        _create_database(dst_conn, database)
        print("  Aplicando schema (DDL + FKs)...")
        _apply_schema(dst_conn, ddl)
    elif options.schema_only:
        print("  Aplicando schema (DDL + FKs)...")
        _apply_schema(dst_conn, ddl)

    if options.schema_only:
        print("  --schema-only: pulando dados")
    else:
        print("  Desabilitando FKs para carga de dados...")
        _set_foreign_keys_enabled(dst_conn, database, enabled=False)
        tables_with_data = []
        try:
            for i, table in enumerate(ddl.tables, 1):
                full_name = f"{table.schema}.{table.name}"
                if options.resume and full_name in completed:
                    continue
                print(f"  [{i}/{len(ddl.tables)}] {full_name}...", end=" ", flush=True)
                try:
                    result = _copy_table_data(
                        src_conn, dst_conn, database, table, options=options, reconnect_src=reconnect_src
                    )
                    rows = result.get("rows", 0)
                    if result.get("skipped"):
                        print("vazia")
                    else:
                        print(f"{rows:,} linhas")
                    completed.add(full_name)
                    state["completed_tables"] = sorted(completed)
                    _save_state(state_path, state)
                    if rows > 0:
                        tables_with_data.append(full_name)
                except Exception as exc:
                    print(f"ERRO: {exc}")
                    raise
                if options.pause_table > 0:
                    time.sleep(options.pause_table)
        finally:
            print("  Reabilitando FKs...", flush=True)
            try:
                _set_foreign_keys_enabled(dst_conn, database, enabled=True)
            except Exception as exc:
                print(f"  AVISO: reabilitar FKs ignorado ({exc})", flush=True)

    if options.enable_cdc:
        print("  Habilitando CDC em dbo.COLABORADOR...")
        _enable_cdc(dst_conn, database)

    if state_path.exists() and not options.resume:
        state_path.unlink(missing_ok=True)

    return {"database": database, "tables": len(ddl.tables), "ok": True}


def run_clone_sim(options: CloneOptions) -> int:
    print("Origem:  MEREO_* (cliente — somente leitura)")
    print("Destino: MSSQL_* (simulador)")
    print(f"Bancos:  {', '.join(options.databases)}")
    print(
        f"batch={options.batch_size} pause_batch={options.pause_batch}s "
        f"pause_table={options.pause_table}s pause_db={options.pause_db}s"
    )
    print(f"dry_run={options.dry_run} schema_only={options.schema_only} enable_cdc={options.enable_cdc}")
    print()

    src_conn = db.connect(config=load_mereo_config(), timeout=600, login_timeout=30)
    dst_conn = None if options.dry_run else db.connect(config=load_mssql_config(), timeout=600, login_timeout=30)

    def reconnect_src():
        nonlocal src_conn
        try:
            src_conn.close()
        except Exception:
            pass
        src_conn = db.connect(config=load_mereo_config(), timeout=600, login_timeout=30)
        return src_conn

    try:
        for i, database in enumerate(options.databases):
            print(f"Extraindo DDL de prod: {database}...")
            ddl = extract_database_ddl(src_conn, database)
            clone_database(src_conn, dst_conn, ddl, options=options, reconnect_src=reconnect_src)
            if i < len(options.databases) - 1 and options.pause_db > 0:
                print(f"Pausa {options.pause_db}s antes do próximo banco...")
                time.sleep(options.pause_db)
    finally:
        src_conn.close()
        if dst_conn is not None:
            dst_conn.close()

    print("\nClone concluído.")
    return 0


def main(argv: list[str] | None = None) -> int:
    # Log em tempo real quando redirecionado para arquivo
    if hasattr(sys.stdout, "reconfigure"):
        try:
            sys.stdout.reconfigure(line_buffering=True)
        except Exception:
            pass
    parser = argparse.ArgumentParser(
        description="Clona schema+dados do cliente para o simulador (cuidadoso com prod)"
    )
    parser.add_argument(
        "--databases",
        default=",".join(PILOT_DATABASES),
        help="Bancos separados por vírgula",
    )
    parser.add_argument("--batch-size", type=int, default=500, help="Linhas por lote (SELECT/INSERT)")
    parser.add_argument("--pause-batch", type=float, default=0.25, help="Pausa entre lotes (s)")
    parser.add_argument("--pause-table", type=float, default=0.4, help="Pausa entre tabelas (s)")
    parser.add_argument("--pause-db", type=float, default=15.0, help="Pausa entre bancos (s)")
    parser.add_argument("--dry-run", action="store_true", help="Só contar linhas em prod, não escrever")
    parser.add_argument("--schema-only", action="store_true", help="Só DDL, sem copiar dados")
    parser.add_argument("--skip-drop", action="store_true", help="Não dropar banco (só schema/dados)")
    parser.add_argument("--enable-cdc", action="store_true", help="Habilitar CDC em dbo.COLABORADOR no sim")
    parser.add_argument("--resume", action="store_true", help="Retomar cópia de dados por tabela")
    parser.add_argument(
        "--state-dir",
        default="output/groups/mereogr/clone_sim",
        help="Diretório de checkpoint (--resume)",
    )
    args = parser.parse_args(argv)

    databases = [d.strip() for d in args.databases.split(",") if d.strip()]
    options = CloneOptions(
        databases=databases,
        batch_size=args.batch_size,
        pause_batch=args.pause_batch,
        pause_table=args.pause_table,
        pause_db=args.pause_db,
        dry_run=args.dry_run,
        schema_only=args.schema_only,
        skip_drop=args.skip_drop,
        enable_cdc=args.enable_cdc,
        resume=args.resume,
        state_dir=Path(args.state_dir),
    )
    try:
        return run_clone_sim(options)
    except KeyboardInterrupt:
        print("\nInterrompido — use --resume para continuar.", file=sys.stderr)
        return 130
    except Exception as exc:
        print(f"Erro: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
