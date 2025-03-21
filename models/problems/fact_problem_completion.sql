with
    problem_events as (
        select distinct *
        from {{ ref("problem_events") }}
        where verb_id = 'https://w3id.org/xapi/acrossx/verbs/evaluated'
    ),
    attempted_subsection_problems as (
        select distinct
            date(emission_time) as attempted_on,
            org,
            course_key,
            {{ section_from_display("display_name_with_location") }} as section_number,
            {{ subsection_from_display("display_name_with_location") }}
            as subsection_number,
            course_order,
            graded,
            actor_id,
            problem_id
        from problem_events
    ),
    problems_per_subsection as (
        select * from ({{ items_per_subsection("%@problem+block@%") }})
    )
select
    attempts.org as org,
    attempts.course_key as course_key,
    problems.section_with_name as section_with_name,
    problems.subsection_with_name as subsection_with_name,
    problems.item_count as item_count,
    attempts.actor_id as actor_id,
    attempts.problem_id as problem_id,
    problems.subsection_block_id as subsection_block_id
from attempted_subsection_problems attempts
join
    problems_per_subsection problems
    on (
        attempts.org = problems.org
        and attempts.course_key = problems.course_key
        and attempts.section_number = problems.section_number
        and attempts.subsection_number = problems.subsection_number
    )
