{{
    config(
        materialized="dictionary",
        fields=[
            ("course_key", "String"),
            ("tag", "String"),
            ("tag_id", "Int32"),
        ],
        primary_key="(course_key, tag)",
        layout="COMPLEX_KEY_HASHED()",
        lifetime=env_var("ASPECTS_COURSE_NAME_CACHE_LIFETIME", "120"),
        source_type="clickhouse",
        connection_overrides={
            "host": "localhost",
        },
    )
}}

select 
    course_names.course_key as course_key, 
    most_recent_tags.value as tag,
    arrayJoin(JSONExtractArrayRaw(course_names.tags_str))::Int32 as tag_id
from {{ ref("dim_course_names") }} course_names
inner join {{ ref("dim_most_recent_tags") }} most_recent_tags FINAL on most_recent_tags.id = tag_id
