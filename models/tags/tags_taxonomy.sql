select
    mot.name taxonomy_name,
    mrot.object_id object_id,
    mrot.lineage lineage,
    trim(BOTH '\"\"' from arrayJoin(JSONExtractArrayRaw(lineage))) tag
from {{ ref("most_recent_object_tags") }} mrot
inner join {{ ref("most_recent_taxonomies") }} mot on mrot.taxonomy = mot.id
