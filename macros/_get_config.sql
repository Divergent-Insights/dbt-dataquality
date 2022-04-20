{% macro _get_config() %}

  {{ 
    return(
      {
        "database" : var('dbt_dataquality_database', target.database), 
        "schema" : var('dbt_dataquality_schema', target.schema),
        "table" : var('dbt_dataquality_table', 'stg_dbt_dataquality'),
        "stage" : var('dbt_dataquality_stage', 'dbt_dataquality'),
        "dbt_target_path" : (var('dbt_dataquality_target_path', 'target')).rstrip("/")
      }
    ) 
  }}
  
{% endmacro %}
