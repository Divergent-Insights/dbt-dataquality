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
        where filename = 'run_results.json.gz'
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
        
        results.value:status::string as status,
        results.value:message::string as message,
        results.value:failures::string as failures,
        results.value:thread_id::string as thread_id,
        results.value:execution_time::float as execution_time,
        
        results.value:adapter_response:_message::string as adapter_response_message,
        results.value:adapter_response:code::string as adapter_response_code,
        results.value:adapter_response:rows_affected::string as adapter_response_rows_affected,
        
        results.value:timing[0]:started_at::timestamp_tz timing_compile_started_at,
        results.value:timing[0]:completed_at::timestamp_tz timing_compile_completed_at,
        results.value:timing[0]:started_at::timestamp_tz timing_execute_started_at,
        results.value:timing[0]:completed_at::timestamp_tz timing_execute_completed_at,    
        
        payload:elapsed_time::float as elapsed_time
    from dedup_logs
        ,lateral flatten(input => payload:results) as results

    {% if is_incremental() %}
        where payload_timestamp_utc > (select max(payload_timestamp_utc) from {{ this }})
    {% endif %}
)
select * from flatten_records
