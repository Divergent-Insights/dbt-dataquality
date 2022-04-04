{% macro create_schema(database=target.database) %}

    {% do log("create_schema started", info=True) %}

    {% set config = _get_config() %}

    {% set sql %}
        create schema if not exists {{ config["database"] }}.{{ config["schema"] }};
    {% endset %}    
    {% do run_query(sql) %}
    {% do log(sql, info=True) %}

    {% do log("create_schema completed", info=True) %}

{% endmacro %}
