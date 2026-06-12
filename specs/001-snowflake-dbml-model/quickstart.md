# Quickstart: LocalDrawDB — Snowflake DBML Mereo

## Pré-requisitos

- [LocalDrawDB](../LocalDrawDB/) instalado (`npm install` no diretório)
- Matriz e SQL em `specs/001-snowflake-dbml-model/contracts/`

## Importar modelo

```bash
cd LocalDrawDB
mkdir -p data/input

# Copiar artefato Mereo (não usar examples/ — regra do repo LocalDrawDB)
cp ../specs/001-snowflake-dbml-model/contracts/mereo_snowflake_dimensional.sql data/input/

npm run dev
# Toolbar → Importar (input/)
```

## Validar camadas

Após import, verificar no canvas:

1. **Layers** `raw`, `staging`, `edw`, `mart` visíveis
2. **Linhagem L1**: `raw.dbo__COLABORADOR` → `staging.stg_colaborador_colaborador` → `edw.dim_employee`
3. **Nenhum** `@origen: raw.` em tabelas `@layer: edw`

## Auditoria rápida (terminal)

```bash
# 616 linhas na matriz
wc -l specs/001-snowflake-dbml-model/contracts/erp_mapping_matrix.csv

# EDW não referencia raw diretamente
awk '/@layer: edw/,/^-- @layer:/' specs/001-snowflake-dbml-model/contracts/mereo_snowflake_dimensional.sql \
  | grep '@origen: raw\.' && echo "FAIL" || echo "OK"
```

## Matriz ERP

Abrir `contracts/erp_mapping_matrix.csv` no Excel/DataGrip para filtrar:

- `dimensional_role=DIM` → 129 dims
- `dimensional_role=EXCLUDE` → 168 sem EDW
- `dimensional_role=DEFER` → 239 stubs

## Próximo passo (fora desta feature)

Após aprovação do DBML: `/speckit.tasks` → implementação dbt em feature separada.
