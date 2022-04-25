# dbt Data Quality

This [dbt](https://github.com/dbt-labs/dbt-core) package helps you to

- Access and report on the outputs from `dbt source freshness` ([sources.json](https://docs.getdbt.com/reference/artifacts/sources-json) and [manifest.json](https://docs.getdbt.com/reference/artifacts/manifest-json))
- Access and report on the outputs from `dbt test` ([run_results.json](https://docs.getdbt.com/reference/artifacts/run-results-json) and [manifest.json](https://docs.getdbt.com/reference/artifacts/manifest-json))

<img src="https://raw.githubusercontent.com/Divergent-Insights/dbt-dataquality/main/dashboards/dbt_dataquality_dashboard_preview.gif"/>

## Prerequisites

- This package is compatible with dbt 1.0.0 and later
- This packages uses Snowflake as the backend for reporting (contributions to support other backend engines are welcomed)
- Snowflake credentials with the right level of access to create/destroy and configure the following objects:
  - Database (optional)
  - Schema (optional)
  - Internal stage (recommended but optional). Alternatively, you can use an external stage
  - Table

## Contributions
We love contributions! Currently, we don't have a roadmap for this package so feel free to help where you can

Here's some ideas where we would love your contribution:

- Adding support for other databases such as Microsoft SQL Server and PostgreSQL
- Extending the downstream data models and incorporate more comprehensive data quality testing coverage and advanced metrics
- Adding new models to capture logging data historically (ideally a customisable rolling window)
- Contributing new dashboards from different tools such as Tableau

If you have any questions, you can contact us at info@divergentinsights.com.au

## High Level Architecture

![High-Level Architecture](https://raw.githubusercontent.com/Divergent-Insights/dbt-dataquality/main/dashboards/dbt_dataquality-high_level_architecture.png)

## Architecture Overview

As per the high-level architecture diagram, these are the different functionalities that this package provides:

- (Optional) Creation of Snowflake resources to store and make available dbt logging information
  - Create a database (optional) - this is only provided for convenience and very unlikely to be required by you
  - Creates a schema (optional)
  - Creates an internal stage (optional)
  - Creates a variant-column staging table

- Loads dbt logging information on an internal stage
  - This is achieved via a set of dbt macros together leveraging Snowflake PUT command

- Copies dbt logging information into a Snowflake table
  - This is achieved via a set of dbt macros together leveraging Sowflake COPY command

- Creating and populating simple dbt models to report on `dbt source freshness` and `dbt tests`
  - Raw logging data is modelled downstream and contextualised for reporting purposes

- Bonus - it provides a ready-to-go Power BI dashboard built on top the dbt models created by the package to showcase all features

---

## Usage

### Package Configuration

Optionally, set any relevant variables in your dbt_project.yml

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

### Resources Creation

Use the macro `create_resources` to create the backend resources required by the package
- If you have the right permissions, you should be able to run this macro to create all resources required by the dbt_dataquality package
  - For example, a successful run of `dbt run-operation create_resources` will give you the schema, table and staging tables required by the package

If you are in a complex environment with stringent permissions, you can run the macro in "dry mode" which will give you the SQL required by the macro. Once you have the SQL you can copy and paste and run manually the parts of the query that make sense
- For example, `dbt run-operation create_resources --args '{dry_run:True}'`

Also, keep in mind that the "create_resources" macro creates an internal stage by default. If you are wanting to load log files via an external stage then you can disable the creation of the internal stage
  - For example, `dbt run-operation create_resources --args '{internal_stage:False}'`

### Generating some log files

Optionally, do a regular run of dbt source freshness or dbt test on your local project to generate some logging files
- For example ```dbt run``` or ```dbt test```

### Loading log files - Internal Stage

Use the load macros provided by the dbt_quality package to load the dbt logging information that's required
- Use the macro `load_log_sources` to load sources.json and manifest.json files
- Use the macro `load_log_tests` to load run_results.json and manifest.json files

Note that the `load_log_sources` and `load_log_tests` macros automatically upload the relevant log and manifest files
For example, the macro `load_log_sources` loads sources.json and manifest.json and the macro `load_log_tests` loads the files run_results.json and manifest.json

### Loading log files - External Stage
To load data from an external stage, you must:
- Workout on your own how to create, configure and load the data to the external stage
  - In this case, when running the `create_resources` macro set the parameter `internal_stage` to `False`
    - For example: `dbt run-operation create_resources --args '{internal_stage: False}'`
- Set the package variable `dbt_dataquality_stage: my_external_stage` (as described at the beginning of the Usage section)
- When running the `load_log_sources` and `load_log_tests` macros set the parameter `load_from_internal_stage` to `False`
  - For example: `dbt run-operation load_log_sources --args '{load_from_internal_stage: False}'`

### Create and populate downstream models

- Use `dbt run --select dbt_quality.sources` to load source freshness logs
- Use `dbt run --select dbt_quality.tests` to load tests logs

## Data Quality Attributes
This package supports capturing and reporting on Data Quality Attributes. This is a very popular feature!

To use this functionality just follow these simple steps:

### Add tests to your models
Just add tests to your models following [the standard dbt testing process](https://docs.getdbt.com/docs/building-a-dbt-project/tests)
Tip: you may want to use some tests from the awesome dbt package [dbt-expectations](https://github.com/calogica/dbt-expectations#expect_row_values_to_have_recent_data)

### Tag your tests
Tag any tests that you want to report on with **your preferred data quality attributes**

To keep things simple at Divergent Insights we use [the ISO/IEC 25012:2008 standard](https://www.iso.org/standard/35736.html) to report on data quality (refer to the image below)
![Data Product Quality](https://iso25000.com/images/figures/ISO_25012_en.png)

You can read more about ISO 25012 [here](https://iso25000.com/index.php/en/iso-25000-standards/iso-25012); however, here's a summary of the key Data Quality Attributes defined by the standard:
- **Accuracy**: the degree to which data has attributes that correctly represent the true value of the intended attribute of a concept or event in a specific context of use.
- **Completeness**: the degree to which subject data associated with an entity has values for all expected attributes and related entity instances in a specific context of use.
- **Consistency**: the degree to which data has attributes that are free from contradiction and are coherent with other data in a specific context of use. It can be either or both among data regarding one entity and across similar data for comparable entities.
- **Credibility**: the degree to which data has attributes that are regarded as true and believable by users in a specific context of use. Credibility includes the concept of authenticity (the truthfulness of origins, attributions, commitments).
- **Currentness / Timeliness**: the degree to which data has attributes that are of the right age in a specific context of use.

Please note that
- Tags **MUST** be prefixed with "dq:", for example `dq:accuracy` or `dq:timeliness`
- Any tag prefixed with "dq:" will be automatically detected and reported on by the package
- In our case, we use four tags aligned to ISO 25012: `dq:accuracy`, `dq:completeness`, `dq:consistency` and `dq:timeliness` (we don't use credibility due to obvious reasons)
- If you add two or more "dq:" tags, only the first tag sorted alphabetically is processed


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

## Dashboarding Data Quality Information
- The models created will allow you to dome some simple but powerful reporting on your data quality (see images below)
- This package includes a nice and simple Power BI sample dashboard to get you going!

### Sources Overview Dashboard
![Sample Dashboard](https://raw.githubusercontent.com/Divergent-Insights/dbt-dataquality/main/dashboards/dashboard1.png)

### Tests Overview Dashboard
![Sample Dashboard](https://raw.githubusercontent.com/Divergent-Insights/dbt-dataquality/main/dashboards/dashboard2.png)

### Data Quality Attributes
![Sample Dashboard](https://raw.githubusercontent.com/Divergent-Insights/dbt-dataquality/main/dashboards/dashboard3.png)

---

## TODO
- Adding testing suite
- Adding more complex downstream metrics on Data Quality Coverage
- When the time is right, adding support for old and new [dbt artifacts schema versions](https://docs.getdbt.com/reference/artifacts/dbt-artifacts), currently only v3 is supported

## License
All the content of this repository is licensed under the [**Apache License 2.0**](https://github.com/Divergent-Insights/dbt-dataquality/blob/main/LICENSE)

This is a permissive license whose main conditions require preservation of copyright and license notices. Contributors provide an express grant of patent rights. Licensed works, modifications, and larger works may be distributed under different terms and without source code.
