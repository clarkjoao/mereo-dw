"""Descobre bancos de um grupo no SQL Server."""

from __future__ import annotations

import json
import sys
from typing import Any

from mereo_tools import db
from mereo_tools.config import SourceKind
from mereo_tools.groups import DatabaseGroup, get_group


def discover_databases(group: DatabaseGroup, *, source: SourceKind = "mereo") -> list[dict[str, Any]]:
    conn = db.connect(source=source)
    try:
        rows = db.fetchall(
            conn,
            """
            SELECT
                name,
                database_id,
                create_date,
                state_desc,
                recovery_model_desc,
                is_cdc_enabled
            FROM sys.databases
            WHERE name LIKE %s
            ORDER BY name
            """,
            (group.sql_like_pattern(),),
        )
    finally:
        conn.close()

    return [r for r in rows if group.matches(r["name"])]


def run_discover(group_name: str, *, source: SourceKind = "mereo") -> int:
    group = get_group(group_name)
    print(f"Grupo: {group.name} (pattern: {group.pattern}, source: {source})")

    rows = discover_databases(group, source=source)
    group.output_dir.mkdir(parents=True, exist_ok=True)
    group.databases_file.write_text(json.dumps(rows, indent=2, default=str), encoding="utf-8")

    print(f"OK — {len(rows)} bancos encontrados")
    print(f"Salvo em: {group.databases_file}")
    for row in rows[:10]:
        print(f"  - {row['name']} ({row['state_desc']})")
    if len(rows) > 10:
        print(f"  ... e mais {len(rows) - 10}")
    return 0


def main(argv: list[str] | None = None) -> int:
    from mereo_tools.cli import base_parser, resolve_source

    parser = base_parser("Lista bancos do grupo no SQL Server")
    args = parser.parse_args(argv)
    try:
        return run_discover(args.group, source=resolve_source(args))
    except Exception as exc:
        print(f"Erro: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
