select
    sf.*,
    sfm.database,
    sfm.schema,
    sfm.description,
    sfm.loader,
    sfm.source_name,
    sfm.source_description,
    sfm.package_name,
    sfm.loaded_at_field
from {{ ref('raw_source_freshness') }} sf
left join {{ ref('raw_source_freshness_manifest') }} sfm on sf.unique_id = sfm.unique_id
