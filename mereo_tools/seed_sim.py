"""Copia amostra de dados do cliente (MEREO_*) para o simulador (MSSQL_*)."""

from __future__ import annotations

import argparse
import re
import sys
import time
import uuid

from mereo_tools import db
from mereo_tools.config import load_mereo_config, load_mssql_config
from mereo_tools.db import use_database

PILOT_DATABASES = ("MereoGR-Afya", "MereoGR-Staging", "MereoGR-Allos")
DEFAULT_TABLE = "dbo.COLABORADOR"


GUID_RE = re.compile(
    r"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
)


def _list_columns(conn, database: str, schema: str, table: str) -> list[str]:
    with use_database(conn, database):
        rows = db.fetchall(
            conn,
            """
            SELECT c.name
            FROM sys.tables t
            INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
            INNER JOIN sys.columns c ON t.object_id = c.object_id
            WHERE s.name = %s AND t.name = %s
            ORDER BY c.column_id
            """,
            (schema, table),
        )
    return [r["name"] for r in rows]


def _column_types(conn, database: str, schema: str, table: str) -> dict[str, str]:
    with use_database(conn, database):
        rows = db.fetchall(
            conn,
            """
            SELECT c.name, ty.name AS type_name
            FROM sys.tables t
            INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
            INNER JOIN sys.columns c ON t.object_id = c.object_id
            INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
            WHERE s.name = %s AND t.name = %s
            """,
            (schema, table),
        )
    return {r["name"]: r["type_name"] for r in rows}


def _coerce_value(value, type_name: str):
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
    return value


def _has_identity(conn, database: str, schema: str, table: str) -> bool:
    with use_database(conn, database):
        row = db.fetchone(
            conn,
            """
            SELECT 1 AS ok
            FROM sys.columns c
            INNER JOIN sys.tables t ON c.object_id = t.object_id
            INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
            WHERE s.name = %s AND t.name = %s AND c.is_identity = 1
            """,
            (schema, table),
        )
    return bool(row)


def _copy_table(
    src_conn,
    dst_conn,
    database: str,
    schema: str,
    table: str,
    *,
    limit: int,
    dry_run: bool,
) -> dict:
    src_cols = _list_columns(src_conn, database, schema, table)
    dst_cols = _list_columns(dst_conn, database, schema, table)
    dst_types = _column_types(dst_conn, database, schema, table)
    common = [c for c in src_cols if c in dst_cols]
    omitted = [c for c in src_cols if c not in dst_cols]

    if not common:
        raise ValueError(f"Nenhuma coluna em comum para {database}.{schema}.{table}")

    col_list = ", ".join(f"[{c}]" for c in common)
    select_sql = f"SELECT TOP ({limit}) {col_list} FROM [{schema}].[{table}] ORDER BY [ID]"

    with use_database(src_conn, database):
        rows = db.fetchall(src_conn, select_sql)

    if dry_run:
        return {
            "database": database,
            "table": f"{schema}.{table}",
            "rows": len(rows),
            "columns": len(common),
            "omitted": omitted,
            "dry_run": True,
        }

    with use_database(dst_conn, database):
        prev = dst_conn.autocommit_state
        dst_conn.autocommit(True)
        try:
            cur = dst_conn.cursor()
            cur.execute(f"DELETE FROM [{schema}].[{table}]")
            if not rows:
                return {
                    "database": database,
                    "table": f"{schema}.{table}",
                    "rows": 0,
                    "columns": len(common),
                    "omitted": omitted,
                    "dry_run": False,
                }

            identity_on = _has_identity(dst_conn, database, schema, table)
            if identity_on:
                cur.execute(f"SET IDENTITY_INSERT [{schema}].[{table}] ON")

            placeholders = ", ".join(["%s"] * len(common))
            insert_sql = f"INSERT INTO [{schema}].[{table}] ({col_list}) VALUES ({placeholders})"
            for row in rows:
                values = tuple(_coerce_value(row[c], dst_types.get(c, "")) for c in common)
                cur.execute(insert_sql, values)

            if identity_on:
                cur.execute(f"SET IDENTITY_INSERT [{schema}].[{table}] OFF")
        finally:
            dst_conn.autocommit(prev)

    return {
        "database": database,
        "table": f"{schema}.{table}",
        "rows": len(rows),
        "columns": len(common),
        "omitted": omitted,
        "dry_run": False,
    }


def run_seed_sim(
    *,
    databases: list[str],
    tables: list[str],
    limit: int,
    dry_run: bool,
    pause: float,
) -> int:
    print(f"Origem: MEREO_* (cliente)")
    print(f"Destino: MSSQL_* (simulador)")
    print(f"Bancos: {', '.join(databases)}")
    print(f"Tabelas: {', '.join(tables)}, limit={limit}, dry_run={dry_run}")
    print()

    src_conn = db.connect(config=load_mereo_config())
    dst_conn = db.connect(config=load_mssql_config())

    try:
        results = []
        for i, database in enumerate(databases):
            for table in tables:
                if "." in table:
                    schema, table_name = table.split(".", 1)
                else:
                    schema, table_name = "dbo", table
                label = f"{database} / {schema}.{table_name}"
                print(f"[{i + 1}/{len(databases)}] {label}...", end=" ", flush=True)
                try:
                    result = _copy_table(
                        src_conn,
                        dst_conn,
                        database,
                        schema,
                        table_name,
                        limit=limit,
                        dry_run=dry_run,
                    )
                    results.append(result)
                    suffix = " (dry-run)" if dry_run else ""
                    print(f"OK — {result['rows']} linhas{suffix}")
                    if result["omitted"]:
                        print(f"  colunas omitidas: {', '.join(result['omitted'])}")
                except Exception as exc:
                    print(f"ERRO: {exc}")
                    return 1
            if i < len(databases) - 1:
                time.sleep(pause)
    finally:
        src_conn.close()
        dst_conn.close()

    print("\nResumo:")
    for r in results:
        print(f"  {r['database']} {r['table']}: {r['rows']} linhas, {r['columns']} colunas")
    return 0


def _parse_tables(table: str | None, tables: list[str] | None) -> list[str]:
    if tables:
        return [t.strip() for t in tables if t.strip()]
    return [table or DEFAULT_TABLE]


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Copia dados do cliente para o simulador")
    parser.add_argument(
        "--databases",
        default=",".join(PILOT_DATABASES),
        help="Bancos separados por vírgula",
    )
    parser.add_argument("--table", default=DEFAULT_TABLE, help="Tabela (ex: dbo.COLABORADOR)")
    parser.add_argument(
        "--tables",
        action="append",
        dest="tables",
        metavar="TABLE",
        help="Tabela adicional (repita; sobrescreve --table se usado)",
    )
    parser.add_argument("--limit", type=int, default=1000, help="Máximo de linhas por banco")
    parser.add_argument("--dry-run", action="store_true", help="Só contar, não escrever")
    parser.add_argument("--pause", type=float, default=2.0, help="Pausa entre bancos (segundos)")
    args = parser.parse_args(argv)

    databases = [d.strip() for d in args.databases.split(",") if d.strip()]
    tables = _parse_tables(args.table, args.tables)
    try:
        return run_seed_sim(
            databases=databases,
            tables=tables,
            limit=args.limit,
            dry_run=args.dry_run,
            pause=args.pause,
        )
    except Exception as exc:
        print(f"Erro: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
