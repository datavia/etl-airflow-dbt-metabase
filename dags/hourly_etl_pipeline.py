from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.dummy_operator import DummyOperator
from datetime import datetime
from scripts import load_stg
# , build_ods, build_dds

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
    description='Часовая загрузка S3 -> stg -> ods -> dds',
    schedule_interval='@hourly',
    max_active_runs=1,
    start_date=datetime(2025, 4, 4),
    catchup=False,
    tags=['auto', 'etl']
) as dag:

    event_types = ['browser_events', 'device_events', 'geo_events', 'location_events']

    stg_tasks = []

    for event in event_types:
        task = PythonOperator(
            task_id=f'load_stg_{event}',
            python_callable=load_stg.run,
            op_kwargs={
                'event_type':event, 
                'execution_date':"{{ execution_date.isoformat() }}",
            }
        )
        stg_tasks.append(task)

    # ods_task = PythonOperator(
    #     task_id='build_ods',
    #     python_callable=build_ods.run,
    #     op_kwargs={"execution_date":"{{ execution_date.isoformat() }}"}
    # )

    # dds_task = PythonOperator(
    #     task_id='build_dds',
    #     python_callable=build_dds.run,
    #     op_kwargs={"execution_date":"{{ execution_date.isoformat() }}"}
    # )

    start = DummyOperator(task_id="start",dag=dag)
    end = DummyOperator(task_id="end",dag=dag)

    start >> stg_tasks >> end
