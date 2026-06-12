# Feature Specification: Snowflake DBML — modelagem dimensional Mereo

**Feature Branch**: `001-snowflake-dbml-model`  
**Created**: 2026-06-12  
**Status**: Draft  
**Input**: Modelagem dimensional Snowflake 616 tabelas: investigar raw CH, produzir spec DBML LocalDrawDB com camadas RAW/STAGING/EDW/MART e metadados `@layer/@origen/@map`; silver 1:1 é contexto apenas; sem dbt.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Visualizar camadas separadas no LocalDrawDB (Priority: P1)

Como analista de dados, quero importar o artefato SQL no LocalDrawDB e ver **quatro zonas distintas** (RAW, STAGING, EDW, MART) para que landing bronze e dimensões conformed não apareçam no mesmo plano visual.

**Why this priority**: Corrige o problema atual em que `raw.*` e dims gold parecem equivalentes no DBeaver/DataGrip; a separação de camadas é pré-requisito para qualquer implementação dbt futura.

**Independent Test**: Copiar `contracts/mereo_snowflake_dimensional.sql` para `LocalDrawDB/data/input/`, importar, e verificar LayerGroups `raw`, `staging`, `edw`, `mart` com zero tabela EDW referenciando `raw.*` via `@origen` direto.

**Acceptance Scenarios**:

1. **Given** o SQL importado, **When** o usuário expande `@layer: edw`, **Then** todas as tabelas têm `@origen` apontando apenas para `staging.*` ou outras tabelas EDW/MART.
2. **Given** o canvas LocalDrawDB, **When** o usuário filtra por layer `raw`, **Then** aparecem objetos `raw.dbo__*` / `raw.competences__*` sem prefixo `dim_` ou `fact_`.
3. **Given** linhagem L1 ativa, **When** o usuário segue `raw.dbo__COLABORADOR` → `edw.dim_employee`, **Then** existe pelo menos um hop intermediário `staging.stg_colaborador_colaborador`.

---

### User Story 2 — Traçar linhagem coluna a coluna (Priority: P2)

Como engenheiro de analytics, quero `@map` inline em colunas STAGING e EDW para que eu saiba exatamente qual coluna ERP alimenta cada atributo dimensional.

**Why this priority**: A silver atual é 1:1 sem documentação de transformação; o demo `demo_lakehouse_complex.sql` prova que `@map` + `@note` são o contrato do app LocalDrawDB.

**Independent Test**: Abrir `edw.dim_employee` no LocalDrawDB, modo linhagem L2, e ver `employee_id` mapeado desde `raw.dbo__COLABORADOR.ID` via staging.

**Acceptance Scenarios**:

1. **Given** hub `dbo.COLABORADOR`, **When** inspeciono `edw.dim_employee`, **Then** colunas de negócio têm `@map` desde staging (não desde raw).
2. **Given** fato `edw.fact_goal_value`, **When** inspeciono grain, **Then** `@note` documenta grain `(tenant_slug, goal_id, dt_ref)`.
3. **Given** transformação derivada (ex.: `line_amount`), **When** `@map` referencia cálculo, **Then** `@note` na coluna descreve a fórmula (padrão demo).

---

### User Story 3 — Catálogo 616 tabelas rastreável (Priority: P3)

Como arquiteto de dados, quero uma matriz ERP → camada → papel → objeto EDW para cada uma das **616 tabelas** do contrato `MereoGR-Afya`, incluindo EXCLUDE e DEFER documentados.

**Why this priority**: Escala multi-cliente exige contrato completo; stubs DEFER evitam re-modelar quando novos tenants popularem tabelas vazias.

**Independent Test**: Abrir `contracts/erp_mapping_matrix.csv` e confirmar 616 linhas com `erp_key` único e `dimensional_role` preenchido.

**Acceptance Scenarios**:

1. **Given** `client_table_classification.csv`, **When** comparo com `erp_mapping_matrix.csv`, **Then** 616/616 `erp_key` presentes.
2. **Given** tabela `HangFire.Job`, **When** consulto matriz, **Then** `dimensional_role=EXCLUDE` e `edw_object` vazio.
3. **Given** tabela DEFER sem dados piloto, **When** consulto matriz, **Then** `edw_object` é stub `edw.defer_*` com `note` explicativo.

---

### Edge Cases

- Tabela bronze ausente no CH (`raw.*` não materializada): objeto RAW no DBML existe como contrato; `@note: CH_PENDING`.
- `MereoGR-Staging` (tenant interno): presente em RAW/STAGING/EDW; MART de produção documenta exclusão (ADR-016).
- PK composta ERP: grain EDW preserva `(tenant_slug, …)`; surrogate `{entity}_key` para joins internos.
- FK no grafo bronze sem coluna física no CH: `@fk` lógico no comentário SQL (padrão LocalDrawDB).
- Domínio `plataforma` / `unclassified`: `@group: exclude` ou `ingestao_erp` conforme classificação.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A spec MUST definir contrato de metadados LocalDrawDB: `@layer`, `@group`, `@note`, `@fk`, `@origen`, `@map` (inline), conforme [LocalDrawDB/examples/input/README.md](../../LocalDrawDB/examples/input/README.md) e [demo_lakehouse_complex.sql](../../LocalDrawDB/examples/input/demo_lakehouse_complex.sql).
- **FR-002**: A spec MUST adotar quatro schemas lógicos Snowflake-style: `raw` → `staging` → `edw` → `mart` (ver [data-model.md](data-model.md#nomenclatura)).
- **FR-003**: A spec MUST exigir investigação de `raw.*` no ClickHouse (row counts, PK, FK, tenants) documentada em [research.md](research.md) antes de finalizar colunas EDW dos hubs.
- **FR-004**: A spec MUST mapear 616 `erp_key` em [contracts/erp_mapping_matrix.csv](contracts/erp_mapping_matrix.csv) com camada, papel dimensional e objeto EDW ou exclusão.
- **FR-005**: A spec MUST normalizar hubs (COLABORADOR, META, AREA, AVALIACAO, …) em dimensões 3NF separadas — proibido wide table 1:1 bronze→EDW.
- **FR-006**: Regra de linhagem: **nenhum** objeto `edw.dim_*`, `edw.fact_*`, `edw.bridge_*` pode declarar `@origen: raw.*` — sempre via `staging.stg_*`.
- **FR-007**: A spec MUST NOT incluir implementação dbt, manifests K8s ou alteração de `analytics/dbt/models/silver/` nesta fase.
- **FR-008**: A spec MUST reutilizar artefatos existentes: `client_table_classification.csv`, `bronze_relationship_graph.json`, `dim_fact_candidates.yaml`, specs de descoberta dimensional em `analytics/docs/`.
- **FR-009**: Silver atual (`colaborador.pessoa`, `metricas.meta`, …) MAY ser citada em `@note` como contexto legado, MUST NOT ser destino da modelagem alvo.
- **FR-010**: Artefato SQL proprietário MUST residir em `specs/001-snowflake-dbml-model/contracts/` — não em `LocalDrawDB/examples/`.
- **FR-011**: Surrogate keys `{entity}_key BIGINT` obrigatórias em dims EDW; natural keys `(tenant_slug, {entity}_id)` documentadas em `@note` de grain.
- **FR-012**: Marts (`mart.*`) MUST derivar somente de EDW (dims/fatos/bridges), nunca de raw ou silver 1:1.

### Key Entities

- **dim_employee** (`dbo.COLABORADOR`): colaborador/pessoa; hub FK grau 164.
- **dim_org_area** (`dbo.AREA`): hierarquia organizacional.
- **dim_org_job** (`dbo.CARGO`): cargos e funções organizacionais.
- **dim_goal** (`dbo.META`): metas/indicadores de desempenho.
- **dim_kpi** (`dbo.INDICADOR`): definição de KPI.
- **dim_time_gestao** / **dim_time_apuracao**: períodos de gestão e apuração RV.
- **dim_eval_cycle** / **dim_competency**: ciclos e competências de avaliação.
- **bridge_employee_area** (`dbo.COLABORADOR_AREA`): vínculo N:N colaborador↔área.
- **fact_goal_value** (`dbo.VALOR_META`): medidas previsto/realizado por meta e data.
- **fact_eval_score** (`competences.CALC_RESULTADO_AVALIADOR_COMPETENCIA`): notas por avaliador×competência.
- **fact_rv** (`dbo.PARTICIPANTE_RV`): remuneração variável.
- **fact_feedback** / **fact_action**: feedback contínuo e planos de ação.
- **report_performance_360** (mart): visão cross-domain colaborador×meta×avaliação (derivada EDW).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `contracts/erp_mapping_matrix.csv` contém **616/616** `erp_key` únicos alinhados a `analytics/catalog/client_table_classification.csv`.
- **SC-002**: **100%** dos objetos EDW no SQL spine têm `@origen` apontando para `staging.*` (auditoria grep: zero `@origen: raw.` em blocos `@layer: edw`).
- **SC-003**: LocalDrawDB importa `contracts/mereo_snowflake_dimensional.sql` e exibe LayerGroups `raw`, `staging`, `edw`, `mart`.
- **SC-004**: Top **20 hubs** de `dim_fact_candidates.yaml` possuem cadeia RAW→STAGING→EDW documentada no SQL spine ou na matriz com `layer_path=raw+staging+edw`.
- **SC-005**: [research.md](research.md) documenta inventário CH `raw` (≥486 tabelas MergeTree, row counts) e amostra multi-tenant.
- **SC-006**: [data-model.md](data-model.md) contém ERD dos três hubs (colaborador, metricas, avaliacao) e tabela de nomenclatura completa.

## Assumptions

- Contrato estrutural de referência: **616 tabelas** em `MereoGR-Afya`; clientes piloto `afya` e `allos` com `tenant_slug` no CH.
- `MereoGR-Staging` é ambiente interno (ADR-016); fora de marts de produção.
- ClickHouse atual mantém bronze em database `raw`; schemas lógicos `staging`/`edw`/`mart` são **modelo lógico** (migração física CH é fase posterior).
- Classificação dimensional (129 DIM, 59 FACT, 10 BRIDGE, 11 REF, 168 EXCLUDE, 239 DEFER) permanece válida até novo `explore_client_dimensions.py`.
- Implementação dbt e depreciação das 373 views silver ocorrem em feature futura, após DBML aprovado.

## Artefatos desta feature

| Artefato | Caminho | Fase |
|----------|---------|------|
| Feature spec | [spec.md](spec.md) | specify |
| Plano | [plan.md](plan.md) | plan |
| Investigação raw | [research.md](research.md) | plan |
| Modelo + nomenclatura | [data-model.md](data-model.md) | plan |
| Quickstart LocalDrawDB | [quickstart.md](quickstart.md) | plan |
| Matriz 616 ERP | [contracts/erp_mapping_matrix.csv](contracts/erp_mapping_matrix.csv) | plan |
| SQL spine → DBML | [contracts/mereo_snowflake_dimensional.sql](contracts/mereo_snowflake_dimensional.sql) | plan |

## Referências

- Demo canônico: [LocalDrawDB/examples/input/demo_lakehouse_complex.sql](../../LocalDrawDB/examples/input/demo_lakehouse_complex.sql)
- Classificação: [analytics/catalog/client_table_classification.csv](../../analytics/catalog/client_table_classification.csv)
- Grafo FK: [analytics/catalog/bronze_relationship_graph.json](../../analytics/catalog/bronze_relationship_graph.json)
- Hubs: [analytics/catalog/dim_fact_candidates.yaml](../../analytics/catalog/dim_fact_candidates.yaml)
- Descoberta: [analytics/docs/client-dimensional-discovery-spec.md](../../analytics/docs/client-dimensional-discovery-spec.md)
- ADR staging: ADR-016 (staging ≠ cliente)
