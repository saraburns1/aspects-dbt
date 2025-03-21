select
    enrollments.emission_time as emission_time,
    enrollments.org as org,
    enrollments.course_key as course_key,
    enrollments.actor_id as actor_id,
    enrollments.enrollment_status as enrollment_status
from {{ ref("enrollment_events") }} enrollments