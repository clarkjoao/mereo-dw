#!/usr/bin/env bash
# Mede latência end-to-end: SQL Server → Debezium/Kafka → raw → Dagster/dbt → gold
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/cluster-env.sh"

export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/mereo-cdc.yaml}"
MSSQL_POD="${MSSQL_POD:-mssql-0}"
TEST_ID="${TEST_ID:-$(date +%s | tail -c 5)}"
GRUPO_ID=9999
POLL_INTERVAL=2
RAW_TIMEOUT=120
GOLD_TIMEOUT=180
WEBSERVER="${WEBSERVER:-http://localhost:3000}"

now_ms() { python3 -c "import time; print(int(time.time()*1000))"; }
elapsed_s() { echo "scale=2; ($2 - $1) / 1000" | bc; }
ts_human() { date -r $(( $1 / 1000 )) '+%H:%M:%S'; }

section() { echo ""; echo "── $1 ──"; }

echo "=== Ingestão end-to-end — id=${TEST_ID}, grupo=${GRUPO_ID} ==="
echo "    Dagster UI: ${WEBSERVER}"

section "Serviços (snapshot inicial)"
kubectl get pods -n mereo-sqlserver -l app=mssql --no-headers 2>/dev/null | awk '{print "  mssql:      "$1" "$3}' || echo "  mssql:      ?"
kubectl get kafkaconnector -n "$NS_KAFKA" --no-headers 2>/dev/null | awk '{print "  connector:  "$1" "$2}' || true
kubectl exec -n "$NS_CH" "$CH_POD" -- clickhouse-client -q \
  "SELECT table, num_messages_read FROM system.kafka_consumers WHERE table='colaborador_kafka' FORMAT PrettyCompact" 2>/dev/null \
  | sed 's/^/  kafka→ch: /' || echo "  kafka→ch:   (indisponível)"

section "Baseline gold (grupo ${GRUPO_ID})"
kubectl exec -n "$NS_CH" "$CH_POD" -- clickhouse-client -q \
  "SELECT tenant_slug, colaborador_count, last_ts_ms FROM gold.colaborador_by_grupo WHERE id_grupo_usuario=${GRUPO_ID} ORDER BY tenant_slug FORMAT PrettyCompact" 2>/dev/null \
  | sed 's/^/  /' || echo "  (sem linhas anteriores)"

T0=$(now_ms)
section "1. INSERT SQL Server ($(ts_human "$T0"))"
kubectl exec -n mereo-sqlserver "$MSSQL_POD" -- /bin/bash -c "/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P \"\$MSSQL_SA_PASSWORD\" -C -Q \"
USE [MereoGR-Afya];
INSERT INTO dbo.COLABORADOR (ID, ID_GRUPO_USUARIO, NOME, EMAIL, ATIVO)
VALUES (${TEST_ID}, ${GRUPO_ID}, N'Batch ${TEST_ID} Afya', N'batch-${TEST_ID}-afya@mereo.local', 1);
USE [MereoGR-Staging];
INSERT INTO dbo.COLABORADOR (ID, ID_GRUPO_USUARIO, NOME, EMAIL, ATIVO)
VALUES (${TEST_ID}, ${GRUPO_ID}, N'Batch ${TEST_ID} Staging', N'batch-${TEST_ID}-staging@mereo.local', 1);
USE [MereoGR-Allos];
INSERT INTO dbo.COLABORADOR (ID, ID_GRUPO_USUARIO, NOME, EMAIL, ATIVO)
VALUES (${TEST_ID}, ${GRUPO_ID}, N'Batch ${TEST_ID} Allos', N'batch-${TEST_ID}-allos@mereo.local', 1);
SELECT 'MereoGR-Afya' AS db, ID, NOME, EMAIL FROM dbo.COLABORADOR WHERE ID=${TEST_ID};
\"" 2>/dev/null | sed 's/^/  /'

T_INSERT=$(now_ms)
echo "  ✓ 3 rows inseridas (+$(elapsed_s "$T0" "$T_INSERT")s)"

section "2. Aguardando raw.colaborador (CDC → Kafka → CH)"
T_RAW=""
deadline=$(( $(date +%s) + RAW_TIMEOUT ))
while [[ $(date +%s) -lt $deadline ]]; do
  count=$(kubectl exec -n "$NS_CH" "$CH_POD" -- clickhouse-client -q \
    "SELECT count() FROM raw.colaborador WHERE id = ${TEST_ID} AND tenant_slug IN ('afya','staging','allos')" 2>/dev/null || echo "0")
  if [[ "${count:-0}" -ge 3 ]]; then
    T_RAW=$(now_ms)
    echo "  ✓ 3 tenants em raw (+$(elapsed_s "$T0" "$T_RAW")s desde insert)"
    kubectl exec -n "$NS_CH" "$CH_POD" -- clickhouse-client -q \
      "SELECT tenant_slug, id, nome, email, _ts_ms, _deleted FROM raw.colaborador WHERE id = ${TEST_ID} ORDER BY tenant_slug FORMAT PrettyCompact" \
      | sed 's/^/  /'
    break
  fi
  echo "  ... ${count:-0}/3 tenants ($(elapsed_s "$T0" "$(now_ms)")s)"
  sleep "$POLL_INTERVAL"
done
[[ -n "$T_RAW" ]] || { echo "TIMEOUT raw após ${RAW_TIMEOUT}s"; exit 1; }

section "3. dbt_build via Dagster"
T_DBT_START=$(now_ms)
DBT_LOG=$("${SCRIPT_DIR}/dbt-via-dagster.sh" 2>&1 | tee /dev/stderr)
DAGSTER_RUN_ID=$(echo "$DBT_LOG" | sed -n 's/^Run lançada: //p' | head -1)
T_DBT=$(now_ms)
echo "  ✓ Dagster run ${DAGSTER_RUN_ID} (+$(elapsed_s "$T_DBT_START" "$T_DBT")s)"
echo "  UI: ${WEBSERVER}/runs/${DAGSTER_RUN_ID}"

if [[ -n "$DAGSTER_RUN_ID" ]] && curl -sf "${WEBSERVER}/server_info" >/dev/null 2>&1; then
  RUN_META=$(curl -sf "${WEBSERVER}/graphql" -H "Content-Type: application/json" \
    -d "{\"query\":\"query { runOrError(runId: \\\"${DAGSTER_RUN_ID}\\\") { ... on Run { status startTime endTime } } }\"}")
  python3 -c "
import json,sys
r=json.load(sys.stdin).get('data',{}).get('runOrError',{})
s=r.get('startTime'); e=r.get('endTime')
dur='?' 
if s and e: dur=f'{(e-s):.1f}s'
print(f\"  status={r.get('status')}  duração_dagster={dur}\")
" <<<"$RUN_META" | sed 's/^/  /'
fi

section "4. gold.colaborador_by_grupo (grupo ${GRUPO_ID})"
T_GOLD=""
deadline=$(( $(date +%s) + GOLD_TIMEOUT ))
while [[ $(date +%s) -lt $deadline ]]; do
  # gold agrega por grupo — verifica stg com o id novo (reflete após dbt)
  stg_count=$(kubectl exec -n "$NS_CH" "$CH_POD" -- clickhouse-client -q \
    "SELECT count() FROM gold.stg_colaborador WHERE id = ${TEST_ID}" 2>/dev/null || echo "0")
  if [[ "${stg_count:-0}" -ge 3 ]]; then
    T_GOLD=$(now_ms)
    echo "  ✓ stg_colaborador: ${stg_count} tenants com id=${TEST_ID} (+$(elapsed_s "$T0" "$T_GOLD")s total)"
    kubectl exec -n "$NS_CH" "$CH_POD" -- clickhouse-client -q \
      "SELECT tenant_slug, id_grupo_usuario, colaborador_count, colaborador_ativos, last_ts_ms FROM gold.colaborador_by_grupo WHERE id_grupo_usuario = ${GRUPO_ID} ORDER BY tenant_slug FORMAT PrettyCompact" \
      | sed 's/^/  /'
    break
  fi
  sleep "$POLL_INTERVAL"
done
[[ -n "$T_GOLD" ]] || { echo "TIMEOUT gold após dbt"; exit 1; }

section "Resumo de latência"
printf "  SQL → raw.colaborador:     %6ss  (%s → %s)\n" \
  "$(elapsed_s "$T0" "$T_RAW")" "$(ts_human "$T0")" "$(ts_human "$T_RAW")"
printf "  raw → Dagster dbt_build:   %6ss  (%s → %s)\n" \
  "$(elapsed_s "$T_RAW" "$T_DBT")" "$(ts_human "$T_RAW")" "$(ts_human "$T_DBT")"
printf "  SQL → gold (end-to-end):   %6ss  (%s → %s)\n" \
  "$(elapsed_s "$T0" "$T_GOLD")" "$(ts_human "$T0")" "$(ts_human "$T_GOLD")"
echo ""
echo "  Dagster run:  ${DAGSTER_RUN_ID:-?}"
echo "  Test id:      ${TEST_ID}"
echo "  Ver na UI:    ${WEBSERVER}/runs/${DAGSTER_RUN_ID}"
