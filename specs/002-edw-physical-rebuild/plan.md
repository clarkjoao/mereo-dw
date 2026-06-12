# Implementation Plan: EDW Physical Rebuild

**Spec**: [spec.md](spec.md) | **Tasks**: [tasks.md](tasks.md) | **Gate de entrada**: spec 001 T112

## Fases

```
Generate (T202–T207) → Checkpoint commit (T208) → Delete (T209–T211) → Build (T212–T214) → Validate (T215–T217)
```

A ordem é deliberada: a árvore dbt nova é gerada e commitada ANTES de deletar a
antiga (T208 é o gate de segurança); o único passo destrutivo no cluster (T211)
é isolado, scriptado e logado.

## Decisões

| Decisão | Escolha | Motivo |
|---|---|---|
| Surrogate key | hash `cityHash64(tenant_slug, naturais)` → Int64 | CH não tem autoincrement; estável entre rebuilds; FK computável no fact sem join; colisão guardada por teste unique |
| Materialização staging | view | pass-through (rename+filtro), sem custo |
| Materialização edw | table MergeTree, ORDER BY = grain | camada consultada por BI/MCP; evita FINAL obrigatório de views sobre ReplacingMergeTree |
| Materialização mart | view | só 3, sobre edw já materializado |
| Geração | `generate_edw_dbt_models.py` reusa `dbml_model.py` | DBML e dbt nunca divergem em shape |
| Legado | gold/silver NUNCA são referência | artefatos não-validados de agente antigo |

## Estrutura dbt alvo

```
analytics/dbt/models/
├── bronze/_bronze__sources.yml        # mantido (sources raw.*)
├── staging/stg_{domain}_{table}.sql   # 209 views: snake renames + casts,
│                                      #   where _deleted=0 + client_tenants_only()
├── edw/dim/ ref/ bridge/ fact/        # tabelas MergeTree, surrogate_key macro
└── mart/                              # 3 views
```

`dbt_project.yml`: árvores staging (+schema staging, view), edw (+schema edw,
table + engine MergeTree), mart (+schema mart, view). Tags por camada para seleção.
Dagster `definitions.py` é manifest-driven: re-parse + ajustar seleções de tag
(`wave_g*` → `staging|edw|mart`).

## ClickHouse

- `analytics/scripts/rebuild-edw-dbs.sh`: verifica `bronze` vazio; DROP dos 9 DBs
  de domínio + silver + gold (+bronze); CREATE staging/edw/mart. Logado, idempotente.
- `k8s/mereo/07-clickhouse-init-sql.yaml`: lista de DBs → raw/staging/edw/mart/pipeline
  + DDL do `pipeline.schema_drift_log`.

## Quarentena de drift (FR-205)

`analytics/scripts/check-tenant-drift.py` (reusa `dbml_model.py`): compara
`output/groups/mereogr/schema/tables/MereoGR-{Tenant}.json` vs matriz + schema Afya;
insere em `pipeline.schema_drift_log` (tenant_slug, object_type, object_name, reason,
payload, detected_at). Já há 14 tenants commitados para testar (Klabin, Magalu, ...).

## Validação

1. `dbt build --select tag:staging` → `tag:edw` → `tag:mart` (afya/allos)
2. `analytics/scripts/check-staging-parity.sh`: count(raw, _deleted=0, prod tenants) == count(staging)
3. Testes dbt: unique em `*_key`, not_null em tenant_slug
4. `validate_dbml_full.py --against-dbt`: colunas DBML edw == colunas dbt geradas
5. `analytics/scripts/validate-pipeline.sh` (refs gold→edw) verde
