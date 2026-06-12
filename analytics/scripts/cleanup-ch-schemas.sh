#!/usr/bin/env bash
# Remove databases legados/vazios do ClickHouse (layout domínio).
# Mantém: raw, pipeline, gold, domínios silver ativos (colaborador, metricas, …).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/cluster-env.sh
source "$SCRIPT_DIR/lib/cluster-env.sh"

DRY_RUN="${DRY_RUN:-false}"

ch_query() {
  kubectl exec -n "$NS_CH" "$CH_POD" -- clickhouse-client -q "$1"
}

drop_db() {
  local db="$1"
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] DROP DATABASE IF EXISTS ${db} SYNC"
    return 0
  fi
  echo "DROP DATABASE IF EXISTS ${db} SYNC"
  ch_query "DROP DATABASE IF EXISTS ${db} SYNC" || true
}

echo "==> ClickHouse cleanup — databases legados (gold_*, bronze, silver)"

# Fix antigo: dbt gravou silver em gold_{domain} (views vazias duplicadas).
while IFS= read -r db; do
  [[ -n "$db" ]] && drop_db "$db"
done < <(
  ch_query "
    SELECT name
    FROM system.databases
    WHERE name LIKE 'gold\\_%'
    ORDER BY name
    FORMAT TSV
  "
)

for db in bronze silver; do
  drop_db "$db"
done

echo ""
echo "==> Inventário atual (excl. system)"
ch_query "
SELECT database, count() AS tables, sum(total_bytes) AS bytes
FROM system.tables
WHERE database NOT IN ('system', 'INFORMATION_SCHEMA', 'information_schema', 'default')
GROUP BY database
ORDER BY database
FORMAT Pretty
"
