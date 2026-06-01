"""Extrai schema (colunas, tipos, PK) de todas as tabelas por banco."""

from __future__ import annotations

import json
import sys
from collections import defaultdict
from datetime import datetime, timezone
from typing import Any

from mereo_tools import db
from mereo_tools.config import SourceKind
from mereo_tools.db_list import load_database_list
from mereo_tools.groups import get_group

COLUMNS_SQL = """
SELECT
    s.name AS schema_name,
    t.name AS table_name,
    c.name AS column_name,
    ty.name AS type_name,
    c.max_length,
    c.precision,
    c.scale,
    c.is_nullable,
    c.column_id,
    CASE WHEN ic.object_id IS NOT NULL THEN 1 ELSE 0 END AS is_pk,
    ISNULL(ic.key_ordinal, 0) AS pk_ordinal
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
INNER JOIN sys.columns c ON t.object_id = c.object_id
INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
LEFT JOIN sys.indexes i ON t.object_id = i.object_id AND i.is_primary_key = 1
LEFT JOIN sys.index_columns ic
    ON i.object_id = ic.object_id AND i.index_id = ic.index_id AND c.column_id = ic.column_id
WHERE t.is_ms_shipped = 0
ORDER BY s.name, t.name, c.column_id
"""


def format_column_type(row: dict[str, Any]) -> str:
    name = row["type_name"]
    if name in ("varchar", "nvarchar", "char", "nchar", "varbinary", "binary"):
        length = row["max_length"]
        if length == -1:
            return f"{name}(max)"
        if name.startswith("n"):
            length = length // 2 if length > 0 else length
        return f"{name}({length})"
    if name in ("decimal", "numeric"):
        return f"{name}({row['precision']},{row['scale']})"
    return name


def extract_schema(conn, database: str) -> list[dict[str, Any]]:
    tables: dict[tuple[str, str], dict[str, Any]] = {}

    with db.use_database(conn, database):
        for row in db.fetchall(conn, COLUMNS_SQL):
            key = (row["schema_name"], row["table_name"])
            if key not in tables:
                tables[key] = {
                    "schema": row["schema_name"],
                    "table": row["table_name"],
                    "columns": [],
                }
            tables[key]["columns"].append(
                {
                    "name": row["column_name"],
                    "type": format_column_type(row),
                    "nullable": bool(row["is_nullable"]),
                    "is_pk": bool(row["is_pk"]),
                    "pk_ordinal": int(row["pk_ordinal"] or 0),
                }
            )

    result = sorted(tables.values(), key=lambda t: (t["schema"], t["table"]))
    for t in result:
        t["pk_columns"] = [c["name"] for c in sorted(
            [c for c in t["columns"] if c["is_pk"]],
            key=lambda c: c["pk_ordinal"],
        )]
    return result


def run_schema_extract(
    group_name: str,
    *,
    source: SourceKind = "mereo",
    databases: list[str] | None = None,
    use_sample: bool = False,
    limit: int | None = None,
    resume: bool = False,
    pause: float = 2.0,
) -> int:
    group = get_group(group_name)
    names = load_database_list(
        group,
        databases=databases,
        use_sample=use_sample,
        limit=limit,
    )
    schema_dir = group.output_dir / "schema" / "tables"
    schema_dir.mkdir(parents=True, exist_ok=True)
    log_path = group.output_dir / "run.log"

    conn = db.connect(source=source)
    print(f"Schema extract — {len(names)} banco(s), source={source}, pause={pause}s")

    try:
        for i, name in enumerate(names, 1):
            out_file = schema_dir / f"{name}.json"
            if resume and out_file.exists():
                print(f"[{i}/{len(names)}] {name} — pulado (resume)")
                continue

            print(f"[{i}/{len(names)}] {name}...", end=" ", flush=True)
            try:
                tables = extract_schema(conn, name)
                payload = {
                    "database": name,
                    "extracted_at": datetime.now(timezone.utc).isoformat(),
                    "table_count": len(tables),
                    "tables": tables,
                }
                out_file.write_text(json.dumps(payload, indent=2, default=str), encoding="utf-8")
                print(f"OK ({len(tables)} tabelas)")
            except Exception as exc:
                print("ERRO")
                with log_path.open("a", encoding="utf-8") as log:
                    log.write(f"{datetime.now(timezone.utc).isoformat()} schema {name}: {exc}\n")

            if i < len(names):
                db.pause_between_databases(pause)
    finally:
        conn.close()

    print(f"\nSchemas em: {schema_dir}")
    return 0


def main(argv: list[str] | None = None) -> int:
    from mereo_tools.cli import base_parser, resolve_source

    parser = base_parser("Extrai schema de todas as tabelas por banco")
    args = parser.parse_args(argv)
    try:
        return run_schema_extract(
            args.group,
            source=resolve_source(args),
            databases=args.databases,
            use_sample=args.sample,
            limit=args.limit,
            resume=args.resume,
            pause=max(args.pause, 2.0) if args.source == "mereo" else args.pause,
        )
    except Exception as exc:
        print(f"Erro: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
