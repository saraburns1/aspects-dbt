{% test accepted_values_xapi(model, column_name, values, table, quote=True) %}

with all_values as (

    select distinct
        {{ column_name }} as value_field

    from {{ table }}

),

validation_errors as (

    select
        value_field

    from all_values
    where value_field not in (
        {% for value in values -%}
            {% if quote -%}
            '{{ value }}'
            {%- else -%}
            {{ value }}
            {%- endif -%}
            {%- if not loop.last -%},{%- endif %}
        {%- endfor %}
        )

)

select *
from validation_errors

{% endtest %}