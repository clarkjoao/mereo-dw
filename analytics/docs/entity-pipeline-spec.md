# Spec de pipeline por entidade

Documento canônico que amarra catálogo → manifests K8s → Dagster. **Wave 1** usa `colaborador` como exemplo completo do **CDC vivo** (Debezium → Kafka → CH).

**ERP completo no CH para modelagem dbt:** ver **[`erp-raw-full-spec.md`](erp-raw-full-spec.md)** — trilha bulk `output/backups` → `raw.{schema}__{table}` (não substitui este template CDC).

Contrato YAML: `analytics/catalog/entities/{entity}.yaml`  
Piloto: `analytics/catalog/pilot.yaml`

---

## Template (preencher por entidade)

### Source SQL Server

| Campo | Descrição |
|-------|-----------|
| `database` | `MereoGR-{Tenant}` (um connector Debezium por banco) |
| `schema.table` | Tabela fonte com PK |
| `pk_columns` | Colunas PK no payload CDC |
| CDC | `is_cdc_enabled` no DB + `sys.sp_cdc_enable_table` na tabela |

### Debezium

| Campo | Descrição |
|-------|-----------|
| `table.include.list` | `{db}.dbo.{TABLE}` |
| `topic.prefix` | Por tenant / connector |
| Transforms | unwrap, reroute, `tenant_slug` no payload |

### Kafka

| Campo | Descrição |
|-------|-----------|
| Tópico | `raw.{entity}` |
| Formato | JSON (Debezium unwrap) |
| Tombstones | Política do connector (retain/delete conforme POC) |

### ClickHouse raw (ingestão automática)

| Artefato | Naming |
|----------|--------|
| Kafka Engine | `raw.{entity}_kafka` |
| `kafka_group_name` | `ch-raw-{entity}-v2` (nunca reutilizar entre entidades) |
| Destino RMT | `raw.{entity}` |
| MV | `raw.{entity}_mv` — UPPER → snake_case, `_ts_ms`, `_deleted` |

DDL: `k8s/mereo/07-clickhouse-init-sql.yaml`

### ClickHouse pipeline (ops)

| Tabela | Quem preenche |
|--------|----------------|
| `pipeline.ingestion_snapshots` | Job Dagster `raw_ingestion_observability` (volume por tenant + total) |
| `pipeline.entity_watermarks` | Mesmo job (+ legado CronJob opcional) |
| `pipeline.consumer_lag_snapshots` | Mesmo job |
| `pipeline.freshness_events` | Sensor `raw_freshness_sensor` quando bloqueia dbt |

### Dagster

| Papel | Componente |
|-------|------------|
| Volume / lag / watermark | Job `raw_ingestion_observability`, schedule `*/5 * * * *` (RUNNING) |
| Gating dbt | Sensor `raw_freshness_sensor` (120s) → job `dbt_build` |
| Env | `MEREPO_PILOT_ENTITY`, `CH_RAW_CONSUMER_GROUP`, `CH_HOST`, `FRESHNESS_MAX_LAG` |

Código: `analytics/dagster/mereo_analytics/definitions.py`

### Offsets

Ver `analytics/docs/offset-registry.md` — donos de offset Kafka/CH/Debezium.

### dbt (fase 2)

| Camada | Model |
|--------|-------|
| staging | `stg_{entity}` |
| gold | conforme contrato |

Não implementar gold neste doc; só após raw estável.

---

## Wave 1 — `colaborador` (exemplo preenchido)

### Source SQL Server

| Item | Valor |
|------|-------|
| Bancos piloto | `MereoGR-Afya`, `MereoGR-Staging`, `MereoGR-Allos` |
| Tabela | `dbo.COLABORADOR` |
| PK | `ID` |
| CDC | Habilitar DB + tabela após seed (`restore-local --enable-cdc`) |
| Init mínimo sim | `k8s/mereo-sqlserver/03-configmap-init-sql.yaml` |

### Debezium

| Tenant | Connector |
|--------|-----------|
| afya | `mereogr-afya-colaborador` |
| staging | `mereogr-staging-colaborador` |
| allos | `mereogr-allos-colaborador` |

Manifest: `k8s/mereo/05-kafka-connectors.yaml` — `table.include.list` = `*.dbo.COLABORADOR`.

### Kafka

| Item | Valor |
|------|-------|
| Tópico | `raw.colaborador` |
| Partições | Conforme cluster Strimzi |

### ClickHouse raw

| Item | Valor |
|------|-------|
| Kafka Engine | `raw.colaborador_kafka` |
| Consumer group | `ch-raw-colaborador-v2` |
| RMT | `raw.colaborador` |
| MV | `raw.colaborador_mv` |
| Lag query | `system.kafka_consumers WHERE table = 'colaborador_kafka'` |

### ClickHouse pipeline

| Item | Valor |
|------|-------|
| Snapshots | `entity = 'colaborador'`, `tenant_slug` vazio = total; demais = por tenant |
| Watermark | `max(_ts_ms)` em `raw.colaborador` |

### Dagster ↔ CH (matriz wave 1)

| Papel | Identificador |
|-------|----------------|
| Consumo Kafka no CH | `raw.colaborador_kafka` |
| Consumer group | `ch-raw-colaborador-v2` |
| Tabela raw | `raw.colaborador` |
| Lag (sensor + observability) | `WHERE table = 'colaborador_kafka'` |
| Observability | `raw_ingestion_observability` / schedule 5 min |
| Gating | `raw_freshness_sensor` → `dbt_build` se lag ≤ `FRESHNESS_MAX_LAG` e watermark > 0 |

### dbt (fase 2)

| Camada | Model |
|--------|-------|
| staging | `stg_colaborador` |
| gold | `colaborador_by_grupo` |

**Nota:** `COLABORADOR` não tem `ID_AREA` — não usar `colaborador_by_area`.

### Seed sim (mínimo)

```bash
kubectl port-forward -n mereo-sqlserver svc/mssql 11434:1433
MSSQL_HOST=127.0.0.1 MSSQL_PORT=11434 uv run python -m mereo_tools restore-local \
  --databases MereoGR-Staging,MereoGR-Allos,MereoGR-Afya \
  --tables dbo.COLABORADOR --skip-schema --skip-drop --enable-cdc
```

Backup: `output/backups/{database}/data/dbo__COLABORADOR.jsonl.gz`

### Aceite

Checklist: `analytics/docs/wave-1-acceptance.md`  
Script: `./analytics/scripts/validate-pipeline.sh`
