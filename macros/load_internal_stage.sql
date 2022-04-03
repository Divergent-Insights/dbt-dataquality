{% macro snowflake_load_internal_stage(database=target.database, schema=target.schema, stage="internal_stage", clean_stage=true, overwrite="false", file="my_file") %}

    -- Load Internal Stage
    -- Note file must contain full path location e.g. "/tmp/my_file.json"
    {% do log("snowflake_load_internal_stage started", info=True) %}
    {% do log("Database: " ~ database, info=True) %}
    {% do log("Schema: " ~ schema, info=True) %}
    {% do log("Stage: " ~ stage, info=True) %}
    {% do log("File: " ~ file, info=True) %}
    {% do log("Overwrite: " ~ overwrite, info=True) %}

    -- Removing all files from the internal stage
    {% if clean_stage == true %}
        {{ snowflake_clean_internal_stage() }}
    {% endif %}

    -- Creating internal stage if it does not exist
    {% set sql %}
        create stage if not exists {{ database }}.{{ schema }}.{{ stage }}
            file_format = ( type = json );        
    {% endset %}    
    {% do run_query(sql) %}
    {% do log(sql, info=True) %}

    -- Populating internal stage
    {% set sql %}
        put file://{{ file }} @{{ database }}.{{ schema }}.{{ stage }} auto_compress=true overwrite = {{ overwrite }};
    {% endset %}    
    {% do run_query(sql) %}
    {% do log(sql, info=True) %}

    {% do log("snowflake_load_internal_stage completed", info=True) %}

{% endmacro %}
