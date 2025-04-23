FROM python:3.8.13

COPY requirements.txt .

RUN pip install --upgrade pip && \
    pip install --no-cache-dir --user -r requirements.txt \
    --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.9.2/constraints-3.8.txt"

WORKDIR /usr/local/airflow

ENV AIRFLOW_HOME=/usr/local/airflow
ENV PATH=/root/.local/bin:$PATH

# меняем тип эксзекутора для Airflow на LocalExecutor (запускает задачи параллельно, но только на одной машине)
ENV AIRFLOW__CORE__EXECUTOR=LocalExecutor
# указываем подключение к постгре
ENV AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres:5432/airflow
# отключаем загрузку примеров дагов
ENV AIRFLOW__CORE__LOAD_EXAMPLES=False
# отключаем загрузку соединений по умолчанию
ENV AIRFLOW__CORE__LOAD_DEFAULT_CONNECTIONS=False
# и еще два флажка, полезных при отладке
# отображать имя хоста в логах
ENV AIRFLOW__CORE__EXPOSE_HOSTNAME=True
# отображать трассировку стека при возникновении ошибки
ENV AIRFLOW__CORE__EXPOSE_STACKTRACE=True