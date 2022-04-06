{% macro load_log_sources() %}

  {% set config = _get_config() %}
  {% set log_file = config["dbt_target_path"] ~ '/sources.json' %}
  {{ load_internal_stage(log_file) }}
  {{ load_src_table() }}
  
{% endmacro %}
