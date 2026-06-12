#!/usr/bin/env bash
# Sincroniza secrets K8s a partir do .env da raiz (nunca commitar valores).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${ENV_FILE:-$REPO_ROOT/.env}"
NAMESPACE="${NAMESPACE:-mereo}"
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/mereo-cdc.yaml}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE — cp .env.example .env and configure MSSQL_*" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

MSSQL_HOST="${MSSQL_HOST:-${MYSQL_HOST:-}}"
MSSQL_PORT="${MSSQL_PORT:-${MYSQL_PORT:-1433}}"
MSSQL_USER="${MSSQL_USER:-${MYSQL_USER:-}}"
MSSQL_PASSWORD="${MSSQL_PASSWORD:-${MYSQL_PASSWORD:-}}"
CH_PASS="${CH_DBT_PASSWORD:-$(cat "$REPO_ROOT/analytics/.ch-dbt-password" 2>/dev/null || true)}"

if [[ -z "$MSSQL_HOST" || -z "$MSSQL_USER" || -z "$MSSQL_PASSWORD" ]]; then
  echo "Configure MSSQL_HOST, MSSQL_USER, MSSQL_PASSWORD in $ENV_FILE" >&2
  exit 1
fi

kubectl apply -f "$REPO_ROOT/k8s/00-namespaces.yaml"

_debezium_secret() {
  local ns="$1"
  kubectl create secret generic mssql-debezium-creds \
    -n "$ns" \
    --from-literal=debezium.properties="database.hostname=${MSSQL_HOST}
database.port=${MSSQL_PORT}
database.user=${MSSQL_USER}
database.password=${MSSQL_PASSWORD}" \
    --dry-run=client -o yaml | kubectl apply -f -
}

_debezium_secret "$NAMESPACE"

# Stack CDC legado: connectors em mereo-test-ns-cdc (fora do namespace mereo)
KAFKA_CDC_NS="${KAFKA_CDC_NS:-mereo-test-ns-cdc}"
if [[ "$KAFKA_CDC_NS" != "$NAMESPACE" ]] && kubectl get namespace "$KAFKA_CDC_NS" >/dev/null 2>&1; then
  _debezium_secret "$KAFKA_CDC_NS"
  echo "Debezium secret synced to ${KAFKA_CDC_NS}"
fi

if [[ -n "$CH_PASS" ]]; then
  kubectl create secret generic clickhouse-dbt-credentials \
    -n "$NAMESPACE" \
    --from-literal=password="$CH_PASS" \
    --dry-run=client -o yaml | kubectl apply -f -
fi

echo "Secrets synced to namespace ${NAMESPACE}"
