# Avaliação Flink router — POC Mereo

## Veredicto (Fase 1)

**Não implementar Flink** no caminho feliz desta POC.

Debezium + SMT (`ExtractNewRecordState`, `ByLogicalTableRouter`, `InsertField` tenant_slug)
consolidam `dbo.COLABORADOR` de múltiplos tenants no tópico único `raw.colaborador`.

## Quando reavaliar

Introduzir **1 job Flink router** somente se:

1. Connect não conseguir rotear tópicos por entidade com qualidade (DLQ alto, schema drift)
2. Volume de connectors por tenant inviabilizar ops antes de template GitOps
3. Necessidade de transformação **antes** do CH que SMT não cobre (não joins analíticos)

## Critério de decisão

| Sinal | Ação |
|-------|------|
| Connectors RUNNING, tópico `raw.colaborador` com lag OK | Manter CH Kafka Engine |
| Muitos tópicos por tenant sem consolidação | Flink router ou melhorar SMT |
| Flink virando segundo dbt | Proibido — joins ficam no dbt |

Referência IaC demo: https://github.com/eficifyltda/data-pipeline.git (namespace `cdc-flink` — legado desligado).
