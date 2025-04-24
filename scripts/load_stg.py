import json
import zipfile
import io
import uuid
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.providers.postgres.hooks.postgres import PostgresHook
from datetime import datetime


def run(execution_date: str, event_type: str):
    if execution_date:
        exec_dt = datetime.fromisoformat(execution_date)
        target_time = exec_dt
    else:
        target_time = datetime.utcnow()
    print(f"Target time: {target_time}")

    year = target_time.strftime("%Y")
    month = target_time.strftime("%m")
    day = target_time.strftime("%d")
    hour = target_time.strftime("%H")

    bucket_name = 'npl-de16-lab8-data'

    s3 = S3Hook(aws_conn_id='s3_yandex')
    pg = PostgresHook(postgres_conn_id='postgresql_lab08')
    conn_pg = pg.get_conn()
    cursor = conn_pg.cursor()

    s3_key = f"year={year}/month={month}/day={day}/hour={hour}/{event_type}.jsonl.zip"
    print(f"Processing file: {s3_key}")
    load_id = str(uuid.uuid4())
    rows = []

    try:
        s3_obj = s3.get_key(s3_key, bucket_name)
        zip_bytes = s3_obj.get()['Body'].read()

        with zipfile.ZipFile(io.BytesIO(zip_bytes)) as zipped_file:
            for name in zipped_file.namelist():
                with zipped_file.open(name) as file:
                    for line in file:
                        row = json.loads(line.decode('utf-8'))
                        rows.append((load_id, s3_key, json.dumps(row)))
        
        if rows:
            cursor.executemany(
                f"INSERT INTO stg.stg_{event_type}_new (load_id, source_name, json_data) VALUES (%s, %s, %s)",
                rows
            )
            print(f"Inserted {len(rows)} rows for {s3_key}")
    except Exception as e:
        print(f"Error while processing {s3_key}: {e}")

    conn_pg.commit()
    cursor.close()
    conn_pg.close()

    print("Loaded successfully")