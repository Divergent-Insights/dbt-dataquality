{{
    config(materialized='table')
}}

with dedup_logs as
(
    select s.*
    from {{ source('dbt_dataquality', 'src_dbt_dataquality') }} s
    inner join (
        select payload_id, max(upload_timestamp_utc) as upload_timestamp_utc
        from {{ source('dbt_dataquality', 'src_dbt_dataquality') }}
        where filename = 'manifest.json.gz'
        group by payload_id
    ) dl on s.payload_id = dl.payload_id and s.upload_timestamp_utc = dl.upload_timestamp_utc
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
        --(json_extract_path_text("'freshness'", 'error_after.count'))::int freshness_error_after_count,
        --(json_extract_path_text("'freshness'", 'error_after.period'))::string freshness_error_after_period,
        --(json_extract_path_text("'freshness'", 'warn_after.count'))::int freshness_warn_after_count,
        --(json_extract_path_text("'freshness'", 'warn_after.period'))::string freshness_warn_after_period,    
        --(json_extract_path_text("'freshness'", 'filter'))::string freshness_filter
    from flatten_records
    pivot(max(value) for key in 
        ('loaded_at_field', 'database', 'description', 'loader', 'source_name', 'source_description', 'package_name', 'schema', 'freshness', 'name'))
)
select * from cleaning_records
