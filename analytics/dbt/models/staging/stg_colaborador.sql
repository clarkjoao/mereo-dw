{{
  config(
    materialized='view',
    tags=['staging', 'legacy-alias'],
  )
}}

/* Legado: staging.stg_colaborador → silver.sl_colaborador_cdc (CDC) */
select
    id,
    tenant_slug,
    nome,
    email,
    id_grupo_usuario,
    ativo,
    _ts_ms,
    _deleted
from {{ ref('pessoa_cdc') }}
