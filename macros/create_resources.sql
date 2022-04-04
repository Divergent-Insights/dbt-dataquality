{% macro create_resources() %}

  {{ create_schema() }}
  {{ create_internal_stage() }}
  {{ create_src_table() }}
  
{% endmacro %}
