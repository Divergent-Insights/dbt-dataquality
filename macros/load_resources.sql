{% macro load_resources(file) %}

  {{ load_internal_stage(file) }}
  {{ load_src_table() }}
  
{% endmacro %}
