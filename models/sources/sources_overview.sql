with latest_records as
(
    select payload_id, status, payload_timestamp_utc
    from {{ ref('raw_source_freshness') }}
    where payload_timestamp_utc >= (select max(payload_timestamp_utc) from {{ ref('raw_source_freshness') }})
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
    from {{ ref('raw_source_freshness') }}
    group by payload_id
),
pivot_results as
(
    select
        payload_id, ifnull("'error'",0) as stale, ifnull("'warning'",0) as warning, ifnull("'pass'",0) as pass
    from grouped_results
    pivot(sum(status_count) for status in ('error', 'warning', 'pass'))    
)
select
    case
        when (stale > 0 or warning > 0) then 'Warning: some data sources require attention'
        else 'It seems that everything is okay'
    end as status
    ,pr.stale
    ,pr.warning
    ,pr.pass
    ,ls.payload_timestamp_utc
from pivot_results pr
left join latest_timestamp ls on pr.payload_id = ls.payload_id
