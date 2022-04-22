{% macro load_log_manifest(load_from_internal_stage=True) %}

  {% set config = _get_config() %}
  {% set log_file = config["dbt_target_path"] ~ '/manifest.json' %}

  {% if load_from_internal_stage %}
      {{ load_internal_stage(file=log_file) }}
  {% endif %}

  {{ load_src_table() }}

{% endmacro %}
