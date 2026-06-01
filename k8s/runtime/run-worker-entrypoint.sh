#!/usr/bin/env bash
# Entrypoint dos run jobs K8s: deps + workspace + exec do comando Dagster (execute_run).
set -euo pipefail

if ! command -v dagster >/dev/null 2>&1; then
  pip install --quiet \
    "dagster>=1.9" "dagster-dbt>=0.25" "dagster-postgres>=0.25" "dagster-k8s>=0.25" \
    "dbt-core>=1.9" "dbt-clickhouse>=1.8" "clickhouse-connect>=0.8"
fi

export CH_DBT_PASSWORD="${CH_DBT_PASSWORD:-${password:-}}"

if [[ -f /config/dagster/sync-workspace.sh ]]; then
  # shellcheck disable=SC1091
  source /config/dagster/sync-workspace.sh
fi

exec "$@"
