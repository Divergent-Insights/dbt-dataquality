{% macro create_resources(dry_run=False, internal_stage=True) %}

  {{ create_schema(dry_run) }}

  {% if internal_stage %}
      {{ create_internal_stage(dry_run) }}
  {% endif %}

  {{ create_src_table(dry_run) }}
  
{% endmacro %}
