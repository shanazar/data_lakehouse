{% macro get_first_existing_column(table_full_name, columns=[]) %}

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
    {% endset %}
    {% set results = run_query(check_columns_query) %}

    {% if results is not none and results.columns %}
        {% set existing_columns = results.columns[0].values() %}
    {% else %}
        {% set existing_columns = [] %}
    {% endif %}

    {% set found = (columns | select("in", existing_columns) | list | first) %}
    {{ return(('"' ~ found ~ '"') if found else "NULL") }}

{% else %}
    {# At parse time, return "NULL" to avoid compilation issues #}
    {{ return("NULL") }}
{% endif %}
{% endmacro %}
