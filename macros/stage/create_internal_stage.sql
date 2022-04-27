{% macro create_internal_stage(dry_run=false) %}

    {% do log("create_internal_stage started", info=True) %}
    {% set config = _get_config() %}

    {% set sql %}
      create stage if not exists {{ config["database"] }}.{{ config["schema"] }}.{{ config["stage"] }}
        file_format = ( type = json );        
    {% endset %}

    {% if not dry_run %}
        {% do run_query(sql) %}
    {% endif %}

    {% do log(sql, info=True) %}

    {% do log("create_internal_stage completed", info=True) %}

{% endmacro %}
