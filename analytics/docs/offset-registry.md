# Offset registry — POC Mereo

| Camada | Onde vive o offset | Consumer group / identificador |
|--------|-------------------|--------------------------------|
| Debezium | Tópico `mereo-connect-offsets` | Por connector (`mereogr-*-colaborador`) |
| ClickHouse Kafka Engine | `system.kafka_consumers` | `ch-raw-colaborador` (único, estável) |
| Dagster / dbt | Nenhum offset Kafka | Sensor freshness apenas |
| Wasabi (futuro) | Connect separado | `wasabi-archive-raw-colaborador` |

**Regra:** nunca compartilhar consumer group entre CH e outros sinks.

**Recovery Tier 1:** replay Kafka → CH (reset offset ou novo `kafka_group_name` + dedup RMT).

**Recovery Tier 3:** Wasabi → `INSERT INTO raw.* FROM s3()` — ver `docs/wasabi-dr.md`.
