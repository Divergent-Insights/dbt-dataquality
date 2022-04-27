{% macro create_schema(dry_run=false) %}

    {% do log("create_schema started", info=True) %}

    {% set config = _get_config() %}

    {% set sql %}
        create schema if not exists {{ config["database"] }}.{{ config["schema"] }};
    {% endset %}

    {% if not dry_run %}
        {% do run_query(sql) %}
    {% endif %}        

    {% do log(sql, info=True) %}

    {% do log("create_schema completed", info=True) %}

{% endmacro %}
