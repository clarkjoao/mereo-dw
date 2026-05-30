#!/usr/bin/env bash
# Control plane local: port-forwards + dashboard com UIs e credenciais.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ANALYTICS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$ANALYTICS_ROOT/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/cluster-env.sh"
RUN_DIR="$ANALYTICS_ROOT/control-plane/.run"
GEN_DIR="$ANALYTICS_ROOT/control-plane/.generated"
TEMPLATE="$ANALYTICS_ROOT/control-plane/dashboard.template.html"
DASHBOARD="$GEN_DIR/index.html"
PID_FILE="$RUN_DIR/pids"
CP_PORT="${CP_PORT:-8765}"

export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/mereo-cdc.yaml}"

load_env() {
  if [[ -f "$REPO_ROOT/.env" ]]; then
    set -a
    # shellcheck disable=SC1091
    source "$REPO_ROOT/.env"
    set +a
  fi
  CH_PASS="${CH_DBT_PASSWORD:-$(cat "$REPO_ROOT/analytics/.ch-dbt-password" 2>/dev/null || true)}"
  MSSQL_HOST="${MSSQL_HOST:-mssql.mereo-sqlserver.svc.cluster.local}"
  MSSQL_PORT="${MSSQL_PORT:-1433}"
  MSSQL_USER="${MSSQL_USER:-sa}"
  MSSQL_PASSWORD="${MSSQL_PASSWORD:-}"
}

pf_entry() {
  printf '%s\n' "$1" >>"$PID_FILE"
}

start_pf() {
  local name=$1 ns=$2 target=$3 local_port=$4 remote_port=$5
  if pgrep -f "kubectl port-forward.*${local_port}:${remote_port}" >/dev/null 2>&1; then
    echo "  [skip] $name — port-forward :$local_port já ativo"
    return
  fi
  kubectl port-forward -n "$ns" "$target" "${local_port}:${remote_port}" \
    >/dev/null 2>&1 &
  pf_entry "$!"
  echo "  [ok]   $name — http://localhost:${local_port}"
}

stop_all() {
  if [[ -f "$PID_FILE" ]]; then
    while read -r pid; do
      [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
    done <"$PID_FILE"
    rm -f "$PID_FILE"
  fi
  pkill -f "python3 -m http.server ${CP_PORT}" 2>/dev/null || true
  echo "Control plane parado."
}

generate_dashboard() {
  mkdir -p "$GEN_DIR"
  load_env

  python3 - "$TEMPLATE" "$DASHBOARD" <<'PY'
import json, sys, datetime, os
from pathlib import Path

template_path, out_path = sys.argv[1], sys.argv[2]
template = Path(template_path).read_text(encoding="utf-8")

ch_pass = os.environ.get("CH_PASS", "")
mssql_user = os.environ.get("MSSQL_USER", "sa")
mssql_pass = os.environ.get("MSSQL_PASSWORD", "")
mssql_host = os.environ.get("MSSQL_HOST", "")
mssql_port = os.environ.get("MSSQL_PORT", "1433")
kubeconfig = os.environ.get("KUBECONFIG", "")

config = {
    "generatedAt": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    "kubeconfig": kubeconfig,
    "services": [
        {
            "name": "Control Plane",
            "description": "Esta página — hub de acesso ao stack POC.",
            "localPort": int(os.environ.get("CP_PORT", "8765")),
            "portForward": False,
            "links": [{"label": "Recarregar", "url": "/"}],
            "credentials": [],
        },
        {
            "name": "ClickHouse",
            "description": "Landing raw + gold + Play UI. Use http://127.0.0.1:18123 no Play (com http://). Ingress só com /etc/hosts.",
            "localPort": 18123,
            "portForward": True,
            "links": [
                {"label": "Play (localhost)", "url": "http://127.0.0.1:18123/play"},
                {"label": "Play (ingress)", "url": "http://clickhouse.mereo.local/play"},
            ],
            "credentials": [
                {"label": "Play URL", "value": "http://127.0.0.1:18123", "secret": False},
                {"label": "Host", "value": "127.0.0.1:18123 (HTTP, não native)", "secret": False},
                {"label": "User", "value": "dbt", "secret": False},
                {"label": "Senha", "value": ch_pass, "secret": True},
                {"label": "In-cluster", "value": "clickhouse-mereo-clickhouse:8123 (namespace mereo)", "secret": False},
            ],
        },
        {
            "name": "Dagster",
            "description": "Orquestração dbt, sensor raw_freshness_sensor, runs.",
            "localPort": 3000,
            "portForward": True,
            "links": [
                {"label": "UI (localhost)", "url": "http://localhost:3000"},
                {"label": "UI (ingress)", "url": "http://dagster.mereo.local"},
            ],
            "credentials": [
                {"label": "Auth", "value": "Sem login na POC", "secret": False},
            ],
        },
        {
            "name": "Kafka Connect",
            "description": "REST API Debezium — status dos connectors.",
            "localPort": 8083,
            "portForward": True,
            "links": [
                {"label": "Connectors", "url": "http://localhost:8083/connectors"},
                {"label": "Afya status", "url": "http://localhost:8083/connectors/mereogr-afya-colaborador/status"},
            ],
            "credentials": [
                {"label": "Auth", "value": "Sem auth na POC", "secret": False},
            ],
        },
        {
            "name": "SQL Server (sim)",
            "description": "Fonte CDC simulada — 3 bancos MereoGR-* in-cluster.",
            "localPort": 11433,
            "portForward": True,
            "links": [],
            "credentials": [
                {"label": "Host", "value": "localhost:11433 (PF) ou " + mssql_host, "secret": False},
                {"label": "Port", "value": mssql_port, "secret": False},
                {"label": "User", "value": mssql_user, "secret": False},
                {"label": "Senha", "value": mssql_pass, "secret": True},
                {"label": "DBs", "value": "MereoGR-Afya, MereoGR-Staging, MereoGR-Allos", "secret": False},
            ],
        },
        {
            "name": "Kafka (CLI)",
            "description": "Sem UI no stack — use kafka-console-consumer no pod.",
            "localPort": None,
            "portForward": False,
            "links": [],
            "credentials": [
                {"label": "Bootstrap", "value": "mereo-kafka-kafka-bootstrap:9092 (namespace mereo)", "secret": False},
                {"label": "Tópico", "value": "raw.colaborador", "secret": False},
                {"label": "Comando", "value": "kubectl exec -n mereo mereo-kafka-kafka-0 -- /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic raw.colaborador --from-beginning --max-messages 5", "secret": False},
            ],
        },
    ],
}

html = template.replace("__CONFIG_JSON__", json.dumps(config, ensure_ascii=False))
Path(out_path).write_text(html, encoding="utf-8")
PY
}

cmd_start() {
  mkdir -p "$RUN_DIR"
  : >"$PID_FILE"

  echo "==> Port-forwards (KUBECONFIG=$KUBECONFIG, layout=$CLUSTER_LAYOUT)"
  start_pf "ClickHouse" "$NS_CH" svc/clickhouse-mereo-clickhouse 18123 8123
  start_pf "Dagster" "$NS_DAGSTER" "svc/${DAGSTER_SVC}" 3000 80
  start_pf "Kafka Connect" "$NS_KAFKA" svc/mereo-connect-connect-api 8083 8083
  start_pf "SQL Server sim" "$NS_MSSQL" svc/mssql 11433 1433

  echo "==> Dashboard"
  generate_dashboard

  if pgrep -f "python3 -m http.server ${CP_PORT}" >/dev/null 2>&1; then
    echo "  [skip] HTTP :$CP_PORT já ativo"
  else
    python3 -m http.server "$CP_PORT" --directory "$GEN_DIR" >/dev/null 2>&1 &
    pf_entry "$!"
    echo "  [ok]   http://localhost:${CP_PORT}"
  fi

  echo ""
  echo "Control plane: http://localhost:${CP_PORT}"
  if command -v open >/dev/null 2>&1; then
    open "http://localhost:${CP_PORT}"
  fi
}

cmd_status() {
  echo "Port-forwards:"
  pgrep -fl "kubectl port-forward" || echo "  (nenhum)"
  echo ""
  echo "Dashboard:"
  pgrep -fl "python3 -m http.server ${CP_PORT}" || echo "  (parado)"
}

usage() {
  cat <<EOF
Uso: $(basename "$0") {start|stop|status|open}

  start   — sobe port-forwards + dashboard em http://localhost:${CP_PORT}
  stop    — encerra port-forwards e servidor HTTP
  status  — lista processos ativos
  open    — regenera dashboard e abre no browser (sem subir PF)

Variáveis: KUBECONFIG, CP_PORT (default 8765)
EOF
}

case "${1:-start}" in
  start) cmd_start ;;
  stop) stop_all ;;
  status) cmd_status ;;
  open)
    generate_dashboard
    echo "http://localhost:${CP_PORT}"
    command -v open >/dev/null 2>&1 && open "http://localhost:${CP_PORT}"
    ;;
  *) usage; exit 1 ;;
esac
