{% macro medallion_bronze_database() -%}
  {{ return(var('bronze_database', 'raw')) }}
{%- endmacro %}

{% macro medallion_silver_database() -%}
  {{ return(var('silver_database', 'silver')) }}
{%- endmacro %}

{% macro medallion_gold_database() -%}
  {{ return(var('gold_database', 'gold')) }}
{%- endmacro %}

{% macro medallion_bronze_table(schema, table) -%}
  {{ medallion_bronze_database() }}.`{{ schema }}__{{ table }}`
{%- endmacro %}

{% macro medallion_silver_audit_columns(source_table) -%}
    now64(3) as _loaded_at,
    '{{ source_table }}' as _source_table
{%- endmacro %}

{% macro medallion_tenant_filter(column='tenant_slug') -%}
  {% if var('tenant_slug', none) is not none %}
    where {{ column }} = '{{ var("tenant_slug") }}'
  {% endif %}
{%- endmacro %}
