{% macro load_src_table() %}

    {% do log("load_src_table started", info=True) %}
    {% set config = _get_config() %}    

    {% set sql %}
        begin;
        copy into {{ config["database"] }}.{{ config["schema"] }}.{{ config["table"] }}
        from
            (
                select
                    sysdate()::timestamp_tz as upload_timestamp_utc,
                    metadata$filename as filename,
                    $1 as payload,
                    $1:metadata:generated_at::timestamp_tz as payload_timestamp_utc,
                    $1:metadata:invocation_id::string as payload_id                    
                from  @{{ config["database"] }}.{{ config["schema"] }}.{{ config["stage"] }}
            )
            file_format=(type='json')
            on_error='skip_file';
        commit;        
    {% endset %}    
    {% do run_query(sql) %}
    {% do log(sql, info=True) %}

    {% do log("load_src_table completed", info=True) %}

{% endmacro %}
