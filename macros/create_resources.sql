{% macro create_resources(dry_run=False, internal_stage=true, create_default_schema=true) %}

  {% if create_default_schema %}
    {{ create_schema(dry_run) }}
  {% endif %}    

  {% if internal_stage %}
    {{ create_internal_stage(dry_run) }}
  {% endif %}

  {{ create_src_table(dry_run) }}
  
{% endmacro %}
