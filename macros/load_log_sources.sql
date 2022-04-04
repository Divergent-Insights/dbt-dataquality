{% macro load_log_sources() %}

  {{ load_internal_stage(file='target/sources.json') }}
  {{ load_src_table() }}
  
{% endmacro %}
