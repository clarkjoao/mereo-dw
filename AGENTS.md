# Memória para agentes — Mereo DW

Documento de contexto para assistentes de IA. **Leia isto antes** de mexer no cluster, em `analytics/`, `k8s/` ou `mereo_tools/`.

**Repo ativo:** `/Users/jvclark/www/mereo-dw` (branch `merge-project-jvc` → `main`)  
**Remote:** `git@github.com:clarkjoao/mereo-dw.git`  
**Repos obsoletos (não evoluir):** `/Users/jvclark/www/mereo-poc` (apagar após merge), `/Users/jvclark/www/mereo` (legado)  
**Última atualização:** 2026-05-30

---

## O que este repo é

| Parte | Função |
|-------|--------|
| `mereo_tools/` | CLI Python (uv) — discover, inventory, schema, drift dos bancos `MereoGR-*` |
| `output/groups/mereogr/` | Artefatos locais do inventário (~200MB, **gitignored**) |
| `analytics/` | **Fonte editável:** dbt, Dagster, catálogo, scripts, SQL |
| `k8s/` | Manifests K8s aplicáveis (2 namespaces) — ver [`k8s/README.md`](k8s/README.md) |
| `k8s/runtime/` | Scripts entrypoint Dagster (sync-workspace, run-worker, auth fix) |

**Princípio:** editar código em `analytics/`; aplicar no cluster via `./k8s/sync-configmaps.sh` + `./k8s/sync-secrets.sh`.

---

## Arquitetura

```
MereoGR (piloto) → Debezium → Kafka raw.{entity}
  → ClickHouse raw (Kafka Engine + MV + ReplacingMergeTree)
  → dbt staging/gold (multi-tenant via tenant_slug)
  → Dagster (freshness sensor + dbt_build via K8sRunLauncher)
  → pipeline.* (watermarks, lag)
```

**Sem Flink** na Fase 1 (ver `analytics/docs/flink-router-eval.md`).

### Naming

| Artefato | Exemplo |
|----------|---------|
| CH landing | `raw.colaborador` |
| CH dbt | `gold.colaborador_by_grupo` |
| CH ops | `pipeline.entity_watermarks` |
| Tópico Kafka | `raw.colaborador` |
| Consumer group CH | `ch-raw-colaborador-v2` |
| Namespaces | `mereo` (plataforma), `mereo-sqlserver` (fonte sim) |

---

## Setup local

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

`.envrc` exporta `KUBECONFIG`.

---

## Kubernetes (2 namespaces)

| Namespace | Conteúdo |
|-----------|----------|
| `mereo` | Kafka, Connect, ClickHouse, Dagster, Postgres, dbt/dagster ConfigMaps |
| `mereo-sqlserver` | SQL Server 2022 simulado (3 bancos piloto + CDC) |

Infra detalhada: [`k8s/README.md`](k8s/README.md).

### Deploy / sync

```bash
export KUBECONFIG="$HOME/.kube/mereo-cdc.yaml"

# Greenfield (ordem em k8s/README.md)
kubectl apply -f k8s/00-namespaces.yaml
kubectl apply -f k8s/mereo-sqlserver/
kubectl apply -f k8s/mereo/

# Secrets e ConfigMaps a partir de .env + analytics/
./k8s/sync-secrets.sh
./k8s/sync-configmaps.sh
```

---

## ClickHouse

| Campo | Valor |
|-------|--------|
| User dbt | senha em `analytics/.ch-dbt-password` |
| Host in-cluster | `clickhouse-mereo-clickhouse:8123` (namespace `mereo`) |
| Pod | `chi-mereo-clickhouse-main-0-0-0` |
| Port-forward | `./analytics/scripts/port-forward-ch.sh` → **localhost:18123** |
| Consumer group | `ch-raw-colaborador-v2` |
| Init DDL | `k8s/mereo/07-clickhouse-init-sql.yaml` (aplicar manualmente — ver k8s/README) |

---

## Dagster — regra obrigatória

**Todo `dbt build` deve passar pelo Dagster** (visibilidade na UI):

- UI: Materialize job `dbt_build`
- CLI: `./analytics/scripts/dbt-via-dagster.sh`

**Nunca** `kubectl exec ... dbt build` em produção da POC.

| Item | Valor |
|------|--------|
| Código | `analytics/dagster/mereo_analytics/definitions.py` |
| User code pod | `analytics-code` (namespace `mereo`) |
| UI port-forward | `kubectl port-forward -n mereo svc/dagster-webserver 3000:80` |
| Fix K8s auth | `k8s/runtime/k8s-client-auth-fix.py` montado como `sitecustomize.py` no daemon |

Após editar dbt/Dagster: `./k8s/sync-configmaps.sh`

---

## mereo_tools

```bash
# 1. Fleet — lista + inventário (todos MereoGR-*)
uv run python -m mereo_tools discover --source mereo
uv run python -m mereo_tools inventory --source mereo --resume --pause 2

# 2. Schema deep-dive — amostra curada (groups.toml mapping_sample)
uv run python -m mereo_tools schema --source mereo --sample --resume --pause 3

# 3. Drift vs referência + relatório COLABORADOR
uv run python -m mereo_tools drift --group mereogr --reference-db MereoGR-Afya --detailed
uv run python -m mereo_tools mapping-report --group mereogr

# 4. Backup local prod → disco (schema + dados; conservador com prod)
uv run python -m mereo_tools backup-local \
  --databases MereoGR-Staging,MereoGR-Allos,MereoGR-Afya \
  --resume \
  --sample-limit 50000 \
  --sample-databases MereoGR-Allos,MereoGR-Afya \
  --schema-only-audit \
  --batch-size 2000 --pause-batch 0.05 --pause-table 0.2 --pause-db 10
# retomar: ... backup-local --resume
# aceitar parcial: --accept-partial dbo.ValorMatriz
# Saída: output/backups/{database}/schema/schema.sql + data/*.jsonl.gz

# 5. Restore backup → sim (sem bater em prod)
kubectl port-forward -n mereo-sqlserver svc/mssql 11434:1433
MSSQL_HOST=127.0.0.1 MSSQL_PORT=11434 uv run python -m mereo_tools restore-local \
  --databases MereoGR-Staging,MereoGR-Allos,MereoGR-Afya \
  --enable-cdc --batch-size 500 --resume
# Saída: SQL Server sim populado; resumo em output/backups/restore_summary.json

# 6. Clone prod → sim (alternativa direta prod→sim)
kubectl port-forward -n mereo-sqlserver svc/mssql 11433:1433
MSSQL_HOST=127.0.0.1 MSSQL_PORT=11433 uv run python -m mereo_tools clone-sim \
  --databases MereoGR-Staging,MereoGR-Allos,MereoGR-Afya \
  --enable-cdc --batch-size 500 --pause-batch 0.25 --pause-table 0.4 --pause-db 15

./analytics/scripts/validate-pipeline.sh
./analytics/scripts/dbt-via-dagster.sh
```

Credenciais no `.env`:
- `MEREO_*` — cliente real (somente dev local: discover, schema, drift, seed origem)
- `MSSQL_*` — simulador (dev) ou cliente real (prod via secrets K8s)

Teste de conexão dual:
```bash
uv run python -m mereo_tools teste_query --source mereo --db MereoGR-Staging
uv run python -m mereo_tools teste_query --source mssql --db MereoGR-Staging
```

Saída: `output/groups/mereogr/` (gitignored). Contratos commitados: `analytics/catalog/entities/*.yaml`.

---

## Catálogo piloto (wave 1)

Entidade `dbo.COLABORADOR` → `raw.colaborador`. Tenants: afya, staging, allos.

**`COLABORADOR` não tem `ID_AREA`** — model `colaborador_by_area` removido.

Models dbt: `stg_colaborador` (view), `colaborador_by_grupo` (table).

---

## Cluster Eficify

| Item | Valor |
|------|--------|
| Kubeconfig | `~/.kube/mereo-cdc.yaml` |
| Traefik LB | `151.244.141.115` |
| `/etc/hosts` | `151.244.141.115 dagster.mereo.local clickhouse.mereo.local` |

Operators compartilhados: `dataflow-system` (Strimzi, CH operator), `traefik`.

Demo legada `cdc-*` — **desligada**, não evoluir.

---

## Scripts operacionais

Scripts detectam layout **unified** (`mereo`) ou **legacy** (4 namespaces) via `analytics/scripts/lib/cluster-env.sh`.

```bash
./analytics/scripts/control-plane.sh start   # hub localhost:8765
./analytics/scripts/validate-pipeline.sh   # 7 checks end-to-end
./analytics/scripts/latency-track.sh         # insert → raw → Dagster → gold + timings
./analytics/scripts/dbt-via-dagster.sh       # dbt_build visível na UI
```

---

## Armadilhas

1. Port-forward CH: porta **18123**, URL `http://127.0.0.1:18123` no Play
2. Consumer group CH: **`ch-raw-colaborador-v2`** (v1 obsoleto)
3. `system.kafka_consumers` no CH 24.3 **não tem coluna `group`** — usar `table = 'colaborador_kafka'`
4. kubernetes-client 36.x: daemon precisa do sitecustomize auth fix
5. Run jobs Dagster: cold-start ~90s (`pip install` em `python:3.12-slim`)
6. Secrets: nunca commitar `.env`, `.ch-dbt-password`, `profiles.yml`
7. ConfigMap model keys: `__` no lugar de `/` (ex.: `staging__stg_colaborador.sql`)

---

## Docs adicionais

| Doc | Conteúdo |
|-----|----------|
| [`analytics/docs/pipeline-observability.md`](analytics/docs/pipeline-observability.md) | Lag, watermarks |
| [`analytics/docs/offset-registry.md`](analytics/docs/offset-registry.md) | Donos de offset |
| [`analytics/docs/flink-router-eval.md`](analytics/docs/flink-router-eval.md) | Sem Flink Fase 1 |
| [`analytics/docs/wasabi-dr.md`](analytics/docs/wasabi-dr.md) | DR Tier 3 futuro |

---

## Roadmap

1. Validar pipeline no layout 2-ns (`mereo`)
2. Wave 2: novas entidades via catálogo
3. Imagem Docker custom para run jobs Dagster (eliminar pip install)
4. ExternalSecrets + Wasabi Tier 3
