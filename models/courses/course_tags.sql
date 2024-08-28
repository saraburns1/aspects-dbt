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
    )
select course_key, course_name, taxonomy_name, tag, lineage
from parsed_tags
inner join
    {{ source("event_sink", "object_tag") }} as ot
    on (course_key = object_id)
    and (parsed_tags.tag = _value)
