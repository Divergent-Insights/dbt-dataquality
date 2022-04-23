with error as
(
    select quality_tag, count(*) error
    from {{ ref('tests_details') }}
    where status = 'error'
    group by quality_tag
)
,fail as
(
    select quality_tag, count(*) fail
    from {{ ref('tests_details') }}
    where status = 'fail'
    group by quality_tag
)
,pass as
(
    select quality_tag, count(*) pass
    from {{ ref('tests_details') }}
    where status = 'pass'
    group by quality_tag
)
,all_status as
(
    select
        distinct
        td.payload_id
        ,td.payload_timestamp_utc
        ,td.quality_tag
        ,coalesce(error.error,0) error
        ,coalesce(fail.fail,0) fail
        ,coalesce(pass.pass,0) pass
        ,(coalesce(error.error,0) + coalesce(fail.fail,0) + coalesce(pass.pass,0)) total
    from {{ ref('tests_details') }} td
        left join error on td.quality_tag = error.quality_tag
        left join fail on td.quality_tag = fail.quality_tag
        left join pass on td.quality_tag = pass.quality_tag
)
select 
    * 
    ,sum(total) over (partition by payload_id) as tests_count
    ,sum(pass) over (partition by payload_id) as tests_passed
    ,((sum(pass) over (partition by payload_id))*100)/(sum(total) over (partition by payload_id)) as overall_tests_success
    ,(pass * 100 / total) as quality_coverage
from all_status