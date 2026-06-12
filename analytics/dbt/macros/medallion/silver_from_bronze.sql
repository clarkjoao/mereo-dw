{% macro silver_from_bronze(bronze_table, columns, deleted_filter=true) %}
{#
  ETL padrão silver: bronze bulk → snake_case + tenant_slug.
  columns: lista de tuplas (source_col, alias, optional_cast_comment)
  Ex.: ('ID', 'id', 'Int64')
#}
select
    tenant_slug,
    {%- for src, alias, cast_hint in columns %}
    {% if cast_hint == 'Int64' -%}
    toInt64(`{{ src }}`) as {{ alias }}
    {%- elif cast_hint == 'UInt8' -%}
    toUInt8(`{{ src }}`) as {{ alias }}
    {%- else -%}
    `{{ src }}` as {{ alias }}
    {%- endif -%}
    {%- if not loop.last %},{% endif %}
    {%- endfor %},
    _ts_ms,
    _deleted
from {{ source('bronze', bronze_table) }}
{% if deleted_filter %}
where _deleted = 0
{% endif %}
{% endmacro %}
