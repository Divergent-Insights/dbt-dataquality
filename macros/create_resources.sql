{% macro create_resources(dry_run = false) %}

  {{ create_schema(dry_run) }}
  {{ create_internal_stage(dry_run) }}
  {{ create_src_table(dry_run) }}
  
{% endmacro %}
