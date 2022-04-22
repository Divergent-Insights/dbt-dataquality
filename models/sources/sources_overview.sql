with latest_records as
(
    select payload_id, status, payload_timestamp_utc
    from {{ ref('raw_source_freshness') }}
    where payload_timestamp_utc = (select max(payload_timestamp_utc) from {{ ref('raw_source_freshness') }})
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
        payload_id, ifnull("'error'",0) as stale, ifnull("'warn'",0) as warning, ifnull("'pass'",0) as pass
    from grouped_results
    pivot(sum(status_count) for status in ('error', 'warn', 'pass'))    
),
clean_pivot_results as
(
    select
        payload_id
        ,case
            when (stale > 0 or warning > 0) then 'Warning: some data sources require attention'
            else 'It seems that everything is okay'
        end as status
        ,case
            when (stale > 0 or warning > 0) then 1
            else 0
        end as status_code
        ,stale
        ,warning
        ,pass
    from pivot_results pr
)
select
    distinct
    lr.payload_id
    ,lr.payload_timestamp_utc
    ,cpv.status
    ,cpv.status_code
    ,cpv.stale
    ,cpv.warning
    ,cpv.pass
from latest_records lr
    left join clean_pivot_results cpv on cpv.payload_id = lr.payload_id
