# Mereo DW — pipeline analytics

Monorepo: inventário SQL Server (`mereo_tools`) + pipeline analytics (Debezium → Kafka → ClickHouse → dbt → Dagster).

**Repo:** `/Users/jvclark/www/mereo-dw` · Remote: `git@github.com:clarkjoao/mereo-dw.git`

## Setup

```bash
cd /Users/jvclark/www/mereo-dw
uv sync
cp .env.example .env
cp analytics/dbt/profiles.yml.example analytics/dbt/profiles.yml
export KUBECONFIG="$HOME/.kube/mereo-cdc.yaml"
export CH_DBT_PASSWORD="$(cat analytics/.ch-dbt-password)"

cd analytics/dagster && uv sync
cd ../dbt && ../dagster/.venv/bin/dbt deps
```

## Estrutura

| Path | Conteúdo |
|------|----------|
| `mereo_tools/` | CLI inventário MereoGR |
| `analytics/` | dbt, Dagster, catálogo, scripts, SQL (fonte editável) |
| `k8s/` | Manifests K8s — 2 namespaces (`mereo` + `mereo-sqlserver`) |
| `k8s/sync-configmaps.sh` | Aplica dbt + Dagster code nos ConfigMaps |
| `k8s/sync-secrets.sh` | Secrets a partir de `.env` |

Infra K8s: [`k8s/README.md`](k8s/README.md) · Contexto agentes: [`AGENTS.md`](AGENTS.md)

## Operação

```bash
export KUBECONFIG="$HOME/.kube/mereo-cdc.yaml"

./analytics/scripts/control-plane.sh start   # hub UIs → localhost:8765
./analytics/scripts/validate-pipeline.sh
./analytics/scripts/dbt-via-dagster.sh         # dbt via Dagster (UI)
./analytics/scripts/latency-track.sh           # teste end-to-end + latência

./k8s/sync-secrets.sh
./k8s/sync-configmaps.sh                       # após editar analytics/
```

## mereo_tools

```bash
uv run python -m mereo_tools discover --group mereogr
uv run python -m mereo_tools inventory --group mereogr
```

Saída local (gitignored): `output/groups/mereogr/`
