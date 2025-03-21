with
    video_playback_events as (
        select
            emission_time,
            org,
            course_key,
            object_id,
            video_duration,
            video_position,
            splitByString('/xblock/', object_id)[-1] as video_id,
            actor_id
        from {{ ref("video_playback_events") }}
        where verb_id = 'https://w3id.org/xapi/video/verbs/played'
    ),
    fact_video_plays as (
        select distinct
            date(plays.emission_time) as viewed_on,
            plays.org as org,
            plays.course_key as course_key,
            plays.video_id as video_id,
            blocks.section_number as section_number,
            blocks.subsection_number as subsection_number,
            blocks.course_order
            plays.actor_id as actor_id
        from video_playback_events plays
        join
            {{ ref("dim_course_blocks") }} blocks
            on (
                plays.course_key = blocks.course_key
                and plays.video_id = blocks.block_id
            )
    ),
    fact_videos_per_subsection as (
        select * from ({{ items_per_subsection("%@video+block@%") }})
    )
select
    fact_video_plays.org as org,
    fact_video_plays.course_key as course_key,
    fact_videos_per_subsection.section_with_name as section_with_name,
    fact_videos_per_subsection.subsection_with_name as subsection_with_name,
    fact_videos_per_subsection.item_count as item_count,
    fact_video_plays.actor_id as actor_id,
    fact_video_plays.video_id as video_id,
    fact_video_plays.course_order as course_order,
    fact_videos_per_subsection.subsection_block_id as subsection_block_id
from fact_video_plays
join
    fact_videos_per_subsection
    on (
        fact_video_plays.org = fact_videos_per_subsection.org
        and fact_video_plays.course_key = fact_videos_per_subsection.course_key
        and fact_video_plays.section_number = fact_videos_per_subsection.section_number
        and fact_video_plays.subsection_number = fact_videos_per_subsection.subsection_number
    )