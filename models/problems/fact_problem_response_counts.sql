{{
    config(
        materialized="materialized_view",
        engine=get_engine("AggregatingMergeTree()"),
        order_by="(org, course_key, problem_id, object_id, interaction_type, success, response)",
    )
}}

with
    first_responses as (
        select
            org,
            course_key,
            problem_id,
            object_id,
            interaction_type,
            success,
            actor_id,
            replaceRegexpAll(
                responses, '<.*?hint.*?<\/.*?hint>|</div>|<div>|\[|\]', ''
            ) as _response1,
            replaceRegexpAll(_response1, '",(\s|)"', ',') as _response2,
            case
                when responses like '[%'
                then arrayJoin(splitByChar(',', replaceAll(_response2, '"', '')))
                else _response2
            end as response
        from {{ ref("problem_events") }}
        where verb_id = 'https://w3id.org/xapi/acrossx/verbs/evaluated' and attempts = 1
    )
select
    org,
    course_key,
    problem_id,
    object_id,
    interaction_type,
    success,
    response,
    uniqExactState(actor_id) as learners
from first_responses
group by org, course_key, problem_id, object_id, interaction_type, success, response
