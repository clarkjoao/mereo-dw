# Contracts — Snowflake DBML Mereo

## Arquivos

| Arquivo | Descrição |
|---------|-----------|
| [erp_mapping_matrix.csv](erp_mapping_matrix.csv) | **616 linhas** — cada `erp_key` → camada, papel, objetos RAW/STAGING/EDW |
| [mereo_snowflake_dimensional.sql](mereo_snowflake_dimensional.sql) | Spine **curado** (52 blocos) — hubs + marts; input do gerador, não importar sozinho |
| `mereo_snowflake_full.sql` | **Artefato autoritativo gerado** — TODAS as tabelas nas 4 camadas; é este que se importa no LocalDrawDB |
| `generator_gaps.md` | Gerado — inventário de gaps (FKs p/ alvos DEFER/EXCLUDE, tipos exóticos) |

## Regeneração

```bash
cd /Users/jvclark/www/mereo-dw
python3 analytics/catalog/generate_dbml_stubs.py    # lê matriz + schema Afya + grafo FK + spine
python3 analytics/catalog/validate_dbml_full.py     # valida o resultado
```

O spine curado é absorvido pelo gerador: blocos STAGING/EDW/MART dos hubs entram **verbatim**; os blocos RAW curados (amostras abreviadas) viram override de `@note`/`@fk` sobre a RAW gerada com colunas completas.

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
