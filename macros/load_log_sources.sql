{% macro load_log_sources(load_from_internal_stage=true, clean_stage=true) %}

  -- Removing all files from the internal stage
  {% if clean_stage %}
      {{ clean_internal_stage() }}
  {% endif %}  

  {% set config = _get_config() %}
  {% set log_file = config["dbt_target_path"] ~ '/sources.json' %}

  {% if load_from_internal_stage %}
      {{ load_log_manifest() }}
      {{ load_internal_stage(file=log_file) }}
  {% endif %}  

  {{ load_src_table() }}
  
{% endmacro %}
