{% macro create_internal_stage() %}

    {% do log("create_internal_stage started", info=True) %}
    {% set config = _get_config() %}

    {% set sql %}
      create stage if not exists {{ config["database"] }}.{{ config["schema"] }}.{{ config["stage"] }}
        file_format = ( type = json );        
    {% endset %}    
    {% do run_query(sql) %}
    {% do log(sql, info=True) %}

    {% do log("create_internal_stage completed", info=True) %}

{% endmacro %}
