-- =============================================================================
-- Mereo ERP — modelagem Snowflake dimensional (spine hubs)
-- Feature: specs/001-snowflake-dbml-model
-- Matriz completa 616 tbl: erp_mapping_matrix.csv
--
-- Camadas: raw → staging → edw → mart
-- Metadados LocalDrawDB: @layer, @group, @note, @fk, @origen, @map
-- Regra: edw.* NUNCA @origen raw.* (sempre via staging)
--
-- Importar:
--   cp specs/001-snowflake-dbml-model/contracts/mereo_snowflake_dimensional.sql \
--      LocalDrawDB/data/input/
-- =============================================================================

-- =============================================================================
-- RAW — landing (amostra hubs; demais 616 em erp_mapping_matrix.csv)
-- =============================================================================

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: Hub universal dbo.COLABORADOR — multi-tenant CDC/bulk
CREATE TABLE IF NOT EXISTS raw.dbo__COLABORADOR (
  tenant_slug STRING,
  ID BIGINT,
  NOME STRING,
  EMAIL STRING,
  ID_GRUPO_USUARIO BIGINT,
  ATIVO INT,
  TIPO_COLABORADOR BIGINT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_organizacao
-- @note: Hierarquia organizacional dbo.AREA
-- @fk: ID_RESPONSAVEL_AREA -> raw.dbo__COLABORADOR.ID
-- @fk: ID_PARENT -> raw.dbo__AREA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__AREA (
  tenant_slug STRING,
  ID BIGINT,
  ID_PERIODO_GESTAO BIGINT,
  ID_RESPONSAVEL_AREA BIGINT,
  ID_PARENT BIGINT,
  COD_AREA STRING,
  DESC_AREA STRING,
  ATIVO INT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_organizacao
-- @note: Cargos dbo.CARGO
CREATE TABLE IF NOT EXISTS raw.dbo__CARGO (
  tenant_slug STRING,
  ID BIGINT,
  DESC_CARGO STRING,
  ATIVO INT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: Bridge N:N colaborador ↔ área
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_AREA -> raw.dbo__AREA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__COLABORADOR_AREA (
  tenant_slug STRING,
  ID BIGINT,
  ID_COLABORADOR BIGINT,
  ID_AREA BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: Metas de desempenho dbo.META
-- @fk: ID_AREA -> raw.dbo__AREA.ID
-- @fk: ID_INDICADOR -> raw.dbo__INDICADOR.ID
-- @fk: ID_RESPONSAVEL_META -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__META (
  tenant_slug STRING,
  ID BIGINT,
  ID_AREA BIGINT,
  ID_INDICADOR BIGINT,
  ID_RESPONSAVEL_META BIGINT,
  ID_PERIODO_GESTAO BIGINT,
  COD_META STRING,
  OBJETIVO STRING,
  PESO_META DECIMAL(18,4),
  DT_INI DATE,
  DT_FIM DATE,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: Definição KPI dbo.INDICADOR
CREATE TABLE IF NOT EXISTS raw.dbo__INDICADOR (
  tenant_slug STRING,
  ID BIGINT,
  COD_INDICADOR STRING,
  DESC_INDICADOR STRING,
  ATIVO INT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: Valores previsto/realizado por meta e data
-- @fk: ID_META -> raw.dbo__META.ID
CREATE TABLE IF NOT EXISTS raw.dbo__VALOR_META (
  tenant_slug STRING,
  ID BIGINT,
  ID_META BIGINT,
  DT_REF DATE,
  PONTUAL_PREVISTO DECIMAL(18,4),
  PONTUAL_REALIZADO DECIMAL(18,4),
  ACUM_PREVISTO DECIMAL(18,4),
  ACUM_REALIZADO DECIMAL(18,4),
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: Períodos de gestão e apuração RV
CREATE TABLE IF NOT EXISTS raw.dbo__PERIODO_GESTAO (
  tenant_slug STRING,
  ID BIGINT,
  DESC_PERIODO_GESTAO STRING,
  DT_INI DATE,
  DT_FIM DATE,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: Período apuração remuneração variável
CREATE TABLE IF NOT EXISTS raw.dbo__PERIODO_APURACAO (
  tenant_slug STRING,
  ID BIGINT,
  ID_PERIODO_GESTAO BIGINT,
  DESC_PERIODO_APURACAO STRING,
  DT_INI DATE,
  DT_FIM DATE,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: Ciclo de avaliação competences.AVALIACAO
CREATE TABLE IF NOT EXISTS raw.competences__AVALIACAO (
  tenant_slug STRING,
  ID BIGINT,
  DESC_AVALIACAO STRING,
  DT_INI_AVALIACAO DATE,
  DT_FIM_AVALIACAO DATE,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: Competências avaliadas
CREATE TABLE IF NOT EXISTS raw.competences__COMPETENCIA (
  tenant_slug STRING,
  ID BIGINT,
  TITULO_COMPETENCIA STRING,
  DESC_COMPETENCIA STRING,
  TIPO_COMPETENCIA STRING,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: Resultado avaliador × competência (fato origem)
-- @fk: ID_COLABORADOR_AVALIADO -> raw.dbo__COLABORADOR.ID
-- @fk: ID_AVALIADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_COMPETENCIA -> raw.competences__COMPETENCIA.ID
CREATE TABLE IF NOT EXISTS raw.competences__CALC_RESULTADO_AVALIADOR_COMPETENCIA (
  tenant_slug STRING,
  ID BIGINT,
  ID_AVALIACAO BIGINT,
  ID_AVALIADOR BIGINT,
  ID_COLABORADOR_AVALIADO BIGINT,
  ID_COMPETENCIA BIGINT,
  NOTA_FINAL DECIMAL(18,4),
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_remuneracao
-- @note: Participante remuneração variável
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_PERIODO_APURACAO -> raw.dbo__PERIODO_APURACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__PARTICIPANTE_RV (
  tenant_slug STRING,
  ID BIGINT,
  ID_COLABORADOR BIGINT,
  ID_PERIODO_APURACAO BIGINT,
  ELEGIVEL_RV INT,
  SALARIO DECIMAL(18,2),
  VALOR_RV_FINAL DECIMAL(18,2),
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: Feedback contínuo
-- @fk: ID_COLABORADOR_PROPRIETARIO -> raw.dbo__COLABORADOR.ID
-- @fk: ID_META -> raw.dbo__META.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FEEDBACK_CONTINUO (
  tenant_slug STRING,
  ID BIGINT,
  ID_COLABORADOR_PROPRIETARIO BIGINT,
  ID_META BIGINT,
  ID_COMPETENCIA BIGINT,
  TEXTO STRING,
  DATA_FEEDBACK TIMESTAMP,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_acao
-- @note: Plano de ação vinculado a meta
-- @fk: ID_META -> raw.dbo__META.ID
-- @fk: ID_RESPONSAVEL_ACAO -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ACAO (
  tenant_slug STRING,
  ID BIGINT,
  ID_META BIGINT,
  ID_RESPONSAVEL_ACAO BIGINT,
  COD_ACAO STRING,
  OQUE STRING,
  STATUS_ACAO STRING,
  DT_INI_PLANEJADA DATE,
  DT_FIM_PLANEJADA DATE,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_referencia
-- @note: Lookup unidade de medida
CREATE TABLE IF NOT EXISTS raw.dbo__UNIDADE_MEDIDA (
  tenant_slug STRING,
  ID BIGINT,
  DESC_UNIDADE_MEDIDA STRING,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — HangFire plataforma; sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.HangFire__Job (
  Id BIGINT,
  StateName STRING,
  PRIMARY KEY (Id)
) USING DELTA;

-- =============================================================================
-- STAGING — cleanse / rename (único hop permitido desde raw)
-- =============================================================================

-- @layer: staging
-- @group: staging
-- @note: Colaborador tipado; filtra _deleted=0
-- @origen: raw.dbo__COLABORADOR
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_colaborador (
  tenant_slug STRING,
  employee_id BIGINT,           -- @map <- raw.dbo__COLABORADOR.ID
  employee_name STRING,         -- @map <- raw.dbo__COLABORADOR.NOME
  email STRING,                 -- @map <- raw.dbo__COLABORADOR.EMAIL
  user_group_id BIGINT,         -- @map <- raw.dbo__COLABORADOR.ID_GRUPO_USUARIO
  is_active INT,                -- @map <- raw.dbo__COLABORADOR.ATIVO
  employee_type_id BIGINT,      -- @map <- raw.dbo__COLABORADOR.TIPO_COLABORADOR
  PRIMARY KEY (tenant_slug, employee_id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Área organizacional
-- @origen: raw.dbo__AREA
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_area (
  tenant_slug STRING,
  area_id BIGINT,               -- @map <- raw.dbo__AREA.ID
  management_period_id BIGINT,  -- @map <- raw.dbo__AREA.ID_PERIODO_GESTAO
  area_manager_id BIGINT,       -- @map <- raw.dbo__AREA.ID_RESPONSAVEL_AREA
  parent_area_id BIGINT,        -- @map <- raw.dbo__AREA.ID_PARENT
  area_code STRING,             -- @map <- raw.dbo__AREA.COD_AREA
  area_desc STRING,             -- @map <- raw.dbo__AREA.DESC_AREA
  is_active INT,                -- @map <- raw.dbo__AREA.ATIVO
  PRIMARY KEY (tenant_slug, area_id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cargo
-- @origen: raw.dbo__CARGO
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_cargo (
  tenant_slug STRING,
  job_id BIGINT,                -- @map <- raw.dbo__CARGO.ID
  job_desc STRING,              -- @map <- raw.dbo__CARGO.DESC_CARGO
  is_active INT,                -- @map <- raw.dbo__CARGO.ATIVO
  PRIMARY KEY (tenant_slug, job_id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Bridge colaborador-area normalizado
-- @origen: raw.dbo__COLABORADOR_AREA
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_colaborador_area (
  tenant_slug STRING,
  link_id BIGINT,               -- @map <- raw.dbo__COLABORADOR_AREA.ID
  employee_id BIGINT,           -- @map <- raw.dbo__COLABORADOR_AREA.ID_COLABORADOR
  area_id BIGINT,               -- @map <- raw.dbo__COLABORADOR_AREA.ID_AREA
  PRIMARY KEY (tenant_slug, link_id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Meta / goal
-- @origen: raw.dbo__META
CREATE TABLE IF NOT EXISTS staging.stg_metricas_meta (
  tenant_slug STRING,
  goal_id BIGINT,               -- @map <- raw.dbo__META.ID
  area_id BIGINT,               -- @map <- raw.dbo__META.ID_AREA
  kpi_id BIGINT,                -- @map <- raw.dbo__META.ID_INDICADOR
  goal_owner_id BIGINT,         -- @map <- raw.dbo__META.ID_RESPONSAVEL_META
  management_period_id BIGINT,  -- @map <- raw.dbo__META.ID_PERIODO_GESTAO
  goal_code STRING,             -- @map <- raw.dbo__META.COD_META
  objective STRING,             -- @map <- raw.dbo__META.OBJETIVO
  goal_weight DECIMAL(18,4),    -- @map <- raw.dbo__META.PESO_META
  dt_start DATE,                -- @map <- raw.dbo__META.DT_INI
  dt_end DATE,                  -- @map <- raw.dbo__META.DT_FIM
  PRIMARY KEY (tenant_slug, goal_id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: KPI / indicador
-- @origen: raw.dbo__INDICADOR
CREATE TABLE IF NOT EXISTS staging.stg_metricas_indicador (
  tenant_slug STRING,
  kpi_id BIGINT,                -- @map <- raw.dbo__INDICADOR.ID
  kpi_code STRING,              -- @map <- raw.dbo__INDICADOR.COD_INDICADOR
  kpi_desc STRING,              -- @map <- raw.dbo__INDICADOR.DESC_INDICADOR
  is_active INT,                -- @map <- raw.dbo__INDICADOR.ATIVO
  PRIMARY KEY (tenant_slug, kpi_id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Valores de meta
-- @origen: raw.dbo__VALOR_META
CREATE TABLE IF NOT EXISTS staging.stg_metricas_valor_meta (
  tenant_slug STRING,
  value_id BIGINT,              -- @map <- raw.dbo__VALOR_META.ID
  goal_id BIGINT,               -- @map <- raw.dbo__VALOR_META.ID_META
  dt_ref DATE,                  -- @map <- raw.dbo__VALOR_META.DT_REF
  punctual_planned DECIMAL(18,4),   -- @map <- raw.dbo__VALOR_META.PONTUAL_PREVISTO
  punctual_actual DECIMAL(18,4),    -- @map <- raw.dbo__VALOR_META.PONTUAL_REALIZADO
  cumulative_planned DECIMAL(18,4), -- @map <- raw.dbo__VALOR_META.ACUM_PREVISTO
  cumulative_actual DECIMAL(18,4),  -- @map <- raw.dbo__VALOR_META.ACUM_REALIZADO
  PRIMARY KEY (tenant_slug, value_id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Período gestão
-- @origen: raw.dbo__PERIODO_GESTAO
CREATE TABLE IF NOT EXISTS staging.stg_metricas_periodo_gestao (
  tenant_slug STRING,
  management_period_id BIGINT,
  period_desc STRING,
  dt_start DATE,
  dt_end DATE,
  PRIMARY KEY (tenant_slug, management_period_id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Período apuração RV
-- @origen: raw.dbo__PERIODO_APURACAO
CREATE TABLE IF NOT EXISTS staging.stg_metricas_periodo_apuracao (
  tenant_slug STRING,
  apuration_period_id BIGINT,
  management_period_id BIGINT,
  period_desc STRING,
  dt_start DATE,
  dt_end DATE,
  PRIMARY KEY (tenant_slug, apuration_period_id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Ciclo avaliação
-- @origen: raw.competences__AVALIACAO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_avaliacao (
  tenant_slug STRING,
  eval_cycle_id BIGINT,
  eval_desc STRING,
  dt_start DATE,
  dt_end DATE,
  PRIMARY KEY (tenant_slug, eval_cycle_id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Competência
-- @origen: raw.competences__COMPETENCIA
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_competencia (
  tenant_slug STRING,
  competency_id BIGINT,
  competency_title STRING,
  competency_desc STRING,
  competency_type STRING,
  PRIMARY KEY (tenant_slug, competency_id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Scores avaliação
-- @origen: raw.competences__CALC_RESULTADO_AVALIADOR_COMPETENCIA
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_calc_resultado (
  tenant_slug STRING,
  score_id BIGINT,
  eval_cycle_id BIGINT,
  evaluator_id BIGINT,
  evaluated_employee_id BIGINT,
  competency_id BIGINT,
  final_score DECIMAL(18,4),
  PRIMARY KEY (tenant_slug, score_id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Participante RV
-- @origen: raw.dbo__PARTICIPANTE_RV
CREATE TABLE IF NOT EXISTS staging.stg_remuneracao_participante_rv (
  tenant_slug STRING,
  participant_id BIGINT,
  employee_id BIGINT,
  apuration_period_id BIGINT,
  is_eligible INT,
  salary DECIMAL(18,2),
  final_rv_amount DECIMAL(18,2),
  PRIMARY KEY (tenant_slug, participant_id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Feedback contínuo
-- @origen: raw.dbo__FEEDBACK_CONTINUO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_feedback_continuo (
  tenant_slug STRING,
  feedback_id BIGINT,
  owner_employee_id BIGINT,
  goal_id BIGINT,
  competency_id BIGINT,
  feedback_text STRING,
  feedback_at TIMESTAMP,
  PRIMARY KEY (tenant_slug, feedback_id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Ação
-- @origen: raw.dbo__ACAO
CREATE TABLE IF NOT EXISTS staging.stg_acao_acao (
  tenant_slug STRING,
  action_id BIGINT,
  goal_id BIGINT,
  action_owner_id BIGINT,
  action_code STRING,
  action_desc STRING,
  action_status STRING,
  planned_start DATE,
  planned_end DATE,
  PRIMARY KEY (tenant_slug, action_id)
) USING DELTA;

-- =============================================================================
-- EDW — star schema normalizado (3NF dims)
-- =============================================================================

-- @layer: edw
-- @group: dimensional
-- @note: DIM colaborador SCD1 — grain (tenant_slug, employee_id)
-- @origen: staging.stg_colaborador_colaborador
CREATE TABLE IF NOT EXISTS edw.dim_employee (
  employee_key BIGINT,
  tenant_slug STRING,
  employee_id BIGINT,           -- @map <- staging.stg_colaborador_colaborador.employee_id
  employee_name STRING,           -- @map <- staging.stg_colaborador_colaborador.employee_name
  email STRING,                   -- @map <- staging.stg_colaborador_colaborador.email
  is_active INT,                  -- @map <- staging.stg_colaborador_colaborador.is_active
  PRIMARY KEY (employee_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM área organizacional
-- @origen: staging.stg_organizacao_area
-- @fk: area_manager_employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.dim_org_area (
  area_key BIGINT,
  tenant_slug STRING,
  area_id BIGINT,
  area_code STRING,
  area_desc STRING,
  parent_area_id BIGINT,
  area_manager_employee_key BIGINT,
  is_active INT,
  PRIMARY KEY (area_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM cargo
-- @origen: staging.stg_organizacao_cargo
CREATE TABLE IF NOT EXISTS edw.dim_org_job (
  job_key BIGINT,
  tenant_slug STRING,
  job_id BIGINT,
  job_desc STRING,
  is_active INT,
  PRIMARY KEY (job_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM meta / goal
-- @origen: staging.stg_metricas_meta
-- @fk: area_key -> edw.dim_org_area.area_key
-- @fk: kpi_key -> edw.dim_kpi.kpi_key
-- @fk: goal_owner_employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.dim_goal (
  goal_key BIGINT,
  tenant_slug STRING,
  goal_id BIGINT,
  goal_code STRING,
  objective STRING,
  goal_weight DECIMAL(18,4),
  area_key BIGINT,
  kpi_key BIGINT,
  goal_owner_employee_key BIGINT,
  management_period_id BIGINT,
  dt_start DATE,
  dt_end DATE,
  PRIMARY KEY (goal_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM KPI
-- @origen: staging.stg_metricas_indicador
CREATE TABLE IF NOT EXISTS edw.dim_kpi (
  kpi_key BIGINT,
  tenant_slug STRING,
  kpi_id BIGINT,
  kpi_code STRING,
  kpi_desc STRING,
  is_active INT,
  PRIMARY KEY (kpi_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM período gestão
-- @origen: staging.stg_metricas_periodo_gestao
CREATE TABLE IF NOT EXISTS edw.dim_time_gestao (
  time_gestao_key BIGINT,
  tenant_slug STRING,
  management_period_id BIGINT,
  period_desc STRING,
  dt_start DATE,
  dt_end DATE,
  PRIMARY KEY (time_gestao_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM período apuração RV
-- @origen: staging.stg_metricas_periodo_apuracao
CREATE TABLE IF NOT EXISTS edw.dim_time_apuracao (
  time_apuracao_key BIGINT,
  tenant_slug STRING,
  apuration_period_id BIGINT,
  period_desc STRING,
  dt_start DATE,
  dt_end DATE,
  PRIMARY KEY (time_apuracao_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM ciclo avaliação
-- @origen: staging.stg_avaliacao_avaliacao
CREATE TABLE IF NOT EXISTS edw.dim_eval_cycle (
  eval_cycle_key BIGINT,
  tenant_slug STRING,
  eval_cycle_id BIGINT,
  eval_desc STRING,
  dt_start DATE,
  dt_end DATE,
  PRIMARY KEY (eval_cycle_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM competência
-- @origen: staging.stg_avaliacao_competencia
CREATE TABLE IF NOT EXISTS edw.dim_competency (
  competency_key BIGINT,
  tenant_slug STRING,
  competency_id BIGINT,
  competency_title STRING,
  competency_desc STRING,
  competency_type STRING,
  PRIMARY KEY (competency_key)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Unidade de medida
-- @origen: raw.dbo__UNIDADE_MEDIDA
CREATE TABLE IF NOT EXISTS staging.stg_referencia_unidade_medida (
  tenant_slug STRING,
  uom_id BIGINT,
  uom_desc STRING,
  PRIMARY KEY (tenant_slug, uom_id)
) USING DELTA;

-- @layer: edw
-- @group: ref
-- @note: REF unidade de medida
-- @origen: staging.stg_referencia_unidade_medida
CREATE TABLE IF NOT EXISTS edw.ref_unit_of_measure (
  uom_key BIGINT,
  tenant_slug STRING,
  uom_id BIGINT,
  uom_desc STRING,
  PRIMARY KEY (uom_key)
) USING DELTA;

-- @layer: edw
-- @group: bridge
-- @note: Bridge colaborador ↔ área (grain link)
-- @origen: staging.stg_colaborador_colaborador_area
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: area_key -> edw.dim_org_area.area_key
CREATE TABLE IF NOT EXISTS edw.bridge_employee_area (
  bridge_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  area_key BIGINT,
  link_id BIGINT,
  PRIMARY KEY (bridge_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: Fato valor meta — grain (tenant_slug, goal_id, dt_ref)
-- @origen: staging.stg_metricas_valor_meta
-- @fk: goal_key -> edw.dim_goal.goal_key
CREATE TABLE IF NOT EXISTS edw.fact_goal_value (
  goal_value_key BIGINT,
  tenant_slug STRING,
  goal_key BIGINT,
  goal_id BIGINT,
  dt_ref DATE,
  punctual_planned DECIMAL(18,4),
  punctual_actual DECIMAL(18,4),
  cumulative_planned DECIMAL(18,4),
  cumulative_actual DECIMAL(18,4),
  PRIMARY KEY (goal_value_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: Fato score avaliação
-- @origen: staging.stg_avaliacao_calc_resultado
-- @fk: evaluated_employee_key -> edw.dim_employee.employee_key
-- @fk: evaluator_employee_key -> edw.dim_employee.employee_key
-- @fk: competency_key -> edw.dim_competency.competency_key
-- @fk: eval_cycle_key -> edw.dim_eval_cycle.eval_cycle_key
CREATE TABLE IF NOT EXISTS edw.fact_eval_score (
  eval_score_key BIGINT,
  tenant_slug STRING,
  score_id BIGINT,
  eval_cycle_key BIGINT,
  evaluated_employee_key BIGINT,
  evaluator_employee_key BIGINT,
  competency_key BIGINT,
  final_score DECIMAL(18,4),
  PRIMARY KEY (eval_score_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: Fato remuneração variável
-- @origen: staging.stg_remuneracao_participante_rv
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: time_apuracao_key -> edw.dim_time_apuracao.time_apuracao_key
CREATE TABLE IF NOT EXISTS edw.fact_rv (
  rv_key BIGINT,
  tenant_slug STRING,
  participant_id BIGINT,
  employee_key BIGINT,
  time_apuracao_key BIGINT,
  is_eligible INT,
  salary DECIMAL(18,2),
  final_rv_amount DECIMAL(18,2),
  PRIMARY KEY (rv_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: Fato feedback contínuo
-- @origen: staging.stg_avaliacao_feedback_continuo
-- @fk: owner_employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.fact_feedback (
  feedback_key BIGINT,
  tenant_slug STRING,
  feedback_id BIGINT,
  owner_employee_key BIGINT,
  goal_key BIGINT,
  competency_key BIGINT,
  feedback_text STRING,
  feedback_at TIMESTAMP,
  PRIMARY KEY (feedback_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: Fato plano de ação
-- @origen: staging.stg_acao_acao
-- @fk: goal_key -> edw.dim_goal.goal_key
-- @fk: action_owner_employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.fact_action (
  action_key BIGINT,
  tenant_slug STRING,
  action_id BIGINT,
  goal_key BIGINT,
  action_owner_employee_key BIGINT,
  action_code STRING,
  action_status STRING,
  planned_start DATE,
  planned_end DATE,
  PRIMARY KEY (action_key)
) USING DELTA;

-- =============================================================================
-- MART — consumo (somente EDW; tenants afya+allos em produção)
-- =============================================================================

-- @layer: mart
-- @group: reports
-- @note: Performance 360 — colaborador × meta × avaliação (cross-domain)
-- @origen: edw.dim_employee, edw.fact_goal_value, edw.fact_eval_score, edw.dim_goal
CREATE TABLE IF NOT EXISTS mart.report_performance_360 (
  employee_key BIGINT,
  tenant_slug STRING,
  employee_name STRING,         -- @map <- edw.dim_employee.employee_name
  goals_with_values INT,        -- @map <- edw.fact_goal_value.goal_key [note: 'COUNT DISTINCT goal_key']
  avg_goal_attainment DECIMAL(18,4), -- @map <- edw.fact_goal_value.punctual_actual [note: 'AVG vs planned']
  eval_scores_count INT,        -- @map <- edw.fact_eval_score.eval_score_key [note: 'COUNT']
  avg_eval_score DECIMAL(18,4), -- @map <- edw.fact_eval_score.final_score [note: 'AVG']
  PRIMARY KEY (employee_key, tenant_slug)
) USING DELTA;

-- @layer: mart
-- @group: reports
-- @note: Metas por área
-- @origen: edw.dim_org_area, edw.fact_goal_value, edw.dim_goal
CREATE TABLE IF NOT EXISTS mart.report_goal_by_area (
  area_key BIGINT,
  tenant_slug STRING,
  area_desc STRING,
  goal_count INT,
  sum_actual DECIMAL(18,4),
  sum_planned DECIMAL(18,4),
  PRIMARY KEY (area_key, tenant_slug)
) USING DELTA;

-- @layer: mart
-- @group: agregados
-- @note: Atingimento diário de metas
-- @origen: edw.fact_goal_value
CREATE TABLE IF NOT EXISTS mart.fct_goal_attainment_daily (
  tenant_slug STRING,
  dt_ref DATE,
  sum_actual DECIMAL(18,4),
  sum_planned DECIMAL(18,4),
  goal_count INT,
  PRIMARY KEY (tenant_slug, dt_ref)
) USING DELTA;
