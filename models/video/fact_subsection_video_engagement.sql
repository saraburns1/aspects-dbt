{{
    config(
        materialized="materialized_view",
        engine=get_engine("ReplacingMergeTree()"),
        primary_key="(org, course_key)",
        order_by="(org, course_key, subsection_block_id, actor_id)",
    )
}}

with
    fact_video_completion as (
        select * from {{ ref('fact_video_completion') }}
    ),
    subsection_counts as (
        select
            org,
            course_key,
            section_with_name,
            subsection_with_name,
            actor_id,
            item_count,
            count(distinct video_id) as videos_viewed,
            case
                when videos_viewed = 0
                then 'No videos viewed yet'
                when videos_viewed = item_count
                then 'All videos viewed'
                else 'At least one video viewed'
            end as engagement_level,
            subsection_block_id,
            section_block_id
        from fact_video_engagement_per_subsection
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
    section_block_id,
    item_count,
    videos_viewed
from subsection_counts
