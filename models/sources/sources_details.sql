select distinct
    sfm.source_name,
    sfm.source_description,
    sfm.loader,
    sf.snapshotted_at,
    sf.status,
    case
        when (sf.status = 'error') then 100
        when (sf.status = 'warn') then 50
        when (sf.status = 'pass') then 0
        else -1
    end as status_code,
    sfm.database as source_database,
    sfm.schema as source_schema,
    sfm.name as table_name,
    sfm.description table_description,
    (   
        'warn: ' || ifnull('after' || sf.freshness_warn_count::string || ' ' || sf.freshness_warn_period , 'undefined') || ', ' ||
        'error: ' || ifnull('after' || sf.freshness_error_count::string || ' ' || sf.freshness_error_period , 'undefined')
    ) as freshness_check,
    sf.freshness_filter
from {{ ref('raw_source_freshness_manifest') }} sfm
left join {{ ref('raw_source_freshness') }} sf on sf.unique_id = sfm.unique_id
where sf.payload_timestamp_utc = (select max(payload_timestamp_utc) from {{ ref('raw_source_freshness') }})