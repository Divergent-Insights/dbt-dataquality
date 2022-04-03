{% macro create_resources() %}

  {{ create_internal_stage() }}
  {{ create_raw_table() }}
  
{% endmacro %}
