
{% docs actor_id %}
The xAPI actor identifier
{% enddocs %}

{% docs block_id %}
The block's unique identifier
{% enddocs %}

{% docs course_key %}
The course key for the course
{% enddocs %}

{% docs course_name %}
The name of the course
{% enddocs %}

{% docs course_order %}
The sort order of this block in the course across all course blocks
{% enddocs %}

{% docs course_run %}
The course run for the course
{% enddocs %}

{% docs display_name %}
The block's name
{% enddocs %}

{% docs dump_id %}
The UUID of the event sink run that published this block to ClickHouse. When a course is published all blocks inside it are sent with the same dump_id.
{% enddocs %}

{% docs email %}
The email address of the learner
{% enddocs %}

{% docs emission_time %}
Timestamp, to the second, of when this event was emitted
{% enddocs %}

{% docs enrollment_mode %}
The mode of enrollment
{% enddocs %}

{% docs enrollment_status %}
Whether a learner is actively enrolled in a course
{% enddocs %}

{% docs event_id %}
The unique identifier for the event
{% enddocs %}

{% docs graded %}
Whether the block is graded
{% enddocs %}

{% docs id %}
The record ID
{% enddocs %}

{% docs learner_name %}
The full name of the learner
{% enddocs %}

{% docs object_id %}
The xAPI object identifier
{% enddocs %}

{% docs org %}
The organization that the course belongs to
{% enddocs %}

{% docs section_block_id %}
The location of this subsection in the course, represented as <section location>:<subsection location>:0
{% enddocs %}

{% docs section_number %}
The location of this section in the course, represented as <section location>:0:0
{% enddocs %}

{% docs section_with_name %}
The name of the section this block belongs to, with section_number prepended
{% enddocs %}

{% docs subsection_block_id %}
The unique identifier for the subsection block
{% enddocs %}

{% docs subsection_number %}
The location of this subsection in the course, represented as <section location>:<subsection location>:0
{% enddocs %}

{% docs subsection_with_name %}
The name of the subsection, with section_number prepended
{% enddocs %}

{% docs time_last_dumped %}
The datetime of the event sink run that published this block to ClickHouse. When a course is published all blocks inside it are sent with the same time_last_dumped
{% enddocs %}

{% docs username %}
The username of the learner
{% enddocs %}

{% docs verb_id %}
The xAPI verb identifier
{% enddocs %}


{% docs object_tag_source %}
Course objects and their associated tags from CMS events:  
`COURSE_CREATED, XBLOCK_CREATED, LIBRARY_BLOCK_CREATED, CONTENT_OBJECT_ASSOCIATIONS_CHANGED`  
and `post_save` Django signal on the Object Tag model
{% enddocs %}
