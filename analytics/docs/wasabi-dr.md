# Wasabi DR — Tier 3 (futuro)

## Quando usar

Somente se **Tier 1 (replay Kafka) não for mais possível** — CH perdeu dados e Kafka já expirou retenção.

Meta operacional: **nunca acionar** graças a retenção Kafka (7d+) + alertas Grafana.

## Pré-requisitos (quando implementar)

- Kafka Connect S3 Sink → Wasabi, consumer group **separado** de `ch-raw-*`
- Manifest sidecar JSON por partição: `entity`, `topic`, offsets, `min_ts_ms`, `max_ts_ms`
- Job Dagster `backfill_from_wasabi` documentado e testado em drill

## Procedimento break-glass

1. Confirmar Kafka sem mensagens na janela
2. Pausar connectors + bloquear sensor Dagster
3. `INSERT INTO raw.colaborador FROM s3(...)` ou republish Kafka
4. Validar `pipeline.entity_watermarks`; retomar pipeline

Ver também `docs/offset-registry.md`.
