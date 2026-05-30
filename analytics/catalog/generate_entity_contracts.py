#!/usr/bin/env python3
"""Gera contratos de entidade a partir de output/groups/<grupo>/schema/tables/*.json."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_SCHEMA_DIR = REPO_ROOT / "output" / "groups" / "mereogr" / "schema" / "tables"
ENTITIES_DIR = Path(__file__).resolve().parent / "entities"


def load_table(schema_dir: Path, database: str, schema: str, table: str) -> dict | None:
    path = schema_dir / f"{database}.json"
    if not path.exists():
        return None
    payload = json.loads(path.read_text(encoding="utf-8"))
    for item in payload.get("tables", []):
        if item["schema"] == schema and item["table"] == table:
            return item
    return None


def build_contract(
    entity: str,
    schema: str,
    table: str,
    databases: list[str],
    schema_dir: Path,
) -> dict:
    samples: list[dict] = []
    column_sets: list[frozenset[str]] = []

    for database in databases:
        row = load_table(schema_dir, database, schema, table)
        if not row:
            continue
        cols = {c["name"]: c for c in row["columns"]}
        column_sets.append(frozenset(cols))
        samples.append(
            {
                "database": database,
                "pk_columns": row.get("pk_columns", []),
                "column_count": len(row["columns"]),
                "columns": [
                    {
                        "name": c["name"],
                        "type": c["type"],
                        "nullable": c["nullable"],
                        "is_pk": c.get("is_pk", False),
                    }
                    for c in row["columns"]
                ],
            }
        )

    if not samples:
        raise SystemExit(f"Nenhum schema encontrado para {schema}.{table} nos bancos {databases}")

    common = set.intersection(*map(set, column_sets)) if column_sets else set()
    all_cols = set.union(*map(set, column_sets)) if column_sets else set()

    return {
        "entity": entity,
        "source": {"schema": schema, "table": table},
        "kafka_topic": f"raw.{entity}",
        "clickhouse": {
            "database": "raw",
            "table": entity,
            "consumer_group": f"ch-raw-{entity}",
        },
        "pilot_databases": databases,
        "pk_columns": samples[0]["pk_columns"],
        "columns_common": sorted(common),
        "columns_drift": sorted(all_cols - common),
        "samples": samples,
    }


def write_contract(contract: dict, out_path: Path) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        f"# Contrato gerado de output/groups/mereogr/schema/tables/",
        f"# Entidade: {contract['entity']} ({contract['source']['schema']}.{contract['source']['table']})",
        "",
    ]
    import yaml

    lines.append(yaml.dump(contract, allow_unicode=True, sort_keys=False))
    out_path.write_text("".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Gera contratos YAML de entidades do inventário de schema")
    parser.add_argument("--schema-dir", type=Path, default=DEFAULT_SCHEMA_DIR)
    parser.add_argument("--entity", default="colaborador")
    parser.add_argument("--source-schema", default="dbo")
    parser.add_argument("--source-table", default="COLABORADOR")
    parser.add_argument(
        "--databases",
        nargs="+",
        default=["MereoGR-Afya", "MereoGR-Staging", "MereoGR-Allos"],
    )
    args = parser.parse_args()

    if not args.schema_dir.exists():
        print(
            f"Schema dir ausente: {args.schema_dir}\n"
            "Rode: uv run python -m mereo_tools schema --group mereogr",
            file=sys.stderr,
        )
        return 1

    contract = build_contract(
        args.entity,
        args.source_schema,
        args.source_table,
        args.databases,
        args.schema_dir,
    )
    out = ENTITIES_DIR / f"{args.entity}.yaml"
    out.parent.mkdir(parents=True, exist_ok=True)
    try:
        import yaml

        write_contract(contract, out)
    except ImportError:
        out.write_text(json.dumps(contract, indent=2, ensure_ascii=False), encoding="utf-8")
        print(f"Escrito {out} (JSON — instale pyyaml para YAML)")
        return 0

    print(f"Escrito {out}")
    print(f"Colunas comuns ({len(contract['columns_common'])}): {', '.join(contract['columns_common'][:8])}...")
    if contract["columns_drift"]:
        print(f"Drift entre tenants: {len(contract['columns_drift'])} colunas")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
