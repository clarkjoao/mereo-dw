#!/usr/bin/env bash
# Detecta layout K8s: unified (mereo) vs legacy (4 namespaces).
# Source: source "$(dirname "$0")/lib/cluster-env.sh"

export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/mereo-cdc.yaml}"

NS_MSSQL="${NS_MSSQL:-mereo-sqlserver}"
MSSQL_POD="${MSSQL_POD:-mssql-0}"

if kubectl get deployment analytics-code -n mereo >/dev/null 2>&1; then
  NS=mereo
  NS_CH=mereo
  NS_DAGSTER=mereo
  CH_POD="${CH_POD:-chi-mereo-clickhouse-main-0-0-0}"
  CONNECT_POD="${CONNECT_POD:-mereo-connect-connect-0}"
  KAFKA_POD="${KAFKA_POD:-mereo-kafka-kafka-0}"
  DAGSTER_SVC="${DAGSTER_SVC:-dagster-webserver}"
  ANALYTICS_DEP="${ANALYTICS_DEP:-analytics-code}"
  # Kafka/Connect podem estar em mereo (manifest alvo) ou mereo-test-ns-cdc (stack legado no cluster)
  if kubectl get kafka mereo-kafka -n mereo-test-ns-cdc >/dev/null 2>&1; then
    CLUSTER_LAYOUT=unified-split
    NS_KAFKA=mereo-test-ns-cdc
    CONNECT_POD=mereo-connect-connect-0
    KAFKA_POD=mereo-kafka-kafka-0
  elif kubectl get kafka mereo-kafka -n mereo >/dev/null 2>&1; then
    CLUSTER_LAYOUT=unified
    NS_KAFKA=mereo
  else
    CLUSTER_LAYOUT=unified
    NS_KAFKA=mereo
  fi
elif kubectl get deployment mereo-analytics-code -n mereo-analytics >/dev/null 2>&1; then
  CLUSTER_LAYOUT=legacy
  NS=mereo-analytics
  NS_KAFKA=mereo-kafka
  NS_CH=mereo-clickhouse
  NS_DAGSTER=mereo-analytics
  CH_POD="${CH_POD:-chi-mereo-clickhouse-main-0-0-0}"
  CONNECT_POD="${CONNECT_POD:-mereo-connect-connect-0}"
  KAFKA_POD="${KAFKA_POD:-mereo-kafka-kafka-0}"
  DAGSTER_SVC="${DAGSTER_SVC:-mereo-dagster-dagster-webserver}"
  ANALYTICS_DEP="${ANALYTICS_DEP:-mereo-analytics-code}"
else
  CLUSTER_LAYOUT=unknown
  NS="${NS:-mereo}"
  NS_KAFKA="${NS_KAFKA:-$NS}"
  NS_CH="${NS_CH:-$NS}"
  NS_DAGSTER="${NS_DAGSTER:-$NS}"
  CH_POD="${CH_POD:-chi-mereo-clickhouse-main-0-0-0}"
  CONNECT_POD="${CONNECT_POD:-mereo-connect-connect-0}"
  KAFKA_POD="${KAFKA_POD:-mereo-kafka-kafka-0}"
  DAGSTER_SVC="${DAGSTER_SVC:-dagster-webserver}"
  ANALYTICS_DEP="${ANALYTICS_DEP:-analytics-code}"
fi

export NS NS_KAFKA NS_CH NS_DAGSTER NS_MSSQL CLUSTER_LAYOUT
export CH_POD CONNECT_POD KAFKA_POD MSSQL_POD DAGSTER_SVC ANALYTICS_DEP
