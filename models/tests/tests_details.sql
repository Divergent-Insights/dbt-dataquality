with latest_records as
(
    select         
        payload_id
        ,payload_timestamp_utc
        ,unique_id
        ,iff(status='success', 'pass', status) status
        ,case
            when (status = 'error') then 100
            when (status = 'fail') then 50
            when (status = 'pass' or status = 'success') then 0
            else -1
        end as status_code    
    from {{ ref('raw_tests') }}
    where payload_timestamp_utc = (select max(payload_timestamp_utc)from {{ ref('raw_tests') }})
)
select
    tm.payload_id
    ,tm.payload_timestamp_utc
    ,tm.name test_name
    ,tm.tags quality_tag
    ,tm.database
    ,split_part(tm.file_key_name, '.', -1) table_name
    ,tm.column_name
    ,lr.status
    ,lr.status_code 
from latest_records lr 
    left join {{ ref('raw_tests_manifest') }} tm
        on lr.unique_id = tm.unique_id
