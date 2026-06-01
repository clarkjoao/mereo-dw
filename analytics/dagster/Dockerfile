FROM python:3.12-slim

WORKDIR /opt/dagster/app

RUN apt-get update && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

COPY dagster/pyproject.toml ./
COPY dagster/mereo_analytics ./mereo_analytics
COPY dbt /opt/dagster/dbt
COPY dbt/profiles.yml.example /opt/dagster/dbt/profiles.yml

RUN pip install --no-cache-dir .

ENV DAGSTER_HOME=/opt/dagster/dagster_home
ENV DBT_PROJECT_DIR=/opt/dagster/dbt
ENV CH_DBT_PASSWORD=""

RUN mkdir -p $DAGSTER_HOME

EXPOSE 3030

CMD ["dagster", "api", "grpc", "-h", "0.0.0.0", "-p", "3030", "-m", "mereo_analytics.definitions"]
