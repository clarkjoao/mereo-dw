#!/usr/bin/env bash
set -euo pipefail

ANALYTICS_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
NAMESPACE="${NAMESPACE:-mereo-analytics}"
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/mereo-cdc.yaml}"

kubectl apply -f "$ANALYTICS_ROOT/k8s/namespaces.yaml"

echo "==> ConfigMaps (dbt + dagster code)"
kubectl create configmap mereo-dbt-project \
  -n "$NAMESPACE" \
  --from-file="$ANALYTICS_ROOT/dbt/dbt_project.yml" \
  --from-file="$ANALYTICS_ROOT/dbt/packages.yml" \
  --from-file=profiles.yml="$ANALYTICS_ROOT/dbt/profiles.yml" \
  --dry-run=client -o yaml | kubectl apply -f -

DBT_MODEL_ARGS=()
while IFS= read -r f; do
  rel="${f#$ANALYTICS_ROOT/dbt/models/}"
  key="${rel//\//__}"
  DBT_MODEL_ARGS+=( "--from-file=${key}=${f}" )
done < <(find "$ANALYTICS_ROOT/dbt/models" -type f)
kubectl create configmap mereo-dbt-models \
  -n "$NAMESPACE" \
  "${DBT_MODEL_ARGS[@]}" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create configmap mereo-dagster-code \
  -n "$NAMESPACE" \
  --from-file=definitions.py="$ANALYTICS_ROOT/dagster/mereo_analytics/definitions.py" \
  --from-file=__init__.py="$ANALYTICS_ROOT/dagster/mereo_analytics/__init__.py" \
  --from-file=start.sh="$ANALYTICS_ROOT/k8s/dagster/start-user-code.sh" \
  --from-file=sync-workspace.sh="$ANALYTICS_ROOT/k8s/dagster/sync-workspace.sh" \
  --from-file=run-worker-entrypoint.sh="$ANALYTICS_ROOT/k8s/dagster/run-worker-entrypoint.sh" \
  --from-file=k8s-client-auth-fix.py="$ANALYTICS_ROOT/k8s/dagster/k8s-client-auth-fix.py" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "==> Helm: Dagster webserver + daemon + PostgreSQL"
helm repo add dagster https://dagster-io.github.io/helm 2>/dev/null || true
helm repo update

helm upgrade --install mereo-dagster dagster/dagster \
  --namespace "$NAMESPACE" \
  -f "$ANALYTICS_ROOT/k8s/dagster/values-k8s-code.yaml" \
  --wait --timeout 10m

kubectl apply -f "$ANALYTICS_ROOT/k8s/dagster/user-code-deployment.yaml"
kubectl apply -f "$ANALYTICS_ROOT/k8s/dagster/ingress.yaml"

echo "Done."
echo "  UI: kubectl port-forward -n $NAMESPACE svc/mereo-dagster-dagster-webserver 3000:80"
echo "  ou http://dagster.mereo.local (151.244.141.115 no /etc/hosts)"
