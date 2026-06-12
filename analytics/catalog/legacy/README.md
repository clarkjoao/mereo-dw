# Legacy — proveniência da era silver 1:1

Artefatos da abordagem anterior (373 views silver 1:1 por domínio), **substituída** pela modelagem snowflake de 4 zonas (`raw → staging → edw → mart`) definida em `specs/001-snowflake-dbml-model/`.

Mantidos no git apenas como proveniência: a `erp_mapping_matrix.csv` e o `client_table_classification.csv` foram derivados destas análises (ver `specs/001-snowflake-dbml-model/research.md`).

**Não usar como referência de convenções** — os geradores aqui contêm bugs conhecidos (ex.: snake_case quebrado gerando colunas `i_d__m_e_t_a`) e os modelos dbt que eles geraram foram deletados sem nunca terem sido commitados.

| Arquivo | O que era |
|---|---|
| `silver_domains.yaml` | 373 entidades silver mapeadas 1:1 para bronze, em 9 domínios |
| `silver_reuse_matrix.csv` | Auditoria silver × classificação dimensional |
| `generate_silver_model.py` / `generate_silver_batch.py` | Geradores das views silver (bug de snake_case) |
| `sync_silver_catalog.py` | Reconciliação bronze_domain_map ↔ silver_domains |
| `audit_silver_reuse.py` | Gerador da matriz de reuso |
| `staging_exploration_summary.yaml` / `staging_vs_client_diff.csv` | Investigação do tenant staging (ADR-016) |
| `explore_client_dimensions.py` / `explore_staging_role.py` | Scripts de exploração ad-hoc |
