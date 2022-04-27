{% macro create_src_table(replace=false, dry_run=false) %}

    {% do log("create_src_table started", info=True) %}
    {% set config = _get_config() %}

    {% set sql %}
        {% if replace == false %}
            create table if not exists {{ config["database"] }}.{{ config["schema"] }}.{{ config["table"] }}
        {% else %}
            create or replace table {{ config["database"] }}.{{ config["schema"] }}.{{ config["table"] }}
        {% endif %}
        (
            upload_timestamp_utc timestamp_tz,
            filename string,
            payload variant,
            payload_timestamp_utc timestamp_tz,
            payload_id string
        );
    {% endset %}

    {% if not dry_run %}
        {% do run_query(sql) %}
    {% endif %}

    {% do log(sql, info=True) %}

    {% do log("create_src_table completed", info=True) %}

{% endmacro %}
