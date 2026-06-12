#!/usr/bin/env python3
"""Sincroniza silver_domains.yaml com bronze_domain_map.yaml (373 entidades business)."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).resolve().parents[2]
BRONZE_MAP = REPO_ROOT / "analytics" / "catalog" / "bronze_domain_map.yaml"
SILVER_DOMAINS = REPO_ROOT / "analytics" / "catalog" / "silver_domains.yaml"

EXCLUDE_DOMAINS = frozenset({"import", "audit", "logs", "plataforma", "views_stg", "config"})

DOMAIN_WAVES: dict[str, int] = {
    "colaborador": 9,
    "organizacao": 5,
    "metricas": 11,
    "avaliacao": 3,
    "remuneracao": 4,
    "referencia": 10,
    "acao": 6,
    "sucessao": 7,
    "pdi": 8,
}

DOMAIN_DESCRIPTIONS: dict[str, str] = {
    "colaborador": "Pessoas e vínculos do colaborador",
    "organizacao": "Estrutura organizacional",
    "metricas": "Metas, indicadores, apuração, OKR e estratégia",
    "avaliacao": "Performance, competências e feedback contínuo",
    "remuneracao": "Variável e RV",
    "referencia": "Dimensões compartilhadas",
    "acao": "Planos de ação, reuniões e contramedidas",
    "sucessao": "Ciclos de sucessão e fóruns",
    "pdi": "Treinamento e plano de desenvolvimento individual",
}


def _snake(name: str) -> str:
    if not name:
        return name
    if name == name.upper() or re.fullmatch(r"[A-Z0-9_]+", name):
        return name.lower()
    s = re.sub(r"(?<=[a-z0-9])(?=[A-Z])", "_", name)
    s = re.sub(r"(?<=[A-Z])(?=[A-Z][a-z])", "_", s)
    return s.lower().replace("__", "_")


def _parse_bronze(bronze: str, erp_schema: str, erp_table: str) -> tuple[str, str]:
    if erp_schema == "cdc" or "__" not in bronze:
        return erp_schema, erp_table
    schema, table = bronze.split("__", 1)
    return schema, table


def _unique_silver_table(base: str, used: set[str], bronze: str) -> str:
    if base not in used:
        return base
    alt = _snake(bronze.replace("__", "_"))
    if alt not in used:
        return alt
    i = 2
    while f"{base}_{i}" in used:
        i += 1
    return f"{base}_{i}"


def _pk_from_table(erp_table: str) -> list[str]:
    return ["id"]


def sync_catalog(*, domain_filter: str | None = None, dry_run: bool = False) -> dict[str, int]:
    bronze_data = yaml.safe_load(BRONZE_MAP.read_text(encoding="utf-8"))
    silver_data = yaml.safe_load(SILVER_DOMAINS.read_text(encoding="utf-8"))

    domains_by_id: dict[str, dict] = {d["id"]: d for d in silver_data.get("domains", [])}
    bronze_by_domain: dict[str, list[dict]] = {}

    for row in bronze_data.get("tables", []):
        dom = row["candidate_domain"]
        if dom in EXCLUDE_DOMAINS or row.get("exclude"):
            continue
        if domain_filter and dom != domain_filter:
            continue
        bronze_by_domain.setdefault(dom, []).append(row)

    stats = {"added": 0, "skipped": 0, "total_business": 0}

    for dom_id, rows in sorted(bronze_by_domain.items()):
        stats["total_business"] += len(rows)
        if dom_id not in domains_by_id:
            domains_by_id[dom_id] = {
                "id": dom_id,
                "ch_database": dom_id,
                "description": DOMAIN_DESCRIPTIONS.get(dom_id, dom_id),
                "entities": [],
            }

        domain = domains_by_id[dom_id]
        existing_by_bronze = {e["bronze"]: e for e in domain.get("entities", [])}
        used_silver = {e["silver_table"] for e in domain.get("entities", [])}
        wave = DOMAIN_WAVES.get(dom_id, 99)

        for row in sorted(rows, key=lambda r: r["bronze"]):
            bronze = row["bronze"]
            if bronze in existing_by_bronze:
                stats["skipped"] += 1
                continue

            erp_schema, erp_table = _parse_bronze(
                bronze, row.get("erp_schema", ""), row.get("erp_table", "")
            )
            base_name = _snake(erp_table)
            silver_table = _unique_silver_table(base_name, used_silver, bronze)
            used_silver.add(silver_table)

            entity = {
                "silver_table": silver_table,
                "bronze": bronze,
                "erp": {"schema": erp_schema, "table": erp_table},
                "pk": _pk_from_table(erp_table),
                "wave": wave,
                "status": "planned",
            }
            domain.setdefault("entities", []).append(entity)
            stats["added"] += 1
            print(f"  + {dom_id}.{silver_table} <- {bronze}")

    silver_data["domains"] = sorted(domains_by_id.values(), key=lambda d: d["id"])

    if not dry_run:
        SILVER_DOMAINS.write_text(
            yaml.dump(silver_data, allow_unicode=True, sort_keys=False, default_flow_style=False),
            encoding="utf-8",
        )

    return stats


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Sync silver_domains.yaml from bronze_domain_map.yaml")
    parser.add_argument("--domain", help="Sincronizar só um domínio")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args(argv)

    print(f"Sincronizando {SILVER_DOMAINS.name} ...")
    stats = sync_catalog(domain_filter=args.domain, dry_run=args.dry_run)
    print(
        f"Adicionadas: {stats['added']}, já no catálogo: {stats['skipped']}, "
        f"business total: {stats['total_business']}"
    )
    if not args.dry_run:
        print(f"Escrito: {SILVER_DOMAINS}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
