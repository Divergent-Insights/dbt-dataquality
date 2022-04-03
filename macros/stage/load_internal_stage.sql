{% macro load_internal_stage(database=target.database, schema=target.schema, stage="dbt_dataquality", clean_stage=true, file="my_file") %}

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

    -- Populating internal stage
    {% set sql %}
        put file://{{ file }} @{{ database }}.{{ schema }}.{{ stage }} auto_compress=true;
    {% endset %}    
    {% do run_query(sql) %}
    {% do log(sql, info=True) %}

    {% do log("load_internal_stage completed", info=True) %}

{% endmacro %}
