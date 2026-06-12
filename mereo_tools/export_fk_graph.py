"""Exporta grafo de FKs para output/groups/<grupo>/schema/foreign_keys.json."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

from mereo_tools.config import load_mereo_config
from mereo_tools import db
from mereo_tools.ddl_extract import ForeignKeyDef, extract_database_ddl
from mereo_tools.groups import get_group

PILOT_DATABASES = ("MereoGR-Afya", "MereoGR-Staging", "MereoGR-Allos")
DEFAULT_BACKUP_DIR = Path("output/backups")

_FK_LINE_RE = re.compile(
    r"ALTER TABLE \[(?P<ps>[^\]]+)\]\.\[(?P<pt>[^\]]+)\] "
    r"(?:WITH NOCHECK )?ADD CONSTRAINT \[(?P<name>[^\]]+)\] "
    r"FOREIGN KEY \((?P<pcols>[^)]+)\) "
    r"REFERENCES \[(?P<rs>[^\]]+)\]\.\[(?P<rt>[^\]]+)\] \((?P<rcols>[^)]+)\)"
    r"(?: ON DELETE (?P<on_delete>[A-Z_ ]+))?"
    r"(?: ON UPDATE (?P<on_update>[A-Z_ ]+))?",
    re.IGNORECASE,
)


def _split_bracket_cols(raw: str) -> list[str]:
    return [c.strip().strip("[]") for c in raw.split(",") if c.strip()]


def parse_foreign_keys_from_schema_sql(text: str) -> list[dict[str, Any]]:
    fks: list[dict[str, Any]] = []
    for line in text.splitlines():
        if "FOREIGN KEY" not in line or "REFERENCES" not in line:
            continue
        match = _FK_LINE_RE.search(line)
        if not match:
            continue
        fks.append(
            {
                "name": match.group("name"),
                "parent_schema": match.group("ps"),
                "parent_table": match.group("pt"),
                "parent_columns": _split_bracket_cols(match.group("pcols")),
                "referenced_schema": match.group("rs"),
                "referenced_table": match.group("rt"),
                "referenced_columns": _split_bracket_cols(match.group("rcols")),
                "on_delete": (match.group("on_delete") or "NO_ACTION").strip().replace(" ", "_"),
                "on_update": (match.group("on_update") or "NO_ACTION").strip().replace(" ", "_"),
            }
        )
    return fks


def load_fks_from_backup(database: str, backup_dir: Path) -> list[dict[str, Any]]:
    ddl_path = backup_dir / database / "schema" / "ddl.json"
    if ddl_path.exists():
        data = json.loads(ddl_path.read_text(encoding="utf-8"))
        if data.get("foreign_keys"):
            return data["foreign_keys"]

    schema_sql = backup_dir / database / "schema" / "schema.sql"
    if schema_sql.exists():
        return parse_foreign_keys_from_schema_sql(schema_sql.read_text(encoding="utf-8"))

    return []


def load_fks_from_live(database: str) -> list[dict[str, Any]]:
    cfg = load_mereo_config()
    with db.connect(cfg) as conn:
        ddl = extract_database_ddl(conn, database)
    return [fk.to_dict() for fk in ddl.foreign_keys]


def _table_key(schema: str, table: str) -> str:
    return f"{schema}.{table}"


def _bronze_key(schema: str, table: str) -> str:
    return f"{schema}__{table}"


def build_graph_payload(
    *,
    reference_db: str,
    foreign_keys: list[dict[str, Any]],
    source: str,
) -> dict[str, Any]:
    edges: list[dict[str, Any]] = []
    hub_degree: dict[str, int] = {}

    for fk in foreign_keys:
        parent = _table_key(fk["parent_schema"], fk["parent_table"])
        ref = _table_key(fk["referenced_schema"], fk["referenced_table"])
        hub_degree[parent] = hub_degree.get(parent, 0) + 1
        hub_degree[ref] = hub_degree.get(ref, 0) + 1
        edges.append(
            {
                "fk_name": fk["name"],
                "from": parent,
                "from_bronze": _bronze_key(fk["parent_schema"], fk["parent_table"]),
                "from_columns": fk["parent_columns"],
                "to": ref,
                "to_bronze": _bronze_key(fk["referenced_schema"], fk["referenced_table"]),
                "to_columns": fk["referenced_columns"],
                "on_delete": fk.get("on_delete", "NO_ACTION"),
                "on_update": fk.get("on_update", "NO_ACTION"),
                "source": "fk",
            }
        )

    hubs = sorted(
        (
            {
                "table": table,
                "bronze": _bronze_key(*table.split(".", 1)),
                "degree": degree,
            }
            for table, degree in hub_degree.items()
        ),
        key=lambda h: (-h["degree"], h["table"]),
    )

    return {
        "reference_db": reference_db,
        "source": source,
        "fk_count": len(foreign_keys),
        "edge_count": len(edges),
        "hubs_top20": hubs[:20],
        "foreign_keys": foreign_keys,
        "edges": edges,
    }


def patch_backup_ddl(database: str, backup_dir: Path, foreign_keys: list[dict[str, Any]]) -> None:
    ddl_path = backup_dir / database / "schema" / "ddl.json"
    if not ddl_path.exists():
        return
    data = json.loads(ddl_path.read_text(encoding="utf-8"))
    data["foreign_keys"] = foreign_keys
    data["fk_count"] = len(foreign_keys)
    ddl_path.write_text(json.dumps(data, indent=2), encoding="utf-8")


def run_export_fk_graph(
    group_name: str,
    *,
    source: str = "backup",
    backup_dir: Path = DEFAULT_BACKUP_DIR,
    reference_db: str | None = None,
    patch_ddl: bool = False,
) -> int:
    group = get_group(group_name)
    ref = reference_db or group.reference_db
    out_dir = group.output_dir / "schema"
    out_dir.mkdir(parents=True, exist_ok=True)

    if source == "backup":
        foreign_keys = load_fks_from_backup(ref, backup_dir)
        if not foreign_keys:
            print(f"FKs não encontradas em backup para {ref}", file=sys.stderr)
            return 1
        if patch_ddl:
            patch_backup_ddl(ref, backup_dir, foreign_keys)
    elif source == "live":
        foreign_keys = load_fks_from_live(ref)
    else:
        print(f"Fonte inválida: {source}", file=sys.stderr)
        return 1

    payload = build_graph_payload(reference_db=ref, foreign_keys=foreign_keys, source=source)
    out_path = out_dir / "foreign_keys.json"
    out_path.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    print(f"Escrito: {out_path} ({payload['fk_count']} FKs, {payload['edge_count']} arestas)")
    print("Top hubs:")
    for hub in payload["hubs_top20"][:10]:
        print(f"  {hub['degree']:4d}  {hub['table']}")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Exporta grafo de FKs para silver domain discovery")
    parser.add_argument("--group", default="mereogr", help="Grupo (groups.toml)")
    parser.add_argument(
        "--source",
        choices=("backup", "live"),
        default="backup",
        help="backup: schema.sql/ddl.json local; live: extrai do SQL Server",
    )
    parser.add_argument("--backup-dir", type=Path, default=DEFAULT_BACKUP_DIR)
    parser.add_argument("--reference-db", help="Banco referência (padrão: groups.toml)")
    parser.add_argument(
        "--patch-ddl",
        action="store_true",
        help="Atualiza foreign_keys[] em output/backups/<db>/schema/ddl.json",
    )
    args = parser.parse_args(argv)
    return run_export_fk_graph(
        args.group,
        source=args.source,
        backup_dir=args.backup_dir,
        reference_db=args.reference_db,
        patch_ddl=args.patch_ddl,
    )


if __name__ == "__main__":
    raise SystemExit(main())
