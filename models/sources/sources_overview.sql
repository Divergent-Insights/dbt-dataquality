with latest_snapshot as
(
    select payload_id, status
    from {{ ref('raw_source_freshness') }}
    where payload_timestamp_utc >= (select max(payload_timestamp_utc) from my_database.my_schema.raw_source_freshness)
),
grouped_results as
(
    select payload_id, status, count(status) status_count
    from latest_snapshot
    group by payload_id, status
),
pivot_results as
(
    select
        payload_id, ifnull("'error'",0) as stale, ifnull("'warning'",0) as warning, ifnull("'okay'",0) as okay
    from grouped_results    
    pivot(sum(status_count) for status in ('error', 'warning', 'okay'))
    
)
select * from pivot_results
