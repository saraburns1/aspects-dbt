/* This model is a view of the base table user_profile. This view should be used for any 
 dictionaries querying user_profile instead of the base table in order for unit test 
 seed refreshes to drop and recreate properly. */
select
    id,
    user_id,
    name,
    username,
    email,
    meta,
    courseware,
    language,
    location,
    year_of_birth,
    gender,
    level_of_education,
    mailing_address,
    city,
    country,
    state,
    goals,
    bio,
    profile_image_uploaded_at,
    phone_number,
    dump_id,
    time_last_dumped
from {{ source("event_sink", "user_profile") }}
