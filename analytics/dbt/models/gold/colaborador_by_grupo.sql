{{
  config(
    materialized='table',
    engine='MergeTree()',
    order_by='(tenant_slug, id_grupo_usuario)',
    settings={'allow_nullable_key': 1}
  )
}}

select
    tenant_slug,
    id_grupo_usuario,
    count() as colaborador_count,
    countIf(ativo = 1) as colaborador_ativos,
    max(_ts_ms) as last_ts_ms
from {{ ref('stg_colaborador') }}
where id_grupo_usuario is not null
group by tenant_slug, id_grupo_usuario
