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
        payload_id, ifnull("'error'",0) as stale, ifnull("'warning'",0) as warning, ifnull("'okay'",0) as okay
    from grouped_results
    pivot(sum(status_count) for status in ('error', 'warning', 'okay'))    
)
select pr.*, ls.payload_timestamp_utc
from pivot_results pr
left join latest_timestamp ls on pr.payload_id = ls.payload_id
