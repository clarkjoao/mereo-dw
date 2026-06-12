# Quickstart: LocalDrawDB — Snowflake DBML Mereo

## Pré-requisitos

- [LocalDrawDB](../../LocalDrawDB/) instalado (`npm install` no diretório)
- Artefatos em `specs/001-snowflake-dbml-model/contracts/`

## Regenerar + validar (pipeline completo)

```bash
cd /Users/jvclark/www/mereo-dw
python3 analytics/catalog/generate_dbml_stubs.py      # gera mereo_snowflake_full.sql (1277 tabelas)
python3 analytics/catalog/validate_dbml_full.py       # contagens, lineage, @map/@fk resolvem
npx tsx LocalDrawDB/scripts/check-sql-import.ts \
  specs/001-snowflake-dbml-model/contracts/mereo_snowflake_full.sql   # parser real, 0 warnings
```

Métricas de referência (2026-06-11): 1277 tabelas, 964 refs, 421 lineages L1,
2603 lineages L2, parse ~3s, 744 KB, **0 warnings**.

## Importar modelo no UI

```bash
cd LocalDrawDB
mkdir -p data/input
# Importar o arquivo COMPLETO gerado (o spine mereo_snowflake_dimensional.sql é
# só curadoria/input do gerador — não importar sozinho)
cp ../specs/001-snowflake-dbml-model/contracts/mereo_snowflake_full.sql data/input/
npm run dev
# Toolbar → Importar (input/)
```

## Validar camadas

Após import, verificar no canvas:

1. **Layers** `raw`, `staging`, `edw`, `mart` visíveis (+ grupo `pipeline` com schema_drift_log)
2. **Linhagem L1**: `raw.dbo__COLABORADOR` → `staging.stg_colaborador_colaborador` → `edw.dim_employee`
3. **Linhagem L2**: `raw.dbo__COLABORADOR.ID` → `staging...employee_id` → `edw.dim_employee.employee_id`
4. **Nenhum** `@origen: raw.` em tabelas `@layer: edw` (garantido pelo validador)

## Matriz ERP

Abrir `contracts/erp_mapping_matrix.csv` no Excel/DataGrip para filtrar:

- `dimensional_role=DIM` → 129 dims (`edw.dim_*`)
- `dimensional_role=FACT` → 59 fatos (61 objetos `fact_*`)
- `dimensional_role=BRIDGE/REF` → 10 + 11
- `dimensional_role=DEFER` → 239 stubs `edw.defer_*` (sem dados piloto)
- `dimensional_role=EXCLUDE` → 168 só em raw (ADR-006)

Gaps documentados (FKs para alvos sem dim, raw sem PK): `contracts/generator_gaps.md`.

## Performance do canvas (T111)

Smoke test executado em 2026-06-11 (Chrome embutido, macOS):

| Métrica | Valor |
|---|---|
| Import (clique → 1277 tabelas renderizadas) | ~6,0 s |
| Status pós-import | `1277 tabela(s), 964 ref(s) — 2603 mapeamento(s) L2` |
| Fit view com modelo completo | ~6 s (animação incluída) |
| Heap JS após import | ~470–810 MB |
| Navegação (busca, pan, zoom, seleção) | fluida após render inicial |

Observações:

- O canvas renderiza todas as 1277 tabelas sem virtualização; o primeiro
  fit view/Organize é a operação mais pesada (~6 s), depois a navegação é fluida.
- **Não** foi necessário filtrar por `@group`, mas para revisão dirigida é mais
  confortável usar a busca de tabela + "Modo linhagem" (esmaece tudo fora da
  cadeia da tabela selecionada) ou desligar camadas no painel (raw/staging/edw/mart).
- O documento default do editor (`loja.cliente`/`loja.pedido`) é mantido no
  import — deletar as 2 tabelas de exemplo após importar.
- Linhagem verificada no canvas: `raw.dbo__COLABORADOR` →
  `staging.stg_colaborador_colaborador` → `edw.dim_employee` (L1) + arestas de
  campo (L2); `pipeline.schema_drift_log` presente.

## Próximo passo

Após gate T112 (revisão humana + commit "001 v1"): spec 002-edw-physical-rebuild
(deleta silver/gold legados, constrói staging/edw/mart em dbt + ClickHouse).
