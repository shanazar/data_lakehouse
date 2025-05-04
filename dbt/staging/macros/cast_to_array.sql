{% macro cast_to_array(column_name, type) %}
    {% if type == 'date' %}
    CASE
        WHEN CAST({{ column_name }} AS varchar) LIKE '[''%'
            THEN transform(cast(json_parse(replace(CAST({{ column_name }} AS varchar), '''', '"')) as array(varchar)),
                        x -> CAST(COALESCE(TRY(date_parse(x, '%Y-%m-%d+%H:%i')),TRY(date_parse(x, '%Y-%m-%d'))) AS date))
        ELSE array[cast(COALESCE(TRY(date_parse(cast({{ column_name }} as varchar), '%Y-%m-%d+%H:%i')),
                                TRY(date_parse(cast({{ column_name }} as varchar), '%Y-%m-%d'))) AS date)]
    end as
    {% else %}
    CASE
        WHEN ('{{ type }}' = 'varchar' and cast({{ column_name }} as varchar) LIKE '[''%') or cast({{ column_name }} as varchar) LIKE '[%'
            THEN CAST(json_parse(replace(replace(cast({{ column_name }} as varchar), '"',''),'''','"')) AS array({{type}}))
        ELSE ARRAY[CAST({{ column_name }} AS {{type}})]
    end as
    {% endif %}
{% endmacro %}