# Research: investigação raw ClickHouse — feature 001-snowflake-dbml-model

**Data**: 2026-06-12  
**Spec**: [spec.md](spec.md)

## Objetivo

Documentar o estado atual da camada **RAW** no ClickHouse e as fontes commitadas que alimentam o DBML, antes de definir colunas STAGING/EDW.

## Inventário ClickHouse `raw` (2026-06-12)

Profiling via `kubectl exec` no pod `chi-mereo-clickhouse-main-0-0-0` (namespace `mereo`):

| Métrica | Valor |
|---------|-------|
| Tabelas MergeTree em `raw` | **486** |
| Tabelas com `total_rows > 0` | **486** (100%) |
| Soma `total_rows` (MergeTree) | **~11.666.571** |
| Objetos CDC piloto | `colaborador`, `colaborador_kafka`, `colaborador_mv` |
| Tamanho aproximado | ~8 GB (`system.tables.total_bytes`) |

**Interpretação**: O bronze bulk do contrato ERP está materializado no CH. A silver 1:1 (373 views em 9 databases) lê essas tabelas via `source('bronze', 'dbo__*')` — será **substituída** pelo modelo RAW→STAGING→EDW, não estendida.

### Piloto CDC `raw.colaborador`

| tenant_slug | rows (snapshot anterior) |
|-------------|--------------------------|
| afya | 1.010 |
| allos | 1.005 |
| staging | 829 |

Validação contínua: `./analytics/scripts/validate-pipeline.sh` (7/7 checks).

## Queries reutilizáveis

### Inventário raw

```sql
SELECT name, engine, total_rows, formatReadableSize(total_bytes) AS size
FROM system.tables
WHERE database = 'raw' AND engine LIKE '%MergeTree%'
ORDER BY total_rows DESC
LIMIT 50;
```

### Cobertura bronze vs contrato 616

```sql
-- Tabelas raw sem classificação (diagnóstico)
SELECT name FROM system.tables
WHERE database = 'raw' AND name NOT LIKE 'colaborador%'
ORDER BY name;
```

Comparar com `analytics/catalog/client_table_classification.csv` coluna `bronze`.

### Multi-tenant em tabela ERP

```sql
SELECT tenant_slug, count() AS n
FROM raw.dbo__COLABORADOR
GROUP BY tenant_slug
ORDER BY tenant_slug;
```

### Top tabelas por volume (amostra investigação)

| bronze | rows (aprox.) | Domínio |
|--------|---------------|---------|
| `dbo__ValorMatriz` | 5.894.028 | metricas |
| `dbo__ParticipantExtract` | 99.300 | remuneracao |
| `dbo__META` | 89.486 | metricas |
| `dbo__VALOR_META` | 101.607 | metricas |
| `competences__CALC_RESULTADO_AVALIADOR_COMPETENCIA` | 101.729 | avaliacao |
| `dbo__COLABORADOR` | multi-tenant | colaborador |

## Fontes commitadas (fonte de verdade)

| Artefato | Uso no DBML |
|----------|-------------|
| [client_table_classification.csv](../../analytics/catalog/client_table_classification.csv) | Papel DIM/FACT/EXCLUDE/DEFER por `erp_key` |
| [bronze_relationship_graph.json](../../analytics/catalog/bronze_relationship_graph.json) | 709 arestas FK → `-- @fk:` |
| [dim_fact_candidates.yaml](../../analytics/catalog/dim_fact_candidates.yaml) | Top 20 hubs, PK, silver legado (contexto) |
| [silver_domains.yaml](../../analytics/catalog/silver_domains.yaml) | Mapeamento domínio CH legado → domínio negócio |
| [client-dimensional-discovery-spec.md](../../analytics/docs/client-dimensional-discovery-spec.md) | Grains G1/G2 propostos (referência) |
| [staging-database-role-spec.md](../../analytics/docs/staging-database-role-spec.md) | Staging ERP −21 tbl vs Afya |

## Classificação dimensional (resumo)

| Papel | Qtd | Tratamento DBML |
|-------|-----|-----------------|
| DIM | 129 | `staging.stg_*` → `edw.dim_*` |
| FACT | 59 | `staging.stg_*` → `edw.fact_*` |
| BRIDGE | 10 | `edw.bridge_*` |
| REF | 11 | `edw.ref_*` |
| EXCLUDE | 168 | só `raw.*`, `@group: exclude` |
| DEFER | 239 | `raw.*` + stub `edw.defer_*` |

**População clientes** (Spec 1): 234 tabelas com dados em Afya **e** Allos; 239 DEFER sem dados no piloto.

## Grafo FK — hubs cross-domain

Arestas mais frequentes ([silver-domain-discovery-spec.md](../../analytics/docs/silver-domain-discovery-spec.md)):

| FKs | De → Para |
|-----|-----------|
| 23 | colaborador → metricas |
| 23 | avaliacao → metricas |
| 40 | colaborador ↔ avaliacao (combinado) |

**Implicação EDW**: Marts (`mart.*`) cruzam domínios apenas após dims/fatos conformed em `edw` — não via joins em `raw`.

## Silver legado (contexto apenas)

| Silver atual | Papel | Substituído por |
|--------------|-------|-----------------|
| `colaborador.pessoa` | view 1:1 `dbo__COLABORADOR` | `staging.stg_colaborador_colaborador` → `edw.dim_employee` |
| `metricas.meta` | view 1:1 | `staging.stg_metricas_meta` → `edw.dim_goal` |
| `gold.dim_*` / `gold.fact_*` | piloto G1–G2 | realocado para `edw.*` no modelo lógico |

**Não reutilizar** aliases quebrados do batch silver (`i_d__m_e_t_a` etc.) — mapear colunas ERP reais de `raw.dbo__*`.

## Lacunas de investigação (fase futura)

- Profiling nullability/PK por tabela DEFER quando tenant novo popular dados
- Amostragem `ValorMatriz` (5.9M rows staging-only) para grain `fact_matrix_cell`
- Validação FK física CH vs grafo lógico (CH não enforce FK)

## Port-forward para profiling local

```bash
./analytics/scripts/port-forward-ch.sh   # localhost:18123
export CH_DBT_PASSWORD="$(cat analytics/.ch-dbt-password)"
```
