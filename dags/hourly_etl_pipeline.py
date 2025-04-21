from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
from scripts import load_stg
# , build_ods, build_dds

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'hourly_etl_pipeline',
    default_args=default_args,
    description='Часовая загрузка S3 -> stg -> ods -> dds',
    schedule_interval='@hourly',
    max_active_runs=1,
    start_date=datetime(2025, 4, 21),
    catchup=False,
    tags=['auto', 'etl']
) as dag:

    stg_task = PythonOperator(
        task_id='load_stg',
        python_callable=load_stg.run,
        op_kwargs={"execution_date":"{{ execution_date.isoformat() }}"}
    )

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

    stg_task 
    
    # >> ods_task >> dds_task