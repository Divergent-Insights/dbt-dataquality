{% macro load_log_tests() %}

  {% set config = _get_config() %}
  {% set log_file = config["dbt_target_path"] ~ '/run_results.json' %}
  {{ load_internal_stage(file=log_file) }}
  {{ load_src_table() }}

{% endmacro %}
