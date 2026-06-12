# Decisões de arquitetura — Silver por domínios

Registro ADR (Architecture Decision Record) da modelagem silver. Catálogo operacional: [`silver_domains.yaml`](../catalog/silver_domains.yaml).

---

## ADR-001 — Domínio de negócio, não schema ERP

**Contexto:** Bronze usa naming técnico `raw.dbo__{TABLE}` (414 tabelas dbo).

**Decisão:** Silver organizada em **CH databases por domínio** (`colaborador`, `metricas`, …), não pastas `dbo/`.

**Consequências:** ETLs legíveis (`metricas.meta`); mapa explícito em `silver_domains.yaml`.

---

## ADR-002 — Naming `{dominio}.{entidade}`

**Decisão:** Tabela CH = `{domain}.{silver_table}` — ex. `colaborador.pessoa`, `metricas.indicador`.

**Consequências:** dbt model `pessoa` em `models/silver/colaborador/` com `+schema: colaborador`.

---

## ADR-003 — Multi-tenant via `tenant_slug`

**Decisão:** Uma tabela silver por entidade; três bancos na coluna `tenant_slug` (staging, allos, afya).

**Consequências:** PK composta `(tenant_slug, id)` nos testes dbt.

---

## ADR-004 — Bronze em `raw`, silver não re-ingere

**Decisão:** Silver só transforma via `source('bronze', …)`; sem duplicar pipeline bulk/CDC.

---

## ADR-005 — COLABORADOR sem ID_AREA

**Decisão:** Vínculo pessoa↔área em `colaborador.vinculo_area` (`dbo__COLABORADOR_AREA`).

---

## ADR-006 — Exclusões da silver

**Decisão:** Fora de escopo: `AUDIT_*`, `IMP_*`, `LOG_*`, `HangFire`, `AbpEntity*`.

---

## ADR-007 — TOP 50k = amostra

**Decisão:** Tabelas com cap no backup (ex. `dbo__CARGO` allos/afya 50k) documentadas como amostra em `silver_domains.yaml` notes.

---

## ADR-008 — competences → domínio avaliacao

**Decisão:** Schema ERP `competences.*` mapeia para CH database `avaliacao`, não schema separado na silver.

---

## ADR-009 — PARTICIPANTE vs PARTICIPANTE_RV

**Decisão:** `dbo__PARTICIPANTE` sem bulk; fato RV = `remuneracao.participante_rv`.

---

## ADR-010 — ValorMatriz onda 5

**Decisão:** `metricas.matriz_valor` (~5,9M rows) adiada até estratégia de volume/agregação.

---

## ADR-011 — Gold depois da silver

**Decisão:** Marts gold só após silver estável por domínio.

---

## ADR-012 — Fontes de verdade

| Artefato | Papel |
|----------|-------|
| `silver_domains.yaml` | Catálogo máquina (bronze → silver, ondas) |
| `silver-domain-discovery-spec.md` | Mapa 486 tabelas bronze → domínios candidatos |
| `bronze_domain_map.yaml` | Classificação máquina (FK + heurísticas) |
| `silver-modeling-guide.md` | Guia humano ETL |
| Este arquivo | Porquê das decisões |

**Regra:** nova onda ou mudança de domínio → atualizar ADR + `silver_domains.yaml`.

---

## ADR-013 — Domínios CH aprovados (workshop 2026-06)

**Contexto:** [`silver-domain-discovery-spec.md`](silver-domain-discovery-spec.md) levantou domínios candidatos e fronteiras ambíguas.

**Decisões:**

| Tópico | Decisão | Evidência |
|--------|---------|-----------|
| Feedback contínuo | **Dentro de `avaliacao`** | FKs para `competences.COMPETENCIA` e `FEEDBACK_CONTINUO`; mesmo ciclo de performance |
| Ação / reunião | **CH database `acao` separado** | Hub `dbo.ACAO` (grau 14); ligação com metas via gold, não merge na silver |
| Sucessão | **CH database `sucessao` separado** | Hub `SuccessionCycle` (grau 21); 23 tabelas cluster próprio |
| OKR (`okr.*`) | **Dentro de `metricas`** (mesmo CH database) | 14 FKs, **zero** ligação estrutural com `dbo.META`; 532 rows; módulo isolado — tabelas silver `objetivo_okr`, `resultado_chave`, etc. |

**Consequências:** 9 CH databases silver: `colaborador`, `organizacao`, `metricas`, `avaliacao`, `remuneracao`, `referencia`, `acao`, `sucessao`, (+ `gold`, `pipeline`, `raw`).

**OKR vs META:** overlap é semântico (objetivos), não relacional. Joins gold podem cruzar `metricas.objetivo_okr` com `metricas.meta` por período/área se regra de negócio exigir — não há FK ERP.

---

## ADR-014 — PDI, estratégia e ValorMatriz (workshop 2026-06)

| Tópico | Decisão |
|--------|---------|
| PDI / Training | **CH database `pdi`** — `Training*`, `Qualification*`, `HISTORICO_PDI`, `competences.*PDI*` |
| Estratégia / SWOT | **Fundir em `metricas`** — `Strategy*`, `SwotAnalysis`, `Perspective`, `Visao` |
| **ValorMatriz** | Permanece em `metricas` onda 5 — ver abaixo |

### O que é `dbo.ValorMatriz`

**Não é** `VALOR_META` (valor por meta/KPI). É o **fato granular da matriz de performance**:

| Campo | Papel |
|-------|--------|
| `FkMatriz` | Definição da matriz (`dbo.Matriz` — indicador + eixos X/Y/Z) |
| `FkMembroDimensao1/2/3` | Célula nos eixos (`dbo.MembroDimensao` — área, filial, etc.) |
| `FkUnidadeMedida` | Unidade da métrica |
| `DtRef` | Data de referência |
| `Pontual*` / `Acum*` | Previsto, forecast, realizado (pontual e acumulado) |

Volume: **~5,9M linhas** (hoje só tenant `staging` no bulk). Silver adiada (ADR-010) até estratégia de partição/agregação.

---

## ADR-015 — Cobertura silver 1:1 e ValorMatriz filtrada (2026-06)

**Contexto:** 373 tabelas bronze de negócio devem ter view silver correspondente (`sync_silver_catalog.py` + `generate_silver_batch.py`).

**Decisões:**

| Tópico | Decisão |
|--------|---------|
| Cobertura | **1 bronze → 1 silver view** por domínio CH; catálogo em `silver_domains.yaml` |
| Automação | `sync_silver_catalog.py` (planned) + `generate_silver_batch.py` (SQL) + `dbt run` por onda |
| **ValorMatriz** | Exceção de volume: `metricas.valor_matriz` com vars dbt |

### Vars `valor_matriz`

| Var | Default | Papel |
|-----|---------|-------|
| `matriz_valor_tenant_slugs` | `['afya','allos','staging']` | Filtro multi-tenant |
| `matriz_valor_dt_ref_from` | `null` | Início do intervalo `DtRef` |
| `matriz_valor_dt_ref_to` | `null` | Fim do intervalo `DtRef` |
| `matriz_valor_unfiltered_guard` | `true` | Se `true` e ambos `DtRef` null → view vazia (`1=0`) |

**Uso:** para consultar staging (~5,9M rows), passar `--vars '{"matriz_valor_dt_ref_from": "2024-01-01", "matriz_valor_unfiltered_guard": false}'` ou intervalo equivalente.

---

## ADR-016 — Staging não é tenant cliente (2026-06)

**Contexto:** [`staging-database-role-spec.md`](staging-database-role-spec.md) — `MereoGR-Staging` foi tratado como par em `tenant_slug` junto com Afya/Allos.

**Evidência:**
- 595 tabelas (−21 vs contrato 616); sem módulo Goal/KPI
- Emails `noreply@mereo.com` vs domínios cliente
- `ValorMatriz` 5,9M rows só em staging (sandbox)
- 99% overlap de **IDs** `COLABORADOR` com Afya — subset de homologação, não produção

**Decisão:**

| Tópico | Decisão |
|--------|---------|
| Papel | **Ambiente interno Mereo** (QA/homolog), não cliente |
| Marts gold | **Excluir** `tenant_slug='staging'` de KPIs de negócio (provisório) |
| Bronze/silver | Pode permanecer para testes operacionais |
| Contrato ERP | Referência = **616 tabelas Afya**; clientes = `MereoGR-{Nome}` |

**Consequências:** novos clientes entram só via `tenant_slug`; staging não define grain de fatos. Reavaliar flag `is_internal` após workshop.

**Specs relacionadas:** [client-dimensional-discovery-spec.md](client-dimensional-discovery-spec.md), [silver-to-dimensional-reuse-spec.md](silver-to-dimensional-reuse-spec.md)
