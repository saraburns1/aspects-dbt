{{
    config(
        materialized="materialized_view",
        engine=get_engine("ReplacingMergeTree()"),
        primary_key="(org, course_key)",
        order_by="(org, course_key, section_block_id, actor_id)",
    )
}}

with
    fact_subsection_page_engagement as (
        select * from {{ ref('fact_subsection_page_engagement') }}
    ),
    section_counts as (
        select
            org,
            course_key,
            course_run,
            actor_id,
            sum(item_count) as item_count,
            sum(pages_visited) as pages_visited,
            case
                when pages_visited = 0
                then 'No pages viewed yet'
                when pages_visited = item_count
                then 'All pages viewed'
                else 'At least one page viewed'
            end as engagement_level,
            section_block_id
        from fact_subsection_page_engagement
        group by org, course_key, course_run, section_block_id, actor_id
    )

select org, course_key, course_run, actor_id, section_block_id, engagement_level
from section_counts
