# Observabilidade pipeline — Grafana/Prometheus

## Já implementado no cluster

- **CronJob** `pipeline-lag-snapshot` (namespace `mereo-clickhouse`, cada 5 min):
  - `pipeline.entity_watermarks` — max `_ts_ms` em `raw.colaborador`
  - `pipeline.consumer_lag_snapshots` — lag de `ch-raw-colaborador`

- **Dagster sensor** `raw_freshness_sensor` — grava em `pipeline.freshness_events` quando bloqueia dbt

## Alertas sugeridos (Grafana `monitoring`)

| Alerta | Query / condição |
|--------|------------------|
| CH Kafka lag alto | `pipeline.consumer_lag_snapshots.lag > 1000` por 10 min |
| Watermark parado | `entity_watermarks.ch_max_ts_ms` sem avanço por 30 min |
| Debezium FAILED | `kubectl get kafkaconnector -n mereo-kafka` state != RUNNING |

## Dashboard panels

1. Lag por consumer group (`ch-raw-colaborador`)
2. `max(_ts_ms)` em `raw.colaborador` vs tempo
3. Contagem `pipeline.freshness_events` onde `dbt_blocked=1`
4. Status connectors Debezium (via kube-state-metrics ou script)

Referência offsets: `docs/offset-registry.md`
