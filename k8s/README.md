# Mereo Analytics — Manifests Kubernetes

Snapshot declarativo dos 4 namespaces que compõem a plataforma de analytics
da Mereo, extraído via `kubectl` do cluster atual e re-anotado com a intenção
de cada peça.

## Arquitetura em uma página

```
┌────────────────────┐    CDC log     ┌────────────────────┐
│  mereo-sqlserver   │ ────────────▶ │   mereo-kafka      │
│  SQL Server 2022   │  (Debezium     │  Strimzi Kafka     │
│  3 bancos:         │  SqlServer)    │  + ZooKeeper       │
│   • MereoGR-Afya   │                │  + Kafka Connect   │
│   • MereoGR-Staging│                │  (3 Connectors)    │
│   • MereoGR-Allos  │                │  tópico unificado: │
│  Tabela piloto:    │                │   raw.colaborador  │
│   dbo.COLABORADOR  │                └──────────┬─────────┘
└────────────────────┘                           │
                                                 │ Kafka engine
                                                 ▼
┌──────────────────────┐  dbt build  ┌────────────────────┐
│  mereo-analytics     │ ──────────▶ │  mereo-clickhouse  │
│  Dagster webserver   │   (ClickH.  │  ClickHouseInstall │
│  Dagster daemon      │    via      │  raw / gold /      │
│  user-code (gRPC)    │    dbt-CH)  │  pipeline schemas  │
│  Postgres (metadata) │             │  CronJob lag snap. │
└──────────────────────┘             └────────────────────┘
```

Documento de contrato da entidade piloto:
`analytics/catalog/entities/colaborador.yaml`.

## Layout dos arquivos

```
k8s/
├── 00-namespaces.yaml                  # cria os 4 namespaces
├── mereo-sqlserver/                    # FONTE (CDC source)
│   ├── 00-secret-sa-credentials.yaml
│   ├── 01-service.yaml
│   ├── 02-statefulset.yaml
│   ├── 03-configmap-init-sql.yaml      # DDL + seed + sp_cdc_enable_*
│   └── 04-job-init.yaml
├── mereo-kafka/                        # BUS de eventos (Strimzi)
│   ├── 00-secret-debezium-creds.yaml
│   ├── 01-kafka-cluster.yaml           # Kafka CR (broker + ZK + entityOperator)
│   ├── 02-kafka-topics.yaml            # schema-history + raw.colaborador
│   ├── 03-kafka-connect.yaml           # KafkaConnect CR
│   └── 04-kafka-connectors.yaml        # 3 Debezium SqlServerConnector
├── mereo-clickhouse/                   # DATA WAREHOUSE
│   ├── 00-secret-dbt-credentials.yaml
│   ├── 01-configmap-init-sql.yaml      # DDL raw/gold/pipeline + MV Kafka
│   ├── 02-clickhouse-installation.yaml # CR do Altinity operator
│   ├── 03-ingress-clickhouse-play.yaml
│   └── 04-cronjob-pipeline-lag-snapshot.yaml
└── mereo-analytics/                    # ORQUESTRAÇÃO (Dagster + dbt + Pg)
    ├── 00-secrets.yaml
    ├── 01-rbac.yaml                    # SA + Role (Jobs/Pods/Events) + Binding
    ├── 02-postgresql.yaml              # Postgres interno do Dagster
    ├── 03-configmaps-dbt.yaml          # dbt project + models
    ├── 04-configmaps-dagster.yaml      # dagster.yaml + workspace + código Python
    ├── 05-deployment-analytics-code.yaml
    ├── 06-deployment-dagster-daemon.yaml
    ├── 07-deployment-dagster-webserver.yaml
    └── 08-ingress-dagster-ui.yaml
```

A numeração no nome do arquivo (`00-`, `01-`, ...) reflete a **ordem de
aplicação** dentro de cada namespace: Secrets/ConfigMaps antes dos workloads
que os referenciam.

## Pré-requisitos no cluster

Estes manifests **assumem** que os operators e add-ons abaixo já estão
instalados no cluster:

| Componente | Função | Namespace típico |
| --- | --- | --- |
| Strimzi Cluster Operator | Reconcilia `Kafka`, `KafkaConnect`, `KafkaTopic`, `KafkaConnector` | `kafka` (ou cluster-wide) |
| Altinity ClickHouse Operator | Reconcilia `ClickHouseInstallation` | `clickhouse-operator-system` |
| Traefik | Ingress controller (classe `traefik`) | `traefik` |
| StorageClass `local-path` | StorageClass default | `local-path-storage` |
| (opcional) cert-manager | Não usado pela PoC, mas presente | `cert-manager` |

Para checar:

```sh
kubectl get crd kafkas.kafka.strimzi.io clickhouseinstallations.clickhouse.altinity.com ingressclasses.networking.k8s.io
```

## Aplicação completa do zero

```sh
# 1) Namespaces
kubectl apply -f 00-namespaces.yaml

# 2) Fonte
kubectl apply -f mereo-sqlserver/

# 3) Bus (esperar Kafka CR ficar READY antes dos connectors)
kubectl apply -f mereo-kafka/00-secret-debezium-creds.yaml
kubectl apply -f mereo-kafka/01-kafka-cluster.yaml
kubectl wait kafka/mereo-kafka -n mereo-kafka --for=condition=Ready --timeout=10m
kubectl apply -f mereo-kafka/02-kafka-topics.yaml
kubectl apply -f mereo-kafka/03-kafka-connect.yaml
kubectl wait kafkaconnect/mereo-connect -n mereo-kafka --for=condition=Ready --timeout=10m
kubectl apply -f mereo-kafka/04-kafka-connectors.yaml

# 4) Warehouse
kubectl apply -f mereo-clickhouse/
# init.sql precisa ser aplicado manualmente (ou via dbt sync-workspace):
kubectl exec -n mereo-clickhouse chi-mereo-clickhouse-main-0-0-0 -- \
  bash -c 'cat /etc/clickhouse-server/conf.d/init.sql | clickhouse-client --multiquery'

# 5) Orquestração
kubectl apply -f mereo-analytics/
```

## URLs locais (Traefik)

Adicionar em `/etc/hosts` (substituir IP pelo do Ingress controller):

```
151.244.141.115  dagster.mereo.local  clickhouse.mereo.local
```

| URL | Aponta para |
| --- | --- |
| `http://dagster.mereo.local` | Webserver Dagster (orquestrador) |
| `http://clickhouse.mereo.local` | ClickHouse HTTP / Play UI |

## Observações importantes

1. **Senhas em base64**: os Secrets aqui contêm valores reais da PoC em
   base64 puro. Em produção, substituir por integração com cofre (External
   Secrets Operator, Vault, SOPS, AWS/Azure KMS).
2. **`replication.factor=1`**: Kafka, Connect, ClickHouse — tudo single-node.
   NÃO é HA. Para prod, escalar Kafka para 3 brokers e ClickHouse para
   ZooKeeper + 2+ réplicas (ou ClickHouse Keeper integrado).
3. **Helm release labels**: alguns manifests (Dagster, Postgres bitnami)
   carregam labels `helm.sh/chart`/`meta.helm.sh/release-name` originárias
   do install via Helm. Foram preservadas porque mover para apply puro sem
   essas labels causaria conflito se você decidir um dia voltar ao Helm.
   Para limpar, basta remover manualmente.
4. **Job `mssql-init`**: rode-o de novo após alteração no
   `mssql-init-sql` ConfigMap:
   ```sh
   kubectl delete job mssql-init -n mereo-sqlserver
   kubectl apply -f mereo-sqlserver/04-job-init.yaml
   ```
5. **Schema do ClickHouse**: `clickhouse-init-sql` ConfigMap é o DDL
   canônico — fonte da verdade da estrutura `raw.*`, `gold.*`, `pipeline.*`.
   Mudou? Roda manualmente via `clickhouse-client --multiquery`.

## Como esses YAMLs foram gerados

Extraídos diretamente do cluster atual em **26/05/2026** com:

```sh
kubectl get <kind> <name> -n <namespace> -o yaml \
  | python3 k8s/_raw/clean_yaml.py > <arquivo>
```

O script `_raw/clean_yaml.py` remove campos de runtime (status,
resourceVersion, uid, managedFields, finalizers, ownerReferences) e
defaults verbosos do API server (terminationMessagePath, schedulerName,
clusterIP, etc), produzindo manifests aplicáveis idempotentemente.

Os arquivos finais foram re-anotados manualmente com a intenção de cada
configuração (cabeçalhos + comentários inline).
