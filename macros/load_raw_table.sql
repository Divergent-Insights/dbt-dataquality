{% macro snowflake_load_raw_table(database=target.database, schema=target.schema, stage="internal_stage", table="stg_table1") %}

    {% do log("snowflake_load_variant_table started", info=True) %}
    {% do log("Database: " ~ database, info=True) %}
    {% do log("Schema: " ~ schema, info=True) %}
    {% do log("Stage: " ~ stage, info=True) %}
    {% do log("Table: " ~ table, info=True) %}

    {% set sql %}
        begin;
        copy into {{ database }}.{{ schema }}.{{ table }}
        from
            (
                select
                    sysdate()::timestamp_tz as upload_timestamp_utc,
                    metadata$filename as filename,
                    $1 as payload,
                    $1:metadata:generated_at::timestamp_tz as payload_timestamp_utc,
                    $1:metadata:invocation_id::string as payload_id                    
                from  @{{ database }}.{{ schema }}.{{ stage }} internal_stage
            )
            file_format=(type='json')
            on_error='skip_file';
        commit;        
    {% endset %}    
    {% do run_query(sql) %}

    {% do log(sql, info=True) %}
    {% do log("snowflake_load_raw_table completed", info=True) %}

{% endmacro %}
