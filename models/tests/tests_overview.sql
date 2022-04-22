with latest_records as
(
    select payload_id, iff(status='success', 'pass', status) status, payload_timestamp_utc
    from {{ ref('raw_tests') }}
    where payload_timestamp_utc = (select max(payload_timestamp_utc) from {{ ref('raw_tests') }})
),
grouped_results as
(
    select payload_id, status, count(status) status_count
    from latest_records
    group by payload_id, status
),
latest_timestamp as
(
    select payload_id, max(payload_timestamp_utc) payload_timestamp_utc 
    from {{ ref('raw_tests') }}
    group by payload_id
),
pivot_results as
(
    select
        payload_id, ifnull("'error'",0) as error, ifnull("'fail'",0) as fail, ifnull("'pass'",0) as pass
    from grouped_results
    pivot(sum(status_count) for status in ('pass', 'fail', 'error'))
)
select
    case
        when (error > 0 or fail > 0) then 'Warning: some data quality issues were detected'
        else 'It seems that everything is okay'
    end as status,
    case
        when (sf.status = 'error') or (sf.status = 'warn') then 1
        else 0
    end as status_code,
    ,pr.error
    ,pr.fail
    ,pr.pass
    ,ls.payload_timestamp_utc
from pivot_results pr
left join latest_timestamp ls on pr.payload_id = ls.payload_id
