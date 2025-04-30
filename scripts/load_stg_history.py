import json
import zipfile
import io
import uuid
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.models import Variable
from datetime import datetime, timedelta

def run_with_variables(event_type: str):
    start_date = Variable.get("lab08_start_date", default_var=None)
    end_date = Variable.get("lab08_end_date", default_var=None)

    if not start_date or not end_date:
        print("Dates not set in variables - skipping.")
    else:
        run(start_date, end_date, event_type)
    

def run(start_date: str, end_date: str, event_type: str):
    start_date = datetime.fromisoformat(start_date)
    end_date = datetime.fromisoformat(end_date)

    if start_date > end_date:
        raise ValueError("start_date must be before end_date")

    total_hours = int((end_date - start_date).total_seconds() // 3600)
    print(f"Processing {total_hours} hours...")

    bucket_name = 'npl-de16-lab8-data'

    s3 = S3Hook(aws_conn_id='s3_yandex')
    pg = PostgresHook(postgres_conn_id='postgresql_lab08')
    conn_pg = pg.get_conn()
    cursor = conn_pg.cursor()

    for hour_offset in range(total_hours):
        target_time = start_date + timedelta(hours=hour_offset)
        year = target_time.strftime("%Y")
        month = target_time.strftime("%m")
        day = target_time.strftime("%d")
        hour = target_time.strftime("%H")

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
                            rows.append((load_id, target_time, s3_key, json.dumps(row)))
            
            if rows:
                cursor.executemany(
                    f"INSERT INTO stg.stg_{event_type} (load_id, load_dttm, source_name, json_data) VALUES (%s, %s, %s, %s)",
                    rows
                )
                conn_pg.commit()
                print(f"Inserted {len(rows)} rows for {s3_key}")
        except Exception as e:
            print(f"Error while processing {s3_key}: {e}")
            raise

    conn_pg.commit()
    cursor.close()
    conn_pg.close()
    print("All data loaded successfully")
