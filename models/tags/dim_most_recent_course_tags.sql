{{
    config(
        materialized="dictionary",
        fields=[
            ("course_key", "String"),
            ("tag", "String"),
            ("course_name", "String"),
            ("taxonomy_name", "String"),
            ("lineage", "String"),
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

with
    parsed_tags as (
        select
            course_key,
            course_name,
            arrayJoin(JSONExtractArrayRaw(tags_str))::Int32 as tag_id
        from {{ ref("dim_course_names") }}
    )
select
    parsed_tags.course_key as course_key,
    most_recent_tags.value as tag,
    parsed_tags.course_name as course_name,
    most_recent_taxonomies.name as taxonomy_name,
    most_recent_tags.lineage as lineage,
    parsed_tags.tag_id as tag_id
from parsed_tags
inner join
    {{ ref("dim_most_recent_tags") }} most_recent_tags FINAL
    on most_recent_tags.id = parsed_tags.tag_id
inner join
    {{ ref("dim_most_recent_taxonomies") }} most_recent_taxonomies FINAL
    on most_recent_taxonomies.id = most_recent_tags.taxonomy
