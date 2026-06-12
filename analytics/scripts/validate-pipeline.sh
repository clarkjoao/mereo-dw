#!/usr/bin/env bash
# Valida pipeline end-to-end: MSSQL sim → Debezium → Kafka → ClickHouse raw → dbt gold.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/cluster-env.sh"

CH_PASS="${CH_DBT_PASSWORD:-$(cat "$REPO_ROOT/analytics/.ch-dbt-password" 2>/dev/null || true)}"
CONSUMER_GROUP="${CONSUMER_GROUP:-ch-raw-colaborador-v2}"
TOPIC="${TOPIC:-raw.colaborador}"
MAX_LAG="${MAX_LAG:-100}"

PASS=0
FAIL=0

ok() {
  echo "  OK: $1"
  PASS=$((PASS + 1))
}

fail() {
  echo "  FAIL: $1" >&2
  FAIL=$((FAIL + 1))
}

section() {
  echo ""
  echo "==> $1"
}

echo "Layout detectado: ${CLUSTER_LAYOUT} (dagster=${NS_DAGSTER}, kafka=${NS_KAFKA}, ch=${NS_CH})"

section "1/7 SQL Server — CDC habilitado nos 3 bancos"
if kubectl get pod "$MSSQL_POD" -n "$NS_MSSQL" >/dev/null 2>&1; then
  CDC_COUNT=$(kubectl exec -n "$NS_MSSQL" "$MSSQL_POD" -- /bin/bash -c \
    '/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -h -1 -W -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM sys.databases WHERE name IN ('\''MereoGR-Afya'\'', '\''MereoGR-Staging'\'', '\''MereoGR-Allos'\'') AND is_cdc_enabled = 1"' 2>/dev/null | head -1 | tr -d '[:space:]' || echo "0")
  if [[ "$CDC_COUNT" == "3" ]]; then
    ok "CDC ativo em 3 bancos piloto"
  else
    fail "CDC esperado em 3 bancos, encontrado: ${CDC_COUNT:-?}"
  fi
else
  fail "Pod $MSSQL_POD não encontrado em $NS_MSSQL"
fi

section "2/7 Debezium connectors"
CONNECTOR_LINES=$(kubectl get kafkaconnector -n "$NS_KAFKA" --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [[ "${CONNECTOR_LINES:-0}" -ge 3 ]]; then
  READY_COUNT=$(kubectl get kafkaconnector -n "$NS_KAFKA" --no-headers 2>/dev/null | awk '$NF=="True"{n++} END{print n+0}')
  if [[ "${READY_COUNT:-0}" -ge 3 ]]; then
    ok "3 connectors Ready"
  else
    fail "${READY_COUNT:-0}/3 connectors Ready — kubectl get kafkaconnector -n $NS_KAFKA"
    kubectl get kafkaconnector -n "$NS_KAFKA" 2>/dev/null || true
    for c in mereogr-afya-colaborador mereogr-staging-colaborador mereogr-allos-colaborador; do
      kubectl get kafkaconnector "$c" -n "$NS_KAFKA" -o jsonpath='{.status.conditions[?(@.type=="NotReady")].message}' 2>/dev/null \
        | head -c 200
      echo ""
    done
  fi
else
  fail "Esperados >=3 KafkaConnector em $NS_KAFKA, encontrados: ${CONNECTOR_LINES:-0}"
  echo "  Dica: layout=${CLUSTER_LAYOUT} — Kafka pode estar em mereo-test-ns-cdc" >&2
fi

section "3/7 Kafka — mensagens em raw.colaborador"
if kubectl get pod "$KAFKA_POD" -n "$NS_KAFKA" >/dev/null 2>&1; then
  MSG_COUNT=$(kubectl exec -n "$NS_KAFKA" "$KAFKA_POD" -- /opt/kafka/bin/kafka-get-offsets.sh \
    --bootstrap-server localhost:9092 --topic "$TOPIC" 2>/dev/null | awk -F: '{s+=$3} END {print s+0}' || echo "0")
  if [[ "${MSG_COUNT:-0}" -gt 0 ]]; then
    ok "Tópico ${TOPIC} tem ~${MSG_COUNT} mensagens (offsets somados)"
  elif kubectl get pod "$CH_POD" -n "$NS_CH" >/dev/null 2>&1; then
    RAW_FALLBACK=$(kubectl exec -n "$NS_CH" "$CH_POD" -- clickhouse-client -q "SELECT count() FROM raw.colaborador" 2>/dev/null || echo "0")
    if [[ "${RAW_FALLBACK:-0}" -gt 0 ]]; then
      ok "Tópico ${TOPIC} ativo (inferido via raw.colaborador=${RAW_FALLBACK} rows)"
    else
      fail "Tópico ${TOPIC} sem mensagens detectáveis"
    fi
  else
    fail "Tópico ${TOPIC} sem mensagens"
  fi
else
  fail "Pod Kafka $KAFKA_POD não encontrado em $NS_KAFKA"
fi

section "4/7 ClickHouse raw.colaborador — 3 tenants"
if kubectl get pod "$CH_POD" -n "$NS_CH" >/dev/null 2>&1; then
  RAW_ROWS=$(kubectl exec -n "$NS_CH" "$CH_POD" -- clickhouse-client -q \
    "SELECT count() FROM raw.colaborador" 2>/dev/null || echo "0")
  TENANT_COUNT=$(kubectl exec -n "$NS_CH" "$CH_POD" -- clickhouse-client -q \
    "SELECT uniqExact(tenant_slug) FROM raw.colaborador" 2>/dev/null || echo "0")
  if [[ "${RAW_ROWS:-0}" -gt 0 && "${TENANT_COUNT:-0}" -ge 3 ]]; then
    ok "raw.colaborador: ${RAW_ROWS} rows, ${TENANT_COUNT} tenants"
    kubectl exec -n "$NS_CH" "$CH_POD" -- clickhouse-client -q \
      "SELECT tenant_slug, count() AS n FROM raw.colaborador GROUP BY tenant_slug ORDER BY tenant_slug" 2>/dev/null || true
  else
    fail "raw.colaborador: rows=${RAW_ROWS:-0}, tenants=${TENANT_COUNT:-0} (esperado rows>0, tenants>=3)"
  fi
else
  fail "Pod ClickHouse $CH_POD não encontrado em $NS_CH"
fi

section "5/7 Kafka consumer lag (CH)"
if kubectl get pod "$CH_POD" -n "$NS_CH" >/dev/null 2>&1; then
  LAG=$(kubectl exec -n "$NS_CH" "$CH_POD" -- clickhouse-client -q \
    "SELECT coalesce(max(assignments.current_offset[1]), 0) - coalesce(max(num_messages_read), 0) FROM system.kafka_consumers WHERE table = 'colaborador_kafka'" 2>/dev/null || echo "999999")
  if [[ "${LAG:-999999}" -le "$MAX_LAG" ]] || [[ "${LAG:-999999}" -lt 0 ]]; then
    ok "Consumer CH colaborador_kafka ativo (lag estimado ${LAG})"
  else
    fail "Lag ${LAG} > ${MAX_LAG}"
  fi
else
  fail "Pod ClickHouse não disponível para checar lag"
fi

section "6/7 pipeline.ingestion_snapshots (observability)"
if kubectl get pod "$CH_POD" -n "$NS_CH" >/dev/null 2>&1; then
  SNAP_EXISTS=$(kubectl exec -n "$NS_CH" "$CH_POD" -- clickhouse-client -q \
    "SELECT count() FROM system.tables WHERE database = 'pipeline' AND name = 'ingestion_snapshots'" 2>/dev/null || echo "0")
  if [[ "${SNAP_EXISTS:-0}" -eq 1 ]]; then
    SNAP_ROWS=$(kubectl exec -n "$NS_CH" "$CH_POD" -- clickhouse-client -q \
      "SELECT count() FROM pipeline.ingestion_snapshots WHERE entity = 'colaborador' AND row_count > 0 AND snapshot_at > now64(3) - INTERVAL 1 HOUR" 2>/dev/null || echo "0")
    if [[ "${SNAP_ROWS:-0}" -gt 0 ]]; then
      ok "pipeline.ingestion_snapshots: ${SNAP_ROWS} linhas recentes (colaborador)"
      kubectl exec -n "$NS_CH" "$CH_POD" -- clickhouse-client -q \
        "SELECT tenant_slug, row_count, kafka_lag, snapshot_at FROM pipeline.ingestion_snapshots WHERE entity = 'colaborador' ORDER BY snapshot_at DESC LIMIT 6" 2>/dev/null || true
    else
      fail "Sem snapshots recentes — aguarde job raw_ingestion_observability ou dispare manualmente na UI Dagster"
    fi
  else
    fail "Tabela pipeline.ingestion_snapshots ausente — aplique k8s/mereo/07-clickhouse-init-sql.yaml"
  fi
else
  fail "Pod ClickHouse não disponível"
fi

section "7/7 Dagster user code + observability"
if kubectl get deployment "$ANALYTICS_DEP" -n "$NS_DAGSTER" >/dev/null 2>&1; then
  RUNNING=$(kubectl get deployment "$ANALYTICS_DEP" -n "$NS_DAGSTER" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
  if [[ "${RUNNING:-0}" -ge 1 ]]; then
    ok "${ANALYTICS_DEP} Ready — jobs raw_ingestion_observability + sensor raw_freshness_sensor na UI Dagster"
  else
    fail "${ANALYTICS_DEP} não Ready"
  fi
else
  fail "Deployment ${ANALYTICS_DEP} não encontrado em $NS_DAGSTER"
fi

echo ""
echo "Resumo: ${PASS} OK, ${FAIL} FAIL"
echo ""
echo "dbt via Dagster (visível na UI):"
echo "  ./analytics/scripts/dbt-via-dagster.sh"
echo ""
echo "Sync após editar código (layout unified):"
echo "  ./k8s/sync-configmaps.sh"
echo "  ./k8s/sync-secrets.sh"

if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
