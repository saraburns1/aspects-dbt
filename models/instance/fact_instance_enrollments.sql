{{
    config(
        materialized="materialized_view",
        engine=get_engine("SummingMergeTree()"),
        order_by="(emission_day, course_key, enrollment_mode, enrollment_status)",
        partition_by="(toYYYYMM(emission_day))",
    )
}}

with
    enrollments as (
        select
            emission_time,
            course_key,
            enrollment_mode,
            splitByString('/', verb_id)[-1] as enrollment_status
        from {{ ref("enrollment_events") }}
    )

select
    date_trunc('day', emission_time) as emission_day,
    course_key,
    enrollment_mode,
    enrollment_status,
    count() as course_enrollment_mode_status_cnt
from enrollments
group by emission_day, course_key, enrollment_mode, enrollment_status
