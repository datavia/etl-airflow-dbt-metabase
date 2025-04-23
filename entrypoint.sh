#!/bin/bash
echo "Waiting for Postgres..."
sleep 10

echo "Running DB migrations..."
airflow db migrate

echo "Creating admin user..."
airflow users create \
  --username "$AIRFLOW_USER" \
  --firstname Admin \
  --lastname Admin \
  --role Admin \
  --email admin@example.com \
  --password "$AIRFLOW_PASSWORD"

echo "Adding PostgreSQL connection..."
airflow connections delete postgresql_lab08 || true
airflow connections add 'postgresql_lab08' \
  --conn-type postgres \
  --conn-host "$POSTGRES_LAB8_HOST" \
  --conn-login "$POSTGRES_LAB8_USER" \
  --conn-password "$POSTGRES_LAB8_PASSWORD" \
  --conn-port 5433 \
  --conn-schema "$POSTGRES_LAB8_DB"

echo "Adding Yandex S3 connection..."
airflow connections delete s3_yandex || true
airflow connections add 's3_yandex' \
  --conn-type aws \
  --conn-login "$S3_YANDEX_ACCESS_KEY_ID" \
  --conn-password "$S3_YANDEX_SECRET_ACCESS_KEY" \
  --conn-extra '{"endpoint_url": "https://storage.yandexcloud.net"}'