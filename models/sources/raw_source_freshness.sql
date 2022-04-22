{{
    config(
        materialized='incremental',
        unique_key='id'
    )
}}

with dedup_logs as
(
    select s.*
    from {{ source('dbt_dataquality', 'stg_dbt_dataquality') }} s
    where s.upload_timestamp_utc = (
        select max(upload_timestamp_utc)
        from {{ source('dbt_dataquality', 'stg_dbt_dataquality') }}
        where filename = 'sources.json.gz'
    )
),
flatten_records as
(
    select
        {{ dbt_utils.surrogate_key(['payload_id', 'payload_timestamp_utc', 'results.value:unique_id']) }} as id,
        payload_id,
        payload_timestamp_utc,
        results.value:unique_id::string as unique_id,
        payload:metadata:dbt_schema_version::string as dbt_schema_version,
        payload:metadata:dbt_version::string as dbt_version,
        payload:metadata:generated_at::timestamp_tz as generated_at,
        payload:metadata:invocation_id::string as invocation_id,
        results.value:max_loaded_at::timestamp_tz as max_loaded_at,
        results.value:snapshotted_at::timestamp_tz as snapshotted_at,
        results.value:max_loaded_at_time_ago_in_s::float as max_loaded_at_time_ago_in_s,
        results.value:status::string as status,
        results.value:criteria:warn_after:count::int as freshness_warn_count,
        results.value:criteria:warn_after:period::string as freshness_warn_period,
        results.value:criteria:error_after:count::int as freshness_error_count,
        results.value:criteria:error_after:period::string as freshness_error_period,
        results.value:criteria:filter::string as freshness_filter,
        results.value:thread_id::string as thread_id,
        results.value:execution_time::float as execution_time,
        results.value:timing[0]:started_at::timestamp_tz as compile_started_at,
        results.value:timing[0]:completed_at::timestamp_tz as compile_completed_at,
        results.value:timing[1]:started_at::timestamp_tz as execute_started_at,
        results.value:timing[1]:completed_at::timestamp_tz as execute_completed_at    
    from dedup_logs
    ,lateral flatten(input => payload:results) as results

    {% if is_incremental() %}
        where payload_timestamp_utc > (select max(payload_timestamp_utc) from {{ this }})
    {% endif %}
)
select * from flatten_records
