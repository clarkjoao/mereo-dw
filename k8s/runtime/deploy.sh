#!/usr/bin/env bash
# Deploy Dagster no namespace analytics (Helm chart oficial).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ANALYTICS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE_NAME="${IMAGE_NAME:-mereo-analytics-dagster}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
NAMESPACE="${NAMESPACE:-analytics}"
WORKER_NODES="${WORKER_NODES:-151.244.141.113 151.244.141.114}"
SSH_USER="${SSH_USER:-efuser}"
KUBECONFIG="${KUBECONFIG:-$HOME/.kube/mereo-cdc.yaml}"
export KUBECONFIG

echo "==> Namespace"
kubectl apply -f "$ANALYTICS_ROOT/k8s/namespace.yaml"

echo "==> Build imagem Docker"
docker build -f "$ANALYTICS_ROOT/dagster/Dockerfile" -t "${IMAGE_NAME}:${IMAGE_TAG}" "$ANALYTICS_ROOT"

echo "==> Distribuir imagem nos workers (ctr import)"
TAR="/tmp/${IMAGE_NAME}-${IMAGE_TAG}.tar"
docker save "${IMAGE_NAME}:${IMAGE_TAG}" -o "$TAR"
for node in $WORKER_NODES; do
  echo "  -> $node"
  scp "$TAR" "${SSH_USER}@${node}:/tmp/dagster-image.tar"
  ssh "${SSH_USER}@${node}" "sudo ctr -n k8s.io images import /tmp/dagster-image.tar && rm /tmp/dagster-image.tar"
done
rm -f "$TAR"

echo "==> Helm repo dagster"
helm repo add dagster https://dagster-io.github.io/helm 2>/dev/null || true
helm repo update

echo "==> Deploy Dagster"
helm upgrade --install mereo-dagster dagster/dagster \
  --namespace "$NAMESPACE" \
  -f "$ANALYTICS_ROOT/k8s/dagster/values.yaml" \
  --set "dagster-user-deployments.deployments[0].image.repository=${IMAGE_NAME}" \
  --set "dagster-user-deployments.deployments[0].image.tag=${IMAGE_TAG}" \
  --set "dagster-user-deployments.deployments[0].image.pullPolicy=IfNotPresent" \
  --wait --timeout 10m

echo "==> Ingress (opcional)"
kubectl apply -f "$ANALYTICS_ROOT/k8s/dagster/ingress.yaml"

echo "Done. Port-forward UI: kubectl port-forward -n $NAMESPACE svc/mereo-dagster-dagster-webserver 3000:80"
