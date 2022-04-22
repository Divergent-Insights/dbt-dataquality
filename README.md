# dbt Data Quality

This [dbt](https://github.com/dbt-labs/dbt-core) package helps to create simple data models from the outputs of `dbt sources freshness` and `dbt tests`. That is, this package will help you to

- Access and report on the output from dbt source freshness (sources.json, manifest.json)
- Access and report on the output from dbt tests (run_results.json, manifest.json)

## Prerequisites

- This package is compatible with dbt 1.0.0 and later
- This packages uses Snowflake as the backend for reporting. Contributions are welcomed to support other backend engines
- Snowflake credentials with the right level of access to create/destroy and configure the following objects:
  - Database (optional)
  - Schema (optional)
  - Internal stage (recommended but optional). Alternatively, you can use an external stage
  - Table

## High Level Architecture

![High-Level Architecture](https://raw.githubusercontent.com/Divergent-Insights/dbt-dataquality/main/dashboards/dbt_dataquality-high_level_architecture.png)

## Package Overview

As per the high-level architecture diagram, these are the different functionalities that this package provides:

- (Optional) Creation of Snowflake resources to store and make available dbt logging information
  - Create a database (optional) - this is only provided for convenience and very unlikely to be required by you
  - Creates a schema (optional)
  - Creates an internal stage (optional)
  - Creates a variant-column staging table

- Loads dbt logging information on an internal stage
  - This is achieved via a set of dbt macros together with the Snowflake PUT command

- Copies dbt logging information into a Snowflake table
  - This is achieved via a set of dbt macros together with the Sowflake COPY command

- Creating and populating simple dbt models to report on `dbt source freshness` and `dbt tests`
  - Raw logging data is modelled downstream and contextualised for reporting purposes

- Bonus - it provides a ready-to-go Power BI report built on top the dbt models to showcase how this data can be used

---

## Usage
- Set any relevant variables in your dbt_project.yml (optional)

  ```
  vars:
    dbt_dataquality:
      dbt_dataquality_database: my_database # optional, default is target.database
      dbt_dataquality_schema: my_schema # optional, default is target.schema
      dbt_dataquality_table: my_table # optional, default is 'stg_dbt_dataquality'
      dbt_dataquality_stage: my_internal_stage | my_external_stage, default is 'dbt_dataquality'),
      dbt_dataquality_target_path: my_dbt_target_directory # optional, default is 'target'
  ```
  **Important**: when using an external stage you need to set the parameter `load_from_internal_stage` to `False` on the load_log_* macros. See below for more details

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
  - To load data from an external stage, you must:
    - Workout on your own how to create and load the data on the external stage
    - If you are using the `create_resources` macro then set the parameter `create_internal_stage` to `False`
      - For example: `dbt run-operation create_resources --args '{create_internal_stage: False}'`
    - Set the package variable `dbt_dataquality_stage: my_external_stage` (as described at the beginning of the Usage section)
    - When running the `load_log_sources` and `load_log_tests` macros set the parameter `load_from_internal_stage` to `False`
      - For example: `dbt run-operation load_log_sources --args '{load_from_internal_stage: False}'`

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

dbt test
dbt run-operation load_log_tests
dbt run --select dbt_dataquality.tests

# Optionally, the dbt_dataquality package uses incremental models so don't forget to use the option `--full-refresh` to rebuild them
# For example
dbt run --full-refresh --select dbt_dataquality.sources
dbt run --full-refresh --select dbt_dataquality.tests
```

Note that the load_log_* macros automatically upload the relevant log and manifest files
For example, the macro load_log_sources loads sources.json and manifest.json

## Dashboards
- The models created will allow you to dome some simple but powerful reporting as per the image below
- This package includes a nice and simple Power BI sample dashboard to get you going!

![Sample Dashboard](https://raw.githubusercontent.com/Divergent-Insights/dbt-dataquality/main/dashboards/dashboard1.png)

---

## TODO
- Data loading will be generalised and extended to handle Snowflake internal and external stages
- This preliminary version focuses on setting the foundations of the packages and logs flattenning
- Next iterations of the package will enhance the downstream models
- Also, a simple dynamic tagging functionality will be added to make nice and simple tests reporting
