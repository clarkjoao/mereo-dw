# Spec 3 — Reuso da silver para modelo dimensional

**Objetivo:** mapear as **373 views silver** existentes para o modelo Snowflake sem re-ingestão.

**Gerado por:** `analytics/catalog/audit_silver_reuse.py` (após Spec 1)  
**Artefato:** [`silver_reuse_matrix.csv`](../catalog/silver_reuse_matrix.csv)

---

## 1. Resumo

| Métrica | Valor |
|---------|-------|
| Entidades silver | **373** |
| Reuso direto (DIM/FACT/BRIDGE) | **210 (56,3%)** |
| Com dados em Afya/Allos → reuso | **209/209 (100%)** |
| REFINE (sem dados cliente no backup) | **163** |
| DEPRECATE (EXCLUDE) | **0** no catálogo silver |

A silver cobre **100% do bronze de negócio** (373/373). Os 163 `REFINE` são entidades modeladas cujo backup piloto não tinha rows em Afya+Allos — permanecem válidas para clientes futuros.

---

## 2. Matriz de ações

| Ação | Qtd | Significado |
|------|-----|-------------|
| `REUSE_AS_DIM` | 140 | Fonte direta de dimensão conformed |
| `REUSE_AS_FACT` | 60 | Fonte direta de fato (grain 1:1) |
| `REUSE_AS_BRIDGE` | 10 | Bridge tables dimensionais |
| `REFINE` | 163 | Manter silver; validar quando cliente tiver dados |
| `REPLACE` | 0 | Gold agrega (próxima fase) |
| `DEPRECATE` | 0 | — |

---

## 3. Gap 616 contrato vs silver

| Bucket | Tabelas | Notas |
|--------|---------|-------|
| Silver implementada | 373 | ODS 1:1 |
| EXCLUDE (audit/plataforma/import) | 168 | Fora star schema |
| DEFER (sem dados piloto) | 239 | Inclui 163 já na silver |
| **616 total** | — | Referência Afya |

**Prioridade carga bronze:** tabelas `DEFER` populadas em Magalu/Klabin/etc. do `mapping_sample` — rodar `mereo_tools drift` antes de expandir.

---

## 4. Qualidade do batch auto-gerado

| Item | Status |
|------|--------|
| PK `id` vs `Id` | Revisar tabelas camelCase (`Training`, `okr.*`) |
| Testes dbt | **10/373** models com testes |
| Duplicação `gold_*` no target k8s | `profiles.yml` schema `gold` — alinhar em PR futuro |
| Macro `silver_from_bronze` | Não adotada — colunas inlined |

---

## 5. Roadmap gold (sem refazer silver)

### Onda G1 — Dimensões

`pessoa`, `area`, `cargo`, `filial`, `meta`, `indicador`, `periodo_gestao`, `periodo_apuracao`, `competencia`, `avaliacao_ciclo`

### Onda G2 — Fatos

`valor_meta`, `nota_meta`, `participante_rv`, `calc_resultado_*`, `resposta`, `feedback_continuo`, `acao`

### Onda G3 — Cross-domain

Joins do grafo FK: colaborador↔metricas (23), avaliacao↔metricas (23), colaborador↔avaliacao (40)

---

## 6. Regenerar

```bash
uv run python analytics/catalog/explore_client_dimensions.py --clients afya,allos
uv run python analytics/catalog/audit_silver_reuse.py
```

---

## 7. Critérios de aceite

- [x] 373 entradas em `silver_reuse_matrix.csv`
- [x] 100% reuso entre silver com dados cliente
- [x] ≥10 candidatos gold com grain (ver Spec 1)
- [x] Input para ADR-016
