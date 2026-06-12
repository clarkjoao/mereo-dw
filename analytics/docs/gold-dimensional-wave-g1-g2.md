# Gold dimensional — ondas G1 + G2 (implementado)

**Pré-requisito:** [client-dimensional-discovery-spec.md](client-dimensional-discovery-spec.md), ADR-016.

## G1 — Dimensões (`gold.dim_*` views)

| Model dbt | Snowflake | Fonte silver |
|-----------|-----------|--------------|
| `dim_employee` | DIM_EMPLOYEE | `colaborador.pessoa` |
| `dim_org_area` | DIM_ORG_AREA | `organizacao.area` |
| `dim_org_job` | DIM_ORG_JOB | `organizacao.cargo` |
| `dim_goal` | DIM_GOAL | `metricas.meta` |
| `dim_kpi` | DIM_KPI | `metricas.indicador` |
| `dim_time_gestao` | DIM_TIME_GESTAO | `metricas.periodo_gestao` |
| `dim_time_apuracao` | DIM_TIME_APURACAO | `metricas.periodo_apuracao` |
| `dim_eval_cycle` | DIM_EVAL_CYCLE | `avaliacao.avaliacao_ciclo` |
| `dim_competency` | DIM_COMPETENCY | `avaliacao.competencia` |

Filtro: `production_tenant_slugs` = `['afya','allos']` (macro `client_tenants_only`).

## G2 — Fatos (`gold.fact_*` tables)

| Model dbt | Grain | Fonte |
|-----------|-------|-------|
| `fact_goal_value` | tenant × meta × dt_ref | `valor_meta` ⋈ `meta` |
| `fact_goal_score` | tenant × meta × nota | `nota_meta` |
| `fact_rv` | tenant × id | `participante_rv` |
| `fact_eval_score` | tenant × id | `calc_resultado_avaliador_competencia` |
| `fact_feedback` | tenant × id | `feedback_continuo` |
| `fact_action` | tenant × id | `acao.acao` |

## Build

```bash
cd analytics/dbt
dbt build --select 'gold.dim.* gold.fact.*'
./analytics/scripts/dbt-via-dagster.sh  # job completo
```

## G3

Ver [gold-dimensional-wave-g3.md](gold-dimensional-wave-g3.md).
