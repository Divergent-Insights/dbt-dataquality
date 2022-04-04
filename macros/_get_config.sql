{% macro _get_config() %}

  {{ 
    return(
      {
        "database" : var('dbt_dataquality_database', target.database), 
        "schema" : var('dbt_dataquality_schema', target.schema),
        "table" : var('dbt_dataquality_table', 'stg_dbt_dataquality'),
        "stage" : 'dbt_dataquality'
      }
    ) 
  }}
  
{% endmacro %}
