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

---

## Package Overview

Overall, this package focuses on doing two things:

- Creation of Snowflake resources to store and make available dbt logging information
  - Creates a schema (optional)
  - Creates a Snowflake internal stage (optional)
  - Creates a variant-column staging table

- Creating and populating a simple dbt model with dbt logging information for reporting purposes
  - First, the data is loaded into a staging table via Snowflake's put command
  - Second, the data is loaded into a variant staging table via Snowflake's copy command
  - Finally, the data is dbt sourced and model to make it suitable for reporting and visualisation

---

## Usage
- Set any relevant variables in your dbt_project.yml (optional)

  ```
  vars:
    dbt_dataquality:
      dbt_dataquality_database: my_database # optional, default is target.database
      dbt_dataquality_schema: my_schema # optional, default is target.schema
      dbt_dataquality_table: my_table # optional, default is 'stg_dbt_dataquality'
      dbt_dataquality_target_path: my_dbt_target_directory # optional, default is 'target'
  ```

- Use the macro `create_resources` to create the required Snowflake resources
  - If you have the right permissions, you should be able to run this macro to create all resources required by the dbt_dataquality package
    - For example, a successful run of `dbt run-operation create_resources` will give you the schema, table and staging tables required by the package

  - If you are in a complex environment with stringent permissions, you can run the macro in "dry mode" which will give you the SQL required by the macro. Once you have the SQL you can copy and paste and run manully the parts of the query that make sense
    - For example, `dbt run-operation create_resources --args '{dry_run:True}'`

  - Keep in mind that the "create_resources" macro creates an internal stage by default. If you are wanting to load log files via an external stage then you can disable the creation of the internal stage
    - For example, `dbt run-operation create_resources --args '{internal_stage:False}'`

- Optionally, do a regular run of dbt source freshness or dbt test on your local project to generate some logging files
  - For example ```dbt run``` or ```dbt test```

- Use the load macros provided by the dbt_quality package to load the dbt logging information that's required
  - Use the macro `load_log_sources` to load sources.json and manifest.json files
  - Use the macro `load_log_tests` to load run_results.json and manifest.json files

- Create and populate downstream models
  - Use `dbt run --select dbt_quality.sources` to load source freshness logs
  - Use `dbt run --select dbt_quality.tests` to load tests logs

### Usage Summary
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

# Optionally, the dbt_dataquality packages created incremental models so don't forget that you can use the --full-refresh option to rebuild them
dbt run --full-refresh --select dbt_dataquality.tests
```

Note that the load_log_* macros automatically upload the relevant log and manifest files
For example, the macro load_log_sources loads sources.json and manifest.json

The models created will allow you to dome some simple but powerful reporting as per the image below

![Sample Dashboard](https://raw.githubusercontent.com/Divergent-Insights/dbt-dataquality/main/dashboards/dashboard1.png)

---

## TODO
- Data loading will be generalised and extended to handle Snowflake internal and external stages
- This preliminary version focuses on setting the foundations of the packages and logs flattenning
- Next iterations of the package will enhance the downstream models
- Also, a simple dynamic tagging functionality will be added to make nice and simple tests reporting
