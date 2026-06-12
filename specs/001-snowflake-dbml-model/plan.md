# Implementation Plan: Snowflake DBML — modelagem dimensional Mereo

**Branch**: `001-snowflake-dbml-model` | **Date**: 2026-06-12 | **Spec**: [spec.md](spec.md)

## Summary

Produzir documentação SpecKit + artefato SQL LocalDrawDB que modela o ERP Mereo (616 tabelas) em arquitetura Snowflake de quatro zonas (RAW→STAGING→EDW→MART), com linhagem `@origen`/`@map`, matriz ERP completa e spine SQL dos hubs principais. Silver 1:1 existente serve apenas como contexto; dbt fora de escopo.

## Technical Context

**Language/Version**: SQL (LocalDrawDB import), Markdown (SpecKit), Python 3.12 (geração matriz)  
**Primary Dependencies**: LocalDrawDB app, ClickHouse 24.3 (investigação raw), artefatos `analytics/catalog/*`  
**Storage**: ClickHouse `raw` (bronze bulk); modelo lógico em `staging`/`edw`/`mart`  
**Testing**: Import LocalDrawDB + grep auditoria `@origen`; contagem 616 na matriz CSV  
**Target Platform**: LocalDrawDB (dev); CH cluster `mereo` (read-only profiling)  
**Constraints**: Sem dbt; sem alterar silver/gold existentes; SQL Mereo só em `specs/.../contracts/`  
**Scale/Scope**: 616 tabelas ERP; 20 hubs prioritários no SQL spine; ~11.6M rows em raw CH

## Constitution Check

*GATE: Spec-only feature — sem código de produção. Compliance: documentação testável, artefatos versionados em `specs/`, sem secrets.*

- [x] Escopo limitado a specs e contratos (não deploy)
- [x] Reutiliza inventário e classificação existentes
- [x] ADR-016 respeitado em requisitos de mart

## Project Structure

### Documentation (this feature)

```text
specs/001-snowflake-dbml-model/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── contracts/
    ├── erp_mapping_matrix.csv      # 616 linhas
    ├── mereo_snowflake_dimensional.sql  # spine hubs + marts
    └── README.md
```

### Source Code (repository root)

Nenhuma alteração em `analytics/dbt/` nesta feature. Scripts de geração futuros podem viver em `analytics/catalog/` em feature posterior.

## Phase 0 — Research ([research.md](research.md))

- Inventário CH `raw.*` (486 MergeTree, row counts)
- Reuso `client_table_classification.csv`, `bronze_relationship_graph.json`
- Queries documentadas para re-profiling

## Phase 1 — Design ([data-model.md](data-model.md))

- Tabela de nomenclatura RAW/STAGING/EDW/MART
- ERD hubs colaborador × metricas × avaliacao
- Grains e SCD policy (SCD1 default dims conformed)
- Matriz 616 em CSV

## Phase 2 — Contracts (gerador + arquivo completo)

- `mereo_snowflake_dimensional.sql`: spine curado dos hubs (52 blocos) — **intocado**, vira input do gerador
- `mereo_snowflake_full.sql`: arquivo completo **gerado** com TODAS as tabelas nas 4 camadas, por `analytics/catalog/generate_dbml_stubs.py`:
  - Inputs: `erp_mapping_matrix.csv` (quais objetos existem), `output/groups/mereogr/schema/tables/MereoGR-Afya.json` (colunas/tipos/PKs), `analytics/catalog/bronze_relationship_graph.json` (709 FKs), spine curado (blocos verbatim p/ staging/edw/mart dos hubs)
  - RAW: 616 tabelas com colunas completas (hubs raw curados são absorvidos como override de `@note`/`@fk`)
  - STAGING: 209 (DIM/FACT/BRIDGE/REF; DEFER não gera staging) com `@map` coluna a coluna
  - EDW: 448 (nomes verbatim da coluna `edw_object` da matriz; surrogates `{entity}_key`; `@origen` SEMPRE staging)
  - MART: 3 curados + `pipeline.schema_drift_log` (quarentena de drift de tenant)
  - Gaps de FK/tipo: `contracts/generator_gaps.md`
- Tasks granulares e resumíveis: [tasks.md](tasks.md) (T101–T112)

## Phase 3 — Validation (scriptada)

1. `python3 analytics/catalog/validate_dbml_full.py` — contagens derivadas da matriz em runtime; nenhum bloco edw com `@origen: raw.`; todo `@map` source existe no schema Afya; blocos curados presentes
2. `npx tsx LocalDrawDB/scripts/check-sql-import.ts contracts/mereo_snowflake_full.sql` — parser headless do LocalDrawDB, exit 0 com 0 warnings
3. Import manual LocalDrawDB conforme [quickstart.md](quickstart.md) (smoke visual)
4. Gate T112: revisão humana + commit "001 v1"

## Phase 4 — Rebuild físico

Em [specs/002-edw-physical-rebuild/](../002-edw-physical-rebuild/) (deleta silver/gold legados, constrói staging/edw/mart em dbt+ClickHouse a partir deste modelo). Fora do escopo desta spec (FR-007 mantido).
