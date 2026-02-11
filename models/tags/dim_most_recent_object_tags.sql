{{
    config(
        materialized="materialized_view",
        schema=env_var("ASPECTS_EVENT_SINK_DATABASE", "event_sink"),
        engine=get_engine("ReplacingMergeTree()"),
        order_by="(id)",
        post_hook="OPTIMIZE TABLE {{ this }} {{ on_cluster() }} FINAL",
    )
}}
with
    latest as (
        select id, max(time_last_dumped) as last_modified
        from {{ source("event_sink", "object_tag") }}
        group by id
    )
select
    object_tag.id as id,
    object_tag.object_id as object_id,
    object_tag.taxonomy as taxonomy,
    object_tag._value as _value,
    object_tag._export_id as _export_id,
    object_tag.lineage as lineage
from {{ source("event_sink", "object_tag") }} object_tag
inner join
    latest
    on latest.id = object_tag.id
    and object_tag.time_last_dumped = latest.last_modified
