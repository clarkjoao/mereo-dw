# Gold dimensional — onda G3 (marts cross-domain)

**Pré-requisito:** [gold-dimensional-wave-g1-g2.md](gold-dimensional-wave-g1-g2.md), grafo FK em `analytics/catalog/bronze_relationship_graph.json`.

## Objetivo

Views analíticas que cruzam domínios silver via joins documentados no grafo (colaborador ↔ metricas ↔ avaliacao), reutilizando dims/fatos G1/G2. Filtro ADR-016: só tenants `afya` e `allos`.

## Marts (`gold.mart_*` views)

| Model dbt | Domínios cruzados | Grain |
|-----------|-------------------|-------|
| `mart_employee_org` | colaborador × organizacao | tenant × colaborador × area |
| `mart_goal_performance` | colaborador × metricas | tenant × meta × dt_ref |
| `mart_employee_rv_detail` | colaborador × metricas × remuneracao | tenant × participante_rv |
| `mart_employee_eval_score` | colaborador × avaliacao | tenant × resultado × competência |
| `mart_goal_action_tracker` | metricas × acao × colaborador | tenant × ação |
| `mart_employee_feedback` | colaborador × metricas × avaliacao | tenant × feedback |

## Build

```bash
cd analytics/dbt
dbt build --select 'gold.mart.*'
# ou stack completo:
dbt build --select 'gold.dim.* gold.fact.* gold.mart.*'
./k8s/sync-configmaps.sh
./analytics/scripts/dbt-via-dagster.sh
```
