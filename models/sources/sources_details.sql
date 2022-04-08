select distinct
    sfm.source_name,
    sfm.source_description,
    sfm.loader,
    sf.snapshotted_at,
    sf.status,
    case
        when (sf.status = 'error') then 2
        when (sf.status = 'warning') then 1
        else 0
    end as status_code,
    sfm.database as source_database,
    sfm.schema as source_schema,
    sfm.name as table_name,
    sfm.description table_description,
    sf.freshness_warn_count,
    sf.freshness_warn_period,
    sf.freshness_error_count,
    sf.freshness_error_period,
    sf.freshness_filter
from {{ ref('raw_source_freshness') }} sf
left join {{ ref('raw_source_freshness_manifest') }} sfm on sf.unique_id = sfm.unique_id
where sf.payload_timestamp_utc >= (select max(payload_timestamp_utc) from my_database.my_schema.raw_source_freshness)