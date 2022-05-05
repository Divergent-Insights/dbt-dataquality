{% macro load_log_manifest() %}

  {% set config = _get_config() %}
  {% set log_file = config["dbt_target_path"] ~ '/manifest.json' %}

  {{ load_internal_stage(file=log_file) }}

{% endmacro %}
