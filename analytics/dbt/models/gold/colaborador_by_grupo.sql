{{
  config(
    materialized='view',
    tags=['gold', 'legacy-alias'],
  )
}}

/* Legado: gold.colaborador_by_grupo → gl_colaborador_by_grupo */
select * from {{ ref('gl_colaborador_by_grupo') }}
