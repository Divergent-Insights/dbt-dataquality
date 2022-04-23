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
pivot_results as
(
    select
        payload_id, ifnull("'error'",0) as error, ifnull("'fail'",0) as fail, ifnull("'pass'",0) as pass
    from grouped_results
    pivot(sum(status_count) for status in ('pass', 'fail', 'error'))
),
clean_pivot_results as
(
    select
        payload_id
        ,case
            when (error > 0 or fail > 0) then 'Warning: some data quality issues were detected'
            else 'It seems that everything is okay'
        end as status
        ,case
            when (error > 0 or fail > 0) then 1
            else 0
        end as status_code
        ,error
        ,fail
        ,pass
    from pivot_results
)
select
    distinct
    lr.payload_id
    ,lr.payload_timestamp_utc
    ,cpv.status
    ,cpv.status_code
    ,cpv.error
    ,cpv.fail
    ,cpv.pass
from latest_records lr
    left join clean_pivot_results cpv on cpv.payload_id = lr.payload_id
