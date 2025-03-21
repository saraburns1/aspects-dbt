{{
    config(
        materialized="dictionary",
        schema=env_var("ASPECTS_EVENT_SINK_DATABASE", "event_sink"),
        fields=[
            ("user_id", "Int32"),
            ("external_user_id", "String"),
            ("username", "String"),
            ("name", "String"),
            ("email", "String"),
        ],
        primary_key="(user_id, external_user_id)",
        layout="COMPLEX_KEY_SPARSE_HASHED()",
        lifetime=env_var("ASPECTS_PII_CACHE_LIFETIME", "120"),
        source_type="clickhouse",
        connection_overrides={
            "host": "localhost",
        },
    )
}}

with
    most_recent_user_profile as (
        select 
            user_id, 
            argMax(username, time_last_dumped) as username,
            argMax(name, time_last_dumped) as name,
            argMax(email, time_last_dumped) as email
        from {{ source("event_sink", "user_profile") }}
        group by user_id
    )
select
    external_id.user_id as user_id,
    if(
        empty(external_id.external_user_id),
        concat('mailto:', email),
        external_id.external_user_id::String
    ) as external_user_id,
    user.username as username,
    user.name as name,
    user.email as email
from most_recent_user_profile user
left outer join
    {{ source("event_sink", "external_id") }} external_id on user.user_id = external_id.user_id
