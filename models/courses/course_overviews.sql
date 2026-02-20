/* This model is a view of the base table course_overviews. This view should be used for any 
 dictionaries querying course_overviews instead of the base table in order for unit test 
 seed refreshes to drop and recreate properly. */
select
    org,
    course_key,
    display_name,
    course_start,
    course_end,
    enrollment_start,
    enrollment_end,
    self_paced,
    course_data_json,
    created,
    modified,
    dump_id,
    time_last_dumped
from {{ source("event_sink", "course_overviews") }}
