# Contracts — Snowflake DBML Mereo

## Arquivos

| Arquivo | Descrição |
|---------|-----------|
| [erp_mapping_matrix.csv](erp_mapping_matrix.csv) | **616 linhas** — cada `erp_key` → camada, papel, objetos RAW/STAGING/EDW |
| [mereo_snowflake_dimensional.sql](mereo_snowflake_dimensional.sql) | Spine SQL LocalDrawDB — hubs prioritários + marts; importar → DBML |

## Escopo do SQL spine

O arquivo `mereo_snowflake_dimensional.sql` **não** contém 616 `CREATE TABLE` completos (artefato seria >500KB). Contém:

1. **RAW** — hubs top 20 + amostras representativas
2. **STAGING** — cadeias documentadas com `@map`
3. **EDW** — dims/fatos/bridges conformed dos hubs
4. **MART** — 3 reports cross-domain

Tabelas restantes estão na matriz CSV; expansão futura via gerador:

```bash
# Futuro: analytics/catalog/generate_dbml_stubs.py --from specs/.../erp_mapping_matrix.csv
```

## Regras de geração (expansão 616)

Para cada linha da matriz:

| `dimensional_role` | Gerar |
|--------------------|-------|
| EXCLUDE | `CREATE TABLE raw.{bronze}` + `@group: exclude` |
| DEFER | RAW + `CREATE TABLE edw.defer_{table}` stub |
| DIM/FACT/BRIDGE/REF | RAW + STAGING + EDW com `@origen`/`@map` |

## Referência de formato

- [LocalDrawDB/examples/input/demo_lakehouse_complex.sql](../../../LocalDrawDB/examples/input/demo_lakehouse_complex.sql)
- [LocalDrawDB/examples/input/README.md](../../../LocalDrawDB/examples/input/README.md)
