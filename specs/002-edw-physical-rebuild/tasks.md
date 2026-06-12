# Tasks: EDW Physical Rebuild

**Gate de entrada**: spec 001 T112 (modelo DBML aprovado no LocalDrawDB)

Contrato de resumabilidade: igual à spec 001 — inputs commitados, outputs em disco,
verificação de 1 linha, geradores idempotentes. Para retomar: rode as verificações
de cima para baixo; a primeira falha é a task atual.

## Generate

- [x] T201 spec.md + plan.md + tasks.md desta spec — arquivos existem
- [ ] T202 Macro `analytics/dbt/macros/surrogate_key.sql` (`cityHash64` → Int64) + modelo probe — `dbt compile` ok
- [ ] T203 `analytics/catalog/generate_edw_dbt_models.py`: emitter staging (209 views + `_staging__models.yml`) — `ls analytics/dbt/models/staging/stg_*.sql | wc -l` == 209
- [ ] T204 Emitter edw dim/ref/bridge — contagens por prefixo batem com a matriz (dim 128+9 curados=... derivar em runtime)
- [ ] T205 Emitter edw fact com FKs hasheadas (mesmos naturais da dim alvo) — fact_ == 61
- [ ] T206 Hubs curados (16 edw + 3 mart) gerados dos blocos do spine com `-- curated` — `grep -rl 'curated' analytics/dbt/models/edw analytics/dbt/models/mart | wc -l` == 19
- [ ] T207 `dbt_project.yml` (árvores staging/edw/mart, tags, engines) + `_edw__models.yml` (testes unique/not_null) — `dbt parse` exit 0

## Checkpoint

- [ ] T208 **Commit**: árvore nova completa parseando, antiga ainda presente — `dbt ls` lista os modelos novos

## Delete

- [ ] T209 Deletar legados rastreados (`models/gold/*`, `models/staging/stg_colaborador.sql` + ymls) — `dbt parse` limpo sem refs quebradas
- [ ] T210 `k8s/mereo/07-clickhouse-init-sql.yaml`: DBs raw/staging/edw/mart/pipeline + DDL `pipeline.schema_drift_log` — `kubectl diff` só muda lista de DBs
- [ ] T211 **Gateado (destrutivo, confirmar com usuário)**: `analytics/scripts/rebuild-edw-dbs.sh` — verifica bronze vazio, DROP 9 domínios+silver+gold, CREATE staging/edw/mart — `SHOW DATABASES` == raw,staging,edw,mart,pipeline

## Build

- [ ] T212 `dbt build --select tag:staging` (afya/allos) — exit 0 + spot counts
- [ ] T213 `dbt build --select tag:edw` — exit 0 incl. testes unique nos `*_key`
- [ ] T214 `dbt build --select tag:mart` — exit 0

## Validate

- [ ] T215 `analytics/scripts/check-staging-parity.sh` (raw↔staging) + `validate_dbml_full.py --against-dbt` (shape DBML↔dbt) — ambos exit 0
- [ ] T216 `analytics/scripts/check-tenant-drift.py` rodado p/ afya/allos/staging; mismatches no `pipeline.schema_drift_log` — tabela populada com drifts conhecidos (ex.: Staging sem 21 tabelas)
- [ ] T217 `validate-pipeline.sh` atualizado (gold→edw) + Dagster re-parse + commit final — pipeline PASS
