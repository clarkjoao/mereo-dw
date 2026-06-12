{% macro generate_schema_name(custom_schema_name, node) -%}
    {#- Silver por domínio: +schema = CH database exato (colaborador, metricas, …) -#}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
