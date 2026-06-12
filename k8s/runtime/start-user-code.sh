#!/usr/bin/env bash
set -euo pipefail

pip install --quiet \
  "dagster>=1.9" "dagster-dbt>=0.25" "dagster-postgres>=0.25" "dagster-k8s>=0.25" \
  "dbt-core>=1.9" "dbt-clickhouse>=1.8" "clickhouse-connect>=0.8"

# shellcheck disable=SC1091
source /config/dagster/sync-workspace.sh

exec dagster api grpc \
  -h 0.0.0.0 -p 3030 \
  -m mereo_analytics.definitions \
  --working-directory /opt/dagster/app
