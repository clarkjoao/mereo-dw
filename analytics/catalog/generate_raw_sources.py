#!/usr/bin/env python3
"""Gera analytics/dbt/models/staging/_raw__sources.yml a partir das tabelas em CH raw."""

from __future__ import annotations

import argparse
from pathlib import Path

import clickhouse_connect

REPO_ROOT = Path(__file__).resolve().parents[2]
OUT_PATH = REPO_ROOT / "analytics" / "dbt" / "models" / "bronze" / "_bronze__sources.yml"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Gera dbt sources para database raw")
    parser.add_argument("--ch-host", default="127.0.0.1")
    parser.add_argument("--ch-port", type=int, default=18123)
    parser.add_argument("--ch-user", default="dbt")
    parser.add_argument("--ch-password", default="")
    args = parser.parse_args(argv)

    password = args.ch_password
    if not password:
        pw = REPO_ROOT / "analytics" / ".ch-dbt-password"
        if pw.exists():
            password = pw.read_text().strip()

    client = clickhouse_connect.get_client(
        host=args.ch_host,
        port=args.ch_port,
        username=args.ch_user,
        password=password,
        secure=False,
    )
    rows = client.query(
        """
        SELECT name, total_rows
        FROM system.tables
        WHERE database = 'raw'
          AND engine IN ('MergeTree', 'ReplacingMergeTree')
          AND total_rows > 0
          AND name NOT LIKE '%_kafka'
          AND name NOT LIKE '%_mv'
        ORDER BY name
        """
    ).result_rows

    lines = [
        "version: 2",
        "",
        "sources:",
        "  - name: bronze",
        "    description: Camada bronze (landing CH raw) — bulk ERP + CDC",
        "    database: raw",
        "    schema: raw",
        "    meta:",
        "      layer: bronze",
        "    tables:",
    ]
    for name, row_count in rows:
        lines.append(f"      - name: {name}")
        lines.append(f"        description: \"~{row_count:,} rows (bulk)\"")
    lines.append("")

    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUT_PATH.write_text("\n".join(lines), encoding="utf-8")
    print(f"Escrito {len(rows)} tabelas em {OUT_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
