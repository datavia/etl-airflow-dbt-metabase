import os
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.bash import BashOperator
from functools import partial
from datetime import datetime
from airflow.models import Variable
from scripts import load_stg_history, remove_data

dag_doc_md = """
            !!! Before triggering set Airflow Variables lab08_start_date and lab08_end_date !!!
            """

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email': ['funchozv@icloud.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 0,
}

with DAG(
    'history_etl_pipeline',
    default_args=default_args,
    description='Историческая загрузка и обработка S3 -> stg -> ods -> dm',
    schedule_interval=None,
    max_active_runs=1,
    start_date=datetime(2025, 4, 4),
    catchup=False,
    doc_md=dag_doc_md,
    tags=['manual', 'etl']
) as dag:

    start_date = Variable.get("lab08_start_date", default_var=None)
    end_date = Variable.get("lab08_end_date", default_var=None)
    event_types = Variable.get(
        "lab08_event_types",
        default_var=None,
        deserialize_json=True
    )

    remove_data_task = PythonOperator(
                task_id='remove_data',
                python_callable=partial(
                    remove_data.run_with_variables,
                    event_types=event_types
                ),  
            )

    load_data_tasks = []

    if event_types is None:
        raise ValueError("Variable 'lab08_event_types' is not set!")

    if isinstance(event_types, list):
        for event in event_types:
            task = PythonOperator(
                task_id=f'load_stg_{event}',
                python_callable=partial(
                    load_stg_history.run_with_variables,
                    event_type=event
                ),  
            )
            load_data_tasks.append(task)
    else:
        raise ValueError("Variable 'lab08_event_types' must be a JSON array!")

    run_dbt_task = BashOperator(
        task_id='run_dbt_models',
        bash_command=f"""dbt run --profiles-dir /dbt_history \
                            --project-dir /dbt_history \
                            --vars '{{"start_date": "{start_date}", "end_date": "{end_date}"}}'
                    """,
        env={
            'DBT_PROFILES_DIR': '/dbt_history',
            'DBT_USER': os.environ.get('POSTGRES_LAB8_USER'),
            'DBT_PASSWORD': os.environ.get('POSTGRES_LAB8_PASSWORD'),
            'DBT_HOST': os.environ.get('POSTGRES_LAB8_HOST'),
            'DBT_DATABASE': os.environ.get('POSTGRES_LAB8_DB'),
            'DBT_SCHEMA': 'ods',
            'PATH': '/root/.local/bin:' + os.environ.get('PATH', '').lstrip('/root/.local/bin:')
        }
    )

    start = DummyOperator(task_id="start",dag=dag)
    end = DummyOperator(task_id="end",dag=dag)

    start >> remove_data_task >> load_data_tasks >> run_dbt_task >> end
