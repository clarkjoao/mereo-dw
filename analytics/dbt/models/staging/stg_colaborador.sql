{{
  config(
    materialized='view'
  )
}}

select
    id,
    tenant_slug,
    nome,
    email,
    id_grupo_usuario,
    ativo,
    _ts_ms,
    _deleted
from {{ source('raw', 'colaborador') }} final
where _deleted = 0
