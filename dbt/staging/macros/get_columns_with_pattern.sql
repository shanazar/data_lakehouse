{% macro get_columns_with_pattern(table_full_name, column_pattern, cast_to_type='') %}
    {% if execute %}
        {% set unquoted = table_full_name | replace('"', '') %}
        {% set parts = unquoted.split('.') %}
        {% set db = parts[0] %}
        {% set schema_name = parts[1] %}
        {% set table_name = parts[2] %}

        {% set check_columns_query %}
          SELECT column_name
          FROM "{{ db }}"."information_schema"."columns"
          WHERE table_schema = '{{ schema_name }}'
            AND table_name = '{{ table_name }}'
            AND column_name LIKE '{{ column_pattern }}'
        {% endset %}

        {% set results = run_query(check_columns_query) %}


        {% if results is not none and results.columns and results.columns[0].values()|length > 0  %}
          {% set col_list = results.columns[0].values() %}
          {% if cast_to_type != '' %}
            {{ return('cast("' ~ (col_list | join('" as '~ cast_to_type ~ '),cast("')) ~ '" as ' ~ cast_to_type ~ ')') }}
          {% else %}
            {{ return('"' ~ (col_list | join('","')) ~ '"') }}
          {% endif %}
        {% else %}
            {{ return('NULL') }}
        {% endif %}
    {% else %}
        {{ return('NULL') }}
    {% endif %}
{% endmacro %}
