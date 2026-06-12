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

## Phase 2 — Contracts

- `mereo_snowflake_dimensional.sql`: spine completo dos 20 hubs + exemplos MART
- Expansão futura: gerar stubs RAW restantes por domínio a partir da matriz

## Phase 3 — Validation (manual)

1. `wc -l contracts/erp_mapping_matrix.csv` → 617 (header + 616)
2. `grep -c '@layer: edw' contracts/mereo_snowflake_dimensional.sql`
3. `grep '@origen: raw\.' contracts/mereo_snowflake_dimensional.sql` em blocos edw → 0
4. Import LocalDrawDB conforme [quickstart.md](quickstart.md)
