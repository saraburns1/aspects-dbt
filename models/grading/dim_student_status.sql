select
    most_recent_enrollment.org as org,
    most_recent_enrollment.course_key as course_key,
    most_recent_enrollment.actor_id as actor_id,
    course_names.course_name as course_name,
    course_names.course_run as course_run,
    if(empty(learner_course_state.approving_state), 'failed', learner_course_state.approving_state) as approving_state,
    most_recent_enrollment.enrollment_mode,
    most_recent_enrollment.enrollment_status,
    learner_course_grade.course_grade,
    {{ get_bucket("course_grade") }} as grade_bucket,
    users.username as username,
    users.name as name,
    users.email as email,
    most_recent_enrollment.emission_time as enrolled_at
from {{ ref("dim_most_recent_enrollment") }} most_recent_enrollment
left join
    {{ ref("dim_learner_most_recent_course_state") }} learner_course_state
    on most_recent_enrollment.org = learner_course_state.org
    and most_recent_enrollment.course_key = learner_course_state.course_key
    and most_recent_enrollment.actor_id = learner_course_state.actor_id
left join
    {{ ref("dim_learner_most_recent_course_grade") }} learner_course_grade
    on most_recent_enrollment.org = learner_course_grade.org
    and most_recent_enrollment.course_key = learner_course_grade.course_key
    and most_recent_enrollment.actor_id = learner_course_grade.actor_id
join
    {{ ref("dim_course_names") }} course_names
    on most_recent_enrollment.org = course_names.org
    and most_recent_enrollment.course_key = course_names.course_key
left outer join
    {{ ref("dim_user_pii") }} users
    on (actor_id like 'mailto:%' and SUBSTRING(actor_id, 8) = users.email)
    or actor_id = toString(users.external_user_id)
