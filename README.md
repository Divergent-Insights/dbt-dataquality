# dbt Data Quality

This [dbt](https://github.com/dbt-labs/dbt-core) package helps to create simple flatten models from the outputs of dbt sources freshness and dbt tests

- Access and report on the output from dbt source freshness (sources.json)
- Access and report on the output from dbt tests (run_results.json)

## Installation Instructions
1. 
2.

## Prerequisites
- This package is compatible with dbt 1.0.0 and later.
- Snowflake credentials with the right level of access to create/destroy and configure the following objects: database, schema, internal stage and table

----

## Package Overview

This package provides a set of macros that are grouped logically, where each group provides "opinionated" logic and specialises on setting up a Snowflake environment 
in very specific way. However, the logic can easily be expanded and adjusted to suit different needs

Each environment setup focuses on implementing the following Snowflake resources:
- Account (configuration only)
- Role (creation and configuration)
- Warehouse (creation and configuration)
- Database (creation and configuration)
- Schema (creation and confiugration)
- User (creation and configuration)
- Internal Stage (creation and configuration)

## Usage
```
dbt run-operation create_resources

dbt source freshness
dbt test

dbt run-operation load_resources --args {'file: target/sources.json'}
dbt run-operation load_resources --args {'file: target/run_results.json'}


```

Note that all arguments are optional. These are the default values:
- env=1
- database=target.database
- schema=target.schema
- role="my_role"
- user="my_user"
- internal_stage="internal_stage"
- file_format="json"
