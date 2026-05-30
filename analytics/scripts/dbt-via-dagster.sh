#!/usr/bin/env bash
# Dispara dbt_build via Dagster (run visível na UI → Runs).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/cluster-env.sh"

export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/mereo-cdc.yaml}"
NAMESPACE="${NAMESPACE:-$NS_DAGSTER}"
JOB_NAME="${JOB_NAME:-dbt_build}"
WEBSERVER="${WEBSERVER:-http://localhost:3000}"
WAIT="${WAIT:-true}"
TIMEOUT="${TIMEOUT:-600}"

if ! curl -sf "${WEBSERVER}/server_info" >/dev/null 2>&1; then
  echo "Dagster UI não acessível em ${WEBSERVER}" >&2
  echo "Rode: kubectl port-forward -n ${NAMESPACE} svc/${DAGSTER_SVC} 3000:80" >&2
  exit 1
fi

PAYLOAD=$(cat <<EOF
{
  "query": "mutation LaunchRun(\$executionParams: ExecutionParams!) { launchRun(executionParams: \$executionParams) { __typename ... on LaunchRunSuccess { run { runId status } } ... on PythonError { message stack } ... on RunConfigValidationInvalid { errors { message } } ... on PipelineNotFoundError { message } } }",
  "variables": {
    "executionParams": {
      "selector": {
        "repositoryLocationName": "mereo-analytics",
        "repositoryName": "__repository__",
        "jobName": "${JOB_NAME}"
      },
      "mode": "default"
    }
  }
}
EOF
)

RESP=$(curl -sf "${WEBSERVER}/graphql" -H "Content-Type: application/json" -d "$PAYLOAD")
RUN_ID=$(python3 -c "import json,sys; d=json.load(sys.stdin); r=d.get('data',{}).get('launchRun',{}); print(r.get('run',{}).get('runId','') if r.get('__typename')=='LaunchRunSuccess' else '')" <<<"$RESP")

if [[ -z "$RUN_ID" ]]; then
  echo "Falha ao lançar job ${JOB_NAME}:" >&2
  echo "$RESP" | python3 -m json.tool 2>/dev/null || echo "$RESP" >&2
  exit 1
fi

echo "Run lançada: ${RUN_ID}"
echo "UI: ${WEBSERVER}/runs/${RUN_ID}"

if [[ "${WAIT}" != "true" ]]; then
  exit 0
fi

echo "Aguardando conclusão (timeout ${TIMEOUT}s)..."
deadline=$(( $(date +%s) + TIMEOUT ))
while [[ $(date +%s) -lt $deadline ]]; do
  STATUS_RESP=$(curl -sf "${WEBSERVER}/graphql" \
    -H "Content-Type: application/json" \
    -d "{\"query\":\"query { runOrError(runId: \\\"${RUN_ID}\\\") { ... on Run { status } ... on RunNotFoundError { message } } }\"}")
  STATUS=$(python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('data',{}).get('runOrError',{}).get('status',''))" <<<"$STATUS_RESP")
  case "$STATUS" in
    SUCCESS)
      echo "Run ${RUN_ID}: SUCCESS"
      exit 0
      ;;
    FAILURE|CANCELED)
      echo "Run ${RUN_ID}: ${STATUS}" >&2
      echo "Ver logs: ${WEBSERVER}/runs/${RUN_ID}" >&2
      exit 1
      ;;
    STARTED|STARTING|QUEUED|NOT_STARTED|MANAGED|CANCELING)
      echo "  status=${STATUS}..."
      sleep 5
      ;;
    *)
      echo "  status=${STATUS:-unknown}..."
      sleep 5
      ;;
  esac
done

echo "Timeout aguardando run ${RUN_ID}" >&2
exit 1
