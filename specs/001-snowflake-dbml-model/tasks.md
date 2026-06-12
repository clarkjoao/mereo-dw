# Tasks: Snowflake DBML — modelo completo (616 tabelas)

**Branch**: `001-snowflake-dbml-model` | **Plano**: [plan.md](plan.md)

## Contrato de resumabilidade

Toda task tem: (a) inputs commitados, (b) output em disco, (c) verificação de 1 linha, (d) geradores idempotentes (regeneram o arquivo inteiro, ordenação determinística).

**Para retomar uma sessão interrompida**: rode as verificações de cima para baixo; a primeira que falhar é a task atual. Rodar tudo:

```bash
cd /Users/jvclark/www/mereo-dw
python3 analytics/catalog/generate_dbml_stubs.py        # regenera o full.sql
python3 analytics/catalog/validate_dbml_full.py         # valida contagens/lineage
npx tsx LocalDrawDB/scripts/check-sql-import.ts specs/001-snowflake-dbml-model/contracts/mereo_snowflake_full.sql
```

## Fase 0 — Limpeza do repo (CONCLUÍDA)

- [x] T001 Deletar dbt legado não-rastreado (silver/ 373 + gold/dim|fact|mart) — `ls analytics/dbt/models/silver` falha
- [x] T002 Mover proveniência silver p/ `analytics/catalog/legacy/` — `ls analytics/catalog/legacy/silver_domains.yaml`
- [x] T003 Exceção .gitignore + commit dos 14 schemas de tenant — `git ls-files output/groups/mereogr/schema/ | wc -l` ≥ 15
- [x] T004 LocalDrawDB como git submodule — `git submodule status | grep -q LocalDrawDB`
- [x] T005 Commits temáticos (k8s, mereo_tools, catálogo, dbt base, specs) — `git status --porcelain | wc -l` == 0
- [x] T006 Push branch — `git ls-remote origin 001-snowflake-dbml-model | grep -q .`

## Fase 2 — Gerador + mereo_snowflake_full.sql

- [x] T101 Amend plan.md (Fase 2 = gerador) + contracts/README.md + este tasks.md — `grep -q mereo_snowflake_full.sql specs/001-snowflake-dbml-model/plan.md`
- [x] T102 `analytics/catalog/dbml_model.py`: loaders (matriz/schema Afya/grafo FK), type map MSSQL→Spark, snake_case correto, regra bronze name (`table` se schema==cdc senão `{schema}__{table}`) — `python3 -c "import sys; sys.path.insert(0,'analytics/catalog'); from dbml_model import load_model; m=load_model(); assert len(m.rows)==616, len(m.rows)"`
- [x] T103 Parser do spine no dbml_model.py: blocos curados indexados por `schema.name` — `python3 -c "...; assert len(m.curated)==52"`
  - Fix no spine (2026-06-11): `stg_organizacao_cargo`/`dim_org_job` mapeavam `dbo.CARGO.ATIVO`, coluna que NÃO existe no schema real (real: ID, COD_CARGO, DESC_CARGO, ID_GRUPO_CARGO, IsCriticalJob) — corrigidos contra o schema Afya
  - Nota: matriz alinhada ao spine em 2026-06-11 (linha `competences.CALC_RESULTADO_AVALIADOR_COMPETENCIA`: staging_object = `stg_avaliacao_calc_resultado`). Sem aliases.
  - Decisão: RAW é sempre gerada com colunas completas do schema Afya (os 17 hubs raw curados são amostras abreviadas); o gerador herda `@note` e une `@fk` curados+grafo. STAGING/EDW/MART curados são emitidos verbatim.
- [x] T104 Gerador `generate_dbml_stubs.py`: seção RAW (616 tabelas, grupos da matriz, @fk do grafo sem self-edges) — `grep -c 'CREATE TABLE IF NOT EXISTS raw\.' contracts/mereo_snowflake_full.sql` == 616
- [x] T105 Seção STAGING (209 = DIM+FACT+BRIDGE+REF; DEFER não gera staging; @map por coluna, vírgula antes do comentário) — `grep -c 'CREATE TABLE IF NOT EXISTS staging\.'` == 209
- [x] T106 Seção EDW dims/refs/bridges (nomes da matriz: dim_=128, ref_=11, brg_=8 + curados dim 9/ref 1/bridge 1) — contagens por prefixo batem com a matriz
- [x] T107 EDW facts (61 por prefixo) + resolução FK→surrogate via grafo + `generator_gaps.md` — `grep -c 'CREATE TABLE IF NOT EXISTS edw\.fact_'` == 61; gaps existe
- [x] T108 DEFER stubs (239, sem @origen) + MART verbatim (3) + `pipeline.schema_drift_log` — defer_==239; mart==3
- [x] T109 `validate_dbml_full.py`: contagens derivadas da matriz em runtime; nenhum bloco edw com `@origen: raw.`; todo @map source existe no schema Afya; blocos curados presentes — `python3 analytics/catalog/validate_dbml_full.py` exit 0
- [x] T110 `LocalDrawDB/scripts/check-sql-import.ts` (sqlToModel headless); triagem de warnings até 0 — `npx tsx LocalDrawDB/scripts/check-sql-import.ts <full.sql>` exit 0
- [ ] T111 Import manual no UI (`cd LocalDrawDB && npm run dev` → Importar input/); registrar performance no quickstart.md — quickstart atualizado
- [ ] T112 **Gate**: revisão humana do modelo no LocalDrawDB; commit "001 v1" — `git log --oneline | grep -q '001 v1'`

## Fase 3 — Rebuild físico → spec 002

Continua em `specs/002-edw-physical-rebuild/tasks.md` (T201–T217). Depende do gate T112.

## Estado dos artefatos (atualizar ao concluir cada task)

| Artefato | Estado |
|---|---|
| `contracts/erp_mapping_matrix.csv` | ✅ 616 linhas, staging alinhado ao spine |
| `contracts/mereo_snowflake_dimensional.sql` | ✅ 52 blocos curados (intocado) |
| `analytics/catalog/dbml_model.py` | ✅ T102–T103 |
| `analytics/catalog/generate_dbml_stubs.py` | ✅ T104–T108 |
| `contracts/mereo_snowflake_full.sql` | ✅ 1277 tabelas, 743KB |
| `contracts/generator_gaps.md` | ✅ 175 gaps (57 FK-sem-dim, 118 raw sem PK) |
| `analytics/catalog/validate_dbml_full.py` | ✅ exit 0 (2613 @map, 979 @fk resolvem) |
| `LocalDrawDB/scripts/check-sql-import.ts` | ✅ 0 warnings, parse 3s |
