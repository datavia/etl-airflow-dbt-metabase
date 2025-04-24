from airflow.providers.postgres.hooks.postgres import PostgresHook


def finalize_tables(event_type: str):
    pg = PostgresHook(postgres_conn_id='postgresql_lab08')
    conn_pg = pg.get_conn()
    cursor = conn_pg.cursor()

    new_table = f"stg.stg_{event_type}_new"
    prod_table = f"stg.stg_{event_type}"
    old_table = f"stg.stg_{event_type}_old"

    print(f"Finalizing table: {event_type}")

    try:
        cursor.execute(f"DROP TABLE IF EXISTS {old_table}")
        cursor.execute(f"ALTER TABLE IF EXISTS {prod_table} RENAME TO {old_table}")
        cursor.execute(f"ALTER TABLE IF EXISTS {new_table} RENAME TO {prod_table}")
        print("Swapped old and new tables.")
    except Exception as e:
        print(f"Error finalizing table {event_type}: {e}")

    conn_pg.comit()
    cursor.close()
    conn_pg.close()
