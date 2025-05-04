{% macro get_tables_by_pattern(database, schema, table_pattern, exclude='') %}

    {% set select_tables_query %}
        SELECT DISTINCT
            concat('"',table_catalog, '"."', table_schema, '"."', table_name, '"') AS table_name
        FROM {{ database }}.INFORMATION_SCHEMA.TABLES
        WHERE table_schema = '{{ schema }}'
          AND table_name LIKE '{{ table_pattern }}'
          {% if exclude != '' %}
          AND table_name NOT LIKE '{{ exclude }}'
          {% endif %}
    {% endset %}

    {% if execute %}
        {% set results = run_query(select_tables_query) %}
        {{ return(results.columns[0].values()) }}
    {% endif %}

{% endmacro %}
