# Feature Spec: EDW Physical Rebuild — staging/edw/mart em dbt + ClickHouse

**Branch**: `001-snowflake-dbml-model` (continua) | **Depende de**: spec 001 gate T112 (modelo DBML aprovado)

## Resumo

Implementação física do modelo snowflake aprovado na spec 001: deleta os resquícios
da era silver/gold (artefatos não-validados de agente antigo), cria os databases
`staging`/`edw`/`mart` no ClickHouse e gera os modelos dbt a partir dos MESMOS
artefatos que geraram o DBML (`dbml_model.py` + matriz + schema Afya + grafo FK),
garantindo que modelo documentado e modelo físico nunca divirjam.

## Requisitos funcionais

- **FR-201**: Deletar modelos dbt legados rastreados (`models/gold/_gold__models.yml`,
  `models/gold/colaborador_by_grupo.sql`, `models/staging/stg_colaborador.sql` + yml)
  e dropar no ClickHouse os 9 DBs de domínio + `silver` + `gold` (+ `bronze` se vazio).
  Manter `raw` e `pipeline`.
- **FR-202**: Gerar modelos dbt via `analytics/catalog/generate_edw_dbt_models.py`
  (reusa `dbml_model.py`): staging 209 views, edw 207 tabelas MergeTree
  (dim 128+ref 11+brg 8+bridge 1+fact 59... contagens derivadas da matriz por prefixo,
  fact_=61), mart 3 views. DEFER (239) e EXCLUDE (168) NÃO são materializados.
- **FR-203**: Surrogate keys por hash determinístico — macro dbt
  `surrogate_key(cols)` = `cityHash64(tenant_slug, naturais)` cast Int64.
  Naturais sempre co-armazenadas. Teste `unique` em todo `*_key` de dim.
- **FR-204**: EDW materializado como tabela MergeTree (`ORDER BY` = grain) — views
  encadeadas sobre ReplacingMergeTree exigiriam FINAL em toda query. Staging e mart
  como views.
- **FR-205**: Quarentena de drift: tabela `pipeline.schema_drift_log` (MergeTree) +
  `analytics/scripts/check-tenant-drift.py` comparando schema JSON de tenant vs
  contrato de 616 tabelas; mismatches logados, nunca descartados em silêncio.
- **FR-206**: `k8s/mereo/07-clickhouse-init-sql.yaml` cria raw/staging/edw/mart/pipeline.
- **FR-207**: Hubs curados (16 edw + 3 mart) gerados a partir dos blocos do spine com
  marcador `-- curated`, protegidos por drift-check (`validate_dbml_full.py --against-dbt`).
- **FR-208**: Validação: `dbt build` por camada contra afya/allos; paridade de contagens
  raw↔staging; `validate-pipeline.sh` verde.

## Fora de escopo

- Mudanças na ingestão raw (Kafka/CDC) — intocada
- Marts além dos 3 modelados
- Materialização de DEFER/EXCLUDE
- SCD2 (SCD1 conforme spec 001)

## Critérios de sucesso

1. `dbt parse` e `dbt build` exit 0 nas 3 camadas contra afya/allos
2. `SHOW DATABASES` == raw, staging, edw, mart, pipeline (+ system)
3. Toda dim com teste `unique` no surrogate passando
4. Contagem staging == contagem raw (`_deleted=0`, tenants de produção)
5. Drift-check DBML↔dbt sem divergência de shape
