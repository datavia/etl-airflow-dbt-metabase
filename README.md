### Шаги для локального запуска 

1. Клонируйте репозиторий Ж
    ```bash
    git clone https://github.com/ArinaExpy/project_lab06.git
    cd project_lab06
    ```
2. Запуск проекта с помощью Docker Compose:
    Для поднятия всех сервисов (Airflow, базы данных) используйте Docker Compose:
    ```bash
    docker compose up -d
    ```
3. После успешного запуска сервисов вы можете зайти в веб-интерфейс Airflow по адресу:
    https://localhost:8080 
    или
    https://your_external_IP:8080

    Логин: admin
    Логин: admin