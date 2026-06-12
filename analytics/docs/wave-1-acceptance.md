# Aceite wave 1 — pipeline raw `colaborador`

Checklist alinhado a `./analytics/scripts/validate-pipeline.sh` e observabilidade Dagster. **Gold/dbt é fase 2** (item 9).

Pré-requisitos:

```bash
export KUBECONFIG="$HOME/.kube/mereo-cdc.yaml"
# opcional CH local: ./analytics/scripts/port-forward-ch.sh
```

---

## Infra e fonte

- [ ] **1. CDC SQL Server** — 3 bancos piloto com `is_cdc_enabled = 1`  
  _Espelha validate §1/7_

- [ ] **2. Debezium** — ≥3 `KafkaConnector` Ready (`mereogr-*-colaborador`)  
  _Espelha validate §2/7_

- [ ] **Seed sim** — `dbo.COLABORADOR` nos 3 bancos via `restore-local --tables dbo.COLABORADOR --skip-schema --skip-drop --enable-cdc`  
  _Não exigido no script; pré-condição dos checks seguintes_

---

## Kafka → ClickHouse raw

- [ ] **3. Kafka** — mensagens em `raw.colaborador` (offsets > 0 ou inferido via CH)  
  _Espelha validate §3/7_

- [ ] **4. CH raw** — `raw.colaborador` com `rows > 0` e `uniqExact(tenant_slug) >= 3`  
  _Espelha validate §4/7_

- [ ] **5. Consumer CH** — lag de `colaborador_kafka` aceitável (`≤ FRESHNESS_MAX_LAG`, default 100)  
  _Espelha validate §5/7_

---

## Observabilidade pipeline

- [ ] **6. Ingestion snapshots** — linhas recentes em `pipeline.ingestion_snapshots` para `entity = 'colaborador'` e `row_count > 0`:

```sql
SELECT entity, tenant_slug, row_count, kafka_lag, snapshot_at
FROM pipeline.ingestion_snapshots
WHERE entity = 'colaborador'
ORDER BY snapshot_at DESC
LIMIT 10;
```

- [ ] **7. Dagster observability** — job `raw_ingestion_observability` com último run SUCCESS; metadata na UI com `total_rows`, `by_tenant`, `kafka_lag`, `watermark_ts_ms`

- [ ] **8. Dagster freshness** — sensor `raw_freshness_sensor` RUNNING (gating; não exige `dbt_build` nesta fase)

---

## Fase 2 (fora do aceite wave 1 raw)

- [ ] **9. Gold + dbt** — `gold.colaborador_by_grupo` populada; `dbt_build` disparado pelo sensor após raw fresh  
  _Espelha validate §6/7 — adiar até branch/modelos gold_

---

## Comando único de validação

```bash
./analytics/scripts/validate-pipeline.sh
```

O script cobre **7 checks** (1–5 raw, 6 `pipeline.ingestion_snapshots`, 7 Dagster). Gold não é gate neste script (item 9 / fase 2).

**Pronto wave 1 (raw):** `./analytics/scripts/validate-pipeline.sh` com **7 OK**; item 9 (gold) opcional.

Comandos úteis:

```bash
kubectl port-forward -n mereo svc/dagster-webserver 3000:80
./analytics/scripts/latency-track.sh   # após INSERT de teste no sim
./k8s/sync-configmaps.sh             # após editar definitions.py
```
