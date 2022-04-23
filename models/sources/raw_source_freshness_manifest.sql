{{
    config(materialized='table')
}}

with dedup_logs as
(
    select s.*
    from {{ source('dbt_dataquality', 'stg_dbt_dataquality') }} s
    where s.upload_timestamp_utc = (
        select max(upload_timestamp_utc)
        from {{ source('dbt_dataquality', 'stg_dbt_dataquality') }}
        where filename = 'manifest.json.gz'
    )
),
flatten_records as
(
    select
        payload_id,
        payload_timestamp_utc,
        sources.key::string unique_id,
        sources_content.key,
        sources_content.value
    from dedup_logs
    ,lateral flatten(input => payload:sources) as sources
    ,lateral flatten(input => sources.value ) as sources_content
    where sources_content.key in 
        ('loaded_at_field', 'database', 'description', 'loader', 'source_name', 'source_description', 'package_name', 'schema', 'freshness', 'name')
),
cleaning_records as
(
    select
        payload_id,
        payload_timestamp_utc,
        unique_id,
        "'name'"::string name,
        "'database'"::string database, 
        "'description'"::string description,
        "'loader'"::string loader,
        "'source_name'"::string source_name,
        "'source_description'"::string source_description,
        "'package_name'"::string package_name,
        "'schema'"::string schema,
        "'loaded_at_field'"::string loaded_at_field
    from flatten_records
    pivot(max(value) for key in 
        ('loaded_at_field', 'database', 'description', 'loader', 'source_name', 'source_description', 'package_name', 'schema', 'freshness', 'name'))
)
select * from cleaning_records
