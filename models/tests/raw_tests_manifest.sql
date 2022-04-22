{{
    config(materialized='table')
}}

with dedup_logs as
(
    select s.*
    from {{ source('dbt_dataquality', 'stg_dbt_dataquality') }} s
    where s.upload_timestamp_utc = (
        select max(upload_timestamp_utc)
        from {{ source('dbt_dataquality', 'stg_dbt_dataquality') }}
        where filename = 'manifest.json.gz'
    )
),
flatten_records as
(
    select
        payload_id
        ,payload_timestamp_utc
        ,tests.key::string unique_id
        ,tests_content.key
        ,case
            when tests_content.key = 'tags' 
                then coalesce(replace(replace(replace(regexp_substr(replace(replace(tests_content.value,' '),'\'','"'), '(dq:)[^,]+(",)|(dq:)[^,]+("])'),'dq:'),'",'),'"]'),'unkonwn')
            when tests_content.key = 'column_name' 
                then coalesce(tests_content.value, 'n/a')
            else tests_content.value
        end as value
    from dedup_logs
    ,lateral flatten(input => payload:nodes) as tests
    ,lateral flatten(input => tests.value ) as tests_content
    where 
        tests_content.key in ('name', 'column_name', 'database', 'description', 'file_key_name', 'package_name', 'tags')
        and unique_id like 'test%'
)
,
cleaning_records as
(
    select
        payload_id
        ,payload_timestamp_utc
        ,unique_id
        ,"'name'"::string name
        ,"'package_name'"::string package_name    
        ,"'database'"::string database
        ,"'description'"::string description
        ,"'column_name'"::string column_name
        ,"'file_key_name'"::string file_key_name
        ,"'tags'"::string tags
    from flatten_records
    pivot(max(value) for key in 
        ('name', 'column_name', 'database', 'description', 'file_key_name', 'package_name', 'tags'))
)
select * from cleaning_records
