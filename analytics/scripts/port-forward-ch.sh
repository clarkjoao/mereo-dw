#!/usr/bin/env bash
# Port-forward ClickHouse HTTP para desenvolvimento local (porta 18123).
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/cluster-env.sh"
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/mereo-cdc.yaml}"
exec kubectl port-forward -n "$NS_CH" svc/clickhouse-mereo-clickhouse 18123:8123
