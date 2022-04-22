{% macro load_log_tests(load_from_internal_stage=True) %}

  {% set config = _get_config() %}
  {% set log_file = config["dbt_target_path"] ~ '/run_results.json' %}

  {% if load_from_internal_stage %}
      {{ load_internal_stage(file=log_file) }}
  {% endif %}

  {{ load_src_table() }}

{% endmacro %}
