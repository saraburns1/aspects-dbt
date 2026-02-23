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
        from {{ source("event_sink", "tag") }}
        group by id
    )
select
    tag.id as id,
    tag.taxonomy as taxonomy,
    tag.parent as parent,
    tag.value as value,
    tag.external_id as external_id,
    tag.lineage as lineage
from {{ source("event_sink", "tag") }} tag
inner join latest on latest.id = tag.id and tag.time_last_dumped = latest.last_modified
