with dedup_logs as
(
    select s.*
    from stg_dbt_dataquality s--{{ source('dbt_dataquality', 'src_dbt_dataquality') }} s
    inner join (
        select payload_id, max(upload_timestamp_utc) as upload_timestamp_utc
        from stg_dbt_dataquality--{{ source('dbt_dataquality', 'src_dbt_dataquality') }}
        where filename = 'manifest.json.gz'
        group by payload_id
    ) dl on s.payload_id = dl.payload_id and s.upload_timestamp_utc = dl.upload_timestamp_utc
),
flatten_records as
(
    select
        payload:metadata:invocation_id,
        sources.key unique_id,
        results2.seq,
        results2.key,
        results2.value
    from dedup_logs
    ,lateral flatten(input => payload:sources) as sources
    ,lateral flatten(input => sources.value ) as results2
    where results2.key in 
        ('unique_id', 'database', 'description', 'loader', 'source_name', 'source_description', 'package_name', 'schema', 'freshness')
)
select * from flatten_records
pivot(max(value) for key in 
        ('unique_id', 'database', 'description', 'loader', 'source_name', 'source_description', 'package_name', 'schema', 'freshness'))
