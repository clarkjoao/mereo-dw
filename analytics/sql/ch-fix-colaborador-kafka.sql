DROP TABLE IF EXISTS raw.colaborador_mv;
DROP TABLE IF EXISTS raw.colaborador_kafka;

CREATE TABLE raw.colaborador_kafka (
    `ID` Int64,
    `NOME` Nullable(String),
    `EMAIL` Nullable(String),
    `ID_GRUPO_USUARIO` Nullable(Int64),
    `ATIVO` Nullable(Bool),
    tenant_slug String,
    ts_ms Nullable(UInt64),
    `__ts_ms` Nullable(UInt64),
    __deleted Nullable(String)
)
ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'mereo-kafka-kafka-bootstrap.mereo-kafka:9092',
    kafka_topic_list = 'raw.colaborador',
    kafka_group_name = 'ch-raw-colaborador-v2',
    kafka_format = 'JSONEachRow',
    kafka_num_consumers = 1,
    kafka_skip_broken_messages = 100;

CREATE MATERIALIZED VIEW raw.colaborador_mv
TO raw.colaborador AS
SELECT
    ID AS id,
    tenant_slug,
    NOME AS nome,
    EMAIL AS email,
    ID_GRUPO_USUARIO AS id_grupo_usuario,
    if(ATIVO IS NULL, NULL, toUInt8(ATIVO)) AS ativo,
    coalesce(ts_ms, __ts_ms, toUInt64(0)) AS _ts_ms,
    if(__deleted = 'true', toUInt8(1), toUInt8(0)) AS _deleted
FROM raw.colaborador_kafka
WHERE ID IS NOT NULL;
