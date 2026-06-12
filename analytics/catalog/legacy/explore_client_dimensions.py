#!/usr/bin/env python3
"""Classifica 616 tabelas ERP (referência Afya) em papéis dimensionais — clientes afya/allos."""

from __future__ import annotations

import argparse
import csv
import gzip
import json
import re
from collections import defaultdict
from pathlib import Path
from typing import Any

import yaml

REPO_ROOT = Path(__file__).resolve().parents[2]
SCHEMA_REF = REPO_ROOT / "output" / "groups" / "mereogr" / "schema" / "tables" / "MereoGR-Afya.json"
FK_GRAPH = REPO_ROOT / "output" / "groups" / "mereogr" / "schema" / "foreign_keys.json"
BRONZE_MAP = REPO_ROOT / "analytics" / "catalog" / "bronze_domain_map.yaml"
SILVER_DOMAINS = REPO_ROOT / "analytics" / "catalog" / "silver_domains.yaml"
BACKUPS = REPO_ROOT / "output" / "backups"
OUT_CSV = REPO_ROOT / "analytics" / "catalog" / "client_table_classification.csv"
OUT_YAML = REPO_ROOT / "analytics" / "catalog" / "dim_fact_candidates.yaml"

EXCLUDE_PREFIXES = (
    "AUDIT_", "IMP_", "LOG_", "HangFire", "AbpEntity", "AbpSettings", "AspNet",
    "audit.", "cache.", "auth.", "core.", "dashboards.", "notification.", "Tasks.",
    "stg.", "dbo.Identity", "dbo.MENU", "dbo.MODULES", "dbo.SQL_TRACE",
)

FACT_MARKERS = (
    "CALC_", "VALOR_", "NOTA_", "Score", "ValorMatriz", "Pontual", "Acum",
    "RESPOSTA", "HISTORICO_", "AUDIT_", "IMP_",
)

BRIDGE_MARKERS = (
    "_AREA", "COLABORADOR_AREA", "COLABORADOR_FUNCAO", "MEMBRO_", "PARTICIPANTE_",
    "VINCULO", "BRIDGE", "_ITEM", "_LABEL", "GRUPO_ITEM",
)

REF_TABLES = frozenset({
    "dbo.UNIDADE_MEDIDA", "dbo.GRANDEZA", "dbo.IDIOMA", "dbo.COTACAO_MOEDA",
    "dbo.TIPO_", "dbo.ESTADO", "dbo.PAIS",
})

DIM_HUBS = frozenset({
    "dbo.COLABORADOR", "dbo.AREA", "dbo.CARGO", "dbo.FILIAL", "dbo.GRUPO_USUARIO",
    "dbo.META", "dbo.INDICADOR", "dbo.PERIODO_GESTAO", "dbo.PERIODO_APURACAO",
    "competences.AVALIACAO", "competences.COMPETENCIA", "competences.AVALIADO",
    "dbo.ACAO", "dbo.REUNIAO", "dbo.SuccessionCycle", "okr.Objective", "okr.KeyResult",
    "dbo.Matriz", "dbo.PARTICIPANTE_RV",
})

FACT_GRAINS: dict[str, str] = {
    "dbo.VALOR_META": "tenant_slug, id_meta, id_periodo_apuracao",
    "dbo.NOTA_META": "tenant_slug, id_meta, id_periodo_apuracao",
    "dbo.ValorMatriz": "tenant_slug, fk_matriz, fk_membro_dimensao1, fk_membro_dimensao2, dt_ref",
    "dbo.PARTICIPANTE_RV": "tenant_slug, id",
    "competences.RESPOSTA": "tenant_slug, id",
    "competences.CALC_RESULTADO_AVALIADOR": "tenant_slug, id_avaliador, id_competencia",
    "dbo.ACAO": "tenant_slug, id",
    "competences.FEEDBACK_CONTINUO": "tenant_slug, id",
}


def _erp_key(schema: str, table: str) -> str:
    return f"{schema}.{table}"


def _bronze_name(schema: str, table: str) -> str:
    return table if schema == "cdc" else f"{schema}__{table}"


def _backup_file(database: str, bronze: str) -> Path:
    return BACKUPS / database / "data" / f"{bronze}.jsonl.gz"


def _count_rows_gz(path: Path) -> int:
    if not path.exists():
        return 0
    try:
        with gzip.open(path, "rt", encoding="utf-8", errors="replace") as f:
            return sum(1 for _ in f)
    except OSError:
        return 0


def _load_fk_degrees() -> tuple[dict[str, int], dict[str, list[str]]]:
    data = json.loads(FK_GRAPH.read_text(encoding="utf-8"))
    out_degree: dict[str, int] = defaultdict(int)
    in_degree: dict[str, int] = defaultdict(int)
    fk_refs: dict[str, list[str]] = defaultdict(list)
    for edge in data.get("edges", []):
        if edge.get("parent_schema"):
            frm = f"{edge['parent_schema']}.{edge['parent_table']}"
            to = f"{edge['referenced_schema']}.{edge['referenced_table']}"
        else:
            frm = edge.get("from_table") or edge.get("from_erp", "")
            to = edge.get("to_table") or edge.get("to_erp", "")
        if frm and to:
            out_degree[frm] += 1
            in_degree[to] += 1
            fk_refs[frm].append(to)
    degree = {t: in_degree[t] + out_degree[t] for t in set(in_degree) | set(out_degree)}
    return degree, dict(fk_refs)


def _load_bronze_index() -> dict[str, dict[str, Any]]:
    data = yaml.safe_load(BRONZE_MAP.read_text(encoding="utf-8"))
    return {t["bronze"]: t for t in data.get("tables", [])}


def _load_silver_by_bronze() -> dict[str, dict[str, Any]]:
    data = yaml.safe_load(SILVER_DOMAINS.read_text(encoding="utf-8"))
    out: dict[str, dict[str, Any]] = {}
    for dom in data.get("domains", []):
        for ent in dom.get("entities", []):
            out[ent["bronze"]] = {**ent, "domain": dom["id"]}
    return out


def _classify_role(
    erp_key: str,
    table: str,
    domain: str,
    excluded: bool,
    fk_degree: int,
    rows_afya: int,
    rows_allos: int,
) -> str:
    if excluded or any(erp_key.startswith(p) or p in erp_key for p in EXCLUDE_PREFIXES):
        return "EXCLUDE"
    if erp_key.startswith("stg."):
        return "EXCLUDE"
    if rows_afya == 0 and rows_allos == 0:
        return "DEFER"
    if erp_key in REF_TABLES or domain == "referencia":
        return "REF"
    if any(m in table for m in BRIDGE_MARKERS) or "COLABORADOR_AREA" in table:
        return "BRIDGE"
    if erp_key in FACT_GRAINS or any(table.startswith(m) for m in ("CALC_", "VALOR_", "NOTA_")):
        return "FACT"
    if table.startswith("CALC_") or "ValorMatriz" in table or table.endswith("Score"):
        return "FACT"
    if erp_key in DIM_HUBS or fk_degree >= 15:
        return "DIM"
    if fk_degree >= 8:
        return "DIM"
    if any(m in table for m in FACT_MARKERS):
        return "FACT"
    if fk_degree <= 2 and rows_afya + rows_allos > 1000:
        return "FACT"
    return "DIM"


def _snowflake_name(role: str, erp_key: str, silver_table: str | None) -> str:
    base = silver_table or erp_key.split(".")[-1].lower()
    prefix = {"DIM": "DIM", "FACT": "FACT", "BRIDGE": "BRG", "REF": "REF"}.get(role, "")
    if not prefix:
        return ""
    return f"{prefix}_{base.upper()}"


def explore(*, clients: list[str]) -> dict[str, Any]:
    schema = json.loads(SCHEMA_REF.read_text(encoding="utf-8"))
    fk_degree, fk_refs = _load_fk_degrees()
    bronze_idx = _load_bronze_index()
    silver_idx = _load_silver_by_bronze()

    db_map = {"afya": "MereoGR-Afya", "allos": "MereoGR-Allos", "staging": "MereoGR-Staging"}
    client_dbs = [db_map[c] for c in clients if c in db_map]

    rows_out: list[dict[str, Any]] = []
    role_counts: dict[str, int] = defaultdict(int)
    dim_candidates: list[dict[str, Any]] = []
    fact_candidates: list[dict[str, Any]] = []

    for t in schema.get("tables", []):
        schema_name, table_name = t["schema"], t["table"]
        erp = _erp_key(schema_name, table_name)
        bronze = _bronze_name(schema_name, table_name)
        pk_cols = t.get("pk_columns") or [c["name"] for c in t.get("columns", []) if c.get("is_pk")]

        counts = {c: _count_rows_gz(_backup_file(db_map[c], bronze)) for c in clients if c in db_map}
        rows_afya = counts.get("afya", 0)
        rows_allos = counts.get("allos", 0)

        bronze_row = bronze_idx.get(bronze, {})
        domain = bronze_row.get("candidate_domain", "unclassified")
        excluded = bronze_row.get("exclude", False) or domain in {
            "import", "audit", "logs", "plataforma", "views_stg", "config",
        }
        silver_ent = silver_idx.get(bronze)
        silver_table = silver_ent["silver_table"] if silver_ent else None
        silver_domain = silver_ent["domain"] if silver_ent else None

        degree = fk_degree.get(erp, 0)
        role = _classify_role(erp, table_name, domain, excluded, degree, rows_afya, rows_allos)
        role_counts[role] += 1

        populated = []
        if rows_afya > 0:
            populated.append("afya")
        if rows_allos > 0:
            populated.append("allos")
        overlap = "both" if len(populated) == 2 else (populated[0] if populated else "none")

        sf_name = _snowflake_name(role, erp, silver_table)
        grain = FACT_GRAINS.get(erp, "")

        row = {
            "erp_key": erp,
            "bronze": bronze,
            "schema": schema_name,
            "table": table_name,
            "domain": domain,
            "dimensional_role": role,
            "snowflake_candidate": sf_name,
            "fk_degree": degree,
            "pk_columns": "|".join(pk_cols),
            "row_count_afya": rows_afya,
            "row_count_allos": rows_allos,
            "populated_clients": overlap,
            "silver_table": silver_table or "",
            "silver_domain": silver_domain or "",
            "silver_implemented": "yes" if silver_ent else "no",
            "grain": grain,
        }
        rows_out.append(row)

        if role == "DIM" and sf_name and rows_afya + rows_allos > 0:
            dim_candidates.append({
                "name": sf_name,
                "erp_key": erp,
                "silver": f"{silver_domain}.{silver_table}" if silver_table else "",
                "pk": pk_cols,
                "fk_degree": degree,
            })
        if role == "FACT" and sf_name and rows_afya + rows_allos > 0:
            fact_candidates.append({
                "name": sf_name,
                "erp_key": erp,
                "silver": f"{silver_domain}.{silver_table}" if silver_table else "",
                "grain": grain or f"tenant_slug, {pk_cols[0] if pk_cols else 'id'}",
                "row_count_afya": rows_afya,
                "row_count_allos": rows_allos,
            })

    rows_out.sort(key=lambda r: (-r["fk_degree"], r["erp_key"]))

    with OUT_CSV.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows_out[0].keys()))
        writer.writeheader()
        writer.writerows(rows_out)

    hubs = json.loads(FK_GRAPH.read_text(encoding="utf-8")).get("hubs_top20", [])
    payload = {
        "reference_db": "MereoGR-Afya",
        "clients": clients,
        "table_count": len(rows_out),
        "role_counts": dict(role_counts),
        "hubs_top20": hubs,
        "dim_candidates": sorted(dim_candidates, key=lambda x: -x["fk_degree"])[:40],
        "fact_candidates": sorted(fact_candidates, key=lambda x: -(x["row_count_afya"] + x["row_count_allos"]))[:40],
        "priority_facts": [
            {"name": "FACT_GOAL_VALUE", "sources": ["metricas.valor_meta", "metricas.nota_meta", "metricas.meta"]},
            {"name": "FACT_RV", "sources": ["remuneracao.participante_rv"]},
            {"name": "FACT_EVAL_SCORE", "sources": ["avaliacao.calc_resultado_avaliador", "avaliacao.resposta"]},
            {"name": "FACT_MATRIX_CELL", "sources": ["metricas.valor_matriz"], "note": "staging-only volume; filter DtRef"},
            {"name": "FACT_ACTION", "sources": ["acao.acao", "acao.reuniao"]},
        ],
    }
    OUT_YAML.write_text(yaml.dump(payload, allow_unicode=True, sort_keys=False, default_flow_style=False), encoding="utf-8")

    return {"rows": len(rows_out), "role_counts": dict(role_counts)}


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Explora dimensões/fatos — clientes Afya/Allos")
    parser.add_argument("--clients", default="afya,allos", help="tenant_slug comma-separated")
    args = parser.parse_args(argv)
    clients = [c.strip() for c in args.clients.split(",") if c.strip()]

    stats = explore(clients=clients)
    print(f"Classificadas: {stats['rows']} tabelas")
    for role, n in sorted(stats["role_counts"].items()):
        print(f"  {role}: {n}")
    print(f"CSV: {OUT_CSV}")
    print(f"YAML: {OUT_YAML}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
