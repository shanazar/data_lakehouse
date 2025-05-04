import os
import duckdb
import logging
from datetime import timedelta
from airflow.decorators import task, dag
from airflow.utils.dates import days_ago
from operators.iceberg import icebergOperator
from airflow.providers.trino.hooks.trino import TrinoHook

default_args = {
    'owner': 'admin',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=5)
}


@dag(
    dag_id='example_dag',
    start_date=days_ago(1),
    max_active_runs=1,
    max_active_tasks=8,
    schedule_interval="00 11 * * *",
    default_args=default_args,
    catchup=False,
    tags=['airflow', 'API', 's3', 'iceberg'],
)
def taskflow():

    @task
    def fetch_api_data():

        logger = logging.getLogger(__name__)
        # Do some file fetching into this file
        filename = ''

        namespace = "schema_name"
        table_name = "table_name"

        conn = duckdb.connect()
        conn.sql(f"CREATE TABLE {table_name} AS SELECT * FROM read_json('{filename}');")
        arrow_table = conn.sql(f"SELECT * FROM {table_name}").arrow()
        schema = arrow_table.schema

        #Connect to Iceberg REST and load data from duckDB
        iceberg = icebergOperator('landing')
        catalog = iceberg.get_catalog()
        catalog.create_namespace_if_not_exists(namespace)
        table = catalog.create_table_if_not_exists(
            identifier=f"{namespace}.{table_name}",
            schema=schema,
        )
        try:
            iceberg.evolve_table_schema(schema, f'{namespace}.{table_name}')
        except ValueError as e:
            logger.error(f'Error evolving table schema: {e}')

            catalog.drop_table(f'{namespace}.{table_name}')
            table = catalog.create_table_if_not_exists(
                identifier=f"{namespace}.{table_name}",
                schema=schema,
            )

        table.overwrite(arrow_table)
        os.remove(filename)

    @task
    def fetch_from_trino():
        trino_conn = TrinoHook().get_conn()
        cursor = trino_conn.cursor()
        query = f"""
                select * from landing.information_schema.schemata
                """
        cursor.execute(query)
        columns = [desc[0] for desc in cursor.description]
        data = cursor.fetchall()
        result = [dict(zip(columns, row)) for row in data]
        return result


    @task.external_python(python=os.environ["ASTRO_PYENV_dbt"], expect_airflow=False)
    def execute_dbt_load_to_staging():
        from operators.dbt import dbtOperator
        return dbtOperator('staging').run(models=['staging'], full_refresh=False)

taskflow()
