{% macro load_log_tests() %}

  {{ load_internal_stage(file='target/run_results.json') }}
  {{ load_src_table() }}
  
{% endmacro %}
