# Mereo — Manifests Kubernetes

Plataforma de analytics da Mereo organizada em **2 namespaces**:

- **`mereo`** — aplicação completa (Kafka, ClickHouse, Dagster, dbt, Postgres).
- **`mereo-sqlserver`** — banco de produção simulado, apartado para
  representar uma fonte externa ao cluster. Em ambientes reais este
  namespace **não existe** — o SQL Server seria um servidor gerenciado
  (RDS / Azure SQL / on-prem) acessado via endpoint estável.

## Arquitetura em uma página

```
┌────────────────────────────┐
│   mereo-sqlserver          │  ◄── fonte externa simulada
│   SQL Server 2022          │      (em prod: RDS/Azure SQL/on-prem)
│   3 bancos:                │
│    • MereoGR-Afya          │
│    • MereoGR-Staging       │
│    • MereoGR-Allos         │
│   Tabela piloto:           │
│    dbo.COLABORADOR (CDC)   │
└──────────────┬─────────────┘
               │ TDS 1433 (cross-namespace)
               │ Debezium SqlServerConnector × 3
               ▼
╔══════════════════════════════════════════════════════════════╗
║   mereo                                  PLATAFORMA          ║
║                                                              ║
║   ┌───────────────────────────┐  ┌────────────────────────┐  ║
║   │ Kafka (Strimzi)           │  │ ClickHouse (Altinity)  │  ║
║   │  • Kafka 3.7.1 broker     │─▶│  • raw.colaborador     │  ║
║   │  • ZooKeeper              │  │   ◀ ENGINE = Kafka     │  ║
║   │  • Kafka Connect (Debez.) │  │  • MV normaliza → raw  │  ║
║   │   tópico: raw.colaborador │  │  • gold/* (dbt build)  │  ║
║   │                           │  │  • pipeline.* (lag/wm) │  ║
║   └───────────────────────────┘  └───────────┬────────────┘  ║
║                                              │ HTTP 8123     ║
║   ┌────────────────────────────────────┐     │               ║
║   │ Dagster                            │─────┘ dbt build     ║
║   │  • dagster-webserver (UI)          │                     ║
║   │  • dagster-daemon (K8sRunLauncher) │                     ║
║   │  • analytics-code (gRPC user code) │                     ║
║   │  • dagster-postgresql (metadados)  │                     ║
║   │  • dbt project + models (CM)       │                     ║
║   └────────────────────────────────────┘                     ║
║                                                              ║
║   Ingresses (Traefik):                                       ║
║    • dagster.mereo.local    → dagster-webserver:80           ║
║    • clickhouse.mereo.local → clickhouse-mereo-clickhouse:8123║
╚══════════════════════════════════════════════════════════════╝
```

Contrato da entidade piloto: `analytics/catalog/entities/colaborador.yaml`.

## Layout dos arquivos

```
k8s/
├── README.md
├── 00-namespaces.yaml                  # mereo + mereo-sqlserver
├── mereo-sqlserver/                    # FONTE EXTERNA (apartado)
│   ├── 00-secret-sa-credentials.yaml
│   ├── 01-service.yaml
│   ├── 02-statefulset.yaml
│   ├── 03-configmap-init-sql.yaml      # DDL + seed + sp_cdc_enable_*
│   └── 04-job-init.yaml
└── mereo/                              # PLATAFORMA UNIFICADA
    ├── 00-secrets.yaml                 # dagster-pg + dbt-cred + debezium-creds
    ├── 01-rbac.yaml                    # SA + Role + RoleBinding
    ├── 02-kafka-cluster.yaml           # Strimzi Kafka CR
    ├── 03-kafka-topics.yaml            # schema-history + raw.colaborador
    ├── 04-kafka-connect.yaml           # KafkaConnect CR
    ├── 05-kafka-connectors.yaml        # 3 Debezium SqlServerConnector
    ├── 06-clickhouse-installation.yaml # Altinity ClickHouseInstallation
    ├── 07-clickhouse-init-sql.yaml     # DDL raw/gold/pipeline + MV Kafka
    ├── 08-cronjob-lag-snapshot.yaml    # snapshot 5min de watermark+lag
    ├── 09-postgresql.yaml              # Postgres interno do Dagster
    ├── 10-configmap-dbt.yaml           # dbt project + models
    ├── 11-configmaps-dagster.yaml      # dagster-env + workspace + instance + code
    ├── 12-deployment-analytics-code.yaml
    ├── 13-deployment-dagster-daemon.yaml
    ├── 14-deployment-dagster-webserver.yaml
    └── 15-ingresses.yaml               # dagster-ui + clickhouse-play
```

A numeração reflete **ordem de aplicação**: Secrets/ConfigMaps → CRs do
Kafka → CRs do ClickHouse → Postgres → Dagster → Ingresses.

## O que mudou (vs. versão anterior em 4 namespaces)

| Antes | Depois | Motivo |
| --- | --- | --- |
| `mereo-kafka`, `mereo-clickhouse`, `mereo-analytics` | `mereo` (único) | Uma aplicação, um namespace. |
| `mereo-dagster-dagster-webserver` | `dagster-webserver` | Eliminado prefixo duplo. |
| `mereo-dagster-{daemon,webserver,pipeline}-env` (3 idênticos) | `dagster-env` (1) | Dedupe. |
| `dagster-postgresql-secret` + `mereo-dagster-postgresql` (2 secrets iguais) | `dagster-postgresql` (1) | Dedupe. |
| `mereo-dagster-postgresql` (StatefulSet) | `dagster-postgresql` | Prefixo redundante. |
| Postgres user/db = `test`/`test` | `dagster`/`dagster` | Default vergonhoso do chart bitnami. |
| `clickhouse-dbt-credentials` em 2 namespaces (clickhouse + analytics) | 1 cópia em `mereo` | Mesmo namespace, sem replicação. |
| URLs FQDN cross-ns: `clickhouse-mereo-clickhouse.mereo-clickhouse.svc...` | `clickhouse-mereo-clickhouse` | Same-namespace, nome curto. |
| Labels Helm órfãs (`heritage`, `chart`, `release`, `app.kubernetes.io/managed-by: Helm`) | Removidas | Não há Helm gerenciando. |
| Annotations `meta.helm.sh/release-*` | Removidas | Idem. |
| `kubectl.kubernetes.io/restartedAt` em template | Removida | Era resíduo de `kubectl rollout restart`. |

**Nomes preservados** (não renomeados porque são identificadores de cluster
em CRs — renomear obrigaria reescrever todas as referências em clientes):
- `mereo-kafka` (Kafka CR — vira prefixo de pods/services Strimzi).
- `mereo-clickhouse` (CHI — vira prefixo de pods/services Altinity).
- `mereo-connect` (KafkaConnect CR).

## Pré-requisitos no cluster

| Componente | Função | Como verificar |
| --- | --- | --- |
| Strimzi Cluster Operator | Reconcilia Kafka/KafkaConnect/KafkaTopic/KafkaConnector | `kubectl get crd kafkas.kafka.strimzi.io` |
| Altinity ClickHouse Operator | Reconcilia ClickHouseInstallation | `kubectl get crd clickhouseinstallations.clickhouse.altinity.com` |
| Traefik | Ingress controller (`ingressClassName: traefik`) | `kubectl get ingressclass traefik` |
| StorageClass default | Provisiona PVCs (local-path, EBS, etc) | `kubectl get sc` |

## Aplicação completa do zero

```sh
# 1) Namespaces
kubectl apply -f k8s/00-namespaces.yaml

# 2) Fonte externa simulada
kubectl apply -f k8s/mereo-sqlserver/

# 3) Aplicar tudo da plataforma. Strimzi/Altinity vão reconciliar em sequência.
kubectl apply -f k8s/mereo/

# 4) Esperar Kafka ficar Ready ANTES dos connectors funcionarem
kubectl wait kafka/mereo-kafka      -n mereo --for=condition=Ready --timeout=10m
kubectl wait kafkaconnect/mereo-connect -n mereo --for=condition=Ready --timeout=10m

# 5) ClickHouse: aplicar o init.sql (não roda automaticamente)
kubectl exec -n mereo chi-mereo-clickhouse-main-0-0-0 -- \
  bash -c 'cat <<EOF | clickhouse-client --multiquery
$(kubectl get cm clickhouse-init-sql -n mereo -o jsonpath="{.data.init\.sql}")
EOF'
```

## URLs locais (Traefik)

Adicionar em `/etc/hosts`:

```
151.244.141.115  dagster.mereo.local  clickhouse.mereo.local
```

| URL | Aponta para |
| --- | --- |
| `http://dagster.mereo.local` | Webserver Dagster |
| `http://clickhouse.mereo.local` | ClickHouse HTTP / Play UI |

## Limitações conhecidas (PoC)

1. **Secrets em base64 puro** — em prod, ExternalSecrets Operator + Vault/SOPS.
2. **`replication.factor=1`** (Kafka, Connect, ClickHouse) — não é HA.
3. **`auto.create.topics.enable=true`** — desligar em prod.
4. **`pip install` em runtime** nos pods do Dagster — em prod construir imagem
   custom com deps pre-instaladas para evitar cold-start.
5. **Sem auth nos Ingresses** — adicionar middleware Traefik (basic-auth ou
   OAuth2 proxy) em prod.
6. **`init.sql` do ClickHouse manual** — não há Job dedicado. Considere
   montar como volume no podTemplate do `ClickHouseInstallation` em prod.
7. **Job `mssql-init` é one-shot**. Para reexecutar:
   ```sh
   kubectl delete job mssql-init -n mereo-sqlserver
   kubectl apply -f k8s/mereo-sqlserver/04-job-init.yaml
   ```

## Como esses YAMLs foram gerados

Extraídos do cluster real em 26/05/2026 via:

```sh
kubectl get <kind> <name> -n <ns> -o yaml \
  | python3 k8s/_raw/clean_yaml.py > <arquivo>
```

O script `_raw/clean_yaml.py` remove campos de runtime (status, uid,
managedFields, finalizers, ownerReferences, kubectl annotations) e defaults
verbosos do API server, produzindo manifests aplicáveis idempotentemente.
Os arquivos finais foram **re-anotados manualmente** com a intenção de cada
peça de configuração + reorganizados em 2 namespaces (esta versão) ou
4 (versão anterior — pasta `_raw/` ainda contém os originais).
