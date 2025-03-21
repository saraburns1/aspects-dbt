{{
    config(
        materialized="materialized_view",
        engine=get_engine("ReplacingMergeTree()"),
        primary_key="(org, course_key)",
        order_by="(org, course_key, section_block_id, actor_id)",
    )
}}

with
    fact_subsection_video_engagement as (
        select * from {{ ref('fact_subsection_video_engagement') }}
    ),
    section_counts as (
        select
            org,
            course_key,
            actor_id,
            sum(item_count) as item_count,
            sum(videos_viewed) as videos_viewed,
            case
                when videos_viewed = 0
                then 'No videos viewed yet'
                when videos_viewed = item_count
                then 'All videos viewed'
                else 'At least one video viewed'
            end as engagement_level,
            section_block_id
        from fact_subsection_video_engagement
        group by org, course_key, section_block_id, actor_id
    )
select org, course_key, actor_id, section_block_id, engagement_level
from section_counts
