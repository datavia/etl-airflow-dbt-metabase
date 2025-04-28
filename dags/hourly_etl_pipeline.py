from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.bash import BashOperator
from datetime import datetime
from scripts import load_stg

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email': ['funchozv@icloud.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 0,
}

with DAG(
    'hourly_etl_pipeline',
    default_args=default_args,
    description='Часовая загрузка и обработка -> stg -> ods -> dm',
    schedule_interval='@hourly',
    max_active_runs=1,
    start_date=datetime(2025, 4, 4),
    catchup=False,
    tags=['auto', 'etl']
) as dag:

    event_types = ['browser_events', 'device_events', 'geo_events', 'location_events']

    load_data_tasks = []

    for event in event_types:
        task = PythonOperator(
            task_id=f'load_stg_{event}',
            python_callable=load_stg.run,
            op_kwargs={
                'event_type':event, 
                'execution_date':"{{ execution_date.isoformat() }}",
            }
        )
        load_data_tasks.append(task)

    run_dbt_task = BashOperator(
        task_id='run_dbt_models',
        bash_command='source /app/.env && dbt run --profiles-dir /dbt --project-dir /bdl_lab08_project',
    )

    start = DummyOperator(task_id="start",dag=dag)
    end = DummyOperator(task_id="end",dag=dag)

    start >> load_data_tasks >> run_dbt_task >> end
