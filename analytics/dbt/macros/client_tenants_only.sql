{% macro client_tenants_only(column='tenant_slug') %}
  {# ADR-016: marts gold só tenants cliente (exclui staging interno). #}
  {{ column }} in (
    {%- for slug in var('production_tenant_slugs') -%}
    '{{ slug }}'{% if not loop.last %}, {% endif %}
    {%- endfor -%}
  )
{% endmacro %}
