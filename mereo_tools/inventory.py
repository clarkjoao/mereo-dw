"""Inventário por banco: tabelas, tamanho, CDC, PKs."""

from __future__ import annotations

import csv
import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from mereo_tools import db
from mereo_tools.groups import DatabaseGroup, get_group

TABLES_SQL = """
SELECT
    s.name AS schema_name,
    t.name AS table_name,
    ISNULL(SUM(CASE WHEN p.index_id IN (0, 1) THEN p.rows ELSE 0 END), 0) AS row_count,
    CAST(ISNULL(SUM(a.total_pages), 0) * 8.0 / 1024 / 1024 AS DECIMAL(18, 2)) AS size_mb,
    t.is_tracked_by_cdc,
    CASE WHEN pk.object_id IS NOT NULL THEN 1 ELSE 0 END AS has_pk
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
LEFT JOIN sys.indexes i ON t.object_id = i.object_id AND i.index_id IN (0, 1)
LEFT JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
LEFT JOIN sys.allocation_units a ON p.partition_id = a.container_id
LEFT JOIN (
    SELECT DISTINCT object_id FROM sys.indexes WHERE is_primary_key = 1
) pk ON t.object_id = pk.object_id
WHERE t.is_ms_shipped = 0
GROUP BY s.name, t.name, t.is_tracked_by_cdc, pk.object_id
ORDER BY s.name, t.name
"""

PK_SQL = """
SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
    OBJECT_NAME(i.object_id) AS table_name,
    STRING_AGG(c.name, ',') WITHIN GROUP (ORDER BY ic.key_ordinal) AS pk_columns
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.is_primary_key = 1
GROUP BY i.object_id
"""

CDC_SQL = """
SELECT
    OBJECT_SCHEMA_NAME(source_object_id) AS schema_name,
    OBJECT_NAME(source_object_id) AS table_name,
    capture_instance
FROM cdc.change_tables
"""

DB_SIZE_SQL = """
SELECT
    CAST(SUM(CAST(size AS bigint)) * 8.0 / 1024 / 1024 AS DECIMAL(18, 2)) AS file_size_mb,
    CAST(SUM(CAST(FILEPROPERTY(name, 'SpaceUsed') AS bigint)) * 8.0 / 1024 / 1024 AS DECIMAL(18, 2)) AS space_used_mb
FROM sys.database_files
"""


def load_database_list(group: DatabaseGroup, db_filter: str | None, limit: int | None) -> list[str]:
    if group.databases_file.exists():
        rows = json.loads(group.databases_file.read_text(encoding="utf-8"))
        names = [r["name"] for r in rows if r.get("state_desc") == "ONLINE"]
    else:
        from mereo_tools.discover import discover_databases

        rows = discover_databases(group)
        names = [r["name"] for r in rows if r.get("state_desc") == "ONLINE"]

    if db_filter:
        names = [n for n in names if n == db_filter]
    if limit:
        names = names[:limit]
    return names


def inventory_database(conn, database: str) -> tuple[dict[str, Any], list[dict[str, Any]], str | None]:
    error: str | None = None
    meta: dict[str, Any] = {"database": database, "scanned_at": datetime.now(timezone.utc).isoformat()}
    tables: list[dict[str, Any]] = []

    try:
        with db.use_database(conn, database):
            db_info = db.fetchone(
                conn,
                "SELECT is_cdc_enabled FROM sys.databases WHERE name = DB_NAME()",
            )
            meta["cdc_enabled"] = bool(db_info and db_info.get("is_cdc_enabled"))

            size_row = db.fetchone(conn, DB_SIZE_SQL)
            meta["file_size_mb"] = float(size_row["file_size_mb"]) if size_row and size_row.get("file_size_mb") else 0.0
            meta["space_used_mb"] = float(size_row["space_used_mb"]) if size_row and size_row.get("space_used_mb") else 0.0
            meta["total_size_mb"] = meta["space_used_mb"]  # alias legado

            table_rows = db.fetchall(conn, TABLES_SQL)
            pk_map: dict[tuple[str, str], str] = {}
            for row in db.fetchall(conn, PK_SQL):
                pk_map[(row["schema_name"], row["table_name"])] = row["pk_columns"]

            cdc_map: dict[tuple[str, str], str] = {}
            if meta["cdc_enabled"]:
                try:
                    for row in db.fetchall(conn, CDC_SQL):
                        cdc_map[(row["schema_name"], row["table_name"])] = row["capture_instance"]
                except Exception:
                    pass

            for row in table_rows:
                key = (row["schema_name"], row["table_name"])
                tables.append(
                    {
                        "database": database,
                        "schema": row["schema_name"],
                        "table": row["table_name"],
                        "row_count": int(row["row_count"] or 0),
                        "size_mb": float(row["size_mb"] or 0),
                        "has_pk": bool(row["has_pk"]),
                        "pk_columns": pk_map.get(key, ""),
                        "is_tracked_by_cdc": bool(row["is_tracked_by_cdc"]),
                        "capture_instance": cdc_map.get(key, ""),
                    }
                )

            meta["table_count"] = len(tables)
            meta["cdc_table_count"] = sum(1 for t in tables if t["is_tracked_by_cdc"])

    except Exception as exc:
        error = str(exc)
        meta["table_count"] = 0
        meta["cdc_table_count"] = 0
        meta["total_size_mb"] = 0.0
        meta["cdc_enabled"] = False

    return meta, tables, error


def run_inventory(
    group_name: str,
    *,
    db_filter: str | None = None,
    limit: int | None = None,
    resume: bool = False,
) -> int:
    group = get_group(group_name)
    names = load_database_list(group, db_filter, limit)
    if not names:
        print("Nenhum banco para processar.", file=sys.stderr)
        return 1

    inv_dir = group.output_dir / "inventory"
    db_dir = group.output_dir / "databases"
    inv_dir.mkdir(parents=True, exist_ok=True)
    db_dir.mkdir(parents=True, exist_ok=True)
    log_path = group.output_dir / "run.log"

    summary_rows: list[dict[str, Any]] = []
    conn = db.connect()

    print(f"Inventário — {len(names)} banco(s)")

    try:
        for i, name in enumerate(names, 1):
            db_path = db_dir / name
            meta_file = db_path / "meta.json"
            tables_file = db_path / "tables.jsonl"

            if resume and meta_file.exists() and tables_file.exists():
                meta = json.loads(meta_file.read_text(encoding="utf-8"))
                summary_rows.append(
                    {
                        "database": name,
                        "state": "ONLINE",
                        "table_count": meta.get("table_count", 0),
                        "space_used_mb": meta.get("space_used_mb", 0),
                        "file_size_mb": meta.get("file_size_mb", 0),
                        "total_size_mb": meta.get("total_size_mb", 0),
                        "cdc_enabled": meta.get("cdc_enabled", False),
                        "cdc_table_count": meta.get("cdc_table_count", 0),
                        "errors": "",
                    }
                )
                print(f"[{i}/{len(names)}] {name} — pulado (resume)")
                continue

            print(f"[{i}/{len(names)}] {name}...", end=" ", flush=True)
            meta, tables, error = inventory_database(conn, name)

            db_path.mkdir(parents=True, exist_ok=True)
            meta_file.write_text(json.dumps(meta, indent=2, default=str), encoding="utf-8")
            with tables_file.open("w", encoding="utf-8") as f:
                for t in tables:
                    f.write(json.dumps(t, default=str) + "\n")

            summary_rows.append(
                {
                    "database": name,
                    "state": "ONLINE",
                    "table_count": meta["table_count"],
                    "space_used_mb": meta["space_used_mb"],
                    "file_size_mb": meta["file_size_mb"],
                    "total_size_mb": meta["total_size_mb"],
                    "cdc_enabled": meta["cdc_enabled"],
                    "cdc_table_count": meta["cdc_table_count"],
                    "errors": error or "",
                }
            )

            status = "ERRO" if error else "OK"
            print(f"{status} ({meta['table_count']} tabelas, {meta['total_size_mb']} MB)")
            if error:
                with log_path.open("a", encoding="utf-8") as log:
                    log.write(f"{datetime.now(timezone.utc).isoformat()} inventory {name}: {error}\n")

    finally:
        conn.close()

    csv_path = inv_dir / "summary.csv"
    fields = [
        "database",
        "state",
        "table_count",
        "space_used_mb",
        "file_size_mb",
        "total_size_mb",
        "cdc_enabled",
        "cdc_table_count",
        "errors",
    ]
    with csv_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(summary_rows)

    (inv_dir / "summary.json").write_text(json.dumps(summary_rows, indent=2, default=str), encoding="utf-8")
    print(f"\nResumo: {csv_path}")
    return 0


def main(argv: list[str] | None = None) -> int:
    from mereo_tools.cli import base_parser

    parser = base_parser("Inventário de tabelas, tamanho e CDC por banco")
    args = parser.parse_args(argv)
    try:
        return run_inventory(
            args.group,
            db_filter=args.db,
            limit=args.limit,
            resume=args.resume,
        )
    except Exception as exc:
        print(f"Erro: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
