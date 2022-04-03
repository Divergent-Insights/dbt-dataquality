{% macro drop_raw_table(database=target.database, schema=target.schema, table="src_dbt_dataquality") %}

    -- Load Internal Stage
    -- Note file must contain full path location e.g. "/tmp/my_file.json"
    {% do log("snowflake_drop_tables started", info=True) %}
    {% do log("Database: " ~ database, info=True) %}
    {% do log("Schema: " ~ schema, info=True) %}

    {% set sql %}
        drop table if exists {{ database }}.{{ schema }}.{{ table }}
    {% endset %}    
    {% do run_query(sql) %}
    {% do log(sql, info=True) %}

    {% do log("drop_raw_table completed", info=True) %}

{% endmacro %}
