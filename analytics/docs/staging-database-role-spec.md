# Spec 2 — Papel do MereoGR-Staging no DW

**Objetivo:** entender o que é Staging, se contém dados de clientes, e como posicioná-lo no modelo Snowflake.

**Gerado por:** `analytics/catalog/explore_staging_role.py`  
**Artefatos:** [`staging_vs_client_diff.csv`](../catalog/staging_vs_client_diff.csv), [`staging_exploration_summary.yaml`](../catalog/staging_exploration_summary.yaml)

---

## 1. Staging não é cliente

| Atributo | Staging | Afya / Allos |
|----------|---------|--------------|
| Papel | Ambiente interno Mereo (QA/homolog) | Clientes reais |
| Tabelas ERP | **595** (−21 vs contrato) | **616** |
| Volume bulk CH | ~6,85M rows | ~2,6M / ~2,3M |
| Emails `COLABORADOR` | `noreply@mereo.com`, `212@mereo.com` | `@afya.com.br`, `@allos.com.br` |

---

## 2. Staging contém dados de Afya/Allos?

**Resposta: subset parcial com IDs reutilizados, não cópia completa de produção.**

| Evidência | Valor |
|-----------|-------|
| `COLABORADOR` staging | 824 rows |
| `COLABORADOR` Afya | 12.408 rows |
| **IDs staging ∩ Afya** | **820 (99,5%)** |
| **IDs staging ∩ Allos** | **817 (99,2%)** |
| CH `id_overlap_stg_afya` | 820 |

Interpretação: Staging usa **o mesmo espaço de IDs** de um subset de colaboradores (provável seed/clone de homologação), mas com **PII anonimizada** (emails Mereo). Não é um quarto tenant de produção — é ambiente de teste com sobreposição de chaves.

**Não** tratar `tenant_slug=staging` como cliente para KPIs de negócio.

---

## 3. Diferenças estruturais (595 vs 616)

### 21 tabelas ausentes em Staging

Módulo **Goal/KPI/ManagementCycle** + views de fila:

- `dbo.Goal`, `GoalResponsible`, `GoalValue`, `KPI`, `KPIBreakdown`, `KPIGrouping`, `ManagementCycle`
- `dbo.Breakdown`, `BreakdownValue`, `BreakdownValueOption`, `BrfGoalSyncLog`
- `dbo.VW_AREA_QUEUE`, `VW_AUDIT_*`, `VW_COLABORADOR_*`, `VW_GOAL_*`, `VW_KPI`, `VW_MANAGEMENT_CYCLE`, `vw_goal`

**Impacto dimensional:** modelos G1/G2 que dependem de Goal/KPI **não podem ser validados só em Staging**.

### Schema `stg.*` (5 tabelas)

| Tabela | Papel provável |
|--------|----------------|
| `stg.VCExtract` | Extração variável/compensação |
| `stg.ConsolidatedScoreView` | View materializada scores |
| `stg.GoalReportView` | Relatório Goal |
| `stg.GoalView` | View Goal |
| `stg.vcExtractLastLastUpdate` | Controle incremental extract |

**Recomendação:** `EXCLUDE` ou `internal-only` — views de pipeline, não entidades de negócio.

---

## 4. Anomalias de volume

| Tabela | Staging | Afya | Allos | Nota |
|--------|---------|------|-------|------|
| **`dbo.ValorMatriz`** | **5.894.028** | 0 | 0 | Sandbox de matriz; ADR-015 guard |
| `dbo.AbpEntityPropertyChanges` | 252k | 50k cap | 50k cap | Plataforma |
| `dbo.ActivityHistory` | 32k | 5,6k | 21 | Mais ativo em staging |

**170 tabelas** têm dados **somente** em Staging (sem rows Afya/Allos no backup) — homologação parcial, não contrato cliente.

---

## 5. Opções para o modelo alvo

| Opção | Prós | Contras |
|-------|------|---------|
| **A — Excluir de marts** | KPIs limpos; sem ruído de QA | Não testa marts com staging |
| **B — Flag `is_internal`** | Testes E2E no Dagster | Risco de vazar em dashboards |
| **C — Bronze separado `raw_internal`** | Isolamento físico | Mais pipelines |

**Recomendação provisória (ADR-016):** **Opção A** para marts gold; staging permanece em bronze/silver para QA operacional. Reavaliar após workshop com time Mereo.

---

## 6. Relação com outros bancos do grupo

Do [`groups.toml`](../../mereo_tools/groups.toml): `HMLAfya`, `implantacao`, `comercialtrial` são bancos **distintos** de `MereoGR-Staging` — não confundir homologação Afya com staging interno.

---

## 7. Regenerar

```bash
uv run python analytics/catalog/explore_staging_role.py
```

---

## 8. Critérios de aceite

- [x] Resposta explícita sobre mistura de dados (subset IDs, emails distintos)
- [x] 3 opções documentadas para papel no DW
- [x] 21 tabelas ausentes + impacto dimensional
- [x] Mapa `stg.*` com recomendação
