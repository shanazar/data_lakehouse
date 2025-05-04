# syntax=quay.io/astronomer/airflow-extensions:v1
FROM quay.io/astronomer/astro-runtime:12.5.0

USER root
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --yes --no-install-recommends \
    git ssh
RUN python -m pip install --upgrade pip
PYENV 3.10 dbt requirements_dbt.txt

WORKDIR /usr/local/airflow