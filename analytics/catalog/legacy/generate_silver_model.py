#!/usr/bin/env python3
"""Gera scaffold ETL silver em models/silver/{domain}/{silver_table}.sql."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).resolve().parents[2]
ENTITIES_DIR = REPO_ROOT / "analytics" / "catalog" / "entities"
DOMAINS_PATH = REPO_ROOT / "analytics" / "catalog" / "silver_domains.yaml"
OUT_ROOT = REPO_ROOT / "analytics" / "dbt" / "models" / "silver"

TEMPLATE = '''{{
  config(
    materialized='view',
    tags=['silver', '{domain}', 'wave_{wave}'],
  )
}}

/*
  Silver — {domain}.{silver_table} (3 bancos via tenant_slug).
  Bronze: {bronze}
  Gerado por generate_silver_model.py — REVISAR antes do build.
*/

select
    tenant_slug,
{column_lines}
    _ts_ms,
    _deleted
from {{{{ source('bronze', '{bronze}') }}}}
where _deleted = 0
'''


def _snake(name: str) -> str:
    s = re.sub(r"(?<!^)(?=[A-Z])", "_", name).lower()
    return s.replace("__", "_")


def _columns_from_contract(data: dict) -> list[str]:
    cols = data.get("columns_common") or []
    if not cols and data.get("landing_columns"):
        cols = [c["source"] for c in data["landing_columns"]]
    lines: list[str] = []
    for col in cols:
        alias = "id" if col.upper() == "ID" else _snake(col)
        if col.upper() == "ID":
            lines.append("    ID as id,")
        else:
            lines.append(f"    `{col}` as {alias},")
    return lines


def _load_domains() -> dict:
    return yaml.safe_load(DOMAINS_PATH.read_text(encoding="utf-8"))


def _find_entity(domains_data: dict, domain_id: str | None, silver_table: str | None) -> dict | None:
    for domain in domains_data.get("domains", []):
        if domain_id and domain["id"] != domain_id:
            continue
        for ent in domain.get("entities", []):
            if silver_table and ent["silver_table"] != silver_table:
                continue
            return {**ent, "domain_id": domain["id"]}
    return None


def _emit(ent: dict, columns: list[str], dry_run: bool) -> str:
    domain = ent["domain_id"]
    silver_table = ent["silver_table"]
    bronze = ent["bronze"]
    wave = ent.get("wave", 1)
    sql = TEMPLATE.format(
        domain=domain,
        silver_table=silver_table,
        wave=wave,
        bronze=bronze,
        column_lines="\n".join(columns) if columns else "    -- TODO: colunas (DESCRIBE bronze)\n",
    )
    out_path = OUT_ROOT / domain / f"{silver_table}.sql"

    if dry_run:
        print(f"# {out_path}\n{sql}\n")
        return silver_table

    out_path.parent.mkdir(parents=True, exist_ok=True)
    if out_path.exists():
        print(f"SKIP (existe): {out_path}")
        return silver_table

    out_path.write_text(sql, encoding="utf-8")
    print(f"Escrito: {out_path}")
    return silver_table


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Scaffold ETL silver por domínio (silver_domains.yaml)")
    parser.add_argument("--domain", help="Domínio (ex.: metricas, colaborador)")
    parser.add_argument("--table", help="Tabela silver (ex.: meta, pessoa)")
    parser.add_argument("--wave", type=int, help="Gerar todas entidades da onda")
    parser.add_argument("--entity", help="Contrato catalog/entities/{entity}.yaml")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args(argv)

    if not DOMAINS_PATH.exists():
        raise SystemExit(f"Catálogo não encontrado: {DOMAINS_PATH}")

    domains_data = _load_domains()

    if args.entity:
        contract_path = ENTITIES_DIR / f"{args.entity}.yaml"
        if not contract_path.exists():
            raise SystemExit(f"Contrato não encontrado: {contract_path}")
        data = yaml.safe_load(contract_path.read_text(encoding="utf-8"))
        ent = _find_entity(domains_data, None, "pessoa") if args.entity == "colaborador" else None
        if not ent:
            schema = data["source"]["schema"]
            table = data["source"]["table"]
            bronze = f"{schema}__{table}"
            ent = {
                "domain_id": args.domain or "colaborador",
                "silver_table": args.table or _snake(table),
                "bronze": bronze,
                "wave": 1,
            }
        cols = _columns_from_contract(data)
        _emit(ent, cols, args.dry_run)
        return 0

    if args.domain and args.table:
        ent = _find_entity(domains_data, args.domain, args.table)
        if not ent:
            raise SystemExit(f"Entidade não encontrada: {args.domain}.{args.table}")
        _emit(ent, ["    -- TODO: colunas"], args.dry_run)
        return 0

    if args.wave is not None:
        for domain in domains_data.get("domains", []):
            for ent in domain.get("entities", []):
                if ent.get("wave") != args.wave:
                    continue
                if ent.get("status") == "implemented":
                    print(f"SKIP (implemented): {domain['id']}.{ent['silver_table']}")
                    continue
                erp_table = ent.get("erp", {}).get("table", "")
                contract = ENTITIES_DIR / f"{_snake(erp_table)}.yaml"
                cols: list[str] = []
                if contract.exists():
                    cols = _columns_from_contract(
                        yaml.safe_load(contract.read_text(encoding="utf-8"))
                    )
                _emit({**ent, "domain_id": domain["id"]}, cols, args.dry_run)
        return 0

    parser.print_help()
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
