/* This model is a view of the base table external_id. This view should be used for any 
 dictionaries querying external_id instead of the base table in order for unit test 
 seed refreshes to drop and recreate properly. */

select
external_user_id,
external_id_type,
username,
user_id,
dump_id,
time_last_dumped
from {{ source("event_sink", "external_id") }}
