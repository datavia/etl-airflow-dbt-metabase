## Описание компонентов

- .github/workflows/docker-publish.yml — GitHub Actions workflow, который автоматизирует процесс построения Docker-образа и его публикации в Docker Hub.
- dags/ — Содержит файлы дагов для Apache Airflow, которые описывают задачи и зависимости для обработки данных.
- scripts/ — В этой папке находятся скрипты, которые выполняют различные этапы обработки данных (например, загрузка данных, их трансформация и т.д.).
- Dockerfile — Файл, который описывает, как строить контейнер для проекта, включая установку всех необходимых зависимостей.
- docker-compose.yml — Используется для запуска Airflow.


## Установка и настройка

### Требования

Для работы с проектом необходимо иметь установленные следующие инструменты:

- Docker
- Docker Compose
- GitHub (для использования CI/CD)

## Работать в своей ветке

### Клонируй репозиторий

    1. Убедись, что у тебя есть SSH-ключ
        Проверь наличие ключей:
        ```bash
        ls ~/.ssh/id_rsa.pub
        ```
        Если ключа нет - создай его:
        ```bash
        ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
        ```
        (просто жми Enter на всех шагах)

    2. Добавь публичный ключ в GitHub
        1. Скопируй ключ:
        ```bash
        cat ~/.ssh/id_rsa.pub
        ```
        2. Перейди в GitHub -> Settings -> SSH and GPG keys
        3. Нажми "New SSH key"
        4. Вставь ключ и нажми "Add SSH key"
    3. Клонируй проект:
        ```bash
        git clone git@github.com:ArinaExpy/project_lab08.git
        cd project_lab08
        ```
    4. (Опционально) Проверь, что всё работает
        ```bash
        ssh -T git@github.com
        ```
     


### Укажи имя своей ветки для Git Sync

    ```env
    GIT_SYNC_BRANCH=feature/my-cool-change
    ```

### Запустить Airflow

    ```bash
    docker compose up --build -d
    ```
После запуска Airflow будет подгружать DAG-и из GitHub (из твоей ветки)
и показывать их в интерфейсе: https://localhost:8080

Важно: локальные изменения не попадут в Airflow, пока ты не запушишь их в Git!
