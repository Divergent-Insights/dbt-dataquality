{% macro clean_internal_stage() %}

    {% do log("clean_internal_stage started", info=True) %}
    {% set config = _get_config() %}

    {% set sql %}
        remove @{{ config["database"] }}.{{ config["schema"] }}.{{ config["stage"] }} pattern='.*.*';
    {% endset %}
    {% do run_query(sql) %}
    {% do log(sql, info=True) %}

    {% do log("clean_internal_stage completed", info=True) %}

{% endmacro %}
