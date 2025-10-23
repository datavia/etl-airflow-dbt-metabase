# End-to-End Data Engineering Project  
### Apache Airflow · dbt · PostgreSQL · Metabase · Docker

---

## 🧩 Overview

This project showcases a **modern end-to-end ELT (Extract–Load–Transform)** data pipeline built with:

- **Apache Airflow** – workflow orchestration and scheduling  
- **dbt (Data Build Tool)** – SQL-based data transformation and testing  
- **PostgreSQL** – data warehouse for raw and modeled data  
- **Metabase** – data visualization and dashboarding  
- **Docker Compose** – containerized, reproducible environment  

It demonstrates how raw data can be ingested, transformed, and visualized through a fully automated pipeline — a typical workflow used in real-world data-engineering projects.

> The original version ran on a cloud VM with S3-compatible storage (Yandex Object Storage).  
> For demonstration, it now uses a simplified local setup that can easily be adapted or extended.

---

## ⚙️ Architecture

```mermaid
flowchart TD
    DockerHub[(🛳️Docker Hub Image Repository)] -->|Pull images| DockerCompose
    GitHub["📂GitHub Repository"] -->|Sync DAGs| GitSync

    subgraph DockerCompose["🛠️Docker Compose"]
        Webserver[🖥️Airflow Webserver]
        Scheduler[⏰Airflow Scheduler]
        GitSync["🔄GitSync "]
        DBTDocs["📄dbt Docs"]
    end

    GitSync --> Webserver
    GitSync --> Scheduler

    Scheduler -->|schedules| DAG
    Webserver -->|view/trigger| DAG

    subgraph DAG["⚙️Airflow DAG (@hourly)"]
        direction LR
        DAGStart([▶️Start DAG]) --> Task1_LoadS3["⬇️Task 1: Load Raw Data from Yandex S3 (STG)"] --> Task2_DBT["⚡Task 2: Run DBT models (ODS, Marts)"] --> DAGEnd([⏹️End DAG])
    end

    YandexS3[(☁️Yandex Cloud S3 Storage)] -->|Provide raw data| Task1_LoadS3

    Task2_DBT --> PostgreSQL[(🗄️PostgreSQL Database)]

    PostgreSQL -->|Read marts data| Metabase["📊Metabase (Dashboards)"]

    style DAG fill:#f9f9f9,stroke:#333
```


