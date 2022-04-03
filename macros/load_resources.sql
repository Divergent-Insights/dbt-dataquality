{% macro load_resources() %}

  {{ load_internal_stage() }}
  {{ load_raw_table() }}
  
{% endmacro %}
