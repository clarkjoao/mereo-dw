#!/usr/bin/env python3
"""Classifica tabelas bronze em domínios candidatos usando FKs, heurísticas e catálogo silver."""

from __future__ import annotations

import argparse
import csv
import json
import re
from collections import defaultdict
from pathlib import Path
from typing import Any

import yaml

REPO_ROOT = Path(__file__).resolve().parents[2]
BRONZE_SOURCES = REPO_ROOT / "analytics" / "dbt" / "models" / "bronze" / "_bronze__sources.yml"
SILVER_DOMAINS = REPO_ROOT / "analytics" / "catalog" / "silver_domains.yaml"
FK_GRAPH = REPO_ROOT / "output" / "groups" / "mereogr" / "schema" / "foreign_keys.json"
SCHEMA_REF = REPO_ROOT / "output" / "groups" / "mereogr" / "schema" / "tables" / "MereoGR-Afya.json"
OUT_MAP = REPO_ROOT / "analytics" / "catalog" / "bronze_domain_map.yaml"
OUT_GRAPH = REPO_ROOT / "analytics" / "catalog" / "bronze_relationship_graph.json"
OUT_SUMMARY = REPO_ROOT / "analytics" / "catalog" / "bronze_domain_summary.csv"

# Hubs conhecidos → domínio (referência estrutural)
HUB_DOMAINS: dict[str, str] = {
    "dbo.COLABORADOR": "colaborador",
    "dbo.COLABORADOR_AREA": "colaborador",
    "dbo.HISTORICO_COLABORADOR_AREA": "colaborador",
    "dbo.HISTORICO_CARGO": "colaborador",
    "dbo.AREA": "organizacao",
    "dbo.CARGO": "organizacao",
    "dbo.FILIAL": "organizacao",
    "dbo.GRUPO_USUARIO": "organizacao",
    "dbo.PERFIL_AREA": "organizacao",
    "dbo.META": "metricas",
    "dbo.INDICADOR": "metricas",
    "dbo.VALOR_META": "metricas",
    "dbo.NOTA_META": "metricas",
    "dbo.PERIODO_GESTAO": "metricas",
    "dbo.PERIODO_APURACAO": "metricas",
    "dbo.EXPRESSAO_CALCULO_META": "metricas",
    "dbo.ValorMatriz": "metricas",
    "dbo.ACAO": "acao",
    "dbo.REUNIAO": "acao",
    "competences.AVALIACAO": "avaliacao",
    "competences.AVALIADO": "avaliacao",
    "competences.AVALIADOR": "avaliacao",
    "competences.COMPETENCIA": "avaliacao",
    "dbo.PARTICIPANTE_RV": "remuneracao",
    "dbo.UNIDADE_MEDIDA": "referencia",
    "dbo.GRANDEZA": "referencia",
    "dbo.SuccessionCycle": "sucessao",
    "okr.Objective": "metricas",
    "okr.KeyResult": "metricas",
    "dbo.FEEDBACK_CONTINUO": "avaliacao",
}

# Decisões workshop — domínios CH aprovados
ACAO_CORE_TABLES = frozenset({
    "ACAO", "REUNIAO", "REUNIAO_PAUSE", "PARTICIPANTE_REUNIAO", "CONTRAMEDIDA", "CAUSA",
    "ANEXO_ACAO", "ANEXO_REUNIAO", "TOPICO_REUNIAO", "MARCADOR_ACAO", "MARCADOR_ACAO_ITEM",
    "EFETIVIDADE_ACAO", "DIARIO_DE_BORDO", "CATCH_BALL", "QUICK_MEETING",
    "GESTOR_MARCADOR_ACAO", "REFERENCIA_CONTRAMEDIDA", "VOTACAO_CAUSA",
    "ActionBase", "ActionBaseLabel", "LabelAction", "RECURRING_JOB", "HISTORICO_WORKFLOW_ACAO",
    "KnowledgeManagement", "NOTIFICACAO",
})

FEEDBACK_MARKERS = (
    "FEEDBACK", "PULSE_", "Feedback", "TAG_FEEDBACK", "AVALIACAO_CONTINUA",
    "FORMULARIO_FEEDBACK",
)

PDI_MARKERS = (
    "Training", "PDI", "Qualification", "BIBLIOTECA", "SkillCategory", "SkillKnowledge",
    "ACAO_SUGERIDA_PDI", "CATEGORIA_PDI_ACAO", "IndividualDevelopmentAction",
    "HISTORICO_PDI", "LabelsTagTrainings",
)

ESTRATEGIA_MARKERS = (
    "Strategy", "SwotAnalysis", "Initiative", "Perspective", "Visao",
)

# Colunas ID_* → hub ERP
INFERRED_HUBS: dict[str, str] = {
    "ID_COLABORADOR": "dbo.COLABORADOR",
    "ID_COLABORADOR_AVALIADO": "dbo.COLABORADOR",
    "ID_COLABORADOR_AVALIADOR": "dbo.COLABORADOR",
    "EmployeeId": "dbo.COLABORADOR",
    "ID_AREA": "dbo.AREA",
    "ID_CARGO": "dbo.CARGO",
    "ID_FILIAL": "dbo.FILIAL",
    "ID_GRUPO_USUARIO": "dbo.GRUPO_USUARIO",
    "ID_META": "dbo.META",
    "ID_INDICADOR": "dbo.INDICADOR",
    "ID_PERIODO_GESTAO": "dbo.PERIODO_GESTAO",
    "ID_PERIODO_APURACAO": "dbo.PERIODO_APURACAO",
    "ID_AVALIACAO": "competences.AVALIACAO",
    "ID_AVALIADO": "competences.AVALIADO",
    "ID_AVALIADOR": "competences.AVALIADOR",
}

EXCLUDE_BUCKETS: list[tuple[str, str, tuple[str, ...]]] = [
    ("import", "staging de carga IMP_*", ("IMP_",)),
    ("audit", "histórico AUDIT_* / audit.*", ("AUDIT_", "audit__")),
    ("logs", "operacional LOG_*", ("LOG_",)),
    ("plataforma", "infra app", (
        "HangFire__", "AbpEntity", "AbpSettings", "AspNet", "cache__", "auth__",
        "core__", "dashboards__", "notification__", "Tasks__", "dbo__Identity",
        "dbo__MENU", "dbo__MODULES", "dbo__Modules", "dbo__SQL_TRACE", "dbo__TaskLog",
        "dbo__BackgroundJob", "dbo____MigrationHistory", "dbo__dual",
        "dbo__API_CONFIG", "dbo__FUNCIONALIDADE", "dbo__SidebarItem", "dbo__Addon",
        "dbo__AdminPasswordResetToken", "dbo__CustomMessages", "dbo__DashboardLayout",
        "dbo__InitialDashboardLayout", "dbo__ImagePanelImages", "dbo__PresentationTemplate",
        "dbo__ImportLog", "dbo__ImportLogError",
    )),
    ("views_stg", "views materializadas stg.*", ("stg__",)),
]

DOMAIN_RULES: list[tuple[str, tuple[str, ...]]] = [
    ("colaborador", (
        "COLABORADOR", "HISTORICO_CARGO", "HISTORICO_COLABORADOR", "Employee",
        "Education", "ProfessionalExperience", "PSW_COLABORADOR", "AspNetUsers",
        "PersonalCharacteristics", "Hobbies", "Dreams", "Certificate", "Absence",
        "WelcomeSupport", "Volunteer", "Curriculum", "Motivations", "LanguageLevel",
        "Sport", "Readiness", "colaborador", "AcceptAgreement", "ConsentAgreement",
        "TERMO_ACEITE",
    )),
    ("organizacao", (
        "AREA", "CARGO", "FILIAL", "GRUPO_", "PERFIL_AREA", "PERFIL_GRUPO",
        "JobPosition", "AreasGroup", "Company", "ADMINISTRADOR", "FUNCAO_AREA",
        "EmployeeBranch", "OrganizationIdentity", "NIVEL", "Locality",
    )),
    ("metricas", (
        "META", "INDICADOR", "VALOR_META", "NOTA_META", "NOTA_", "dbo__NOTA",
        "PERIODO_GESTAO",
        "PERIODO_APURACAO", "EXPRESSAO_CALCULO", "ValorMatriz", "Matriz", "FAIXA_",
        "FAROL", "CURVA_", "DIRETRIZ", "Goal", "Trigger", "MonthlyGoal",
        "YearPersonalGoal", "BOOK", "METABOOK", "ScoreValues", "RelUpperGoal",
        "MembroDimensao", "Dimensao", "HISTORICO_PERC_REALIZADO", "GRUPO_INDICADOR",
        "INFO_NOTA_META", "StrategyGoal", "StrategyCycle", "StrategyAnalysis",
        "StrategyAction", "ItemSwot", "SwotAnalysis", "KPIStakeholder",
        "dbo__Item", "ArvoreMembrosQuebra", "NivelMembros", "CategoryAnalysis",
        "FREQUENCIA_ACOMP", "FREQUENCIA_VISUALIZACAO", "okr__",
    )),
    ("avaliacao", (
        "AVALIACAO", "AVALIADO", "AVALIADOR", "COMPETENCIA", "CALC_RESULTADO",
        "NINE_BOX", "Evaluation", "FORMULARIO_AVALIACAO", "CALIBRADOS",
        "INSTANCIA_", "CONSIDERACAO_FINAL", "RESPOSTA_AVALIACAO", "FAIXA_CLASSIFICACAO",
        "competences__", "Question", "DeliberationOption",
        "FEEDBACK", "PULSE_", "Feedback", "TAG_FEEDBACK", "AVALIACAO_CONTINUA",
        "FORMULARIO_FEEDBACK", "ReactionEvaluation", "EffectivenessEvaluation",
    )),
    ("remuneracao", (
        "PARTICIPANTE_RV", "RV", "Modifier", "AdvancePayment", "ParticipantExtract",
        "ParticipantAggregated", "EligibleDiscretionary", "EvaluationDiscretionary",
        "Discretionary", "GRUPO_PAGTO", "ScoreValuesRV", "SimulationRV",
        "PermissaoFinanceira", "COTACAO_MOEDA",
    )),
    ("referencia", (
        "UNIDADE_MEDIDA", "GRANDEZA", "IDIOMA", "VERSAO", "TipoAcumulacao",
        "TranslateTag", "SYSTEM_CONFIG", "PLUGIN_INFO", "MAIL_CONFIG",
    )),
    ("acao", (
        "ACAO", "REUNIAO", "CONTRAMEDIDA", "MARCADOR_ACAO", "EFETIVIDADE_ACAO",
        "TOPICO_REUNIAO", "ANEXO_ACAO", "ANEXO_REUNIAO", "GESTOR_MARCADOR",
        "LabelAction", "StrategyAction", "CAUSA", "CONTRAMEDIDA", "DIARIO_DE_BORDO",
        "CATCH_BALL", "QUICK_MEETING", "RECURRING_JOB", "ActionBase",
    )),
    ("sucessao", (
        "SUCESSAO", "Succession", "FORUM_", "JobEvaluationSuccession",
        "ManagerSuccession", "AVALIADOR_FORUM", "AVALIADO_SUCESSAO",
        "DELIBERACAO_FORUM", "FUNCAO_SUCESSAO", "FUNCAO_POTENCIAL",
        "FUNCAO_RISCO", "FUNCAO_IMPACTO", "ScoreCurve",
    )),
    ("pdi", (
        "PDI", "Training", "HISTORICO_PDI", "ACAO_SUGERIDA_PDI", "BIBLIOTECA",
        "Qualification", "SkillKnowledge", "SkillCategory",
    )),
    ("estrategia", ("Strategy", "SwotAnalysis", "Initiative", "Perspective", "Visao")),
]


def _workshop_domain(erp_schema: str, erp_table: str, bronze: str) -> str | None:
    """Domínio CH aprovado em workshop (sobrescreve FK/heurística)."""
    if erp_schema == "okr":
        return "metricas"
    if any(m in erp_table or m in bronze for m in FEEDBACK_MARKERS):
        return "avaliacao"
    if any(m in erp_table or m in bronze for m in PDI_MARKERS):
        return "pdi"
    if any(m in erp_table or m in bronze for m in ESTRATEGIA_MARKERS):
        return "metricas"
    if erp_table in ACAO_CORE_TABLES:
        return "acao"
    return None


def _parse_bronze_name(name: str) -> tuple[str, str]:
    if "__" not in name:
        return ("cdc", name)
    schema, table = name.split("__", 1)
    return (schema, table)


def _parse_row_count(description: str | None) -> int:
    if not description:
        return 0
    m = re.search(r"~([\d,]+)", description)
    return int(m.group(1).replace(",", "")) if m else 0


def load_bronze_tables() -> list[dict[str, Any]]:
    data = yaml.safe_load(BRONZE_SOURCES.read_text(encoding="utf-8"))
    tables: list[dict[str, Any]] = []
    for t in data["sources"][0]["tables"]:
        name = t["name"]
        schema, table = _parse_bronze_name(name)
        tables.append(
            {
                "bronze": name,
                "erp_schema": schema,
                "erp_table": table,
                "row_count": _parse_row_count(t.get("description")),
            }
        )
    return tables


def load_silver_index() -> dict[str, dict[str, Any]]:
    data = yaml.safe_load(SILVER_DOMAINS.read_text(encoding="utf-8"))
    index: dict[str, dict[str, Any]] = {}
    for domain in data.get("domains", []):
        for ent in domain.get("entities", []):
            index[ent["bronze"]] = {
                "domain": domain["id"],
                "silver_table": ent["silver_table"],
                "status": ent.get("status", "planned"),
                "wave": ent.get("wave"),
            }
    return index


def load_schema_columns() -> dict[str, list[str]]:
    if not SCHEMA_REF.exists():
        return {}
    data = json.loads(SCHEMA_REF.read_text(encoding="utf-8"))
    out: dict[str, list[str]] = {}
    for t in data.get("tables", []):
        key = f"{t['schema']}.{t['table']}"
        out[key] = [c["name"] for c in t.get("columns", [])]
    return out


def load_fk_edges() -> tuple[list[dict[str, Any]], dict[str, list[dict[str, Any]]]]:
    if not FK_GRAPH.exists():
        return [], {}
    data = json.loads(FK_GRAPH.read_text(encoding="utf-8"))
    edges = data.get("edges", [])
    by_parent: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for e in edges:
        by_parent[e["from_bronze"]].append(e)
    return edges, by_parent


def _match_exclude(bronze: str, erp_table: str) -> tuple[bool, str, str]:
    for bucket, reason, patterns in EXCLUDE_BUCKETS:
        for pat in patterns:
            if pat.endswith("__") and bronze.startswith(pat):
                return True, bucket, reason
            if bronze.startswith(f"dbo__{pat}") or erp_table.startswith(pat):
                return True, bucket, reason
            if pat in bronze or pat in erp_table:
                return True, bucket, reason
    return False, "", ""


def _match_domain_rules(bronze: str, erp_schema: str, erp_table: str) -> tuple[str, str] | None:
    if erp_schema == "competences":
        return "avaliacao", "prefix"
    if erp_schema == "okr":
        return "metricas", "prefix"
    for domain, patterns in DOMAIN_RULES:
        for pat in patterns:
            if pat.endswith("__") and bronze.startswith(pat):
                return domain, "prefix"
            if erp_table.startswith(pat) or pat in erp_table:
                return domain, "prefix"
    return None


def _domain_from_fk(
    bronze: str,
    fk_by_parent: dict[str, list[dict[str, Any]]],
) -> tuple[str, list[str], str] | None:
    edges = fk_by_parent.get(bronze, [])
    if not edges:
        return None
    domain_votes: dict[str, int] = defaultdict(int)
    refs: list[str] = []
    for e in edges:
        ref_key = e["to"]
        refs.append(ref_key)
        dom = HUB_DOMAINS.get(ref_key)
        if dom:
            domain_votes[dom] += 1
    if not domain_votes:
        return None
    best = max(domain_votes, key=lambda d: domain_votes[d])
    return best, refs, "fk"


def _domain_from_columns(
    erp_key: str,
    columns: list[str],
) -> tuple[str, list[str], str] | None:
    hubs: list[str] = []
    domain_votes: dict[str, int] = defaultdict(int)
    for col in columns:
        hub = INFERRED_HUBS.get(col)
        if hub:
            hubs.append(f"{col}->{hub}")
            dom = HUB_DOMAINS.get(hub)
            if dom:
                domain_votes[dom] += 1
    if not domain_votes:
        return None
    best = max(domain_votes, key=lambda d: domain_votes[d])
    return best, hubs, "inferred"


def classify_table(
    entry: dict[str, Any],
    silver_index: dict[str, dict[str, Any]],
    schema_cols: dict[str, list[str]],
    fk_by_parent: dict[str, list[dict[str, Any]]],
) -> dict[str, Any]:
    bronze = entry["bronze"]
    erp_schema = entry["erp_schema"]
    erp_table = entry["erp_table"]
    erp_key = f"{erp_schema}.{erp_table}" if erp_schema != "cdc" else f"cdc.{erp_table}"

    excluded, exclude_bucket, exclude_reason = _match_exclude(bronze, erp_table)
    if excluded:
        return {
            **entry,
            "erp_key": erp_key,
            "candidate_domain": exclude_bucket,
            "confidence": "exclude",
            "exclude": True,
            "exclude_reason": exclude_reason,
            "silver_status": None,
            "hub_columns": [],
            "referenced_tables": [],
            "classification_method": "exclude_pattern",
        }

    if bronze in silver_index:
        si = silver_index[bronze]
        return {
            **entry,
            "erp_key": erp_key,
            "candidate_domain": si["domain"],
            "confidence": "manual",
            "exclude": False,
            "silver_table": si["silver_table"],
            "silver_status": si["status"],
            "silver_wave": si.get("wave"),
            "hub_columns": [],
            "referenced_tables": [],
            "classification_method": "silver_domains.yaml",
        }

    method = "unclassified"
    confidence = "low"
    candidate = "unclassified"
    hub_columns: list[str] = []
    referenced: list[str] = []

    fk_result = _domain_from_fk(bronze, fk_by_parent)
    if fk_result:
        candidate, referenced, confidence = fk_result
        method = "fk_graph"

    col_result = None
    cols = schema_cols.get(erp_key, [])
    if cols:
        col_result = _domain_from_columns(erp_key, cols)
        if col_result:
            col_domain, hub_columns, _ = col_result
            if method == "fk_graph" and col_domain != candidate:
                candidate = col_domain if len(hub_columns) > len(referenced) else candidate
                confidence = "fk+inferred"
                method = "fk+inferred"
            elif method == "unclassified":
                candidate, confidence, method = col_domain, "inferred", "inferred_columns"

    rule_result = _match_domain_rules(bronze, erp_schema, erp_table)
    if rule_result:
        rule_domain, rule_conf = rule_result
        if method in ("unclassified",) or confidence == "low":
            candidate, confidence, method = rule_domain, rule_conf, "name_pattern"
        elif candidate != rule_domain and confidence != "fk":
            confidence = f"{confidence}+pattern_conflict"
            method = f"{method}+pattern({rule_domain})"

    if candidate == "unclassified":
        candidate, confidence, method = "config", "fallback", "fallback_config"

    workshop = _workshop_domain(erp_schema, erp_table, bronze)
    if workshop:
        candidate = workshop
        confidence = "workshop"
        method = "workshop_approved"

    return {
        **entry,
        "erp_key": erp_key,
        "candidate_domain": candidate,
        "confidence": confidence,
        "exclude": False,
        "silver_status": None,
        "hub_columns": hub_columns,
        "referenced_tables": referenced,
        "classification_method": method,
        "column_count": len(cols),
        "id_columns": [c for c in cols if c.startswith("ID_") or c.endswith("Id")],
    }


def build_summary(classified: list[dict[str, Any]]) -> list[dict[str, Any]]:
    by_domain: dict[str, dict[str, Any]] = defaultdict(
        lambda: {"tables": 0, "rows": 0, "implemented": 0, "excluded": False}
    )
    total_rows = sum(t["row_count"] for t in classified)
    for t in classified:
        dom = t["candidate_domain"]
        by_domain[dom]["tables"] += 1
        by_domain[dom]["rows"] += t["row_count"]
        by_domain[dom]["excluded"] = t.get("exclude", False)
        if t.get("silver_status") == "implemented":
            by_domain[dom]["implemented"] += 1

    rows = []
    for dom in sorted(by_domain, key=lambda d: (-by_domain[d]["tables"], d)):
        info = by_domain[dom]
        rows.append(
            {
                "domain": dom,
                "tables": info["tables"],
                "rows": info["rows"],
                "pct_rows": round(100 * info["rows"] / total_rows, 2) if total_rows else 0,
                "implemented": info["implemented"],
                "excluded": info["excluded"],
            }
        )
    return rows


def build_relationship_graph(
    classified: list[dict[str, Any]],
    fk_edges: list[dict[str, Any]],
) -> dict[str, Any]:
    bronze_set = {t["bronze"] for t in classified}
    domain_by_bronze = {t["bronze"]: t["candidate_domain"] for t in classified}

    nodes = [
        {
            "id": t["bronze"],
            "erp_key": t["erp_key"],
            "domain": t["candidate_domain"],
            "row_count": t["row_count"],
            "silver_status": t.get("silver_status"),
            "exclude": t.get("exclude", False),
        }
        for t in classified
    ]

    edges = []
    for e in fk_edges:
        if e["from_bronze"] not in bronze_set:
            continue
        edges.append(
            {
                **e,
                "from_domain": domain_by_bronze.get(e["from_bronze"]),
                "to_domain": domain_by_bronze.get(e["to_bronze"]),
            }
        )

    cross_domain = [
        e for e in edges
        if e.get("from_domain") and e.get("to_domain")
        and e["from_domain"] != e["to_domain"]
        and e["from_domain"] not in ("excluded", "import", "audit", "logs", "plataforma", "views_stg", "unclassified")
        and e["to_domain"] not in ("excluded", "import", "audit", "logs", "plataforma", "views_stg", "unclassified")
    ]

    return {
        "node_count": len(nodes),
        "edge_count": len(edges),
        "cross_domain_edge_count": len(cross_domain),
        "nodes": nodes,
        "edges": edges,
        "cross_domain_edges_sample": cross_domain[:50],
    }


def run_analysis() -> dict[str, Any]:
    bronze_tables = load_bronze_tables()
    silver_index = load_silver_index()
    schema_cols = load_schema_columns()
    fk_edges, fk_by_parent = load_fk_edges()

    classified = [
        classify_table(t, silver_index, schema_cols, fk_by_parent)
        for t in bronze_tables
    ]
    summary = build_summary(classified)
    graph = build_relationship_graph(classified, fk_edges)

    unclassified = [t for t in classified if t["candidate_domain"] == "unclassified"]
    business_domains = [
        d for d in summary
        if d["domain"] not in ("import", "audit", "logs", "plataforma", "views_stg", "unclassified")
    ]

    payload = {
        "generated_by": "analyze_bronze_domains.py",
        "bronze_table_count": len(classified),
        "reference_schema": "MereoGR-Afya",
        "fk_source": str(FK_GRAPH.relative_to(REPO_ROOT)) if FK_GRAPH.exists() else None,
        "unclassified_count": len(unclassified),
        "business_domain_count": len(business_domains),
        "summary": summary,
        "tables": classified,
    }

    OUT_MAP.parent.mkdir(parents=True, exist_ok=True)
    OUT_MAP.write_text(
        yaml.dump(payload, allow_unicode=True, sort_keys=False, default_flow_style=False),
        encoding="utf-8",
    )
    OUT_GRAPH.write_text(json.dumps(graph, indent=2), encoding="utf-8")

    with OUT_SUMMARY.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=["domain", "tables", "rows", "pct_rows", "implemented", "excluded"],
        )
        writer.writeheader()
        writer.writerows(summary)

    return {
        "tables": len(classified),
        "unclassified": len(unclassified),
        "summary": summary,
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Classifica bronze em domínios candidatos")
    parser.add_argument("--dry-run", action="store_true", help="Só imprime resumo")
    args = parser.parse_args(argv)

    result = run_analysis()
    print(f"Tabelas classificadas: {result['tables']}")
    print(f"Não classificadas: {result['unclassified']}")
    print("\nResumo por domínio:")
    for row in result["summary"]:
        print(
            f"  {row['domain']:15s}  tables={row['tables']:4d}  "
            f"rows={row['rows']:>12,}  ({row['pct_rows']:5.1f}%)  "
            f"implemented={row['implemented']}"
        )
    if not args.dry_run:
        print(f"\nEscrito: {OUT_MAP}")
        print(f"Escrito: {OUT_GRAPH}")
        print(f"Escrito: {OUT_SUMMARY}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
