{% macro snowflake_clean_internal_stage(database=target.database, schema=target.schema, stage="internal_stage", pattern="*.*") %}

    {% do log("snowflake_clean_internal_stage started", info=True) %}
    {% do log("Database: " ~ database, info=True) %}
    {% do log("Schema: " ~ schema, info=True) %}
    {% do log("Stage: " ~ stage, info=True) %}
    {% do log("pattern: " ~ file, info=True) %}

    {% set sql %}
        remove @{{ database }}.{{ schema }}.{{ stage }} pattern='.{{ pattern }}';
    {% endset %}    
    {% do run_query(sql) %}

    {% do log(sql, info=True) %}
    {% do log("snowflake_clean_internal_stage completed", info=True) %}

{% endmacro %}
