#!/usr/bin/env bash
# Gera ConfigMaps dbt + Dagster a partir de analytics/ (fonte editável).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ANALYTICS_ROOT="$REPO_ROOT/analytics"
RUNTIME="$REPO_ROOT/k8s/runtime"
NAMESPACE="${NAMESPACE:-mereo}"
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/mereo-cdc.yaml}"

PROFILES="${ANALYTICS_ROOT}/dbt/profiles.yml"
if [[ ! -f "$PROFILES" ]]; then
  PROFILES="${ANALYTICS_ROOT}/dbt/profiles.yml.example"
fi

echo "==> ConfigMap dbt-project"
kubectl create configmap dbt-project \
  -n "$NAMESPACE" \
  --from-file="$ANALYTICS_ROOT/dbt/dbt_project.yml" \
  --from-file="$ANALYTICS_ROOT/dbt/packages.yml" \
  --from-file=profiles.yml="$PROFILES" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "==> ConfigMap dbt-models"
DBT_MODEL_ARGS=()
while IFS= read -r f; do
  rel="${f#$ANALYTICS_ROOT/dbt/models/}"
  key="${rel//\//__}"
  DBT_MODEL_ARGS+=( "--from-file=${key}=${f}" )
done < <(find "$ANALYTICS_ROOT/dbt/models" -type f)
kubectl create configmap dbt-models \
  -n "$NAMESPACE" \
  "${DBT_MODEL_ARGS[@]}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "==> ConfigMap dagster-code"
kubectl create configmap dagster-code \
  -n "$NAMESPACE" \
  --from-file=definitions.py="$ANALYTICS_ROOT/dagster/mereo_analytics/definitions.py" \
  --from-file=__init__.py="$ANALYTICS_ROOT/dagster/mereo_analytics/__init__.py" \
  --from-file=start.sh="$RUNTIME/start-user-code.sh" \
  --from-file=sync-workspace.sh="$RUNTIME/sync-workspace.sh" \
  --from-file=run-worker-entrypoint.sh="$RUNTIME/run-worker-entrypoint.sh" \
  --from-file=k8s-client-auth-fix.py="$RUNTIME/k8s-client-auth-fix.py" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "==> Rollout restart (pods que montam ConfigMaps)"
for dep in analytics-code dagster-daemon dagster-webserver; do
  if kubectl get deployment "$dep" -n "$NAMESPACE" >/dev/null 2>&1; then
    kubectl rollout restart "deployment/${dep}" -n "$NAMESPACE"
    kubectl rollout status "deployment/${dep}" -n "$NAMESPACE" --timeout=5m || true
  fi
done

echo "Done. ConfigMaps synced in ${NAMESPACE}."
