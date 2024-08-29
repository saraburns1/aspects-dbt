with latest as (
        select id, max(time_last_dumped) as last_modified
        from {{ source("event_sink", "object_tag") }}
        group by id
    ),
    most_recent as (
        select
            object_id,
            _value,
            lineage,
            taxonomy,
            trim(BOTH '\"\"' from arrayJoin(JSONExtractArrayRaw(lineage))) tag
        from {{ source("event_sink", "object_tag") }} ot
        inner join
            latest mrot
            on mrot.id = ot.id
            and ot.time_last_dumped = mrot.last_modified
    )
select * from most_recent
