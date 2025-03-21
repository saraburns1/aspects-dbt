{{
    config(
        materialized="materialized_view",
        schema=env_var("ASPECTS_EVENT_SINK_DATABASE", "event_sink"),
        engine=get_engine("ReplacingMergeTree()"),
        order_by="(location)",
        post_hook="OPTIMIZE TABLE {{ this }} {{ on_cluster() }} FINAL",
    )
}}

with 
    latest as (
        select 
            location, 
            argMax(display_name, time_last_dumped) as block_name,
            argMax(xblock_data_json, time_last_dumped) as xblock_data_json,
            argMax(order, time_last_dumped) as course_order,
            argMax(course_key, time_last_dumped) as course_key,
            argMax(dump_id, time_last_dumped) as dump_id,
            argMax(section, time_last_dumped) as section,
            argMax(subsection, time_last_dumped) as subsection,
            argMax(unit, time_last_dumped) as unit,
            max(time_last_dumped) as max_time_last_dumped
        from {{ source("event_sink", "course_blocks") }}
        group by location
    )
select
    location,
    block_name,
    toString(section)
    || ':'
    || toString(subsection)
    || ':'
    || toString(unit)
    || ' - '
    || block_name as display_name_with_location,
    JSONExtractInt(xblock_data_json, 'section') as section,
    JSONExtractInt(xblock_data_json, 'subsection') as subsection,
    JSONExtractInt(xblock_data_json, 'unit') as unit,
    JSONExtractBool(xblock_data_json, 'graded') as graded,
    course_order,
    course_key,
    dump_id,
    max_time_last_dumped as time_last_dumped
from latest
