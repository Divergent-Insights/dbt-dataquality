{% macro load_internal_stage(file) %}

    {% do log("load_internal_stage started", info=True) %}
    {% set config = _get_config() %}

    -- Populating internal stage
    {% set sql %}
        put file://{{ file }} @{{ config["database"] }}.{{ config["schema"] }}.{{ config["stage"] }} auto_compress=true;
    {% endset %}    
    {% do run_query(sql) %}
    {% do log(sql, info=True) %}

    {% do log("load_internal_stage completed", info=True) %}

{% endmacro %}
