with latest_records as
(
    select         
        payload_id
        ,payload_timestamp_utc        
        ,unique_id        
        ,status
        ,case
            when (status = 'error') then 100
            when (status = 'warn') then 50
            when (status = 'pass') then 0
            else -1
        end as status_code
        ,freshness_warn_count
        ,freshness_warn_period
        ,freshness_error_count
        ,freshness_error_period
        ,snapshotted_at
        ,freshness_filter
    from {{ ref('raw_source_freshness') }}
    where payload_timestamp_utc = (select max(payload_timestamp_utc) from {{ ref('raw_source_freshness') }})
)
select
    lr.payload_id
    ,lr.payload_timestamp_utc
    ,lr.snapshotted_at    
    ,lr.freshness_filter    
    ,sfm.source_name
    ,sfm.source_description
    ,sfm.loader
    ,sfm.database as source_database
    ,sfm.schema as source_schema
    ,sfm.name as table_name
    ,sfm.description table_description
    ,(
        'warn: ' || ifnull('after' || lr.freshness_warn_count::string || ' ' || lr.freshness_warn_period , 'undefined') || ', ' ||
        'error: ' || ifnull('after' || lr.freshness_error_count::string || ' ' || lr.freshness_error_period , 'undefined')
    ) as freshness_check
from latest_records lr
    left join {{ ref('raw_source_freshness_manifest') }} sfm
        on lr.unique_id = sfm.unique_id
