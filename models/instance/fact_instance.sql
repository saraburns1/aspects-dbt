{{
    config(
        materialized="materialized_view",
        schema=env_var("ASPECTS_XAPI_DATABASE", "xapi"),
        engine=get_engine("AggregatingMergeTree()"),
        order_by="(emission_day)",
        partition_by="(toYYYYMM(emission_day))",
    )
}}

select
    date_trunc('day', emission_time) as emission_day,
    uniqCombinedState(actor_id) as actors_cnt,
    uniqCombinedState(event_id) as events_cnt,
    uniqCombinedState(course_id) as courses_cnt
from {{ ref("xapi_events_all_parsed") }}
group by emission_day
