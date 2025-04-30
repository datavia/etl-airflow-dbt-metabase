import json
import zipfile
import io
import uuid
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.models import Variable
from datetime import datetime, timedelta

def run_with_variables(event_types: list):
    start_date = Variable.get("lab08_start_date", default_var=None)
    end_date = Variable.get("lab08_end_date", default_var=None)

    if not start_date or not end_date:
        print("Dates not set in variables - skipping.")
    else:
        run(start_date, end_date, event_types)
    

def run(start_date: str, end_date: str, event_types: str):
    start_date = datetime.fromisoformat(start_date)
    end_date = datetime.fromisoformat(end_date)

    if start_date > end_date:
        raise ValueError("start_date must be before end_date")

    pg = PostgresHook(postgres_conn_id='postgresql_lab08')
    conn_pg = pg.get_conn()
    cursor = conn_pg.cursor()

    for event_type in event_types:
        cursor.execute(f"""DELETE FROM stg.stg_{event_type} WHERE load_dttm >= {start_date} and load_dttm < {end_date}""")
        cursor.execute(f"""DELETE FROM ods.ods_{event_type} WHERE load_hour >= {start_date} and load_hour < {end_date}""")
        conn_pg.commit()
        print(f"Deleted for {event_type}")

    cursor.execute(f"""DELETE FROM dm.dm_events WHERE load_hour >= {start_date} and load_hour < {end_date}""")
    cursor.execute(f"""DELETE FROM dm.dm_sales WHERE load_hour >= {start_date} and load_hour < {end_date}""")

    conn_pg.commit()
    cursor.close()
    conn_pg.close()
    print("Data deleted successfully")
