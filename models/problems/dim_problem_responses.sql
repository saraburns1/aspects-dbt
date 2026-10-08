with
    final_results as (
        select
            counts.org as org,
            counts.course_key as course_key,
            splitByChar('@', counts.problem_id)[3] as block_id_short,
            counts.response as response,
            counts.success as success,
            counts.interaction_type as interaction_type,
            counts.learners as learners,
            {{
                format_problem_number_location(
                    "counts.object_id", "blocks.display_name_with_location"
                )
            }}
        from {{ ref("fact_problem_response_counts") }} counts
        left join
            {{ ref("dim_course_blocks") }} blocks
            on (
                counts.course_key = blocks.course_key
                and counts.problem_id = blocks.block_id
            )
    )
select
    org,
    course_key,
    block_id_short,
    response,
    success,
    interaction_type,
    problem_number,
    problem_name_location,
    uniqExactMerge(learners) as response_count
from final_results
group by
    org,
    course_key,
    block_id_short,
    response,
    success,
    interaction_type,
    problem_number,
    problem_name_location
