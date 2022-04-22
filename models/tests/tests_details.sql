select distinct
    tm.database
    ,split_part(file_key_name, '.', -1) table
    ,tm.column_name
    ,t.status
    ,case
        when (t.status = 'error') then 100
        when (t.status = 'fail') then 50
        when (t.status = 'pass') then 0
        else -1
    end as status_code
from {{ ref('raw_tests') }} t
left join {{ ref('raw_tests_manifest') }} tm on t.unique_id = tm.unique_id
where t.payload_timestamp_utc >= (select max(payload_timestamp_utc) from {{ ref('raw_source_freshness') }})