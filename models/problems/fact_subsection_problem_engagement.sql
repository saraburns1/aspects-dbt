{{
    config(
        materialized="materialized_view",
        engine=get_engine("ReplacingMergeTree()"),
        primary_key="(org, course_key)",
        order_by="(org, course_key, subsection_block_id, actor_id)",
    )
}}

with
    fact_problem_completion as (
        select * from {{ ref('fact_problem_completion') }}
    ),
    subsection_counts as (
        select
            org,
            course_key,
            section_with_name,
            subsection_with_name,
            actor_id,
            item_count,
            count(distinct problem_id) as problems_attempted,
            case
                when problems_attempted = 0
                then 'No problems attempted yet'
                when problems_attempted = item_count
                then 'All problems attempted'
                else 'At least one problem attempted'
            end as engagement_level,
            subsection_block_id,
            section_block_id
        from fact_problem_completion
        group by
            org,
            course_key,
            section_with_name,
            subsection_with_name,
            actor_id,
            item_count,
            subsection_block_id,
            section_block_id
    )
select 
    org, 
    course_key, 
    actor_id, 
    subsection_block_id, 
    engagement_level,
    item_count,
    problems_attempted,
    section_block_id
from subsection_counts
