# dbt Data Quality

This [dbt](https://github.com/dbt-labs/dbt-core) package helps to create simple flatten models from the outputs of dbt sources freshness and dbt tests

- Access and report on the output from dbt source freshness (sources.json)
- Access and report on the output from dbt tests (run_results.json)

## Prerequisites
- This package is compatible with dbt 1.0.0 and later.
- Snowflake credentials with the right level of access to create/destroy and configure the following objects:
  - Database (optional)
  - Schema (optional)
  - Internal stage
  - Table

----

## Package Overview

Overall, this package focuses on doing two things:

1. Creates Snowflake resources to hold dbt sources and tests data
- Optionally, creates a schema
- Creates a Snowflake internal stage
- Creates a variant-column staging table

2. Loads a simple dbt model with dbt sources and tests data
- First, the data is loaded into a staging table via Snowflake's put command
- Second, the data is loaded into a variant staging table via Snowflake's copy command
- Finally, the data is dbt sourced and model to make it suitable for reporting and visualisation

## Usage
0. Optionally, set any relevant variables in your dbt_project.yml
```
vars:
  dbt_dataquality:
    dbt_dataquality_database: my_database # optional, default is target.database
    dbt_dataquality_schema: my_schema # optional, default is target.schema
    dbt_dataquality_table: my_table # optional, default is 'stg_dbt_dataquality'
    dbt_dataquality_target_path: my_dbt_target_directory # optional, default is 'target'
```
1. First, use the macro "create_resources" to create the required Snowflake resources
2. Second, either run dbt source freshness and dbt test and use the relevant "load_log_sources/tests" to load the logs
3. Create and populate downstream models using dbt run --select sources/tests

### Usage Example
#### Step 1. Snowflake Resources Creation
Use the following command ```dbt run-operation create_resources``` to create the resources where dbt logging data is uploaded into. This macro does the following:
- If it does not exist, a Snowflake schema is created
- If it does not exist, a Snowflake internal stage is created
- If is does not exist, a Snowflake table is created

#### Summary
Here's all the steps put together:
```
dbt run-operation create_resources

dbt source freshness
dbt run-operation load_log_sources
dbt run --select dbt_dataquality.sources

# Optionally, since this an incremental model you can use the --full-refresh option to rebuild the model
dbt run --full-refresh --select dbt_dataquality.sources

dbt test
dbt run-operation load_log_tests
dbt run --select dbt_dataquality.tests

# Optionally, since this an incremental model you can use the --full-refresh option to rebuild the model
dbt run --full-refresh --select dbt_dataquality.tests
```

Note that the load_log_* macros automatically upload the relevant log and manifest files
For example, the macro load_log_sources loads sources.json and manifest.json

The models created will allow you to dome some simple but powerful reporting as per the image below

![Sample Dashboard](https://raw.githubusercontent.com/Divergent-Insights/dbt-dataquality/main/dashboards/dashboard1.png)

## TODO
- This preliminary version focuses on setting the foundations of the packages and logs flattenning
- Next iterations of the package will enhance the downstream models
- Also, a simple dynamic tagging functionality will be added to make nice and simple tests reporting
