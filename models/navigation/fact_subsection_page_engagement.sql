{{
    config(
        materialized="materialized_view",
        engine=get_engine("ReplacingMergeTree()"),
        primary_key="(org, course_key)",
        order_by="(org, course_key, subsection_block_id, actor_id)",
    )
}}

with
    fact_navigation_completion as (
        select * from {{ ref('fact_navigation_completion') }}
    ),
    subsection_counts as (
        select
            org,
            course_key,
            course_run, 
            section_with_name,
            subsection_with_name,
            actor_id,
            item_count,
            count(distinct block_id) as pages_visited,
            case
                when pages_visited = 0
                then 'No pages viewed yet'
                when pages_visited = item_count
                then 'All pages viewed'
                else 'At least one page viewed'
            end as engagement_level,
            subsection_block_id,
            section_block_id
        from fact_navigation_completion
        group by
            org,
            course_key,
            course_run, 
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
    course_run, 
    actor_id, 
    engagement_level,
    item_count,
    pages_visited,
    subsection_block_id,
    section_block_id
from subsection_counts
