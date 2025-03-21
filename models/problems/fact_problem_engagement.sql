{{
    config(
        materialized="materialized_view",
        engine=get_engine("ReplacingMergeTree()"),
        primary_key="(org, course_key)",
        order_by="(org, course_key, subsection_block_id, actor_id)",
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
            engagement_level as section_subsection_problem_engagement
        from {{ ref('fact_subsection_problem_engagement') }}
    ),
    section_engagement as (
        select
            org,
            course_key,
            'section' as content_level,
            actor_id,
            section_block_id as block_id,
            engagement_level as section_subsection_problem_engagement
        from {{ ref('fact_section_problem_engagement') }}
    ),
    problem_engagement as (
        select *
        from subsection_engagement
        union all
        select *
        from section_engagement
    )
select
    problem_engagement.org as org,
    problem_engagement.course_key as course_key,
    course_blocks.course_run as course_run,
    course_blocks.display_name_with_location as section_subsection_name,
    problem_engagement.content_level as content_level,
    problem_engagement.actor_id as actor_id,
    problem_engagement.section_subsection_problem_engagement as section_subsection_problem_engagement
from problem_engagement
join
    {{ ref("dim_course_blocks") }} course_blocks
    on (
        problem_engagement.org = course_blocks.org
        and problem_engagement.course_key = course_blocks.course_key
        and problem_engagement.block_id = course_blocks.block_id
    )
