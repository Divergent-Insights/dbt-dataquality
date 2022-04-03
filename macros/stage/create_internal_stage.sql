{% macro create_internal_stage(database=target.database, schema=target.schema, , stage="dbt_dataquality") %}

    -- Load Internal Stage
    -- Note file must contain full path location e.g. "/tmp/my_file.json"
    {% do log("snowflake_create_variant_table started", info=True) %}
    {% do log("Database: " ~ database, info=True) %}
    {% do log("Schema: " ~ schema, info=True) %}

    {% set sql %}
      create stage if not exists {{ database }}.{{ schema }}.{{ stage }}
        file_format = ( type = json );        
    {% endset %}    
    {% do run_query(sql) %}
    {% do log(sql, info=True) %}
    {% do log(sql, info=True) %}

    {% do log("create_internal_stage completed", info=True) %}

{% endmacro %}
