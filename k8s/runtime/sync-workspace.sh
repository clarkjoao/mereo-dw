#!/usr/bin/env bash
# Sincroniza ConfigMaps → /opt/dagster (user-code pod e run jobs).
set -euo pipefail

mkdir -p /opt/dagster/dbt/models/staging /opt/dagster/dbt/models/gold /opt/dagster/dbt/macros
cp /config/dbt/dbt_project.yml /config/dbt/packages.yml /opt/dagster/dbt/
cp /config/dbt/profiles.yml /opt/dagster/dbt/profiles.yml

if [[ -d /config/macros ]]; then
  for f in /config/macros/*; do
    [ -f "$f" ] || continue
    key=$(basename "$f")
    rel="${key//__//}"
    mkdir -p "/opt/dagster/dbt/macros/$(dirname "$rel")"
    cp "$f" "/opt/dagster/dbt/macros/$rel"
  done
fi

for f in /config/models/*; do
  [ -f "$f" ] || continue
  key=$(basename "$f")
  rel="${key//__//}"
  mkdir -p "/opt/dagster/dbt/models/$(dirname "$rel")"
  cp "$f" "/opt/dagster/dbt/models/$rel"
done

mkdir -p /opt/dagster/app/mereo_analytics
cp /config/dagster/definitions.py /config/dagster/__init__.py /opt/dagster/app/mereo_analytics/

export DBT_PROJECT_DIR=/opt/dagster/dbt
export DBT_PROFILES_DIR=/opt/dagster/dbt
export DBT_TARGET="${DBT_TARGET:-k8s}"
export DBT_EXECUTABLE="${DBT_EXECUTABLE:-dbt}"
export PYTHONPATH=/opt/dagster/app

cd /opt/dagster/dbt && dbt deps && dbt parse --profiles-dir .
