with
    visited_subsection_pages as (
        select distinct
            date(navigation.emission_time) as visited_on,
            navigation.org as org,
            navigation.course_key as course_key,
            navigation.actor_id as actor_id,
            navigation.block_id as block_id,
            course_blocks.display_name_with_location as section_subsection_name,
        from {{ ref("navigation_events") }} navigation
    ),
    pages_per_subsection as (
        select * from ({{ items_per_subsection("%@vertical+block@%") }})
    )
select
    visits.visited_on as visited_on,
    visits.org as org,
    visits.course_key as course_key,
    blocks.course_run as course_run,
    {{ section_from_display("blocks.display_name_with_location") }}
    as section_number,
    {{ subsection_from_display("blocks.display_name_with_location") }}
    as subsection_number,
    pages.section_with_name as section_with_name,
    pages.subsection_with_name as subsection_with_name,
    pages.course_order as course_order,
    pages.item_count as page_count,
    visits.actor_id as actor_id,
    visits.block_id as block_id,
    pages.section_block_id as section_block_id,
    pages.subsection_block_id as subsection_block_id,
from visited_subsection_pages visits
join
    {{ ref("dim_course_blocks") }} blocks
    on (
        navigation.course_key = blocks.course_key
        and navigation.block_id = blocks.block_id
    )
join
    pages_per_subsection pages
    on (
        visits.org = pages.org
        and visits.course_key = pages.course_key
        and section_number = pages.section_number
        and subsection_number = pages.subsection_number
    )
