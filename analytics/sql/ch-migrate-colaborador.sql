-- Migração POC: alinhar raw.colaborador ao contrato real (dbo.COLABORADOR).
-- Rodar no ClickHouse se a tabela foi criada com id_area (versão anterior).

DROP TABLE IF EXISTS raw.colaborador_mv;
DROP TABLE IF EXISTS raw.colaborador_kafka;

CREATE TABLE IF NOT EXISTS raw.colaborador_new (
    id Int64,
    tenant_slug String,
    nome Nullable(String),
    email Nullable(String),
    id_grupo_usuario Nullable(Int64),
    ativo Nullable(UInt8),
    _ts_ms UInt64,
    _deleted UInt8
)
ENGINE = ReplacingMergeTree(_ts_ms, _deleted)
ORDER BY (tenant_slug, id);

-- Se raw.colaborador antiga existir vazia ou em POC, substituir:
DROP TABLE IF EXISTS raw.colaborador;
RENAME TABLE raw.colaborador_new TO raw.colaborador;

-- Recriar Kafka engine + MV (ver init-schema-configmap.yaml)
