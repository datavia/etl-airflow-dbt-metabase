from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.dummy_operator import DummyOperator
from functools import partial
from datetime import datetime
from scripts import load_stg_history
# , finalize_stg_history

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
    description='Историческая загрузка S3 -> stg -> ods -> dds',
    schedule_interval=None,
    max_active_runs=1,
    start_date=datetime(2025, 4, 4),
    catchup=False,
    tags=['manual', 'etl']
) as dag:

    event_types = ['browser_events', 'device_events', 'geo_events', 'location_events']

    stg_tasks = []

    for event in event_types:
        task = PythonOperator(
            task_id=f'load_stg_{event}',
            python_callable=partial(load_stg_history.run_with_variables, event_type=event),
        )
        stg_tasks.append(task)
    
    # finalize_tasks = []

    # for event in event_types:
    #     task = PythonOperator(
    #         task_id=f'finalize_{event}',
    #         python_callable=partial(finalize_stg_history.finalize_tables, event_type=event),
    #     )
    #     finalize_tasks.append(task)

    start = DummyOperator(task_id="start",dag=dag)
    end = DummyOperator(task_id="end",dag=dag)

    start >> stg_tasks >> end
    # for stg_task, finalize_task in zip(stg_tasks, finalize_tasks):
    #     stg_task >> finalize_task
    # finalize_tasks >> end 
