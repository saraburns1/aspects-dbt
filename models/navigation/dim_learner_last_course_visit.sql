{{
    config(
        materialized="materialized_view",
        engine=get_engine("ReplacingMergeTree(emission_time)"),
        primary_key="(org, course_key, actor_id)",
        order_by="(org, course_key, actor_id)",
        ttl=env_var("ASPECTS_DATA_TTL_EXPRESSION", ""),
    )
}}

select org, course_key, actor_id, max(emission_time) as emission_time
from {{ ref("navigation_events") }}
group by org, course_key, actor_id
