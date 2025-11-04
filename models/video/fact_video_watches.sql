{{
    config(
        materialized="materialized_view",
        engine=get_engine("ReplacingMergeTree()"),
        primary_key="(org, course_key, block_id, actor_id)",
        order_by="(org, course_key, block_id, actor_id)",
    )
}}

with
    watched_video_segments as (
        select
            org,
            course_key,
            actor_id,
            block_id,
            object_id,
            watched_segment,
            sum(watch_count) as watched_count,
            video_duration
        from {{ ref("fact_video_segments") }}
        group by
            org,
            course_key,
            actor_id,
            object_id,
            block_id,
            watched_segment,
            video_duration
    ),
    aggregate as (
        select
            org,
            course_key,
            actor_id,
            video_duration,
            object_id,
            block_id,
            count(watched_segment) as _total_segments_watched,
            max(watched_count) as video_watched_count,
            max(
                case when watched_count > 1 then watched_count else 0 end
            ) as video_rewatched_count
        from watched_video_segments
        group by org, course_key, object_id, block_id, actor_id, video_duration
    ),
    final_results as (
        select
            aggregate.org,
            aggregate.course_key,
            {{ format_object_location("blocks.display_name_with_location") }},  -- object_location, object_name_location
            aggregate.actor_id,
            aggregate.video_watched_count,
            aggregate.video_rewatched_count,
            aggregate._total_segments_watched / aggregate.video_duration
            >= .95 as watched_entire_video,
            concat(
                '<a href="',
                aggregate.object_id,
                '" target="_blank">',
                object_name_location,
                '</a>'
            ) as video_link,
            blocks.section_with_name as section_with_name,
            blocks.subsection_with_name as subsection_with_name,
            aggregate.block_id as block_id
        from aggregate
        join
            {{ ref("dim_course_blocks") }} blocks
            on (
                aggregate.course_key = blocks.course_key
                and aggregate.block_id = blocks.block_id
            )
    )
select
    org,
    course_key,
    object_location as video_location,
    object_name_location as video_name_location,
    actor_id,
    video_watched_count,
    video_rewatched_count,
    watched_entire_video,
    video_link,
    section_with_name,
    subsection_with_name,
    block_id
from final_results
