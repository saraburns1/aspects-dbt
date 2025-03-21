{{
    config(
        materialized="materialized_view",
        engine=get_engine("ReplacingMergeTree()"),
        primary_key="(org, course_key)",
        order_by="(org, course_key, actor_id)",
    )
}}

with
    subsection_engagement as (
        select
            org,
            course_key,
            'subsection' as content_level,
            actor_id,
            subsection_block_id as block_id,
            engagement_level as section_subsection_page_engagement,
            course_run
        from {{ ref("fact_subsection_page_engagement") }}
    ),
    section_engagement as (
        select
            org,
            course_key,
            'section' as content_level,
            actor_id,
            section_block_id as block_id,
            engagement_level as section_subsection_page_engagement,
            course_run
        from {{ ref("fact_section_page_engagement") }}
    ),
    page_engagement as (
        select *
        from subsection_engagement
        union all
        select *
        from section_engagement
    )
select
    page_engagement.org as org,
    page_engagement.course_key as course_key,
    page_engagement.course_run as course_run,
    course_blocks.display_name_with_location as section_subsection_name,
    page_engagement.content_level as content_level,
    page_engagement.actor_id as actor_id,
    page_engagement.section_subsection_page_engagement as section_subsection_page_engagement
from page_engagement
join
    {{ ref("dim_course_blocks") }} course_blocks
    on (
        page_engagement.org = course_blocks.org
        and page_engagement.course_key = course_blocks.course_key
        and page_engagement.block_id = course_blocks.block_id
    )
