with
    most_recent_overviews as (
        select org, course_key, max(modified) as last_modified
        from {{ source("event_sink", "course_overviews") }}
        group by org, course_key
    ),
    most_recent_course_tags as (
        select
            course_key,
            display_name as course_name,
            splitByString('+', course_key)[-1] as course_run,
            org,
            JSONExtract(course_data_json, 'tags', 'String') as tags_str
        from {{ source("event_sink", "course_overviews") }} co
        inner join
            most_recent_overviews mro
            on co.org = mro.org
            and co.course_key = mro.course_key
            and co.modified = mro.last_modified
    ),
    parsed_tags as (
        select
            course_key,
            course_name,
            JSONExtractKeys(tags_str) as taxonomy,
            JSONExtractKeysAndValues(tags_str, 'String') as tags_keys,
            arrayJoin(tags_keys) as taxonomy_tuple,
            taxonomy_tuple .1 as taxonomy_name,
            taxonomy_tuple .2 as tags_array_str,
            JSONExtractArrayRaw(tags_array_str) as tags,
            trim(BOTH '\"\"' from arrayJoin(tags)) as tag
        from most_recent_course_tags
    ),
    most_recent_object_tags as (
        select id, max(time_last_dumped) as last_modified
        from {{ source("event_sink", "object_tag") }}
        group by id
    ),
    tags_table as (
        select
            object_id,
            _value,
            lineage,
            trim(BOTH '\"\"' from arrayJoin(JSONExtractArrayRaw(lineage))) tag,
            tax.name AS taxonomy_name
        from {{ source("event_sink", "object_tag") }} ot
        inner join
            most_recent_object_tags mrot
            on mrot.id = ot.id
            and ot.time_last_dumped = mrot.last_modified
            INNER JOIN event_sink.taxonomy AS tax ON tax.id = taxonomy
    )
select
    pt.course_key course_key,
    pt.course_name course_name,
    pt.taxonomy_name,
    tt.tag tag,
    tt.lineage lineage
from parsed_tags pt
inner join tags_table tt on (course_key = object_id) and (pt.tag = _value) and (tt.taxonomy_name = pt.taxonomy_name)
