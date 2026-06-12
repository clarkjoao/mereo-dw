-- =============================================================================
-- Mereo ERP — modelo Snowflake COMPLETO (gerado — NÃO EDITAR À MÃO)
-- Feature: specs/001-snowflake-dbml-model
--
-- Regenerar:  python3 analytics/catalog/generate_dbml_stubs.py
-- Validar:    python3 analytics/catalog/validate_dbml_full.py
--
-- Camadas geradas: raw,staging,edw,mart
-- Contagens: raw=616 staging=209 edw=448 mart=3 pipeline=1
-- Curadoria: blocos staging/edw/mart do spine mereo_snowflake_dimensional.sql
--            entram verbatim; raw curada vira override de @note/@fk
-- Regra:     edw.* NUNCA @origen raw.* (sempre via staging)
-- =============================================================================

-- =============================================================================
-- RAW — landing CDC/bulk (616 tabelas, colunas completas do ERP)
-- =============================================================================

-- @layer: raw
-- @group: bridge
-- @note: BRIDGE → edw.brg_colaborador_funcao
-- @fk: ID_AVALIACAO -> raw.competences__AVALIACAO.ID
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_FUNCAO -> raw.competences__FUNCAO.ID
CREATE TABLE IF NOT EXISTS raw.competences__COLABORADOR_FUNCAO (
  tenant_slug STRING,
  ID INT,
  ID_COLABORADOR INT,
  ID_FUNCAO INT,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  FUNCAO_ATUAL INT,
  ID_AVALIACAO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: bridge
-- @note: Bridge N:N colaborador ↔ área
-- @fk: ID_AREA -> raw.dbo__AREA.ID
-- @fk: ID_AREA -> raw.dbo__AREA.ID
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__COLABORADOR_AREA (
  tenant_slug STRING,
  ID INT,
  ID_COLABORADOR INT,
  ID_AREA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: bridge
-- @note: BRIDGE → edw.brg_faixa_farol_item
-- @fk: ID_FAIXA_FAROL -> raw.dbo__FAIXA_FAROL.ID
-- @fk: ID_FAROL -> raw.dbo__FAROL.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FAIXA_FAROL_ITEM (
  tenant_slug STRING,
  ID INT,
  ID_FAIXA_FAROL INT,
  ID_FAROL INT,
  OPERADOR_MIM INT,
  VALOR_MIN DOUBLE,
  OPERADOR_MAX INT,
  VALOR_MAX DOUBLE,
  HABILITADO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: bridge
-- @note: BRIDGE → edw.brg_formulario_feedback_aba_item
-- @fk: ID_FORMULARIO_FEEDBACK_ABA -> raw.dbo__FORMULARIO_FEEDBACK_ABA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FORMULARIO_FEEDBACK_ABA_ITEM (
  tenant_slug STRING,
  ID INT,
  ID_FORMULARIO_FEEDBACK_ABA INT,
  TIPO_CONTEUDO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: bridge
-- @note: BRIDGE → edw.brg_forum_participante_sucessao
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_FORUM_SUCESSAO -> raw.dbo__FORUM_CALIBRAGEM_SUCESSAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FORUM_PARTICIPANTE_SUCESSAO (
  tenant_slug STRING,
  ID INT,
  ID_FORUM_SUCESSAO INT,
  ID_COLABORADOR INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: bridge
-- @note: BRIDGE → edw.brg_historico_area
CREATE TABLE IF NOT EXISTS raw.dbo__HISTORICO_COLABORADOR_AREA (
  tenant_slug STRING,
  ID INT,
  ID_COLABORADOR INT,
  ID_AREA INT,
  DT_UPD TIMESTAMP,
  SCORE DECIMAL(28,8),
  DT_FIM TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: bridge
-- @note: BRIDGE → edw.brg_instancia_participante_sucessao
-- @fk: ID_AVALIADO_SUCESSAO -> raw.dbo__AVALIADO_SUCESSAO.ID
-- @fk: ID_COLABORADOR_RESPOSAVEL_ALTERACAO -> raw.dbo__COLABORADOR.ID
-- @fk: ID_INSTANCIA_SUCESSAO -> raw.dbo__INSTANCIA_SUCESSAO.ID
-- @fk: ID_PARENT -> raw.dbo__INSTANCIA_PARTICIPANTE_SUCESSAO.ID
-- @fk: ID_QUADRANTE_SUCESSAO_DE -> raw.dbo__FORUM_QUADRANTE_SUCESSAO_MODELO.ID
-- @fk: ID_QUADRANTE_SUCESSAO_PARA -> raw.dbo__FORUM_QUADRANTE_SUCESSAO_MODELO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__INSTANCIA_PARTICIPANTE_SUCESSAO (
  tenant_slug STRING,
  ID INT,
  ID_INSTANCIA_SUCESSAO INT,
  ID_AVALIADO_SUCESSAO INT,
  ID_QUADRANTE_SUCESSAO_DE INT,
  ID_QUADRANTE_SUCESSAO_PARA INT,
  JUSTIFICATIVA_DESEMPENHO STRING,
  JUSTIFICATIVA_POTENCIAL STRING,
  DESEMPENHO_PARTICIPANTE_CALIBRADO INT,
  POTENCIAL_PARTICIPANTE_CALIBRADO INT,
  DT_ALTERACAO TIMESTAMP,
  ID_COLABORADOR_RESPOSAVEL_ALTERACAO INT,
  ATIVO INT,
  ID_PARENT INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: bridge
-- @note: Participante remuneração variável
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_PERIODO_APURACAO -> raw.dbo__PERIODO_APURACAO.ID
-- @fk: ID_PERIODO_APURACAO -> raw.dbo__PERIODO_APURACAO.ID
-- @fk: JobPositionId -> raw.dbo__CARGO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__PARTICIPANTE_RV (
  tenant_slug STRING,
  ID INT,
  ID_PERIODO_APURACAO INT,
  ID_COLABORADOR INT,
  ELEGIVEL_RV INT,
  DT_ADMISSAO DATE,
  DT_DEMISSAO DATE,
  SALARIO DOUBLE,
  MULTIPLO_RV_FINAL DOUBLE,
  VALOR_RV_FINAL DOUBLE,
  DISCRICIONARIO DOUBLE,
  AVALIACAO_COMPETENCIA DOUBLE,
  AVALIACAO_COMPETENCIA_COMENTARIO STRING,
  DISCRICIONARIO_COMENTARIO STRING,
  EligibilityComment STRING,
  JobPositionId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: bridge
-- @note: BRIDGE → edw.brg_perfil_area
-- @fk: ID_AREA -> raw.dbo__AREA.ID
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__PERFIL_AREA (
  tenant_slug STRING,
  ID INT,
  ID_COLABORADOR INT,
  ID_AREA INT,
  VISUALIZAR INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: bridge
-- @note: BRIDGE → edw.brg_psw_colaborador_item
-- @fk: ID_COLABORADOR -> raw.dbo__PSW_COLABORADOR.ID_COLABORADOR
CREATE TABLE IF NOT EXISTS raw.dbo__PSW_COLABORADOR_ITEM (
  tenant_slug STRING,
  ID_COLABORADOR INT,
  CREATE_DATE TIMESTAMP,
  PSW STRING,
  PRIVATE_CURRENT_PSW BINARY,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_acao_sugerida_pdi
-- @fk: ID_CATEGORIA -> raw.competences__CATEGORIA_PDI_ACAO.ID
-- @fk: ID_COMPETENCIA -> raw.competences__COMPETENCIA.ID
CREATE TABLE IF NOT EXISTS raw.competences__ACAO_SUGERIDA_PDI (
  tenant_slug STRING,
  ID INT,
  DESC_ACAO_SUGERIDA STRING,
  ID_CATEGORIA INT,
  ATIVO INT,
  ID_COMPETENCIA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: Ciclo de avaliação competences.AVALIACAO
-- @fk: ID_PERIODO_GESTAO -> raw.dbo__PERIODO_GESTAO.ID
CREATE TABLE IF NOT EXISTS raw.competences__AVALIACAO (
  tenant_slug STRING,
  ID INT,
  DESC_AVALIACAO STRING,
  DT_INI_AVALIACAO TIMESTAMP,
  DT_FIM_AVALIACAO TIMESTAMP,
  MENSAGEM_FORMULARIO STRING,
  OCULTAR_COMENTARIO_FORMULARIO INT,
  COMENTARIO_NOTA_ABAIXO INT,
  VISUALIZAR_RESULTADO_PARCIAL INT,
  DT_CRIACAO_AVALIACAO TIMESTAMP,
  DT_SINCRONIZACAO_COLABORADOR TIMESTAMP,
  DT_FECHAMENTO_SINCRONIZACAO TIMESTAMP,
  DT_PROCESSAMENTO_CALCULO TIMESTAMP,
  DT_FECHAMENTO_AVALIACAO TIMESTAMP,
  COMENTARIO_NOTA_ACIMA INT,
  HABILITAR_NOTA_CONSENSO INT,
  HABILITAR_NOTA_CONSENSO_NUMERICA INT,
  PDI_AUTO_AVALIACAO INT,
  PDI_CRIADO_PELO_LIDER INT,
  CONSIDERACOES_FINAIS_OBRIGATORIO INT,
  PRECISAO_DECIMAL INT,
  FEEDBACK_MANUAL INT,
  HABILITAR_CONSENSO_SEM_AUTO INT,
  PERGUNTA_LIVRE_OBRIGATORIO INT,
  HABILITAR_CAMPO_COMENTARIO_LIDER INT,
  EXIBIR_NOTA_ORDEM_DECRESCENTE INT,
  EDITAR_RESPOSTA_LIVRE_FEEDBACK INT,
  EXIBIR_NOTA_FINAL_CALCULADA INT,
  OCULTAR_VISAO_AVALIADO INT,
  ID_TIPO_AVALIACAO INT,
  CONSOLIDADO_PERGUNTA_LIVRE_OBRIGATORIO INT,
  DESTACA_FAIXA_CLASSIFICACAO INT,
  REGRA_DE_CALCULO_1 INT,
  REGRA_DE_CALCULO_2 INT,
  ID_PERIODO_GESTAO INT,
  MES INT,
  OCULTAR_FUNCAO INT,
  OCULTAR_NOTA_CALCULADA INT,
  AREA_FORMULARIO_AVALIACAO INT,
  MATRICULA_FORMULARIO_AVALIACAO INT,
  LIDER_FORMULARIO_AVALIACAO INT,
  FUNCAO_FORMULARIO_AVALIACAO INT,
  FOTO_FORMULARIO_AVALIACAO INT,
  PROGRESSO_FORMULARIO_AVALIACAO INT,
  MOSTRAR_ULTIMA_NOTA INT,
  AVALIADO_SUGERE_PDI_POS_FEEDBACK INT,
  HABILITAR_WORKFLOW INT,
  SCORE_PERFORMANCE_VIA_CARGA INT,
  HABILITAR_CONSIDERACOES_FINAIS_FEEDBACK INT,
  OCULTAR_NOTA_PONDERADA INT,
  HABILITAR_NOTAFINAL_FEEDBACK INT,
  CALIBRAGEM_ATRAVES_NOTA INT,
  RESULTADO_FEEDBACK_MANUAL INT,
  QUALIDADE_FEEDBACK_OBRIGATORIA INT,
  HABILITAR_INTERESSE_DE_MUDANCA_DE_AREA INT,
  LOCALIZACAO_PERGUNTA_INTERESSE_MUDANCA_DE_AREA INT,
  DESABILITAR_PERGUNTAS_LIVRES_RESULTADO_FEEDBACK INT,
  DESABILITAR_COMENTARIO_FATOR_AVALIACAO INT,
  DESABILITAR_COMENTARIO_COMPETENCIA INT,
  PERMITIR_CRIAR_PDI_FEEDBACK INT,
  PERMITIR_AVALIADO_AVALIAR_QUALIDADE_FEEDBACK INT,
  TIPO_FLUXO INT,
  STATUS INT,
  CICLO_VIGENTE INT,
  CADASTRO_POSSUI_PENDENCIAS INT,
  OCULTAR_CLASSIFICACAO_COMPETENCIA INT,
  PDI_NO_FEEDBACK_NOTA_ABAIXO INT,
  PDI_NO_FEEDBACK_NOTA_ACIMA INT,
  HABILITAR_CALIBRAGEM_COMPETENCIA INT,
  OCULTAR_FAIXA_DE_CLASSIFICACAO INT,
  OCULTAR_NOTA_NUMERICA INT,
  OCULTAR_NOTA_COMPETENCIA_PDF INT,
  EXIBIR_COMENTARIO_AVALIACOES_PDF_FEEDBACK INT,
  EXIBIR_COMENTARIO_FATOR_AVALIACAO_RESULTADO INT,
  TIPO_AVALIADOR_FORMULARIO_AVALIACAO INT,
  TIPO_SELETOR_NOTA INT,
  TIPO_VISUALIZACAO_FORMULARIO_AVALIACAO INT,
  HABILITAR_INTERESSE_MUDANCA_LOCALIDADE INT,
  NUMERO_MAX_AREAS_MUDANCA INT,
  NUMERO_MAX_LOCALIDADE_MUDANCA INT,
  HABILITAR_ESPECIFICACAO_MUDANCA_LOCALIDADE INT,
  HABILITAR_PERGUNTA_ESCOLHA_SUCESSOR INT,
  EXIGIR_QUALIDADE_FEEDBACK_ANTES_RESULTADO INT,
  HABILITAR_COMENTARIO_COMPETENCIA_FATOR INT,
  FOTO_FORMULARIO_FEEDBACK INT,
  AREA_FORMULARIO_FEEDBACK INT,
  LIDER_FORMULARIO_FEEDBACK INT,
  PROGRESS_FORMULARIO_FEEDBACK INT,
  EXIBIR_RADAR_CHART_FEEDBACK INT,
  EXIBIR_NOTA_FINAL_FEEDBACK INT,
  EXIBIR_NOTA_CONDENSADA_FEEDBACK INT,
  DESTACA_FAIXA_CLASSIFICACAO_TIPO_AVALIADOR INT,
  EXIBIR_CLASSIFICACAO_TIPO_AVALIADOR INT,
  EXIBIR_NOTA_CALCULADA_TIPO_AVALIADOR INT,
  TIPO_SELETOR_NOTA_FEEDBACK INT,
  TIPO_VISUALIZACAO_FORMULARIO_FEEDBACK INT,
  OCULTAR_NOTA_NUMERICA_FEEDBACK INT,
  EXIBIR_PAINEL_PERFORMANCE_FEEDBACK INT,
  ANALISE_DESEMP_CONTINUO INT,
  HABILITAR_INDICACAO INT,
  HABILITAR_INDICACAO_ATOR_AVALIADO INT,
  HABILITAR_INDICACAO_ATOR_MANAGER INT,
  HABILITAR_INDICACAO_REVISAO INT,
  HABILITAR_INDICACAO_REVISAO_AVALIADO INT,
  HABILITAR_INDICACAO_REVISAO_GESTOR INT,
  HABILITAR_INDICACAO_REVISAO_ADMINISTRADOR INT,
  HABILITAR_INDICACAO_EDICAO INT,
  DESABILITAR_FEEDBACK INT,
  EXIBIR_NOTA_COMENTARIO_AVALIACAO_LIDER INT,
  EXIBIR_PAINEL_PERFORMANCE_EVALUATION INT,
  EXIBIR_COMENTARIO_FORUM_FEEDBACK INT,
  EXIBIR_NOTA_COMPETENCIA_TIPO_AVALIADOR INT,
  OCULTAR_AVALIADOR_MINHAS_AVALIACOES INT,
  EIXO_X_MATRIZ STRING,
  EIXO_Y_MATRIZ STRING,
  MinimumToShowCommentsResult INT,
  COMENTARIO_FEEDBACK_OBRIGATORIO_NOTA_CONSENSO INT,
  COMENTARIO_AVALIACAO_OBRIGATORIO INT,
  EXIBIR_TOOLTIP_RADAR_OUTSIDE INT,
  QUANTIDADE_MAXIMA_INDICACAO_AVALIADOR INT,
  MINIMO_INDICACAO_TIPO3 INT,
  MAXIMO_INDICACAO_TIPO3 INT,
  MINIMO_INDICACAO_TIPO4 INT,
  MAXIMO_INDICACAO_TIPO4 INT,
  MINIMO_INDICACAO_TIPO5 INT,
  MAXIMO_INDICACAO_TIPO5 INT,
  MINIMO_INDICACAO_TIPO6 INT,
  MAXIMO_INDICACAO_TIPO6 INT,
  MINIMO_INDICACAO_TIPO7 INT,
  MAXIMO_INDICACAO_TIPO7 INT,
  MINIMO_INDICACAO_TIPOPROJETO INT,
  MAXIMO_INDICACAO_TIPOPROJETO INT,
  EXIBIR_RADAR_CHART_RESULTADO INT,
  DT_LIMITE_SINCRONIZACAO_COLABORADOR_AVALIADO TIMESTAMP,
  HABILITAR_CALIBRAGEM_NOTA_FINAL INT,
  LIMITE_CALIBRAGEM_NOTA_FINAL INT,
  HABILITA_CARDAPIO_ACOES_PDI INT,
  HABILITAR_EXIBICAO_QUADRANTE_NO_FEEDBACK_RESULTADO INT,
  HideScoreAndConsensusResult INT,
  AVALIADO_VISUALIZA_PDI_POS_FEEDBACK INT,
  HABILITAR_QUALIDADE_FEEDBACK INT,
  HideRatingNotesByGroup INT,
  MinimumNumberEvaluators INT,
  PreviewMatrixPositioning INT,
  XAxisComposition INT,
  YAxisComposition INT,
  CompetenceScoreDescriptionType INT,
  EnableCommentsEvaluationFactorsFeedbackForm INT,
  EvaluationCommentsAnonymousRulesEvaluatorsFeedbackForm INT,
  MinimumToShowCommentsFeedbackForm INT,
  EnableCommentsEvaluationFactorFeedbackFormOpenQuestion INT,
  EvaluationCommentsAnonymousRulesEvaluatorsFeedbackFormOpenQuestion INT,
  MinimumToShowCommentsFeedbackFormOpenQuestion INT,
  EnableCommentsEvaluationFactorsResult INT,
  EvaluationCommentsAnonymousRulesLeadersResult INT,
  EvaluationCommentsAnonymousRulesEvaluatorsResult INT,
  EnableCommentsEvaluationFactorsResultOpenQuestion INT,
  EvaluationCommentsAnonymousRulesLeadersResultOpenQuestion INT,
  EvaluationCommentsAnonymousRulesEvaluatorsResultOpenQuestion INT,
  MinimumToShowCommentsResultOpenQuestion INT,
  XAxisMultiplicationFactorToRanking DECIMAL(28,8),
  YAxisMultiplicationFactorToRanking DECIMAL(28,8),
  EnableMultiplicationRankingFactor INT,
  HABILITAR_CALIBRAGEM_PERGUNTAS_LIVRES INT,
  EnableCompetenceTypeComment INT,
  CompetenceTypeCommentRequired INT,
  HideCompetencesTypeResult INT,
  EnableCompetenceTypeCommentsFeedbackForm INT,
  EvaluationCompetenceTypeCommentsAnonymousRulesEvaluatorsFeedbackForm INT,
  MinimumToShowCompetenceTypeComments INT,
  EnableCompetenceTypeCommentsResult INT,
  EvaluationCompetenceTypeCommentsAnonymousRulesEvaluatorsResult INT,
  EvaluationCompetenceTypeCommentsAnonymousRulesLeadersResult INT,
  MinimumToShowCompetenceTypeCommentsResult INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_avaliado
-- @fk: ID_AVALIACAO -> raw.competences__AVALIACAO.ID
-- @fk: ID_COLABORADOR_AVALIADO -> raw.dbo__COLABORADOR.ID
-- @fk: ID_COLABORADOR_FUNCAO -> raw.competences__COLABORADOR_FUNCAO.ID
-- @fk: ID_COLABORADOR_SUCESSOR -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.competences__AVALIADO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_COLABORADOR_AVALIADO INT,
  ID_COLABORADOR_FUNCAO INT,
  EMAIL_BOAS_VINDAS_RECEBIDO INT,
  AREA_DE_INTERESSE_DE_MUDANCA INT,
  Status INT,
  MIGRADO_NOVO_GT INT,
  ID_COLABORADOR_SUCESSOR INT,
  TEMPO_NECESSARIO_SUCESSOR INT,
  TIPO_TEMPO_SUCESSOR INT,
  DATA_INDICACAO TIMESTAMP,
  DATA_APROVACAO_INDICACAO TIMESTAMP,
  BLOQUEADO_PARA_LIBERACAO INT,
  BLOQUEADO_PARA_LIBERACAO_INDICACAO INT,
  BLOQUEADO_PARA_LIBERACAO_APROVACAO_INDICACAO INT,
  IndicationComment STRING,
  LeaderIndicationComment STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_categoria_pdi_acao
CREATE TABLE IF NOT EXISTS raw.competences__CATEGORIA_PDI_ACAO (
  tenant_slug STRING,
  ID INT,
  DESC_CATEGORIA STRING,
  ATIVO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: Competências avaliadas
-- @fk: ID_AVALIACAO -> raw.competences__AVALIACAO.ID
-- @fk: ID_BIBLIOTECA -> raw.dbo__BIBLIOTECA.ID
-- @fk: ID_PARENT -> raw.competences__COMPETENCIA.ID
CREATE TABLE IF NOT EXISTS raw.competences__COMPETENCIA (
  tenant_slug STRING,
  ID INT,
  ID_BIBLIOTECA INT,
  TITULO_COMPETENCIA STRING,
  DESC_COMPETENCIA STRING,
  TIPO_COMPETENCIA INT,
  TIPO_TECNICA INT,
  TIPO_COMPORTAMENTAL INT,
  HABILITAR_FATOR_AVALIACAO INT,
  ORDENACAO INT,
  ID_AVALIACAO INT,
  ID_PARENT INT,
  CODIGO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_curva_pontuacao_avaliacao
CREATE TABLE IF NOT EXISTS raw.competences__CURVA_PONTUACAO_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  CRITERIO_PONTUACAO STRING,
  SIGNIFICADO_PONTUACAO STRING,
  NOTA_REFERENCIA INT,
  NOTA_PONTUACAO INT,
  PERC_ALCANCE DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_competence_type_comment
-- @fk: EvaluationFormId -> raw.competences__FORMULARIO_AVALIACAO.ID
CREATE TABLE IF NOT EXISTS raw.competences__CompetenceTypeComment (
  tenant_slug STRING,
  Id INT,
  EvaluationFormId INT,
  CompetenceType INT,
  Comment STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_faixa_classificacao_avaliacao
-- @fk: ID_AVALIACAO -> raw.competences__AVALIACAO.ID
CREATE TABLE IF NOT EXISTS raw.competences__FAIXA_CLASSIFICACAO_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  DESCRICAO STRING,
  NOTA_DE DECIMAL(28,8),
  NOTA_ATE DECIMAL(28,8),
  PORCENTAGEM_CURVA_ESPERADA DECIMAL(28,8),
  NOTA_DE_NUMERIC DECIMAL(28,8),
  NOTA_ATE_NUMERIC DECIMAL(28,8),
  MESCLAR_COM_FAIXA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_faixa_classificacao_performance_avaliacao
-- @fk: ID_AVALIACAO -> raw.competences__AVALIACAO.ID
CREATE TABLE IF NOT EXISTS raw.competences__FAIXA_CLASSIFICACAO_PERFORMANCE_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  DESCRICAO STRING,
  NOTA_DE DECIMAL(28,8),
  NOTA_ATE DECIMAL(28,8),
  PORCENTAGEM_CURVA_ESPERADA DECIMAL(28,8),
  MESCLAR_COM_FAIXA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_fator_avaliacao
-- @fk: ID_COMPETENCIA -> raw.competences__COMPETENCIA.ID
CREATE TABLE IF NOT EXISTS raw.competences__FATOR_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  ID_COMPETENCIA INT,
  DETALHE_FATOR_AVALIACAO STRING,
  DESC_FATOR_AVALIACAO STRING,
  CODIGO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_funcao
-- @fk: ID_AVALIACAO -> raw.competences__AVALIACAO.ID
-- @fk: ID_PARENT -> raw.competences__FUNCAO.ID
-- @fk: ID_PARENT_AJUSTE -> raw.competences__FUNCAO.ID
CREATE TABLE IF NOT EXISTS raw.competences__FUNCAO (
  tenant_slug STRING,
  ID INT,
  COD_FUNCAO STRING,
  DESC_FUNCAO STRING,
  ID_PARENT INT,
  ID_PARENT_AJUSTE INT,
  ID_AVALIACAO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_metodo_calculo
-- @fk: ID_AVALIACAO -> raw.competences__AVALIACAO.ID
-- @fk: ID_PARENT -> raw.competences__METODO_CALCULO.ID
CREATE TABLE IF NOT EXISTS raw.competences__METODO_CALCULO (
  tenant_slug STRING,
  ID INT,
  NOME STRING,
  AUTO DECIMAL(28,8),
  LIDER DECIMAL(28,8),
  PAR DECIMAL(28,8),
  TIME DECIMAL(28,8),
  COMITE DECIMAL(28,8),
  CLIENTE DECIMAL(28,8),
  FORNECEDOR DECIMAL(28,8),
  ATIVO INT,
  ID_AVALIACAO INT,
  ID_PARENT INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_peso_tipo_avaliador
-- @fk: ID_AVALIACAO -> raw.competences__AVALIACAO.ID
-- @fk: ID_FUNCAO -> raw.competences__FUNCAO.ID
-- @fk: ID_METODO_CALCULO -> raw.competences__METODO_CALCULO.ID
CREATE TABLE IF NOT EXISTS raw.competences__PESO_TIPO_AVALIADOR (
  tenant_slug STRING,
  ID INT,
  ID_FUNCAO INT,
  ID_METODO_CALCULO INT,
  ID_AVALIACAO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_tipo_avaliacao
CREATE TABLE IF NOT EXISTS raw.competences__TIPO_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  DESCRICAO STRING,
  ATIVO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_tipo_avaliador
CREATE TABLE IF NOT EXISTS raw.competences__TIPO_AVALIADOR (
  tenant_slug STRING,
  ID INT,
  PT_BR STRING,
  EN_US STRING,
  ES_ES STRING,
  TIPO STRING,
  DESCRICAO STRING,
  RadarChartColor STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_topico_pergunta_livre
CREATE TABLE IF NOT EXISTS raw.competences__TOPICO_PERGUNTA_LIVRE (
  tenant_slug STRING,
  ID INT,
  DESCRICAO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_settings
CREATE TABLE IF NOT EXISTS raw.competences__settings (
  tenant_slug STRING,
  id INT,
  name STRING,
  value STRING,
  type STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_administrador_local
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_MODULO -> raw.dbo__Modules.Id
CREATE TABLE IF NOT EXISTS raw.dbo__ADMINISTRADOR_LOCAL (
  tenant_slug STRING,
  ID INT,
  ID_COLABORADOR INT,
  ID_MODULO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_administrador_local_filial
-- @fk: ID_ADMINISTRADOR_LOCAL -> raw.dbo__ADMINISTRADOR_LOCAL.ID
-- @fk: ID_FILIAL -> raw.dbo__FILIAL.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ADMINISTRADOR_LOCAL_FILIAL (
  tenant_slug STRING,
  ID INT,
  ID_ADMINISTRADOR_LOCAL INT,
  ID_FILIAL INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: Hierarquia organizacional dbo.AREA
-- @fk: ID_FILIAL -> raw.dbo__FILIAL.ID
-- @fk: ID_PARENT -> raw.dbo__AREA.ID
-- @fk: ID_PARENT -> raw.dbo__AREA.ID
-- @fk: ID_PERIODO_GESTAO -> raw.dbo__PERIODO_GESTAO.ID
-- @fk: ID_RESPONSAVEL_AREA -> raw.dbo__COLABORADOR.ID
-- @fk: ID_RESPONSAVEL_AREA -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__AREA (
  tenant_slug STRING,
  ID INT,
  ID_PERIODO_GESTAO INT,
  ID_FILIAL INT,
  ID_RESPONSAVEL_AREA INT,
  ID_PARENT INT,
  ID_SOURCE INT,
  LEVEL_TREE STRING,
  COD_AREA STRING,
  DESC_AREA STRING,
  ATIVO INT,
  SCORE_AREA DOUBLE,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_area_forum_sucessao
-- @fk: ID_AREA -> raw.dbo__AREA.ID
-- @fk: ID_FORUM -> raw.dbo__FORUM_CALIBRAGEM_SUCESSAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__AREA_FORUM_SUCESSAO (
  tenant_slug STRING,
  ID INT,
  ID_AREA INT,
  ID_FORUM INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_avaliador_forum_sucessao
-- @fk: ID_COLABORADOR_AVALIADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_FORUM -> raw.dbo__FORUM_CALIBRAGEM_SUCESSAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__AVALIADOR_FORUM_SUCESSAO (
  tenant_slug STRING,
  ID INT,
  ID_COLABORADOR_AVALIADOR INT,
  ID_FORUM INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_avaliado_sucessao
-- @fk: ID_CICLO_SUCESSAO -> raw.dbo__SuccessionCycle.ID
-- @fk: ID_COLABORADOR_AVALIADO -> raw.dbo__COLABORADOR.ID
-- @fk: ID_COLABORADOR_AVALIADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_FUNCAO -> raw.dbo__FUNCAO_SUCESSAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__AVALIADO_SUCESSAO (
  tenant_slug STRING,
  ID INT,
  ID_CICLO_SUCESSAO INT,
  ID_COLABORADOR_AVALIADO INT,
  ID_FUNCAO INT,
  STATUS INT,
  ID_COLABORADOR_AVALIADOR INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_accept_agreement_signature_attachment
-- @fk: Id -> raw.dbo__TERMO_ACEITE_ASSINATURA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__AcceptAgreementSignatureAttachment (
  tenant_slug STRING,
  Id INT,
  FileName STRING,
  Key STRING,
  UploadDate TIMESTAMP,
  ContentType STRING,
  ContentLength INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_action_base_label
-- @fk: ActionBase_Id -> raw.dbo__ActionBase.Id
-- @fk: Label_Id -> raw.core__Label.Id
CREATE TABLE IF NOT EXISTS raw.dbo__ActionBaseLabel (
  tenant_slug STRING,
  ActionBase_Id INT,
  Label_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ActionBase_Id, Label_Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_area_history_config
-- @fk: ManagementCycle_Id -> raw.dbo__PERIODO_GESTAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__AreaHistoryConfig (
  tenant_slug STRING,
  Id INT,
  LastSyncDate TIMESTAMP,
  ManagementCycle_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_biblioteca
CREATE TABLE IF NOT EXISTS raw.dbo__BIBLIOTECA (
  tenant_slug STRING,
  ID INT,
  DESC_BIBLIOTECA STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: Cargos dbo.CARGO
-- @fk: ID_GRUPO_CARGO -> raw.dbo__GRUPO_CARGO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__CARGO (
  tenant_slug STRING,
  ID INT,
  COD_CARGO STRING,
  DESC_CARGO STRING,
  ID_GRUPO_CARGO INT,
  IsCriticalJob INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_catch_ball
-- @fk: ID_DATA_PROVIDER_PROPOSTO -> raw.dbo__COLABORADOR.ID
-- @fk: ID_DIRETRIZ_PROPOSTO -> raw.dbo__DIRETRIZ.ID
-- @fk: ID_INDICADOR_PROPOSTO -> raw.dbo__INDICADOR.ID
-- @fk: ID_META -> raw.dbo__META.ID
-- @fk: ID_META_SUPERIOR_PROPOSTO -> raw.dbo__META.ID
-- @fk: ID_PROCESSO_PROPOSTO -> raw.dbo__PROCESSO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__CATCH_BALL (
  tenant_slug STRING,
  ID INT,
  ID_META INT,
  ID_INDICADOR_PROPOSTO INT,
  ID_DIRETRIZ_PROPOSTO INT,
  ID_PROCESSO_PROPOSTO INT,
  ID_META_SUPERIOR_PROPOSTO INT,
  ID_DATA_PROVIDER_PROPOSTO INT,
  DT_WORKFLOW TIMESTAMP,
  OBJETIVO_PROPOSTO STRING,
  PESO_META_PROPOSTO DOUBLE,
  VALOR_META_PROPOSTO DOUBLE,
  DT_INI_PROPOSTO TIMESTAMP,
  DT_FIM_PROPOSTO TIMESTAMP,
  TIPO_ACUMULACAO_PROPOSTO INT,
  INDICADOR_JUSTIFICATIVA STRING,
  DIRETRIZ_JUSTIFICATIVA STRING,
  PROCESSO_JUSTIFICATIVA STRING,
  META_SUPERIOR_JUSTIFICATIVA STRING,
  DATA_PROVIDER_JUSTIFICATIVA STRING,
  OBJETIVO_JUSTIFICATIVA STRING,
  PESO_META_JUSTIFICATIVA STRING,
  VALOR_META_JUSTIFICATIVA STRING,
  DT_INI_JUSTIFICATIVA STRING,
  DT_FIM_JUSTIFICATIVA STRING,
  TIPO_ACUMULACAO_JUSTIFICATIVA STRING,
  OBSERVACAO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_causa
-- @fk: ID_CONTRAMEDIDA -> raw.dbo__CONTRAMEDIDA.ID
-- @fk: ID_CRIADOR_CAUSA -> raw.dbo__COLABORADOR.ID
-- @fk: ID_INDICADOR -> raw.dbo__INDICADOR.ID
-- @fk: ParentCause -> raw.dbo__CAUSA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__CAUSA (
  tenant_slug STRING,
  ID INT,
  ID_INDICADOR INT,
  ID_CONTRAMEDIDA INT,
  DESC_CAUSA STRING,
  SUB_CAUSA1 STRING,
  SUB_CAUSA2 STRING,
  SUB_CAUSA3 STRING,
  SUB_CAUSA4 STRING,
  SUB_CAUSA5 STRING,
  GESTAO_CONHECIMENTO_ATIVO INT,
  SELECIONADA INT,
  ID_CRIADOR_CAUSA INT,
  COD_CAUSA STRING,
  ID_ULTIMO_EDITOR_CAUSA INT,
  ParentCause INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_code_generator
-- @fk: ID_PERIODO_GESTAO -> raw.dbo__PERIODO_GESTAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__CODE_GENERATOR (
  tenant_slug STRING,
  TABLE_NAME STRING,
  ID_PERIODO_GESTAO INT,
  VALOR INT,
  AUTOMATICA INT,
  Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: Hub universal dbo.COLABORADOR — multi-tenant CDC/bulk
-- @fk: ID_GRUPO_USUARIO -> raw.dbo__GRUPO_USUARIO.ID
-- @fk: ID_IDIOMA -> raw.dbo__IDIOMA.ID
-- @fk: Locality_Id -> raw.dbo__Locality.Id
CREATE TABLE IF NOT EXISTS raw.dbo__COLABORADOR (
  tenant_slug STRING,
  ID INT,
  ID_GRUPO_USUARIO INT,
  ID_IDIOMA INT,
  USER_LOGIN STRING,
  NOME STRING,
  EMAIL STRING,
  WORKFLOW_ACOES INT,
  ATIVO INT,
  FOTO_PATH STRING,
  USUARIO_AD INT,
  TIPO_COLABORADOR INT,
  EXIBIR_TUTORIAL INT,
  Registration STRING,
  EXIBIR_TUTORIAL_DASH_PERFORMANCE INT,
  FCMToken STRING,
  AvailabilityRelocateStatus INT,
  SignatureConsentAgreement INT,
  Locality_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_configuracoes_gerais_feedback_continuo
CREATE TABLE IF NOT EXISTS raw.dbo__CONFIGURACOES_GERAIS_FEEDBACK_CONTINUO (
  tenant_slug STRING,
  ID INT,
  FEEDBACK_ANONIMO_ATIVO INT,
  FEEDBACK_DIRETO_ATIVO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_curva_multiplo
-- @fk: ID_NIVEL -> raw.dbo__NIVEL.ID
-- @fk: ID_PERIODO_APURACAO -> raw.dbo__PERIODO_APURACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__CURVA_MULTIPLO (
  tenant_slug STRING,
  ID INT,
  ID_NIVEL INT,
  ID_PERIODO_APURACAO INT,
  NOTA_CURVA_MULTIPLO DOUBLE,
  MULTIPLO_CURVA_MULTIPLO DOUBLE,
  Concept STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_curva_premiacao
CREATE TABLE IF NOT EXISTS raw.dbo__CURVA_PREMIACAO (
  tenant_slug STRING,
  ID INT,
  ID_PERIODO_GESTAO INT,
  ID_SOURCE INT,
  COD_CURVA_PREMIACAO STRING,
  DESC_CURVA_PREMIACAO STRING,
  TIPO_INTERPOLACAO INT,
  UseMinScoreInsteadOfZero INT,
  DefaultCurve INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_calibration_group_discretionary
-- @fk: CalculationPeriod_Id -> raw.dbo__PERIODO_APURACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__CalibrationGroupDiscretionary (
  tenant_slug STRING,
  ID INT,
  CalculationPeriod_Id INT,
  Description STRING,
  ScoreCalculationInformation STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_cause_analysis_permission
-- @fk: Countermeasure_Id -> raw.dbo__CONTRAMEDIDA.ID
-- @fk: Employee_Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__CauseAnalysisPermission (
  tenant_slug STRING,
  Id INT,
  Countermeasure_Id INT,
  Employee_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_certificate
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__Certificate (
  tenant_slug STRING,
  Id INT,
  Logo STRING,
  Title STRING,
  Issuer STRING,
  License STRING,
  Start TIMESTAMP,
  End TIMESTAMP,
  EmployeeId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_certificate_attachment
-- @fk: Id -> raw.dbo__Certificate.Id
CREATE TABLE IF NOT EXISTS raw.dbo__CertificateAttachment (
  tenant_slug STRING,
  Id INT,
  FileName STRING,
  Key STRING,
  UploadDate TIMESTAMP,
  ContentType STRING,
  ContentLength INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_company
CREATE TABLE IF NOT EXISTS raw.dbo__Company (
  tenant_slug STRING,
  Id INT,
  Logo STRING,
  Name STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_concept_discretionary
-- @fk: PeriodoApuracao_Id -> raw.dbo__PERIODO_APURACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ConceptDiscretionary (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  Grade DECIMAL(18,2),
  PeriodoApuracao_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_consent_agreement
CREATE TABLE IF NOT EXISTS raw.dbo__ConsentAgreement (
  tenant_slug STRING,
  Id INT,
  Description STRING,
  Subject STRING,
  Version STRING,
  LastUpdate TIMESTAMP,
  Active INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_curriculum_attachment
-- @fk: Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__CurriculumAttachment (
  tenant_slug STRING,
  Id INT,
  FileName STRING,
  Key STRING,
  UploadDate TIMESTAMP,
  ContentType STRING,
  ContentLength INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_custom_grade_formation
-- @fk: Area_Id -> raw.dbo__AREA.ID
-- @fk: PaymentGroup_Id -> raw.dbo__GRUPO_PAGTO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__CustomGradeFormation (
  tenant_slug STRING,
  Id INT,
  Description STRING,
  Percentage DOUBLE,
  Area_Id INT,
  PaymentGroup_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_diretriz
-- @fk: ID_PERIODO_GESTAO -> raw.dbo__PERIODO_GESTAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__DIRETRIZ (
  tenant_slug STRING,
  ID INT,
  ID_PERIODO_GESTAO INT,
  COD_DIRETRIZ STRING,
  DESC_DIRETRIZ STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_dreams
-- @fk: Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__Dreams (
  tenant_slug STRING,
  Id INT,
  Personal STRING,
  Professional STRING,
  Values STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_efetividade_acao
-- @fk: ID_ACAO -> raw.dbo__ACAO.ID
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__EFETIVIDADE_ACAO (
  tenant_slug STRING,
  ID INT,
  ID_COLABORADOR INT,
  ID_ACAO INT,
  TIPO INT,
  ATUAL INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_education_attachment
-- @fk: Id -> raw.dbo__Education.Id
CREATE TABLE IF NOT EXISTS raw.dbo__EducationAttachment (
  tenant_slug STRING,
  Id INT,
  FileName STRING,
  UploadDate TIMESTAMP,
  ContentType STRING,
  Key STRING,
  ContentLength INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_employee_branch
-- @fk: IdBranch -> raw.dbo__FILIAL.ID
-- @fk: IdEmployee -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__EmployeeBranch (
  tenant_slug STRING,
  Id INT,
  IdEmployee INT,
  IdBranch INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_evaluation_cycle_instance
-- @fk: ForumId -> raw.dbo__NINE_BOX.ID
CREATE TABLE IF NOT EXISTS raw.dbo__EvaluationCycleInstance (
  tenant_slug STRING,
  Id INT,
  ForumId INT,
  Description STRING,
  CreationDate TIMESTAMP,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  Status INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_evaluation_cycle_quadrant
-- @fk: EvaluationCycleId -> raw.competences__AVALIACAO.ID
-- @fk: XAxisClassificationId -> raw.competences__FAIXA_CLASSIFICACAO_AVALIACAO.ID
-- @fk: YAxisClassificationId -> raw.competences__FAIXA_CLASSIFICACAO_PERFORMANCE_AVALIACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__EvaluationCycleQuadrant (
  tenant_slug STRING,
  Id INT,
  EvaluationCycleId INT,
  XAxisClassificationId INT,
  YAxisClassificationId INT,
  Title STRING,
  Description STRING,
  BackgroundColor STRING,
  TitleColor STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_faixa_farol
CREATE TABLE IF NOT EXISTS raw.dbo__FAIXA_FAROL (
  tenant_slug STRING,
  ID INT,
  COD_FAIXA_FAROL STRING,
  DESC_FAIXA_FAROL STRING,
  COMPARADOR INT,
  DefaultForGoalsBookScore INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_farol
CREATE TABLE IF NOT EXISTS raw.dbo__FAROL (
  tenant_slug STRING,
  ID INT,
  DESC_FAROL STRING,
  HABILITADO INT,
  COR_HEXADECIMAL STRING,
  COR_RGB STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: Feedback contínuo
-- @fk: ID_COLABORADOR_PROPRIETARIO -> raw.dbo__COLABORADOR.ID
-- @fk: ID_COLABORADOR_PROPRIETARIO -> raw.dbo__COLABORADOR.ID
-- @fk: ID_COMPETENCIA -> raw.competences__COMPETENCIA.ID
-- @fk: ID_FEEDBACK_PAI -> raw.dbo__FEEDBACK_CONTINUO.Id
-- @fk: ID_META -> raw.dbo__META.ID
-- @fk: ID_META -> raw.dbo__META.ID
-- @fk: ID_REUNIAO -> raw.dbo__REUNIAO.ID
-- @fk: ID_TIPO_FEEDBACK -> raw.dbo__TIPO_FEEDBACK_CONTINUO.ID
-- @fk: PulseId -> raw.dbo__PULSE_FEEDBACK_CONTINUO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FEEDBACK_CONTINUO (
  tenant_slug STRING,
  Id INT,
  ID_COLABORADOR_PROPRIETARIO INT,
  ID_FEEDBACK_PAI INT,
  TEXTO STRING,
  CATEGORIA_FEEDBACK INT,
  DATA_FEEDBACK TIMESTAMP,
  ACEITA_RESPOSTAS_ANONIMAS INT,
  FEEDBACK_ANONIMO INT,
  DESCRICAO STRING,
  ID_META INT,
  ID_REUNIAO INT,
  ID_COMPETENCIA INT,
  ID_TIPO_FEEDBACK INT,
  PulseId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_filial
-- @fk: ID_IDIOMA -> raw.dbo__IDIOMA.ID
-- @fk: ID_MOEDA -> raw.dbo__UNIDADE_MEDIDA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FILIAL (
  tenant_slug STRING,
  ID INT,
  ID_IDIOMA INT,
  ID_MOEDA INT,
  COD_FILIAL STRING,
  DESC_FILIAL STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_formulario_feedback_aba
-- @fk: ID_AVALIACAO -> raw.competences__AVALIACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FORMULARIO_FEEDBACK_ABA (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  DESCRICAO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_forum_calibragem_sucessao
-- @fk: ID_CICLO_SUCESSAO -> raw.dbo__SuccessionCycle.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FORUM_CALIBRAGEM_SUCESSAO (
  tenant_slug STRING,
  ID INT,
  ID_CICLO_SUCESSAO INT,
  DESCRICAO STRING,
  DATA_CRIACAO TIMESTAMP,
  DATA_ENCERRAMENTO TIMESTAMP,
  STATUS INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_forum_quadrante_sucessao_modelo
-- @fk: ID_CICLO_SUCESSAO -> raw.dbo__SuccessionCycle.ID
-- @fk: ID_CLASSIFICACAO_PERFORMANCE_SUCESSAO -> raw.dbo__YAxisClassification.ID
-- @fk: ID_CLASSIFICACAO_POTENCIAL -> raw.dbo__XAxisClassification.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FORUM_QUADRANTE_SUCESSAO_MODELO (
  tenant_slug STRING,
  ID INT,
  ID_CICLO_SUCESSAO INT,
  ID_CLASSIFICACAO_PERFORMANCE_SUCESSAO INT,
  ID_CLASSIFICACAO_POTENCIAL INT,
  TITULO STRING,
  COR_FUNDO STRING,
  COR_TITULO STRING,
  DESCRICAO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_frequencia_acomp
CREATE TABLE IF NOT EXISTS raw.dbo__FREQUENCIA_ACOMP (
  tenant_slug STRING,
  ID INT,
  DESC_FREQUENCIA_ACOMP STRING,
  FATOR_PERIODO DOUBLE,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_frequencia_visualizacao
CREATE TABLE IF NOT EXISTS raw.dbo__FREQUENCIA_VISUALIZACAO (
  tenant_slug STRING,
  ID INT,
  DESC_FREQUENCIA_VISUALIZACAO STRING,
  QTE_MES INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_factor_trigger_configuration
-- @fk: CustomGradeFormation_Id -> raw.dbo__CustomGradeFormation.Id
-- @fk: PaymentGroup_Id -> raw.dbo__GRUPO_PAGTO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FactorTriggerConfiguration (
  tenant_slug STRING,
  Id INT,
  Type INT,
  Value DECIMAL(28,8),
  PaymentGroup_Id INT,
  CustomGradeFormation_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_feedback_history
-- @fk: FeedbackId -> raw.dbo__FEEDBACK_CONTINUO.Id
CREATE TABLE IF NOT EXISTS raw.dbo__FeedbackHistory (
  tenant_slug STRING,
  Id INT,
  FeedbackId INT,
  Text STRING,
  Date TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_feedback_participant
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: FeedbackId -> raw.dbo__FEEDBACK_CONTINUO.Id
CREATE TABLE IF NOT EXISTS raw.dbo__FeedbackParticipant (
  tenant_slug STRING,
  Id INT,
  EmployeeId INT,
  FeedbackId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_grupo_cargo
CREATE TABLE IF NOT EXISTS raw.dbo__GRUPO_CARGO (
  tenant_slug STRING,
  ID INT,
  COD_GRUPO_CARGO STRING,
  DESC_GRUPO_CARGO STRING,
  COR STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_grupo_funcionalidade
-- @fk: ID_MODULO -> raw.dbo__Modules.Id
CREATE TABLE IF NOT EXISTS raw.dbo__GRUPO_FUNCIONALIDADE (
  tenant_slug STRING,
  ID INT,
  DESC_GRUPO_FUNCIONALIDADE STRING,
  ORDEM_EXIBICAO INT,
  ID_PARENT INT,
  ID_MODULO INT,
  ICONE STRING,
  TAG STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_grupo_pagto
-- @fk: ID_PERIODO_APURACAO -> raw.dbo__PERIODO_APURACAO.ID
-- @fk: ID_POOL -> raw.dbo__Pool.Id
-- @fk: ProportionalityModifier_Id -> raw.dbo__Modifier.Id
CREATE TABLE IF NOT EXISTS raw.dbo__GRUPO_PAGTO (
  tenant_slug STRING,
  ID INT,
  ID_PERIODO_APURACAO INT,
  COD_GRUPO_PAGTO STRING,
  DESC_GRUPO_PAGTO STRING,
  PERC_INDIVIDUAL DOUBLE,
  PERC_AREA DOUBLE,
  PERC_SUPERIOR DOUBLE,
  PERC_PRESIDENCIA DOUBLE,
  POOL_GRUPO_PAGTO DOUBLE,
  PERC_AVALIACAO_COMPETENCIA DOUBLE,
  PERC_DISCRICIONARIO DOUBLE,
  ID_POOL INT,
  PERC_FILIAL DOUBLE,
  VALOR_POOL DECIMAL(28,8),
  ProportionalityModifier_Id INT,
  ApplyCascadeEffect INT,
  PERC_AVALIACAO_DISCRICIONARIA DOUBLE,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_grupo_usuario
-- @fk: PAINEL_INICIAL_LAYOUT_ID -> raw.dbo__InitialDashboardLayout.Id
CREATE TABLE IF NOT EXISTS raw.dbo__GRUPO_USUARIO (
  tenant_slug STRING,
  ID INT,
  DESC_GRUPO_USUARIO STRING,
  TIPO_USUARIO INT,
  COD_GRUPO_USUARIO STRING,
  REQUIRE_TWO_FACTOR INT,
  PAINEL_INICIAL_LAYOUT_ID INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_goal_discussion
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: GoalId -> raw.dbo__META.ID
CREATE TABLE IF NOT EXISTS raw.dbo__GoalDiscussion (
  tenant_slug STRING,
  Id INT,
  GoalId INT,
  EmployeeId INT,
  Message STRING,
  CreatedDate TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_goal_pendency_value_import
CREATE TABLE IF NOT EXISTS raw.dbo__GoalPendencyValueImport (
  tenant_slug STRING,
  ImportLogId INT,
  Line INT,
  GoalId INT,
  GoalValueId INT,
  ReferenceDate TIMESTAMP,
  PunctualActual DECIMAL(28,8),
  AccumulatedActual DECIMAL(28,8),
  PunctualNaActual INT,
  AccumulatedNaActual INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_goal_workflow
-- @fk: ManagementCycle_Id -> raw.dbo__PERIODO_GESTAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__GoalWorkflow (
  tenant_slug STRING,
  ManagementCycle_Id INT,
  WorkflowType INT,
  ID INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_goal_workflow_custom_step
-- @fk: Id -> raw.dbo__PERIODO_GESTAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__GoalWorkflowCustomStep (
  tenant_slug STRING,
  Id INT,
  Title STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_goal_workflow_step
-- @fk: IdGoalWorkflow -> raw.dbo__GoalWorkflow.ID
CREATE TABLE IF NOT EXISTS raw.dbo__GoalWorkflowStep (
  tenant_slug STRING,
  Id INT,
  IdGoalWorkflow INT,
  Order INT,
  Type INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_hobbies
-- @fk: Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__Hobbies (
  tenant_slug STRING,
  Id INT,
  Personal STRING,
  Family STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: Definição KPI dbo.INDICADOR
-- @fk: ID_FAIXA_FAROL -> raw.dbo__FAIXA_FAROL.ID
-- @fk: ID_FREQUENCIA_ACOMP -> raw.dbo__FREQUENCIA_ACOMP.ID
-- @fk: ID_UNIDADE_MEDIDA -> raw.dbo__UNIDADE_MEDIDA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__INDICADOR (
  tenant_slug STRING,
  ID INT,
  ID_UNIDADE_MEDIDA INT,
  ID_FREQUENCIA_ACOMP INT,
  ID_FAIXA_FAROL INT,
  COD_INDICADOR STRING,
  DESC_INDICADOR STRING,
  MEMORIA_CALCULO STRING,
  POLARIDADE INT,
  ATIVO INT,
  AlertDataProviderDay INT,
  AlertDataProviderAdvance INT,
  AlertDataProviderFreq INT,
  EnableEditionAlertDataProvider INT,
  AlertStakeholderDay INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_indicador_tipometa
-- @fk: ID_INDICADOR -> raw.dbo__INDICADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__INDICADOR_TIPOMETA (
  tenant_slug STRING,
  ID INT,
  ID_INDICADOR INT,
  TIPO_META INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_instancia_comite
-- @fk: COLABORADOR_ID -> raw.dbo__COLABORADOR.ID
-- @fk: INSTANCIA_ID -> raw.dbo__EvaluationCycleInstance.Id
CREATE TABLE IF NOT EXISTS raw.dbo__INSTANCIA_COMITE (
  tenant_slug STRING,
  ID INT,
  INSTANCIA_ID INT,
  COLABORADOR_ID INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_instancia_comite_sucessao
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_INSTANCIA_SUCESSAO -> raw.dbo__INSTANCIA_SUCESSAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__INSTANCIA_COMITE_SUCESSAO (
  tenant_slug STRING,
  ID INT,
  ID_INSTANCIA_SUCESSAO INT,
  ID_COLABORADOR INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_instancia_sucessao
-- @fk: ID_FORUM_SUCESSAO -> raw.dbo__FORUM_CALIBRAGEM_SUCESSAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__INSTANCIA_SUCESSAO (
  tenant_slug STRING,
  ID INT,
  ID_FORUM_SUCESSAO INT,
  DESCRICAO STRING,
  DATA_CRIACAO TIMESTAMP,
  DATA_INICIO_INSTANCIA TIMESTAMP,
  DATA_FIM_INSTANCIA TIMESTAMP,
  STATUS INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_item_lista_personalizada_feedback_continuo
-- @fk: FeedbackTypeId -> raw.dbo__TIPO_FEEDBACK_CONTINUO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ITEM_LISTA_PERSONALIZADA_FEEDBACK_CONTINUO (
  tenant_slug STRING,
  Id INT,
  DESCRICAO STRING,
  FeedbackTypeId INT,
  ATIVO INT,
  COR_TEXTO STRING,
  COR_FUNDO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_job_position_core
CREATE TABLE IF NOT EXISTS raw.dbo__JobPositionCore (
  tenant_slug STRING,
  Id INT,
  Code STRING,
  Description STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_language_level
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__LanguageLevel (
  tenant_slug STRING,
  Id INT,
  Proficiency INT,
  EmployeeId INT,
  LanguageId INT,
  Observation STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_locality
CREATE TABLE IF NOT EXISTS raw.dbo__Locality (
  tenant_slug STRING,
  Id INT,
  Description STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: Metas de desempenho dbo.META
-- @fk: ID_AREA -> raw.dbo__AREA.ID
-- @fk: ID_AREA -> raw.dbo__AREA.ID
-- @fk: ID_CURVA_PREMIACAO -> raw.dbo__CURVA_PREMIACAO.ID
-- @fk: ID_DATA_PROVIDER -> raw.dbo__COLABORADOR.ID
-- @fk: ID_DIRETRIZ -> raw.dbo__DIRETRIZ.ID
-- @fk: ID_INDICADOR -> raw.dbo__INDICADOR.ID
-- @fk: ID_INDICADOR -> raw.dbo__INDICADOR.ID
-- @fk: ID_PERIODO_GESTAO -> raw.dbo__PERIODO_GESTAO.ID
-- @fk: ID_RESPONSAVEL_META -> raw.dbo__COLABORADOR.ID
-- @fk: ID_RESPONSAVEL_META -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__META (
  tenant_slug STRING,
  ID INT,
  ID_PERIODO_GESTAO INT,
  ID_AREA INT,
  ID_INDICADOR INT,
  ID_RESPONSAVEL_META INT,
  ID_DATA_PROVIDER INT,
  ID_DIRETRIZ INT,
  ID_CURVA_PREMIACAO INT,
  ID_SOURCE INT,
  COD_META STRING,
  OBJETIVO STRING,
  FONTE_DADOS STRING,
  MEMORIA_CALCULO STRING,
  PESO_META DOUBLE,
  SCORE_META DOUBLE,
  SCORE_PONDERADO DOUBLE,
  VALOR_META DOUBLE,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  TIPO_META INT,
  TIPO_ACUMULACAO INT,
  TIPO_VALOR_META INT,
  STATUS_VALIDACAO INT,
  LOCK_FORECAST INT,
  META_QUALIFICADORA INT,
  PASSO_VALIDACAO INT,
  EnableGoalAudit INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_modifier
-- @fk: PaymentGroup_Id -> raw.dbo__GRUPO_PAGTO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__Modifier (
  tenant_slug STRING,
  Id INT,
  Code STRING,
  Description STRING,
  AppliesTo INT,
  Type INT,
  Value DECIMAL(28,8),
  PaymentGroup_Id INT,
  MathType INT,
  Config STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_modifier_item
-- @fk: IdModifier -> raw.dbo__Modifier.Id
CREATE TABLE IF NOT EXISTS raw.dbo__ModifierItem (
  tenant_slug STRING,
  Id INT,
  IdModifier INT,
  Conditional DECIMAL(28,8),
  Value DECIMAL(28,8),
  IdExternalConditional INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_motivations
-- @fk: Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__Motivations (
  tenant_slug STRING,
  Id INT,
  Personal STRING,
  Demotivations STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_nine_box
CREATE TABLE IF NOT EXISTS raw.dbo__NINE_BOX (
  tenant_slug STRING,
  ID INT,
  DESCRICAO STRING,
  DT_CRIACAO TIMESTAMP,
  ATIVO INT,
  ID_AVALIACAO INT,
  STATUS INT,
  DT_ENCERRAMENTO TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_nivel
-- @fk: ID_GRUPO_PAGTO -> raw.dbo__GRUPO_PAGTO.ID
-- @fk: ID_PERIODO_APURACAO -> raw.dbo__PERIODO_APURACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__NIVEL (
  tenant_slug STRING,
  ID INT,
  ID_PERIODO_APURACAO INT,
  ID_GRUPO_PAGTO INT,
  COD_NIVEL STRING,
  DESC_NIVEL STRING,
  MULTIPLO_SALARIAL DOUBLE,
  SALARIO DOUBLE,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_notificacao
CREATE TABLE IF NOT EXISTS raw.dbo__NOTIFICACAO (
  tenant_slug STRING,
  ID INT,
  TITULO_MODAL STRING,
  DESCRICAO_NOTIFICACAO STRING,
  ATIVO INT,
  TIPO_NOTIFICACAO INT,
  DATA_EXPIRACAO TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_notificacao_lida
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_NOTIFICACAO -> raw.dbo__NOTIFICACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__NOTIFICACAO_LIDA (
  tenant_slug STRING,
  ID INT,
  ID_NOTIFICACAO INT,
  ID_COLABORADOR INT,
  DT_LEITURA TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_normalization_curve_point
-- @fk: CalculationPeriod_Id -> raw.dbo__PERIODO_APURACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__NormalizationCurvePoint (
  tenant_slug STRING,
  Id INT,
  PerformanceScore DECIMAL(28,8),
  EvaluationScore DECIMAL(28,8),
  IsReference INT,
  CalculationPeriod_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_perfil_usuario
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_FUNCIONALIDADE -> raw.dbo__FUNCIONALIDADE.ID
CREATE TABLE IF NOT EXISTS raw.dbo__PERFIL_USUARIO (
  tenant_slug STRING,
  ID INT,
  ID_COLABORADOR INT,
  ID_FUNCIONALIDADE STRING,
  OUTRAS_AREAS INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: Período apuração remuneração variável
-- @fk: ID_PERIODO_GESTAO -> raw.dbo__PERIODO_GESTAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__PERIODO_APURACAO (
  tenant_slug STRING,
  ID INT,
  ID_PERIODO_GESTAO INT,
  DESC_PERIODO_APURACAO STRING,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  STATUS_PERIODO_APURACAO INT,
  TIPO_RV INT,
  ID_CICLO_AVALIACAO INT,
  EXTRACT_AUTO_RELEASE INT,
  TYPE_DISPLAY_MODIFIERS INT,
  JobPositionHistoryCalculation INT,
  AreaHistoryCalculation INT,
  HistoryCalculationAppliedIn INT,
  DECIMAL_PRECISION INT,
  ModifiersLimit DECIMAL(28,8),
  DateProportionalityType INT,
  OPTIONS STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: Períodos de gestão e apuração RV
CREATE TABLE IF NOT EXISTS raw.dbo__PERIODO_GESTAO (
  tenant_slug STRING,
  ID INT,
  DESC_PERIODO_GESTAO STRING,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  STATUS INT,
  STATUS_PLANEJAMENTO INT,
  QTE_MESES INT,
  PRECISAO_DECIMAL_SCORE INT,
  ALTERAR_VALOR_HISTORICO INT,
  HABILITAR_TERMO_ACEITE INT,
  CONSIDERAR_META_NA_SCORE INT,
  ACAO_DIAS_RETROATIVOS INT,
  EnableGoalAudit INT,
  OPCAO_CARREGAMENTO_FILTRO INT,
  ScoreRef INT,
  AlertDataProviderDay INT,
  AlertDataProviderFreq INT,
  GoalAuditType INT,
  HABILITAR_COMPARTILHAMENTO_ROTULOS INT,
  GoalNotReachedTrackingPonctual INT,
  GoalNotReachedTrackingAccumulated INT,
  GoalNotReachedMinMonthsTracking INT,
  GoalNotReachedSendingMailFrequency INT,
  GoalActionsCalcType INT,
  TIPO_META_HABILITADO STRING,
  PERMITIR_NOTA_META_DIFERENTE_CEM_PORCENTO INT,
  EnableEditionAlertDataProviderInKpi INT,
  AlertDataProviderAdvance INT,
  GoalAuditFrequency INT,
  GoalAuditRequiredAttach INT,
  EnableValidationByWeight INT,
  TrafficLightApplication INT,
  DeviationTreatmentStep INT,
  DeviationExhibitionOption INT,
  DayLimitToChangeValues INT,
  ZeroScoreOfGoalsWithPendencies INT,
  EnableQualifierGoal INT,
  EnableUpperGoal INT,
  EnableForecast INT,
  ProjectGoalCalculationOption INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_processo
-- @fk: ID_INDICADOR -> raw.dbo__INDICADOR.ID
-- @fk: ID_RESPONSAVEL -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__PROCESSO (
  tenant_slug STRING,
  ID INT,
  ID_INDICADOR INT,
  ID_RESPONSAVEL INT,
  COD_PROCESSO STRING,
  DESC_PROCESSO STRING,
  TIPO_PROCESSO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_personal_characteristics
-- @fk: Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__PersonalCharacteristics (
  tenant_slug STRING,
  Id INT,
  Personal STRING,
  Others STRING,
  WhatWillNotGiveUp STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_pool
-- @fk: AdvanceResultsPeriod_Id -> raw.dbo__PERIODO_APURACAO.ID
-- @fk: PeriodoApuracao_Id -> raw.dbo__PERIODO_APURACAO.ID
-- @fk: UpperPool_Id -> raw.dbo__Pool.Id
CREATE TABLE IF NOT EXISTS raw.dbo__Pool (
  tenant_slug STRING,
  Id INT,
  Code STRING,
  Description STRING,
  Value DECIMAL(28,8),
  PeriodoApuracao_Id INT,
  UpperPool_Id INT,
  Path STRING,
  RedistributePoolByScore INT,
  RedistributePoolByCalculationPeriod INT,
  AdvanceResultsPeriod_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_presentation_favorite_slide
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: PresentationTemplateSlideId -> raw.dbo__PresentationTemplateSlide.Id
CREATE TABLE IF NOT EXISTS raw.dbo__PresentationFavoriteSlide (
  tenant_slug STRING,
  Id INT,
  EmployeeId INT,
  PresentationTemplateSlideId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_professional_experience
-- @fk: CompanyId -> raw.dbo__Company.Id
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: JobPositionId -> raw.dbo__JobPositionCore.Id
CREATE TABLE IF NOT EXISTS raw.dbo__ProfessionalExperience (
  tenant_slug STRING,
  Id INT,
  LocationId INT,
  Location STRING,
  Start TIMESTAMP,
  End TIMESTAMP,
  JobDescription STRING,
  CurrentJob INT,
  EmployeeId INT,
  KnowledgeArea STRING,
  CompanyId INT,
  JobPositionId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_profile_edit_permission
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: UserGroupId -> raw.dbo__GRUPO_USUARIO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ProfileEditPermission (
  tenant_slug STRING,
  Id INT,
  EmployeeId INT,
  UserGroupId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_recurring_job
CREATE TABLE IF NOT EXISTS raw.dbo__RECURRING_JOB (
  tenant_slug STRING,
  ID INT,
  JOB_ID STRING,
  TIPO_JOB INT,
  CRON_EXPRESSION STRING,
  JOB_DESCRIPTION STRING,
  ATIVO INT,
  PARAMETERS STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_range_discretionary
-- @fk: PeriodoApuracao_Id -> raw.dbo__PERIODO_APURACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__RangeDiscretionary (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  MinimumGrade DECIMAL(18,2),
  MaximumGrade DECIMAL(18,2),
  PeriodoApuracao_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_readiness
-- @fk: SuccessionCycleId -> raw.dbo__SuccessionCycle.ID
CREATE TABLE IF NOT EXISTS raw.dbo__Readiness (
  tenant_slug STRING,
  Id INT,
  SuccessionCycleId INT,
  TimeSlot STRING,
  Order INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_rel_upper_goal
-- @fk: GoalId -> raw.dbo__META.ID
-- @fk: UpperGoalId -> raw.dbo__META.ID
CREATE TABLE IF NOT EXISTS raw.dbo__RelUpperGoal (
  tenant_slug STRING,
  GoalId INT,
  UpperGoalId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, GoalId, UpperGoalId)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_server_cache_preferences_management_cycle
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: ManagementCycleId -> raw.dbo__PERIODO_GESTAO.ID
-- @fk: SidebarItemId -> raw.dbo__SidebarItem.Id
CREATE TABLE IF NOT EXISTS raw.dbo__ServerCachePreferencesManagementCycle (
  tenant_slug STRING,
  Id INT,
  SidebarItemId INT,
  ManagementCycleId INT,
  EmployeeId INT,
  FilterJson STRING,
  OperationDate TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_simulation_rv_cache
-- @fk: Participant_Id -> raw.dbo__PARTICIPANTE_RV.ID
CREATE TABLE IF NOT EXISTS raw.dbo__SimulationRVCache (
  tenant_slug STRING,
  Id INT,
  Participant_Id INT,
  Cache BINARY,
  Date TIMESTAMP,
  LastConnection TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_skill_category
CREATE TABLE IF NOT EXISTS raw.dbo__SkillCategory (
  tenant_slug STRING,
  Id INT,
  Description STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_skill_knowledge
-- @fk: SkillCategoryId -> raw.dbo__SkillCategory.Id
CREATE TABLE IF NOT EXISTS raw.dbo__SkillKnowledge (
  tenant_slug STRING,
  Id INT,
  Description STRING,
  SkillCategoryId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_sport
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__Sport (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  SportId INT,
  Frequency INT,
  EmployeeId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_succession_cycle
CREATE TABLE IF NOT EXISTS raw.dbo__SuccessionCycle (
  tenant_slug STRING,
  ID INT,
  Description STRING,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  STATUS INT,
  DecimalPrecision INT,
  IsCurrentCycle INT,
  FlowType INT,
  HasPendences INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_succession_cycle_settings
-- @fk: DeliberationOption_Id -> raw.dbo__DeliberationOption.Id
-- @fk: EvaluationCycleId -> raw.competences__AVALIACAO.ID
-- @fk: ID -> raw.dbo__SuccessionCycle.ID
-- @fk: ManagementCycleId -> raw.dbo__PERIODO_GESTAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__SuccessionCycleSettings (
  tenant_slug STRING,
  ID INT,
  ScoreAchievementViaImport INT,
  XAxisDescription STRING,
  YAxisDescription STRING,
  ScoreCompetenceViaImport INT,
  ScorePerformanceViaImport INT,
  EvaluationCycleId INT,
  ManagementCycleId INT,
  MonthTo INT,
  PercentagePerformanceScore DECIMAL(28,8),
  PercentageCompetenceScore DECIMAL(28,8),
  SuccessionCycleId INT,
  HideNumericalScores INT,
  EnableDeliberationsEmployee INT,
  DeliberationOption_Id INT,
  PercentagePotentialScore DECIMAL(28,8),
  XAxisComposition INT,
  YAxisComposition INT,
  ShowButtonToOpenFormCompetence INT,
  HidePotentialBlock INT,
  HideRiskBlock INT,
  HidePerformanceBlock INT,
  EnableSuccessorSelection INT,
  EnableVerticalSuccessorMoves INT,
  EnableHorizontalSuccesorMoves INT,
  MinimumVerticalSuccessors INT,
  MaximumVerticalSuccessors INT,
  MinimumHorizontalSuccessors INT,
  MaximumHorizontalSuccessors INT,
  COMENTARIO_QUANTITATIVO_OBRIGATORIO INT,
  COMENTARIO_QUALITATIVO_OBRIGATORIO INT,
  COMENTARIO_SELECAO_OBRIGATORIO INT,
  HideImpactBlock INT,
  EnableClassificationCalibrationAtEvaluation INT,
  EnableJobPositionSuccessor INT,
  HidePotentialSummary INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_succession_results
-- @fk: EvaluatedSuccessionId -> raw.dbo__AVALIADO_SUCESSAO.ID
-- @fk: FinalScoreImpactCalibId -> raw.dbo__ClassificationImpactOfLoss.Id
-- @fk: FinalScoreRiskCalibId -> raw.dbo__ClassificationRiskOfLoss.Id
-- @fk: FinalScoreXAxisClassificationCalibId -> raw.dbo__XAxisClassification.ID
-- @fk: FinalScoreXAxisClassificationId -> raw.dbo__XAxisClassification.ID
-- @fk: FinalScoreYAxisClassificationCalibId -> raw.dbo__YAxisClassification.ID
-- @fk: FinalScoreYAxisClassificationId -> raw.dbo__YAxisClassification.ID
CREATE TABLE IF NOT EXISTS raw.dbo__SuccessionResults (
  tenant_slug STRING,
  Id INT,
  EvaluatedSuccessionId INT,
  FinalScoreXAxis DECIMAL(28,8),
  FinalScoreYAxis DECIMAL(28,8),
  FinalScoreXAxisClassificationId INT,
  FinalScoreXAxisClassificationCalibId INT,
  FinalScoreYAxisClassificationId INT,
  FinalScoreYAxisClassificationCalibId INT,
  FinalScoreCompetence DECIMAL(28,8),
  FinalScorePerformance DECIMAL(28,8),
  FinalScorePotential DECIMAL(28,8),
  DataSourceCompetenceScore INT,
  DataSourcePerformanceScore INT,
  DataSourcePotentialScore INT,
  FinalScoreRisk DECIMAL(28,8),
  FinalScoreImpact DECIMAL(28,8),
  FinalScoreRiskCalibId INT,
  FinalScoreImpactCalibId INT,
  CompetenceSyncDate TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_system_knowledge
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: SkillCategoryId -> raw.dbo__SkillCategory.Id
-- @fk: SkillKnowledgeId -> raw.dbo__SkillKnowledge.Id
CREATE TABLE IF NOT EXISTS raw.dbo__SystemKnowledge (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  Level INT,
  EmployeeId INT,
  SkillCategoryId INT,
  SkillKnowledgeId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_tag_feedback
-- @fk: ID_FEEDBACK -> raw.dbo__FEEDBACK_CONTINUO.Id
-- @fk: ID_TAG -> raw.dbo__TAG_FEEDBACK_CONTINUO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__TAG_FEEDBACK (
  tenant_slug STRING,
  Id INT,
  ID_TAG INT,
  ID_FEEDBACK INT,
  TIPO_TAG INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_tag_feedback_continuo
CREATE TABLE IF NOT EXISTS raw.dbo__TAG_FEEDBACK_CONTINUO (
  tenant_slug STRING,
  ID INT,
  PONTO_POSITIVO STRING,
  PONTO_A_DESENVOLVER STRING,
  ATIVO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_termo_aceite
-- @fk: ID_PERIODO_GESTAO -> raw.dbo__PERIODO_GESTAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__TERMO_ACEITE (
  tenant_slug STRING,
  ID INT,
  ID_PERIODO_GESTAO INT,
  TEXTO STRING,
  ESCONDER_PERCENTUAL INT,
  LastUpdate TIMESTAMP,
  AgreementsRestrictionsToSend STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_termo_aceite_secao
-- @fk: ID_TERMO_ACEITE -> raw.dbo__TERMO_ACEITE.ID
CREATE TABLE IF NOT EXISTS raw.dbo__TERMO_ACEITE_SECAO (
  tenant_slug STRING,
  ID INT,
  ID_TERMO_ACEITE INT,
  ORDEM INT,
  TIPO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_timeline_feedback
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_FEEDBACK -> raw.dbo__FEEDBACK_CONTINUO.Id
-- @fk: ID_PULSE_RESPONDIDO -> raw.dbo__PULSE_FEEDBACK_CONTINUO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__TIMELINE_FEEDBACK_CONTINUO (
  tenant_slug STRING,
  Id INT,
  ID_COLABORADOR INT,
  ID_FEEDBACK INT,
  ARQUIVADO INT,
  LIDO INT,
  ID_PULSE_RESPONDIDO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_tipo_feedback_continuo
CREATE TABLE IF NOT EXISTS raw.dbo__TIPO_FEEDBACK_CONTINUO (
  tenant_slug STRING,
  ID INT,
  DESCRICAO STRING,
  ATIVO INT,
  TIPO_FEEDBACK INT,
  EDICAO_PERMITIDA INT,
  EXCLUIDO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_theme
-- @fk: OwnerId -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__Theme (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  OwnerId INT,
  LayoutSetting STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_theme_history
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: ThemeId -> raw.dbo__Theme.Id
CREATE TABLE IF NOT EXISTS raw.dbo__ThemeHistory (
  tenant_slug STRING,
  Id INT,
  EmployeeId INT,
  UpdateDate TIMESTAMP,
  ThemeId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_trigger
-- @fk: Area_Id -> raw.dbo__AREA.ID
-- @fk: Employee_Id -> raw.dbo__COLABORADOR.ID
-- @fk: Goal_Id -> raw.dbo__META.ID
-- @fk: PeriodoApuracao_Id -> raw.dbo__PERIODO_APURACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__Trigger (
  tenant_slug STRING,
  Id INT,
  Code STRING,
  Description STRING,
  Type INT,
  Area_Id INT,
  Employee_Id INT,
  Goal_Id INT,
  PeriodoApuracao_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_trigger_curve
-- @fk: Id -> raw.dbo__Trigger.Id
CREATE TABLE IF NOT EXISTS raw.dbo__TriggerCurve (
  tenant_slug STRING,
  Id INT,
  Code STRING,
  Description STRING,
  Type INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_trigger_curve_item
-- @fk: IdCurve -> raw.dbo__TriggerCurve.Id
CREATE TABLE IF NOT EXISTS raw.dbo__TriggerCurveItem (
  tenant_slug STRING,
  Id INT,
  IdCurve INT,
  Value DECIMAL(28,8),
  MultipleFactor DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_volunteer_experience
-- @fk: CompanyId -> raw.dbo__Company.Id
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: FunctionId -> raw.dbo__VolunteerFunction.Id
CREATE TABLE IF NOT EXISTS raw.dbo__VolunteerExperience (
  tenant_slug STRING,
  Id INT,
  Start TIMESTAMP,
  End TIMESTAMP,
  JobDescription STRING,
  Cause STRING,
  CurrentJob INT,
  EmployeeId INT,
  CompanyId INT,
  FunctionId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_volunteer_function
CREATE TABLE IF NOT EXISTS raw.dbo__VolunteerFunction (
  tenant_slug STRING,
  Id INT,
  Description STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_x_axis_classification
-- @fk: IdSuccessionCycle -> raw.dbo__SuccessionCycle.ID
CREATE TABLE IF NOT EXISTS raw.dbo__XAxisClassification (
  tenant_slug STRING,
  ID INT,
  IdSuccessionCycle INT,
  Description STRING,
  ScoreFrom DOUBLE,
  ScoreTo DOUBLE,
  ExpectedCurve DOUBLE,
  MergeWith INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_y_axis_classification
-- @fk: IdSuccessionCycle -> raw.dbo__SuccessionCycle.ID
CREATE TABLE IF NOT EXISTS raw.dbo__YAxisClassification (
  tenant_slug STRING,
  ID INT,
  IdSuccessionCycle INT,
  Description STRING,
  ScoreFrom DECIMAL(28,8),
  ScoreTo DECIMAL(28,8),
  ExpectedCurve DECIMAL(28,8),
  MergeWith INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: dimensional
-- @note: DIM → edw.dim_year_personal_goal
-- @fk: MotivationsId -> raw.dbo__Motivations.Id
CREATE TABLE IF NOT EXISTS raw.dbo__YearPersonalGoal (
  tenant_slug STRING,
  Id INT,
  PersonalGoal STRING,
  Year INT,
  MotivationsId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.HangFire__AggregatedCounter (
  tenant_slug STRING,
  Id INT,
  Key STRING,
  Value BIGINT,
  ExpireAt TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.HangFire__Counter (
  tenant_slug STRING,
  Id INT,
  Key STRING,
  Value INT,
  ExpireAt TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.HangFire__Hash (
  tenant_slug STRING,
  Id INT,
  Key STRING,
  Field STRING,
  Value STRING,
  ExpireAt TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — HangFire plataforma; sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.HangFire__Job (
  tenant_slug STRING,
  Id INT,
  StateId INT,
  StateName STRING,
  InvocationData STRING,
  Arguments STRING,
  CreatedAt TIMESTAMP,
  ExpireAt TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: JobId -> raw.HangFire__Job.Id
CREATE TABLE IF NOT EXISTS raw.HangFire__JobParameter (
  tenant_slug STRING,
  Id INT,
  JobId INT,
  Name STRING,
  Value STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.HangFire__JobQueue (
  tenant_slug STRING,
  Id INT,
  JobId INT,
  Queue STRING,
  FetchedAt TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.HangFire__List (
  tenant_slug STRING,
  Id INT,
  Key STRING,
  Value STRING,
  ExpireAt TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.HangFire__Schema (
  tenant_slug STRING,
  Version INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Version)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.HangFire__Server (
  tenant_slug STRING,
  Id STRING,
  Data STRING,
  LastHeartbeat TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.HangFire__Set (
  tenant_slug STRING,
  Id INT,
  Key STRING,
  Score DOUBLE,
  Value STRING,
  ExpireAt TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: JobId -> raw.HangFire__Job.Id
CREATE TABLE IF NOT EXISTS raw.HangFire__State (
  tenant_slug STRING,
  Id INT,
  JobId INT,
  Name STRING,
  Reason STRING,
  CreatedAt TIMESTAMP,
  Data STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: CreatedBy -> raw.dbo__COLABORADOR.ID
-- @fk: ResponsibleId -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.Tasks__ToDo (
  tenant_slug STRING,
  Id INT,
  Description STRING,
  Status INT,
  CreatedAt TIMESTAMP,
  Deadline TIMESTAMP,
  CompletedOn TIMESTAMP,
  ResponsibleId INT,
  CreatedBy INT,
  Active INT,
  Removed INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.audit__AuditLogs (
  tenant_slug STRING,
  Id BIGINT,
  EntityNamespace STRING,
  UserId INT,
  AuditType INT,
  ClientId STRING,
  JsonPreviousValue STRING,
  JsonCurrentValue STRING,
  CreationDate TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.auth__UserSideBarMenu (
  tenant_slug STRING,
  UserId INT,
  ManagementCycleId INT,
  JsonMenu STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, UserId, ManagementCycleId)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.cache__CONTEXT (
  tenant_slug STRING,
  ID INT,
  ID_PERIODO_GESTAO INT,
  CACHE_NAME STRING,
  CACHE_DATE TIMESTAMP,
  CACHE_VALUE STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.cache__FILTER (
  tenant_slug STRING,
  ID INT,
  ID_PERIODO_GESTAO INT,
  CACHE_NAME STRING,
  CACHE_DATE TIMESTAMP,
  CACHE_VALUE STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.cache__USER_PROFILE (
  tenant_slug STRING,
  ID INT,
  CACHE_NAME STRING,
  CACHE_DATE TIMESTAMP,
  CACHE_VALUE STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.core__Label (
  tenant_slug STRING,
  Id INT,
  Tag STRING,
  Applicability INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.core__ThemeSettings (
  tenant_slug STRING,
  MAIN_COLOR STRING,
  SECONDARY_COLOR STRING,
  GRADIENT INT,
  Logo STRING,
  DefaultPageBackground STRING,
  LoginPageBackground STRING,
  DefaultPageBackgroundLayoutOption INT,
  Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: DashboardId -> raw.dashboards__Dashboard.Id
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: ModuleId -> raw.dbo__Modules.Id
CREATE TABLE IF NOT EXISTS raw.dashboards__AccessLog (
  tenant_slug STRING,
  Id INT,
  EmployeeId INT,
  ModuleId INT,
  DashboardId INT,
  DashboardName STRING,
  AccessDate TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ModuleId -> raw.dbo__Modules.Id
CREATE TABLE IF NOT EXISTS raw.dashboards__Dashboard (
  tenant_slug STRING,
  Id INT,
  Description STRING,
  ModuleId INT,
  MetabaseDashboardId INT,
  Language STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__API_CONFIG (
  tenant_slug STRING,
  ID INT,
  API_COD STRING,
  API_URL STRING,
  API_KEY STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_ACAO (
  tenant_slug STRING,
  ID INT,
  ID_META INT,
  ID_CRIADOR_ACAO INT,
  ID_RESPONSAVEL_ACAO INT,
  ID_CONTRAMEDIDA INT,
  ID_CAUSA INT,
  COD_ACAO STRING,
  OQUE STRING,
  COMO STRING,
  PORQUE STRING,
  ONDE STRING,
  JUSTIFICATIVA_CANCELAMENTO STRING,
  JUSTIFICATIVA_NEGACAO STRING,
  INVESTIMENTO DOUBLE,
  RETORNO DOUBLE,
  DT_CRIACAO_ACAO TIMESTAMP,
  DT_INI_PLANEJADA TIMESTAMP,
  DT_FIM_PLANEJADA TIMESTAMP,
  DT_INI_REALIZADA TIMESTAMP,
  DT_FIM_REALIZADA TIMESTAMP,
  PERC_REALIZADO DOUBLE,
  ORIGEM_ACAO INT,
  STATUS_ACAO INT,
  STATUS_APROVACAO INT,
  DIAS_ANTECEDENCIA INT,
  EMAIL_ALERT INT,
  OBSERVACAO STRING,
  DT_UPD TIMESTAMP,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_AREA (
  tenant_slug STRING,
  ID INT,
  ID_PERIODO_GESTAO INT,
  ID_FILIAL INT,
  ID_RESPONSAVEL_AREA INT,
  ID_PARENT INT,
  ID_SOURCE INT,
  LEVEL_TREE STRING,
  COD_AREA STRING,
  DESC_AREA STRING,
  ATIVO INT,
  SCORE_AREA DOUBLE,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_AREA_HISTORY (
  tenant_slug STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  Id INT,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  Area_Id INT,
  Employee_Id INT,
  Score DECIMAL(28,8),
  StartDateRef TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  DESC_AVALIACAO STRING,
  DT_INI_AVALIACAO TIMESTAMP,
  DT_FIM_AVALIACAO TIMESTAMP,
  MENSAGEM_FORMULARIO STRING,
  ACESSAR_RESUMO_FORMULARIO INT,
  OCULTAR_COMENTARIO_FORMULARIO INT,
  COMENTARIO_NOTA_ABAIXO INT,
  VISUALIZAR_RESULTADO_PARCIAL INT,
  DT_CRIACAO_AVALIACAO TIMESTAMP,
  DT_SINCRONIZACAO_COLABORADOR TIMESTAMP,
  DT_FECHAMENTO_SINCRONIZACAO TIMESTAMP,
  DT_PROCESSAMENTO_SINCRONIZACAO TIMESTAMP,
  DT_FECHAMENTO_AVALIACAO TIMESTAMP,
  PROFICIENCIA_FORMULARIO_AVALIACAO INT,
  COMENTARIO_NOTA_ACIMA INT,
  HABILITAR_NOTA_CONSENSO INT,
  HABILITAR_NOTA_CONSENSO_NUMERICA INT,
  NOTA_EM_CAIXA_SELECAO INT,
  PDI_AUTO_AVALIACAO INT,
  PDI_CRIADO_PELO_LIDER INT,
  PDI_CRIADO_PELO_AVALIADO INT,
  CONSIDERACOES_FINAIS_OBRIGATORIO INT,
  PRECISAO_DECIMAL INT,
  FEEDBACK_MANUAL INT,
  OCULTAR_NOTA_REFERENCIA INT,
  HABILITAR_CONSENSO_SEM_AUTO INT,
  PERGUNTA_LIVRE_OBRIGATORIO INT,
  HABILITAR_CAMPO_COMENTARIO_LIDER INT,
  HABILITAR_GRAFICO_PDI INT,
  EXIBIR_NOTA_ORDEM_CRESCENTE INT,
  EDITAR_RESPOSTA_LIVRE_FEEDBACK INT,
  EXIBIR_NOTA_FINAL_CALCULADA INT,
  OCULTAR_NOTA_CALIBRAGEM INT,
  OCULTAR_VISAO_AVALIADO INT,
  ID_TIPO_AVALIACAO INT,
  OCULTAR_TIPO_COMPETENCIA INT,
  CONSOLIDADO_PERGUNTA_LIVRE_OBRIGATORIO INT,
  DESTACA_FAIXA_CLASSIFICACAO INT,
  REGRA_DE_CALCULO_1 INT,
  REGRA_DE_CALCULO_2 INT,
  OCULTAR_NOTA_FEEDBACK INT,
  ID_PERIODO_GESTAO INT,
  MES INT,
  OCULTAR_FUNCAO INT,
  OCULTAR_NOTA_CALCULADA INT,
  AREA_FORMULARIO_AVALIACAO INT,
  MATRICULA_FORMULARIO_AVALIACAO INT,
  LIDER_FORMULARIO_AVALIACAO INT,
  FUNCAO_FORMULARIO_AVALIACAO INT,
  FOTO_FORMULARIO_AVALIACAO INT,
  PROGRESSO_FORMULARIO_AVALIACAO INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_AVALIADO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_COLABORADOR_AVALIADO INT,
  ID_COLABORADOR_FUNCAO INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_AVALIADOR (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_AVALIADO INT,
  ID_COLABORADOR_AVALIADOR INT,
  TIPO_AVALIADOR INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_CALC_RESPOSTA (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_FORMULARIO_AVALIACAO INT,
  ID_AVALAIDO INT,
  ID_AVALIADOR INT,
  ID_FUNCAO INT,
  ID_RESPOSTA_AVALIACAO INT,
  PESO_FUNCAO_COMPETENCIA DOUBLE,
  NOTA_REFERENCIA DOUBLE,
  PERC_ALCANCE_REFERENCIA DOUBLE,
  NOTA_RESPOSTA DOUBLE,
  PERC_ALCANCE_RESPOSTA DOUBLE,
  NOTA_CONSENSO DOUBLE,
  PERC_ALCANCE_CONSENSO DOUBLE,
  NOTA_PONDERADA DOUBLE,
  PERC_PONDERADO DOUBLE,
  NOTA_CONSENSO_PONDERADA DOUBLE,
  PERC_CONSENSO_PONDERADO DOUBLE,
  NOTA_PONDERADA_NUMERIC DECIMAL(18,5),
  NOTA_CONSENSO_PONDERADA_NUMERIC DECIMAL(18,5),
  FEEDBACK_ENVIADO INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_CALC_RESULTADO_AVALIADOR (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_AVALIADO INT,
  ID_COLABORADOR_AVALIADO INT,
  ID_AVALIADOR INT,
  ID_COLABORADOR_AVALIADOR INT,
  NOTA_FINAL DOUBLE,
  NOTA_FINAL_NUMERIC DECIMAL(18,5),
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_CALC_RESULTADO_AVALIADOR_TIPO_COMPETENCIA (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_AVALIADO INT,
  ID_COLABORADOR_AVALIADO INT,
  ID_AVALIADOR INT,
  ID_COLABORADOR_AVALIADOR INT,
  TIPO_COMPETENCIA INT,
  NOTA_FINAL DOUBLE,
  NOTA_FINAL_NUMERIC DECIMAL(18,5),
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_CALC_RESULTADO_COLABORADOR (
  tenant_slug STRING,
  ID STRING,
  ID_AVALIACAO STRING,
  ID_AVALIADO STRING,
  ID_COLABORADOR_AVALIADO STRING,
  NOTA_FINAL STRING,
  NOTA_FINAL_DECIMAL STRING,
  OPERATION_TYPE STRING,
  ID_USER STRING,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_CALC_RESULTADO_COMPETENCIA (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_AVALIADO INT,
  ID_COLABORADOR_AVALIADO INT,
  ID_COMPETENCIA INT,
  NOTA_FINAL DOUBLE,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_CALC_RESULTADO_FATOR_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_AVALIADO INT,
  ID_COLABORADOR_AVALIADO INT,
  ID_FUNCAO_COMPETENCIA INT,
  ID_COMPETENCIA INT,
  ID_FATOR_AVALIACAO INT,
  NOTA_FINAL DOUBLE,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_CALC_RESULTADO_TIPO_AVALIADOR (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_AVALIADO INT,
  ID_COLABORADOR_AVALIADO INT,
  TIPO_AVALIADOR INT,
  NOTA_FINAL DOUBLE,
  NOTA_FINAL_NUMERIC DECIMAL(18,5),
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_CALC_RESULTADO_TIPO_AVALIADOR_TIPO_COMPETENCIA (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_AVALIADO INT,
  ID_COLABORADOR_AVALIADO INT,
  TIPO_AVALIADOR INT,
  TIPO_COMPETENCIA INT,
  NOTA_FINAL DOUBLE,
  NOTA_FINAL_NUMERIC DECIMAL(18,5),
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_CALIBRADOS_PERFORMANCE (
  tenant_slug STRING,
  ID STRING,
  NINE_BOX_ID STRING,
  ID_INSTANCIA STRING,
  ID_AVALIADO STRING,
  NOME STRING,
  NOTA_PERFORMANCE STRING,
  NOTA_COMPETENCIA STRING,
  CLASSIFICACAO STRING,
  NOVA_CLASSIFICACAO STRING,
  ID_COLABORADOR_AVALIADO STRING,
  ID_CLASSIFICACAO_DE STRING,
  ID_CLASSIFICACAO_PARA STRING,
  CLASSIFICACAO_COMPETENCIA STRING,
  NOVA_CLASSIFICACAO_COMPETENCIA STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_COLABORADOR (
  tenant_slug STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  ID INT,
  ID_GRUPO_USUARIO INT,
  ID_IDIOMA INT,
  USER_LOGIN STRING,
  NOME STRING,
  EMAIL STRING,
  WORKFLOW_ACOES INT,
  ATIVO INT,
  FOTO_PATH STRING,
  USUARIO_AD INT,
  TIPO_COLABORADOR INT,
  EXIBIR_TUTORIAL INT,
  Registration STRING,
  EXIBIR_TUTORIAL_DASH_PERFORMANCE INT,
  FCMToken STRING,
  AvailabilityRelocateStatus INT,
  SignatureConsentAgreement INT,
  Locality_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_COLABORADOR_AREA (
  tenant_slug STRING,
  ID INT,
  ID_COLABORADOR INT,
  ID_AREA INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_COLABORADOR_FUNCAO (
  tenant_slug STRING,
  ID INT,
  ID_COLABORADOR INT,
  ID_FUNCAO INT,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  FUNCAO_ATUAL INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  ID_AVALIACAO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_COMPETENCIA (
  tenant_slug STRING,
  ID INT,
  ID_BIBLIOTECA INT,
  TITULO_COMPETENCIA STRING,
  DESC_COMPETENCIA STRING,
  TIPO_COMPETENCIA INT,
  TIPO_TECNICA INT,
  TIPO_COMPORTAMENTAL INT,
  HABILITAR_FATOR_AVALIACAO INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  ORDENACAO INT,
  ATIVO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_CONSIDERACAO_FINAL (
  tenant_slug STRING,
  ID STRING,
  ID_FORMULARIO_AVALIACAO STRING,
  PONTOS_POSITIVOS STRING,
  PONTOS_DESENVOLVER STRING,
  COMENTARIO_FINAL STRING,
  COMENTARIO_LIDER STRING,
  COMENTARIO_AVALIADO STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  COMENTARIO_QUALIDADE STRING,
  NOTA_QUALIDADE INT,
  DATA_FEEDBACK TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_COTACAO_MOEDA (
  tenant_slug STRING,
  ID INT,
  ID_MOEDA_ORIGEM INT,
  ID_MOEDA_DESTINO INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_COTACAO_MOEDA_ITEM (
  tenant_slug STRING,
  ID INT,
  ID_COTACAO_MOEDA INT,
  DT_COTACAO TIMESTAMP,
  VALOR_PREVISTO DOUBLE,
  VALOR_FORECAST1 DOUBLE,
  VALOR_FORECAST2 DOUBLE,
  VALOR_REALIZADO DOUBLE,
  VALOR_ACUMULADO_PREVISTO DOUBLE,
  VALOR_ACUMULADO_FORECAST1 DOUBLE,
  VALOR_ACUMULADO_FORECAST2 DOUBLE,
  VALOR_ACUMULADO_REALIZADO DOUBLE,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_CURVA_PONTUACAO (
  tenant_slug STRING,
  ID INT,
  CRITERIO_PONTUACAO STRING,
  SIGNIFICADO_PONTUACAO STRING,
  NOTA_REFERENCIA INT,
  NOTA_PONTUACAO INT,
  PERC_ALCANCE DOUBLE,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_CURVA_PONTUACAO_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  CRITERIO_PONTUACAO STRING,
  SIGNIFICADO_PONTUACAO STRING,
  NOTA_REFERENCIA INT,
  NOTA_PONTUACAO INT,
  PERC_ALCANCE DOUBLE,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_CURVA_PREMIACAO (
  tenant_slug STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  ID INT,
  ID_PERIODO_GESTAO INT,
  ID_SOURCE INT,
  COD_CURVA_PREMIACAO STRING,
  DESC_CURVA_PREMIACAO STRING,
  TIPO_INTERPOLACAO INT,
  UseMinScoreInsteadOfZero INT,
  DefaultCurve INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_DIRETRIZ (
  tenant_slug STRING,
  ID INT,
  ID_PERIODO_GESTAO INT,
  COD_DIRETRIZ STRING,
  DESC_DIRETRIZ STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_EMPLOYEEACCESSGROUP (
  tenant_slug STRING,
  ID INT,
  Employee_Id INT,
  Module_Id INT,
  Type INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_FAIXA_CLASSIFICACAO (
  tenant_slug STRING,
  ID INT,
  DESCRICAO STRING,
  NOTA_DE DOUBLE,
  NOTA_ATE DOUBLE,
  PORCENTAGEM_CURVA_ESPERADA DOUBLE,
  NOTA_DE_NUMERIC DECIMAL(18,5),
  NOTA_ATE_NUMERIC DECIMAL(18,5),
  MESCLAR_COM_FAIXA INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_FAIXA_CLASSIFICACAO_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  DESCRICAO STRING,
  NOTA_DE DOUBLE,
  NOTA_ATE DOUBLE,
  PORCENTAGEM_CURVA_ESPERADA DOUBLE,
  NOTA_DE_NUMERIC DECIMAL(18,5),
  NOTA_ATE_NUMERIC DECIMAL(18,5),
  MESCLAR_COM_FAIXA INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_FAIXA_CLASSIFICACAO_PERFORMANCE (
  tenant_slug STRING,
  ID INT,
  DESCRICAO STRING,
  NOTA_DE DOUBLE,
  NOTA_ATE DOUBLE,
  PORCENTAGEM_CURVA_ESPERADA DOUBLE,
  MESCLAR_COM_FAIXA INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_FAIXA_CLASSIFICACAO_PERFORMANCE_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  DESCRICAO STRING,
  NOTA_DE DOUBLE,
  NOTA_ATE DOUBLE,
  PORCENTAGEM_CURVA_ESPERADA DOUBLE,
  MESCLAR_COM_FAIXA INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_FAIXA_FAROL (
  tenant_slug STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  ID INT,
  COD_FAIXA_FAROL STRING,
  DESC_FAIXA_FAROL STRING,
  COMPARADOR INT,
  DefaultForGoalsBookScore INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_FAIXA_FAROL_ITEM (
  tenant_slug STRING,
  ID INT,
  ID_FAIXA_FAROL INT,
  ID_FAROL INT,
  OPERADOR_MIM INT,
  VALOR_MIN DOUBLE,
  OPERADOR_MAX INT,
  VALOR_MAX DOUBLE,
  HABILITADO INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_FATOR_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  ID_COMPETENCIA INT,
  DETALHE_FATOR_AVALIACAO STRING,
  DESC_FATOR_AVALIACAO STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_FILIAL (
  tenant_slug STRING,
  ID INT,
  ID_IDIOMA INT,
  ID_MOEDA INT,
  COD_FILIAL STRING,
  DESC_FILIAL STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_FUNCAO (
  tenant_slug STRING,
  ID INT,
  COD_FUNCAO STRING,
  DESC_FUNCAO STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  ID_AVALIACAO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_FUNCAO_COMPETENCIA (
  tenant_slug STRING,
  ID INT,
  ID_FUNCAO INT,
  ID_COMPETENCIA INT,
  ID_FATOR_AVALIACAO INT,
  PROFICIENCIA INT,
  EXPERIENCIA_ANO INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  AUTO DOUBLE,
  LIDER DOUBLE,
  PAR DOUBLE,
  TIME DOUBLE,
  COMITE DOUBLE,
  CLIENTE DOUBLE,
  FORNECEDOR DOUBLE,
  PESO_GERAL_POR_FATOR DECIMAL(18,5),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_FUNCAO_PERGUNTA_LIVRE (
  tenant_slug STRING,
  ID INT,
  ID_FUNCAO INT,
  PERGUNTA_LIVRE STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  ORDENACAO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_GRANDEZA (
  tenant_slug STRING,
  ID INT,
  DESC_GRANDEZA STRING,
  TIPO_CONVERSAO INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_GRUPO_INDICADOR (
  tenant_slug STRING,
  ID INT,
  ID_GRANDEZA INT,
  ID_DIRETRIZ INT,
  DESC_GRUPO_INDICADOR STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_HISTORICO_CARGO (
  tenant_slug STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  ID INT,
  ID_CARGO INT,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  SALARIO DOUBLE,
  ID_COLABORADOR INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_HISTORICO_PDI (
  tenant_slug STRING,
  ID INT,
  ID_PDI INT,
  ID_COLABORADOR INT,
  OBSERVACAO STRING,
  DT_CRIACAO TIMESTAMP,
  DT_INI_PLANEJADA TIMESTAMP,
  DT_FIM_PLANEJADA TIMESTAMP,
  DT_INI_REALIZADA TIMESTAMP,
  DT_FIM_REALIZADA TIMESTAMP,
  PROGRESSO INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_INDICADOR (
  tenant_slug STRING,
  ID INT,
  ID_UNIDADE_MEDIDA INT,
  ID_FREQUENCIA_ACOMP INT,
  ID_FAIXA_FAROL INT,
  COD_INDICADOR STRING,
  DESC_INDICADOR STRING,
  MEMORIA_CALCULO STRING,
  POLARIDADE INT,
  ATIVO INT,
  AlertDataProviderDay INT,
  AlertDataProviderAdvance INT,
  AlertDataProviderFreq INT,
  EnableEditionAlertDataProvider INT,
  AlertStakeholderDay INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_INSTANCIA (
  tenant_slug STRING,
  ID INT,
  ID_NINE_BOX INT,
  ID_NINE_BOX_CALIBRADOS INT,
  DT_CRIACAO TIMESTAMP,
  DESCRICAO STRING,
  DT_INICIO_INSTANCIA TIMESTAMP,
  DT_FIM_INSTANCIA TIMESTAMP,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_INSTANCIA_CALIBRADOS (
  tenant_slug STRING,
  ID INT,
  COLABORADOR_ID INT,
  INSTANCIA_ID INT,
  ID_FAIXA_CLASSIFICACAO_DE INT,
  ID_FAIXA_CLASSIFICACAO_PARA INT,
  JUSTIFICATIVA STRING,
  OBSERVACAO STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_INSTANCIA_CALIBRADOS_PERFORMANCE (
  tenant_slug STRING,
  ID INT,
  COLABORADOR_ID INT,
  INSTANCIA_ID INT,
  ID_FAIXA_CLASSIFICACAO_PERFORMANCE_DE INT,
  ID_FAIXA_CLASSIFICACAO_PERFORMANCE_PARA INT,
  JUSTIFICATIVA STRING,
  OBSERVACAO STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_INSTANCIA_COMITE (
  tenant_slug STRING,
  ID INT,
  INSTANCIA_ID INT,
  COLABORADOR_ID INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_MARCADOR_ACAO (
  tenant_slug STRING,
  ID INT,
  TAG STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_META (
  tenant_slug STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  ID INT,
  ID_PERIODO_GESTAO INT,
  ID_AREA INT,
  ID_INDICADOR INT,
  ID_RESPONSAVEL_META INT,
  ID_DATA_PROVIDER INT,
  ID_DIRETRIZ INT,
  ID_CURVA_PREMIACAO INT,
  ID_SOURCE INT,
  COD_META STRING,
  OBJETIVO STRING,
  FONTE_DADOS STRING,
  MEMORIA_CALCULO STRING,
  PESO_META DOUBLE,
  SCORE_META DOUBLE,
  SCORE_PONDERADO DOUBLE,
  VALOR_META DOUBLE,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  TIPO_META INT,
  TIPO_ACUMULACAO INT,
  TIPO_VALOR_META INT,
  STATUS_VALIDACAO INT,
  LOCK_FORECAST INT,
  META_QUALIFICADORA INT,
  PASSO_VALIDACAO INT,
  EnableGoalAudit INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_NINE_BOX (
  tenant_slug STRING,
  ID INT,
  DESCRICAO STRING,
  DT_CRIACAO TIMESTAMP,
  ATIVO INT,
  ID_AVALIACAO INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_NINE_BOX_CALIBRADOS (
  tenant_slug STRING,
  ID INT,
  ID_NINE_BOX INT,
  ID_COLABORADOR INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_NOTA_META (
  tenant_slug STRING,
  ID INT,
  ID_META INT,
  ID_NOTA INT,
  PERC_NOTA DOUBLE,
  VALOR_NOTA DOUBLE,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_PDI (
  tenant_slug STRING,
  ID INT,
  ID_FORMULARIO_AVALIACAO INT,
  ID_COMPETENCIA INT,
  OQUE STRING,
  DT_INI_PLANEJADA TIMESTAMP,
  DT_FIM_PLANEJADA TIMESTAMP,
  DT_INI_REALIZADA TIMESTAMP,
  DT_FIM_REALIZADA TIMESTAMP,
  DT_CRIACAO_PDI TIMESTAMP,
  OBSERVACAO STRING,
  ID_FATOR_AVALIACAO INT,
  STATUS_APROVACAO INT,
  ID_AVALIACAO INT,
  PROGRESSO DOUBLE,
  ORIGEM INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_PERIODO_APURACAO (
  tenant_slug STRING,
  ID INT,
  ID_PERIODO_GESTAO INT,
  DESC_PERIODO_APURACAO STRING,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  STATUS_PERIODO_APURACAO INT,
  TIPO_RV INT,
  ID_CICLO_AVALIACAO INT,
  EXTRACT_AUTO_RELEASE INT,
  TYPE_DISPLAY_MODIFIERS INT,
  JobPositionHistoryCalculation INT,
  AreaHistoryCalculation INT,
  HistoryCalculationAppliedIn INT,
  DECIMAL_PRECISION INT,
  ModifiersLimit DECIMAL(28,8),
  DateProportionalityType INT,
  Options STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_PERIODO_GESTAO (
  tenant_slug STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  ID INT,
  DESC_PERIODO_GESTAO STRING,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  STATUS INT,
  STATUS_PLANEJAMENTO INT,
  QTE_MESES INT,
  PRECISAO_DECIMAL_SCORE INT,
  ALTERAR_VALOR_HISTORICO INT,
  HABILITAR_TERMO_ACEITE INT,
  CONSIDERAR_META_NA_SCORE INT,
  ACAO_DIAS_RETROATIVOS INT,
  EnableGoalAudit INT,
  OPCAO_CARREGAMENTO_FILTRO INT,
  ScoreRef INT,
  AlertDataProviderDay INT,
  AlertDataProviderFreq INT,
  GoalAuditType INT,
  HABILITAR_COMPARTILHAMENTO_ROTULOS INT,
  GoalNotReachedTrackingPonctual INT,
  GoalNotReachedTrackingAccumulated INT,
  GoalNotReachedMinMonthsTracking INT,
  GoalNotReachedSendingMailFrequency INT,
  GoalActionsCalcType INT,
  TIPO_META_HABILITADO STRING,
  PERMITIR_NOTA_DIFERENTE_CEM_PORCENTO INT,
  EnableEditionAlertDataProviderInKpi INT,
  AlertDataProviderAdvance INT,
  GoalAuditFrequency INT,
  GoalAuditRequiredAttach INT,
  EnableValidationByWeight INT,
  TrafficLightApplication INT,
  DeviationTreatmentStep INT,
  DeviationExhibitionOption INT,
  DayLimitToChangeValues INT,
  ZeroScoreOfGoalsWithPendencies INT,
  EnableQualifierGoal INT,
  EnableUpperGoal INT,
  EnableForecast INT,
  ProjectGoalCalculationOption INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_PSW_COLABORADOR (
  tenant_slug STRING,
  ID_COLABORADOR INT,
  CREATE_DATE TIMESTAMP,
  LAST_UPD TIMESTAMP,
  EXPIRED INT,
  ATTEMPTS INT,
  CURRENT_PSW STRING,
  PRIVATE_CURRENT_PSW BINARY,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_QUADRANTES_MATRIZ_TALENTOS (
  tenant_slug STRING,
  ID INT,
  ID_NINE_BOX INT,
  NOME_QUADRANTE STRING,
  ID_FAIXA_CLASSIFICACAO_COMPETENCIA INT,
  ID_FAIXA_CLASSIFICACAO_PERFORMANCE INT,
  MESCLADO_COM INT,
  COR_FUNDO STRING,
  COR_TITULO STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_RESPOSTA_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  ID_FORMULARIO_AVALIACAO INT,
  ID_FUNCAO_COMPETENCIA INT,
  ID_NOTA_RESPOSTA INT,
  ID_NOTA_CONSENSO INT,
  COMENTARIO_RESPOSTA STRING,
  DT_RESPOSTA TIMESTAMP,
  DT_RESPOSTA_CONSENSO TIMESTAMP,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_RESPOSTA_LIVRE_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  ID_FORMULARIO_AVALIACAO INT,
  ID_FUNCAO_PERGUNTA_LIVRE INT,
  RESPOSTA_LIVRE STRING,
  DT_RESPOSTA TIMESTAMP,
  RESPOSTA_CONSOLIDADO STRING,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_SYSTEM_CONFIG (
  tenant_slug STRING,
  CLIENT_NAME STRING,
  CLIENT_URL STRING,
  SYSTEM_VERSION STRING,
  PSW_TRY INT,
  PSW_UPPER INT,
  PSW_LOWER INT,
  PSW_NUMBER INT,
  PSW_ESPECIAL_CHAR INT,
  PSW_MIN_LENGTH INT,
  PSW_DAYS INT,
  PSW_REUSABLE INT,
  LIMIT_TREE_AREA INT,
  LIMIT_TREE_ENTIDADE INT,
  LIMIT_TREE_GRUPO_CONTA INT,
  MAIN_PAGE STRING,
  TIPO_COTACAO INT,
  FORECAST1_LABEL STRING,
  FORECAST2_LABEL STRING,
  ACCESS_GROUP_ADMIN_MANAGEMENT INT,
  ID INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  ClientOptions STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_TERMO_ACEITE_ASSINATURA (
  tenant_slug STRING,
  ID INT,
  ID_TERMO_ACEITE INT,
  ID_AREA_COLABORADOR INT,
  ID_COLABORADOR INT,
  ASSINATURA_COLABORADOR INT,
  DATA_ASSINATURA_COLABORADOR TIMESTAMP,
  ID_RESPONSAVEL_AREA INT,
  ASSINATURA_RESPONSAVEL_AREA INT,
  DATA_ASSINATURA_RESPONSAVEL_AREA TIMESTAMP,
  TIPO_ASSINATURA_COLABORADOR INT,
  TIPO_ASSINATURA_RESPONSAVEL_AREA INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_TIPO_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  DESCRICAO STRING,
  ATIVO INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_UNIDADE_MEDIDA (
  tenant_slug STRING,
  ID INT,
  ID_GRANDEZA INT,
  ID_MOEDA_CONVERSAO INT,
  COD_UNIDADE_MEDIDA STRING,
  DESC_UNIDADE_MEDIDA STRING,
  SIMBOLO STRING,
  PRECISAO_DECIMAL INT,
  FATOR_CONVERSAO DOUBLE,
  REFERENCIA INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AUDIT_VALOR_META (
  tenant_slug STRING,
  ID INT,
  ID_META INT,
  DT_REF TIMESTAMP,
  PONTUAL_PREVISTO DOUBLE,
  PONTUAL_FORECAST1 DOUBLE,
  PONTUAL_FORECAST2 DOUBLE,
  PONTUAL_REALIZADO DOUBLE,
  ACUM_PREVISTO DOUBLE,
  ACUM_FORECAST1 DOUBLE,
  ACUM_FORECAST2 DOUBLE,
  ACUM_REALIZADO DOUBLE,
  NA INT,
  NA_PREVISTO INT,
  NA_REALIZADO INT,
  NA_FORECAST1 INT,
  NA_FORECAST2 INT,
  NA_ACUM_PREVISTO INT,
  NA_ACUM_REALIZADO INT,
  NA_ACUM_FORECAST1 INT,
  NA_ACUM_FORECAST2 INT,
  OPERATION_TYPE STRING,
  ID_USER INT,
  DT_LOG TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AbpEntityChangeSets (
  tenant_slug STRING,
  Id BIGINT,
  BrowserInfo STRING,
  ClientIpAddress STRING,
  ClientName STRING,
  CreationTime TIMESTAMP,
  ExtensionData STRING,
  ImpersonatorTenantId INT,
  ImpersonatorUserId BIGINT,
  Reason STRING,
  TenantId INT,
  UserId BIGINT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: EntityChangeSetId -> raw.dbo__AbpEntityChangeSets.Id
CREATE TABLE IF NOT EXISTS raw.dbo__AbpEntityChanges (
  tenant_slug STRING,
  Id BIGINT,
  ChangeTime TIMESTAMP,
  ChangeType INT,
  EntityChangeSetId BIGINT,
  EntityId STRING,
  EntityTypeFullName STRING,
  TenantId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: EntityChangeId -> raw.dbo__AbpEntityChanges.Id
CREATE TABLE IF NOT EXISTS raw.dbo__AbpEntityPropertyChanges (
  tenant_slug STRING,
  Id BIGINT,
  EntityChangeId BIGINT,
  NewValue STRING,
  OriginalValue STRING,
  PropertyName STRING,
  PropertyTypeFullName STRING,
  TenantId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AbpSettings (
  tenant_slug STRING,
  Id BIGINT,
  TenantId INT,
  UserId BIGINT,
  Name STRING,
  Value STRING,
  LastModificationTime TIMESTAMP,
  LastModifierUserId BIGINT,
  CreationTime TIMESTAMP,
  CreatorUserId BIGINT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: Functionality_Id -> raw.dbo__FUNCIONALIDADE.ID
CREATE TABLE IF NOT EXISTS raw.dbo__Addon (
  tenant_slug STRING,
  Id INT,
  Code STRING,
  Description STRING,
  Enabled INT,
  Href STRING,
  Icon STRING,
  Tag STRING,
  Functionality_Id STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AdminPasswordResetToken (
  tenant_slug STRING,
  Id INT,
  Ip STRING,
  TargetEmployeeId INT,
  CreatedByAdminId INT,
  GeneratedAt TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: UserId -> raw.dbo__AspNetUsers.Id
CREATE TABLE IF NOT EXISTS raw.dbo__AspNetPreviousPassword (
  tenant_slug STRING,
  PasswordHash STRING,
  UserId INT,
  CreateDate TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, PasswordHash, UserId)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AspNetRoles (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AspNetUserClaims (
  tenant_slug STRING,
  Id INT,
  UserId INT,
  ClaimType STRING,
  ClaimValue STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AspNetUserLogins (
  tenant_slug STRING,
  LoginProvider STRING,
  ProviderKey STRING,
  UserId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, LoginProvider, ProviderKey, UserId)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__AspNetUserRoles (
  tenant_slug STRING,
  UserId INT,
  RoleId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, UserId, RoleId)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__AspNetUsers (
  tenant_slug STRING,
  Id INT,
  UserName STRING,
  Email STRING,
  EmailConfirmed INT,
  PasswordHash STRING,
  SecurityStamp STRING,
  PhoneNumber STRING,
  PhoneNumberConfirmed INT,
  TwoFactorEnabled INT,
  LockoutEndDateUtc TIMESTAMP,
  LockoutEnabled INT,
  AccessFailedCount INT,
  IsGoogleAuthenticatorEnabled INT,
  GoogleAuthenticatorSecretKey STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: UserId -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__BackgroundJobManagement (
  tenant_slug STRING,
  Id INT,
  Process STRING,
  StatusLog INT,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  LastUpdate TIMESTAMP,
  UserId INT,
  UserLogin STRING,
  Msg STRING,
  PercentProgress INT,
  AttemptCount INT,
  IdentifierRequest STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: PaymentGroup_Id -> raw.dbo__GRUPO_PAGTO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__CustomMessages (
  tenant_slug STRING,
  Id INT,
  Message STRING,
  Type INT,
  PaymentGroup_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: InitialDashboardLayoutId -> raw.dbo__InitialDashboardLayout.Id
CREATE TABLE IF NOT EXISTS raw.dbo__DashboardLayoutMatrix (
  tenant_slug STRING,
  Id INT,
  InitialDashboardCardType INT,
  Name STRING,
  Row INT,
  Column INT,
  InitialDashboardLayoutId INT,
  Settings STRING,
  InternationalDescription STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_GRUPO_FUNCIONALIDADE -> raw.dbo__GRUPO_FUNCIONALIDADE.ID
-- @fk: ID_MENU -> raw.dbo__MENU.ID_PK
-- @fk: SidebarItem_Id -> raw.dbo__SidebarItem.Id
CREATE TABLE IF NOT EXISTS raw.dbo__FUNCIONALIDADE (
  tenant_slug STRING,
  ID STRING,
  ID_GRUPO_FUNCIONALIDADE INT,
  DESC_FUNCIONALIDADE STRING,
  ORDEM_EXIBICAO INT,
  ID_MENU INT,
  SidebarItem_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_ACAO (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_ACAO INT,
  ID_META INT,
  ID_CRIADOR_ACAO INT,
  ID_RESPONSAVEL_ACAO INT,
  ID_CONTRAMEDIDA INT,
  ID_CAUSA INT,
  COD_ACAO STRING,
  OQUE STRING,
  COMO STRING,
  PORQUE STRING,
  ONDE STRING,
  JUSTIFICATIVA_CANCELAMENTO STRING,
  INVESTIMENTO DOUBLE,
  RETORNO DOUBLE,
  DT_CRIACAO_ACAO TIMESTAMP,
  DT_INI_PLANEJADA TIMESTAMP,
  DT_FIM_PLANEJADA TIMESTAMP,
  DT_INI_REALIZADA TIMESTAMP,
  DT_FIM_REALIZADA TIMESTAMP,
  ORIGEM_ACAO INT,
  STATUS_ACAO INT,
  STATUS_APROVACAO INT,
  DIAS_ANTECEDENCIA INT,
  EMAIL_ALERT INT,
  OBSERVACAO STRING,
  DT_REF_CONTRAMEDIDA TIMESTAMP,
  ID_INDICADOR INT,
  ID_CRIADOR_CAUSA INT,
  COD_CAUSA STRING,
  DESC_CAUSA STRING,
  SUB_CAUSA1 STRING,
  SUB_CAUSA2 STRING,
  SUB_CAUSA3 STRING,
  SUB_CAUSA4 STRING,
  SUB_CAUSA5 STRING,
  GESTAO_CONHECIMENTO_ATIVO INT,
  SELECIONADA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_AREA (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_AREA INT,
  ID_PERIODO_GESTAO INT,
  ID_FILIAL INT,
  ID_PARENT INT,
  COD_AREA STRING,
  DESC_AREA STRING,
  COD_PARENT STRING,
  ATIVO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_CALCULO_MANUAL_PERFORMANCE (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_CALCULO_MANUAL_PERFORMANCE INT,
  ID_COLABORADOR INT,
  SCORE DECIMAL(28,8),
  DATA_REFERENCIA TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_CARGO (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_CARGO INT,
  ID_NIVEL INT,
  ID_PERIODO_APURACAO INT,
  DESC_CARGO STRING,
  COD_CARGO STRING,
  ID_GRUPO_CARGO INT,
  DESC_GRUPO_CARGO STRING,
  COD_GRUPO_CARGO STRING,
  IsCriticalJob INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_CAUSA (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_CAUSA INT,
  ID_INDICADOR INT,
  ID_META INT,
  ID_CONTRAMEDIDA INT,
  ID_CRIADOR_CAUSA INT,
  COD_CAUSA STRING,
  DT_REF TIMESTAMP,
  DESC_CAUSA STRING,
  SUB_CAUSA1 STRING,
  SUB_CAUSA2 STRING,
  SUB_CAUSA3 STRING,
  SUB_CAUSA4 STRING,
  SUB_CAUSA5 STRING,
  GESTAO_CONHECIMENTO_ATIVO INT,
  SELECIONADA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_COLABORADOR (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_COLABORADOR INT,
  ID_PERIODO_GESTAO INT,
  ID_AREA INT,
  ID_GRUPO_USUARIO INT,
  ID_IDIOMA INT,
  USER_LOGIN STRING,
  NOME STRING,
  EMAIL STRING,
  WORKFLOW_ACOES INT,
  ATIVO INT,
  USUARIO_AD INT,
  SignatureConsentAgreement INT,
  LocalityId INT,
  LocalityDescription STRING,
  REGISTRATION STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_COLABORADOR_FUNCAO (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_COLABORADOR_FUNCAO INT,
  ID_COLABORADOR INT,
  ID_FUNCAO INT,
  USER_LOGIN STRING,
  COD_FUNCAO STRING,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_COTACAO_MOEDA (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_COTACAO_MOEDA_ITEM INT,
  ID_COTACAO_MOEDA INT,
  DT_COTACAO TIMESTAMP,
  VALOR_PREVISTO DOUBLE,
  VALOR_FORECAST1 DOUBLE,
  VALOR_FORECAST2 DOUBLE,
  VALOR_REALIZADO DOUBLE,
  ID_MOEDA_ORIGEM INT,
  ID_MOEDA_DESTINO INT,
  VALOR_ACUMULADO_PREVISTO DOUBLE,
  VALOR_ACUMULADO_FORECAST1 DOUBLE,
  VALOR_ACUMULADO_FORECAST2 DOUBLE,
  VALOR_ACUMULADO_REALIZADO DOUBLE,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_EMPLOYEEMODIFIERVALUE (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_EMPLOYEE_MODIFIER_VALUE INT,
  ID_EMPLOYEE INT,
  ID_MODIFIER INT,
  VALUE DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_EMPLOYEE_ACCESS_GROUP (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_EMPLOYE_ACCESS_GROUP INT,
  EMPLOYEE_ID INT,
  MODULE_ID INT,
  TYPE INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_EXPRESSAO_CALCULO_META (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  ID_EXPRESSAO_CALCULO_META INT,
  ID_META INT,
  ID_META_REF INT,
  ID_GRUPO_CONTA_REF INT,
  ID_ENTIDADE_REF INT,
  TIPO_PROCESSO_REF INT,
  TIPO_MATRIZ_REF INT,
  VALOR_REF DOUBLE,
  PESO_META_REF DECIMAL(28,8),
  OPERADOR INT,
  DESC_EXPRESSAO STRING,
  ORDEM INT,
  COD_META STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_FORECAST (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_VALOR_META INT,
  ID_META INT,
  NUM_FORECAST INT,
  DT_REF TIMESTAMP,
  PONTUAL_FORECAST1 DOUBLE,
  PONTUAL_FORECAST2 DOUBLE,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_HISTORICO_AREA (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_HISTORICO_AREA INT,
  ID_COLABORADOR INT,
  ID_AREA INT,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  NOTA_AREA DOUBLE,
  ULTIMO_HISTORICO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_HISTORICO_CARGO (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_HISTORICO_CARGO INT,
  ID_PARTICIPANTE_RV INT,
  ID_CARGO INT,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  SALARIO DOUBLE,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_INDICADOR (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_INDICADOR INT,
  ID_UNIDADE_MEDIDA INT,
  ID_FREQUENCIA_ACOMP INT,
  ID_FAIXA_FAROL INT,
  COD_INDICADOR STRING,
  DESC_INDICADOR STRING,
  MEMORIA_CALCULO STRING,
  POLARIDADE INT,
  ATIVO INT,
  AlertDataProviderDay INT,
  AlertDataProviderAdvance INT,
  AlertDataProviderFreq INT,
  EnableEditionAlertDataProvider INT,
  AlertStakeholderDay INT,
  StakeholdersListIds STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_JOB_POSITION_LEVEL (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  JOBPOSITION_ID INT,
  LEVEL_ID INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_LEVEL (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  LEVEL_ID INT,
  LEVEL_CODE STRING,
  LEVEL_DESCRIPTION STRING,
  PAYMENTGROUP_ID INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_LIDER_AVALIADO (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  USER_LOGIN_AVALIADO STRING,
  ID_COLABORADOR_AVALIADO INT,
  ID_AVALIADO INT,
  USER_LOGIN_AVALIADOR STRING,
  ID_COLABORADOR_AVALIADOR INT,
  ID_AVALIADOR INT,
  TIPO_AVALIADOR INT,
  ID_FUNCAO INT,
  COD_FUNCAO STRING,
  ID_AVALIACAO INT,
  DESC_AVALIACAO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_MARCADOR_ACAO_ITEM (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  ID_MARCADOR_ACAO INT,
  COD_ACAO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_META (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_META INT,
  ID_PERIODO_GESTAO INT,
  ID_AREA INT,
  ID_INDICADOR INT,
  ID_RESPONSAVEL_META INT,
  ID_DATA_PROVIDER INT,
  ID_DIRETRIZ INT,
  ID_CURVA_PREMIACAO INT,
  COD_META STRING,
  OBJETIVO STRING,
  FONTE_DADOS STRING,
  MEMORIA_CALCULO STRING,
  PESO_META DOUBLE,
  VALOR_META DOUBLE,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  TIPO_META INT,
  TIPO_ACUMULACAO INT,
  TIPO_VALOR_META INT,
  STATUS_VALIDACAO INT,
  ID_META_COMPARTILHADA INT,
  COD_META_COMPARTILHADA STRING,
  IS_EMPTY_TAG INT,
  IS_EMPTY_UPPERGOALS INT,
  META_QUALIFICADORA INT,
  TIPO_IMPACTO_META_QUALIFICADORA INT,
  PASSO_VALIDACAO INT,
  EnableGoalAudit INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_MUDA_RESPONSAVEL_AREA (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_COLABORADOR INT,
  ID_PERIODO_GESTAO INT,
  ID_AREA_RESP INT,
  USUARIO_AD INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_NOTA_META (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_NOTA_META INT,
  ID_META INT,
  ID_NOTA INT,
  PERC_NOTA DOUBLE,
  VALOR_NOTA DOUBLE,
  TIPO_VALOR INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_PARTICIPANTE_RV (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_PARTICIPANTE_RV INT,
  ID_PERIODO_APURACAO INT,
  ID_COLABORADOR INT,
  ELEGIVEL_RV INT,
  DT_ADMISSAO DATE,
  DT_DEMISSAO DATE,
  SALARIO DOUBLE,
  MULTIPLO_RV_FINAL DOUBLE,
  VALOR_RV_FINAL DOUBLE,
  DISCRICIONARIO DOUBLE,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_PERFIL_AREA (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_COLABORADOR INT,
  ID_AREA INT,
  VISUALIZAR INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_RESPONSAVEL_AREA (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  USER_LOGIN STRING,
  ID_AREA INT,
  ID_COLABORADOR INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_RESPONSAVEL_AREA_DEL (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  USER_LOGIN STRING,
  ID_AREA INT,
  ID_COLABORADOR INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_UPPER_GOAL (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  ID_META_SUPERIOR INT,
  COD_META STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID_LOG_IMP, ID_META_SUPERIOR, COD_META)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMP_VALOR_META (
  tenant_slug STRING,
  ID_LOG_IMP INT,
  LINE INT,
  ID_VALOR_META INT,
  ID_META INT,
  DT_REF TIMESTAMP,
  PONTUAL_PREVISTO DOUBLE,
  PONTUAL_FORECAST1 DOUBLE,
  PONTUAL_FORECAST2 DOUBLE,
  PONTUAL_REALIZADO DOUBLE,
  ACUM_PREVISTO DOUBLE,
  ACUM_FORECAST1 DOUBLE,
  ACUM_FORECAST2 DOUBLE,
  ACUM_REALIZADO DOUBLE,
  NA INT,
  NA_PREVISTO INT,
  NA_REALIZADO INT,
  NA_FORECAST1 INT,
  NA_FORECAST2 INT,
  NA_ACUM_PREVISTO INT,
  NA_ACUM_REALIZADO INT,
  NA_ACUM_FORECAST1 INT,
  NA_ACUM_FORECAST2 INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__Identity (
  tenant_slug STRING,
  Id INT,
  Naturalness INT,
  Nationality INT,
  Gender INT,
  BirthDate TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: Attachment_Id -> raw.dbo__ImagePanelImagesAttachment.Id
CREATE TABLE IF NOT EXISTS raw.dbo__ImagePanelImages (
  tenant_slug STRING,
  Id INT,
  ImagePath STRING,
  Attachment_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__ImagePanelImagesAttachment (
  tenant_slug STRING,
  Id INT,
  FileName STRING,
  Key STRING,
  UploadDate TIMESTAMP,
  ContentType STRING,
  ContentLength INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: Employee_Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ImportLog (
  tenant_slug STRING,
  Id INT,
  InputFile STRING,
  Employee_Id INT,
  Message STRING,
  Type INT,
  Status INT,
  Step INT,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  IsDeleted INT,
  OutputFile STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ImportLog_Id -> raw.dbo__ImportLog.Id
CREATE TABLE IF NOT EXISTS raw.dbo__ImportLogError (
  tenant_slug STRING,
  Id INT,
  Line INT,
  Error STRING,
  ImportLog_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__InitialDashboardLayout (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  LayoutType INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__Item (
  tenant_slug STRING,
  Id INT,
  Nome STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__LOG_DATA_EXTRACT (
  tenant_slug STRING,
  ID INT,
  TIPO_DATA_EXTRACT INT,
  STATUS_LOG INT,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  USER_LOG STRING,
  MSG STRING,
  ATIVO INT,
  FILE_NAME STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_DATA_EXTRACT -> raw.dbo__LOG_DATA_EXTRACT.ID
CREATE TABLE IF NOT EXISTS raw.dbo__LOG_DATA_EXTRACT_ITEM (
  tenant_slug STRING,
  ID INT,
  ID_LOG_DATA_EXTRACT INT,
  MSG STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__LOG_EMAIL (
  tenant_slug STRING,
  ID INT,
  ID_COLABORADOR INT,
  EMAIL STRING,
  TIPO_ENVIO INT,
  DT_ENVIO TIMESTAMP,
  SUCESSO INT,
  MENSAGEM_ERRO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__LOG_EMAIL_ACAO_VENCER (
  tenant_slug STRING,
  ID_ACAO INT,
  DT_ENVIO TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__LOG_IMP (
  tenant_slug STRING,
  ID INT,
  TIPO_IMPORT INT,
  STATUS INT,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  USER_LOG STRING,
  MSG STRING,
  ATIVO INT,
  ITEMS_COUNT INT,
  FILE_KEY STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_IMP -> raw.dbo__LOG_IMP.ID
CREATE TABLE IF NOT EXISTS raw.dbo__LOG_IMP_ITEM (
  tenant_slug STRING,
  ID INT,
  ID_LOG_IMP INT,
  LINE INT,
  MSG STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__LOG_LOGIN (
  tenant_slug STRING,
  ID_COLABORADOR INT,
  ID_PERIODO_GESTAO INT,
  DT_LOGIN TIMESTAMP,
  USER_LOG STRING,
  STATUS_LOGIN INT,
  TRY_PSW STRING,
  USER_HOST_ADDRESS STRING,
  USER_BROWSER INT,
  USER_OS INT,
  Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__LOG_TASK (
  tenant_slug STRING,
  ID INT,
  TIPO_TASK INT,
  STATUS_LOG INT,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  USER_LOG STRING,
  MSG STRING,
  ATIVO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_LOG_TASK -> raw.dbo__LOG_TASK.ID
CREATE TABLE IF NOT EXISTS raw.dbo__LOG_TASK_ITEM (
  tenant_slug STRING,
  ID INT,
  ID_LOG_TASK INT,
  MSG STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__MENU (
  tenant_slug STRING,
  ID STRING,
  DESC_MENU STRING,
  PAGINA STRING,
  ATIVO INT,
  ORDEM_EXIBICAO INT,
  PARENT_ID INT,
  ID_PK INT,
  ICON STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID_PK)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__Modules (
  tenant_slug STRING,
  Id INT,
  Code STRING,
  Description STRING,
  Enabled INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ID_CURVA_PREMIACAO -> raw.dbo__CURVA_PREMIACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__NOTA (
  tenant_slug STRING,
  ID INT,
  ID_CURVA_PREMIACAO INT,
  NUM_NOTA DOUBLE,
  NOTA_META INT,
  OBRIGATORIA INT,
  Concept STRING,
  PercentageBetterToUp DECIMAL(28,8),
  PercentageBetterToDown DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: OwnerId -> raw.dbo__COLABORADOR.ID
-- @fk: ThemeId -> raw.dbo__Theme.Id
CREATE TABLE IF NOT EXISTS raw.dbo__PresentationTemplate (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  OwnerId INT,
  ThemeId INT,
  CurrentTemplate INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: PresentationTemplateId -> raw.dbo__PresentationTemplate.Id
CREATE TABLE IF NOT EXISTS raw.dbo__PresentationTemplateHistory (
  tenant_slug STRING,
  Id INT,
  EmployeeId INT,
  PresentationTemplateId INT,
  UpdateDate TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: PresentationTemplateId -> raw.dbo__PresentationTemplate.Id
CREATE TABLE IF NOT EXISTS raw.dbo__PresentationTemplateShare (
  tenant_slug STRING,
  Id INT,
  PresentationTemplateId INT,
  EmployeeId INT,
  PermissionType INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: PresentationTemplateId -> raw.dbo__PresentationTemplate.Id
CREATE TABLE IF NOT EXISTS raw.dbo__PresentationTemplateSlide (
  tenant_slug STRING,
  Id INT,
  PresentationTemplateId INT,
  SlideTitle STRING,
  ModuleId INT,
  FeatureId INT,
  SlideOrder INT,
  Filters STRING,
  BasicSlide INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: PresentationTemplateId -> raw.dbo__PresentationTemplate.Id
CREATE TABLE IF NOT EXISTS raw.dbo__PresentationTemplateVersion (
  tenant_slug STRING,
  Id INT,
  PresentationTemplateId INT,
  EmployeeId INT,
  VersionName STRING,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  Status INT,
  CreatedOn TIMESTAMP,
  Filename STRING,
  Key STRING,
  ContentType STRING,
  ContentLength INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__SQL_TRACE (
  tenant_slug STRING,
  ID INT,
  DT_INI TIMESTAMP,
  TEXTO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: ModuleId -> raw.dbo__Modules.Id
-- @fk: ParentId -> raw.dbo__SidebarItem.Id
CREATE TABLE IF NOT EXISTS raw.dbo__SidebarItem (
  tenant_slug STRING,
  Id INT,
  ModuleId INT,
  Code STRING,
  Description STRING,
  Url STRING,
  Status INT,
  ExibitionOrder INT,
  Icon STRING,
  ParentId INT,
  Tag STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: SidebarItemId -> raw.dbo__SidebarItem.Id
CREATE TABLE IF NOT EXISTS raw.dbo__SidebarItemFavorite (
  tenant_slug STRING,
  Id INT,
  SidebarItemId INT,
  EmployeeId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
-- @fk: Employee_Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__TaskLog (
  tenant_slug STRING,
  Id INT,
  Type INT,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  Status INT,
  Step INT,
  Message STRING,
  Active INT,
  Employee_Id INT,
  JobId STRING,
  ExecutionAttemptCount INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__VW_AUDIT_AREA_QUEUE (
  tenant_slug STRING,
  ID INT,
  ID_AREA INT,
  ID_PERIODO_GESTAO INT,
  COD_FILIAL STRING,
  COD_AREA STRING,
  DESC_AREA STRING,
  COD_PARENT STRING,
  INSERT_DATE TIMESTAMP,
  OPERATION INT,
  NEW_DESC_AREA_SUP STRING,
  NEW_ID_AREA_SUP INT,
  USER_LOGIN STRING,
  NOME STRING,
  DT_LOG TIMESTAMP,
  ACTION INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__VW_AUDIT_COLABORADOR_QUEUE (
  tenant_slug STRING,
  ID INT,
  ID_COLABORADOR INT,
  ID_PERIODO_GESTAO INT,
  COD_AREA STRING,
  USER_LOGIN STRING,
  AREAS_UNDER_RESP STRING,
  COD_GRUPO_USUARIO STRING,
  NOME STRING,
  ID_IDIOMA INT,
  EMAIL STRING,
  WORKFLOW_ACOES INT,
  ACTIVE INT,
  INSERT_DATE TIMESTAMP,
  OPERATION INT,
  NEW_DESC_AREA STRING,
  OBSERVATION STRING,
  LOGGED_USER_LOGIN STRING,
  LOGGED_USER_NAME STRING,
  DT_LOG TIMESTAMP,
  ACTION INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo____MigrationHistory (
  tenant_slug STRING,
  MigrationId STRING,
  ContextKey STRING,
  Model BINARY,
  ProductVersion STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, MigrationId, ContextKey)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.dbo__dual (
  tenant_slug STRING,
  dummy STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, dummy)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.notification__MailSettings (
  tenant_slug STRING,
  MailRestrictionLevel INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.stg__ConsolidatedScoreView (
  tenant_slug STRING,
  Login STRING,
  Name STRING,
  AreaCode STRING,
  AreaDescription STRING,
  ReferenceDate TIMESTAMP,
  PunctualScore DOUBLE,
  AccumulatedScore DOUBLE,
  YTDScore DOUBLE,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.stg__GoalReportView (
  tenant_slug STRING,
  GoalId INT,
  StrategicPillarCode STRING,
  StrategicPillarDescription STRING,
  AreaCode STRING,
  AreaDescription STRING,
  GoalCode STRING,
  Objective STRING,
  ResponsibleLogin STRING,
  ResponsibleRegistration STRING,
  ResponsibleName STRING,
  KPICode STRING,
  KPIDescription STRING,
  GoalWeight DECIMAL(28,8),
  GoalValue DECIMAL(28,8),
  EndDate TIMESTAMP,
  CalculationMemory STRING,
  DataSource STRING,
  AggregationTypeDescription STRING,
  TrafficLightRange STRING,
  GoalType STRING,
  UpperGoal STRING,
  DataProviderLogin STRING,
  DataProviderName STRING,
  GoalValueId INT,
  ReferenceDate TIMESTAMP,
  Attachment INT,
  PunctualPlanned DOUBLE,
  NAPunctualPlanned INT,
  PunctualActual DOUBLE,
  NAPunctualActual INT,
  AccumulatedPlanned DOUBLE,
  NAAccumulatedPlanned INT,
  AccumulatedActual DOUBLE,
  NAAccumulatedActual INT,
  PunctualForecast1 DOUBLE,
  NAPunctualForecast1 INT,
  PunctualForecast2 DOUBLE,
  NAPunctualForecast2 INT,
  AccumulatedForecast1 DOUBLE,
  NAAccumulatedForecast1 INT,
  AccumulatedForecast2 DOUBLE,
  NAAccumulatedForecast2 INT,
  IsQualifierGoal INT,
  HasCountermeasure INT,
  PunctualDeviation DOUBLE,
  PunctualDeviationPercentage DOUBLE,
  NAPunctualDeviation INT,
  AccumulatedDeviation DOUBLE,
  AccumulatedDeviationPercentage DOUBLE,
  NAAccumulatedDeviation INT,
  PunctualTrafficLight STRING,
  AccumulatedTrafficLight STRING,
  PunctualScore DOUBLE,
  AccumulatedScore DOUBLE,
  NAPunctualScore INT,
  NAAccumulatedScore INT,
  GoalValueFilled INT,
  DecimalPrecision INT,
  EnableGoalAudit INT,
  AuditStatusDescription STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.stg__GoalView (
  tenant_slug STRING,
  GoalId INT,
  UpperAreaCode STRING,
  UpperAreaDescription STRING,
  AreaCode STRING,
  AreaDescription STRING,
  StrategicPillarCode STRING,
  StrategicPillarDescription STRING,
  AreaResponsibleLogin STRING,
  AreaResponsibleName STRING,
  GoalCode STRING,
  GoalType INT,
  GoalTypeDescription STRING,
  ResponsibleLogin STRING,
  ResponsibleRegistration STRING,
  ResponsibleName STRING,
  Objective STRING,
  ValidationStatus INT,
  ValidationStatusDescription STRING,
  GoalWeight DECIMAL(28,8),
  GoalValue DECIMAL(28,8),
  KPICode STRING,
  KPIDescription STRING,
  Polarity INT,
  PolarityDescription STRING,
  ReferencedGoalCode STRING,
  ReferencedProjectGoalCode STRING,
  DataProviderLogin STRING,
  DataProviderName STRING,
  ScoreCurveCode STRING,
  ScoreCurveDescription STRING,
  AggregationType INT,
  AggregationTypeDescription STRING,
  ValueDefinitionType INT,
  ValueDefinitionTypeDescription STRING,
  AccumulatedPlanned DOUBLE,
  NAAccumulatedPlanned INT,
  AccumulatedActual DOUBLE,
  NAAccumulatedActual INT,
  GoalScore DOUBLE,
  EndDate TIMESTAMP,
  CalculationMemory STRING,
  DataSource STRING,
  TrafficLightRange STRING,
  UpperGoal STRING,
  IsQualifierGoal INT,
  DecimalPrecision INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.stg__VCExtract (
  tenant_slug STRING,
  TotalSetor DECIMAL(18,6),
  TotalPonderado DECIMAL(18,6),
  AreaId INT,
  BranchId INT,
  ParticipantId INT,
  PercIndividual DECIMAL(18,6),
  PercArea DECIMAL(18,6),
  PercSuperior DECIMAL(18,6),
  PercPresidencia DECIMAL(18,6),
  PercAvaliacaoCompetencia DECIMAL(18,6),
  PercDiscricionario DECIMAL(18,6),
  PercFilial DECIMAL(18,6),
  PercAvaliacaoDiscricionaria DECIMAL(18,6),
  TriggerId INT,
  TotalScore DECIMAL(18,6),
  TotalParticipants INT,
  TotalScoreSum DECIMAL(18,6),
  AverageScore DECIMAL(18,6),
  CompensationScore DECIMAL(18,6),
  CompensationMultiple DECIMAL(18,6),
  JobPositionDescription STRING,
  JobPositionCode STRING,
  JobPositionIsCritical INT,
  JobPositionSalary DECIMAL(18,6),
  JobPositionInitialDate TIMESTAMP,
  MultipleForScore100 DECIMAL(18,6),
  CompensationSalary DECIMAL(18,6),
  AdiantamentoPPRActual DECIMAL(18,6),
  MesesElegiveisActual DECIMAL(18,6),
  AreaCompensationsResult DECIMAL(18,6),
  Id BIGINT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: exclude
-- @note: EXCLUDE — sem EDW (ADR-006)
CREATE TABLE IF NOT EXISTS raw.stg__vcExtractLastLastUpdate (
  tenant_slug STRING,
  EndDate TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_avaliador
-- @fk: ID_AVALIACAO -> raw.competences__AVALIACAO.ID
-- @fk: ID_AVALIADO -> raw.competences__AVALIADO.ID
-- @fk: ID_COLABORADOR_AVALIADOR -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.competences__AVALIADOR (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_AVALIADO INT,
  ID_COLABORADOR_AVALIADOR INT,
  TIPO_AVALIADOR INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_calc_resposta
CREATE TABLE IF NOT EXISTS raw.competences__CALC_RESPOSTA (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_FORMULARIO_AVALIACAO INT,
  ID_AVALIADO INT,
  ID_AVALIADOR INT,
  ID_FUNCAO INT,
  ID_RESPOSTA_AVALIACAO INT,
  PESO_FUNCAO_COMPETENCIA DECIMAL(28,8),
  NOTA_REFERENCIA DECIMAL(28,8),
  PERC_ALCANCE_REFERENCIA DECIMAL(28,8),
  NOTA_RESPOSTA DECIMAL(28,8),
  PERC_ALCANCE_RESPOSTA DECIMAL(28,8),
  NOTA_CONSENSO DECIMAL(28,8),
  PERC_ALCANCE_CONSENSO DECIMAL(28,8),
  NOTA_PONDERADA DECIMAL(28,8),
  PERC_PONDERADO DECIMAL(28,8),
  NOTA_CONSENSO_PONDERADA DECIMAL(28,8),
  PERC_CONSENSO_PONDERADO DECIMAL(28,8),
  NOTA_PONDERADA_NUMERIC DECIMAL(18,5),
  NOTA_CONSENSO_PONDERADA_NUMERIC DECIMAL(18,5),
  FEEDBACK_ENVIADO INT,
  NOTA_CALIBRADA DECIMAL(28,8),
  NOTA_CALIBRADA_PONDERADA DECIMAL(28,8),
  WeightedAssessmetCompetenceTypeScore DECIMAL(28,8),
  AppliedWeightGeneralScore DECIMAL(28,8),
  AppliedWeightCompetenceTypeScore DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_calc_resultado_avaliador
CREATE TABLE IF NOT EXISTS raw.competences__CALC_RESULTADO_AVALIADOR (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_AVALIADO INT,
  ID_COLABORADOR_AVALIADO INT,
  ID_AVALIADOR INT,
  ID_COLABORADOR_AVALIADOR INT,
  NOTA_FINAL DECIMAL(28,8),
  NOTA_FINAL_NUMERIC DECIMAL(28,8),
  NOTA_FINAL_HABILIDADE DECIMAL(28,8),
  NOTA_FINAL_COMPORTAMENTAL DECIMAL(28,8),
  NOTA_FINAL_NUMERIC_HABILIDADE DECIMAL(28,8),
  NOTA_FINAL_NUMERIC_COMPORTAMENTAL DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: Resultado avaliador × competência (fato origem)
-- @fk: ID_AVALIACAO -> raw.competences__AVALIACAO.ID
-- @fk: ID_AVALIADO -> raw.competences__AVALIADO.ID
-- @fk: ID_AVALIADOR -> raw.competences__AVALIADOR.ID
-- @fk: ID_AVALIADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_COLABORADOR_AVALIADO -> raw.dbo__COLABORADOR.ID
-- @fk: ID_COLABORADOR_AVALIADO -> raw.dbo__COLABORADOR.ID
-- @fk: ID_COLABORADOR_AVALIADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_COMPETENCE -> raw.competences__COMPETENCIA.ID
-- @fk: ID_TIPO_AVALIADOR -> raw.competences__TIPO_AVALIADOR.ID
CREATE TABLE IF NOT EXISTS raw.competences__CALC_RESULTADO_AVALIADOR_COMPETENCIA (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_AVALIADOR INT,
  ID_TIPO_AVALIADOR INT,
  ID_AVALIADO INT,
  ID_COLABORADOR_AVALIADO INT,
  ID_COLABORADOR_AVALIADOR INT,
  ID_COMPETENCE INT,
  NOTA_FINAL DECIMAL(28,8),
  GeneralWeight DECIMAL(28,8),
  WeightedGeneralScore DECIMAL(28,8),
  CompetenceTypeWeight DECIMAL(28,8),
  WeightedCompetenceTypeScore DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_calc_resultado_colaborador_performance
-- @fk: ID_AVALIADO -> raw.competences__AVALIADO.ID
CREATE TABLE IF NOT EXISTS raw.competences__CALC_RESULTADO_COLABORADOR_PERFORMANCE (
  tenant_slug STRING,
  ID INT,
  ID_AVALIADO INT,
  NOTA_FINAL DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_calc_resultado_competencia
CREATE TABLE IF NOT EXISTS raw.competences__CALC_RESULTADO_COMPETENCIA (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_AVALIADO INT,
  ID_COLABORADOR_AVALIADO INT,
  ID_COMPETENCIA INT,
  NOTA_FINAL DECIMAL(28,8),
  NOTA_FINAL_CONSENSADA DECIMAL(28,8),
  NOTA_FINAL_CALIBRADA DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_calc_resultado_fator_avaliacao
CREATE TABLE IF NOT EXISTS raw.competences__CALC_RESULTADO_FATOR_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_AVALIADO INT,
  ID_COLABORADOR_AVALIADO INT,
  ID_FUNCAO_COMPETENCIA INT,
  ID_COMPETENCIA INT,
  ID_FATOR_AVALIACAO INT,
  NOTA_FINAL DECIMAL(28,8),
  NOTA_FINAL_CONSENSADA DECIMAL(28,8),
  NOTA_FINAL_CALIBRADA DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_calc_resultado_tipo_avaliador
CREATE TABLE IF NOT EXISTS raw.competences__CALC_RESULTADO_TIPO_AVALIADOR (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_AVALIADO INT,
  ID_COLABORADOR_AVALIADO INT,
  TIPO_AVALIADOR INT,
  NOTA_FINAL DECIMAL(28,8),
  NOTA_FINAL_NUMERIC DECIMAL(28,8),
  TechnicalFinalScore DECIMAL(28,8),
  BehavioralFinalScore DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_comentario_avaliado_nine_box
-- @fk: ID_AVALIADO -> raw.competences__AVALIADO.ID
-- @fk: ID_NINE_BOX -> raw.dbo__NINE_BOX.ID
CREATE TABLE IF NOT EXISTS raw.competences__COMENTARIO_AVALIADO_NINE_BOX (
  tenant_slug STRING,
  ID INT,
  ID_AVALIADO INT,
  ID_NINE_BOX INT,
  COMENTARIO STRING,
  DT_ATUALIZACAO TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_comentario_competencia
-- @fk: ID_COMPETENCIA -> raw.competences__COMPETENCIA.ID
-- @fk: ID_FORMULARIO_AVALIACAO -> raw.competences__FORMULARIO_AVALIACAO.ID
CREATE TABLE IF NOT EXISTS raw.competences__COMENTARIO_COMPETENCIA (
  tenant_slug STRING,
  ID INT,
  ID_FORMULARIO_AVALIACAO INT,
  ID_COMPETENCIA INT,
  COMENTARIO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_consideracao_final
-- @fk: ID_FORMULARIO_AVALIACAO -> raw.competences__FORMULARIO_AVALIACAO.ID
CREATE TABLE IF NOT EXISTS raw.competences__CONSIDERACAO_FINAL (
  tenant_slug STRING,
  ID INT,
  ID_FORMULARIO_AVALIACAO INT,
  PONTOS_POSITIVOS STRING,
  PONTOS_DESENVOLVER STRING,
  COMENTARIO_FINAL STRING,
  COMENTARIO_LIDER STRING,
  COMENTARIO_AVALIADO STRING,
  COMENTARIO_QUALIDADE STRING,
  NOTA_QUALIDADE INT,
  DATA_FEEDBACK TIMESTAMP,
  QUALIDADE_AVALIADA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_evaluation_cycle_calc_result_evaluated
-- @fk: EmployeeEvaluatedId -> raw.dbo__COLABORADOR.ID
-- @fk: EvaluatedId -> raw.competences__AVALIADO.ID
-- @fk: EvaluationCycleId -> raw.competences__AVALIACAO.ID
CREATE TABLE IF NOT EXISTS raw.competences__EvaluationCycleCalcResultEvaluated (
  tenant_slug STRING,
  Id INT,
  EvaluationCycleId INT,
  EvaluatedId INT,
  EmployeeEvaluatedId INT,
  FinalScore DECIMAL(28,8),
  FinalScoreConsensus DECIMAL(28,8),
  FinalScoreCalib DECIMAL(28,8),
  PDFHistoryUrl STRING,
  FinalScoreBehavior DECIMAL(28,8),
  FinalScoreBehaviorConsensus DECIMAL(28,8),
  FinalScoreBehaviorCalib DECIMAL(28,8),
  FinalScoreTechnical DECIMAL(28,8),
  FinalScoreTechnicalConsensus DECIMAL(28,8),
  FinalScoreTechnicalCalib DECIMAL(28,8),
  CalibrationRankingEvaluated DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_formulario_avaliacao
-- @fk: ID_AVALIACAO -> raw.competences__AVALIACAO.ID
-- @fk: ID_AVALIADO -> raw.competences__AVALIADO.ID
-- @fk: ID_AVALIADOR -> raw.competences__AVALIADOR.ID
-- @fk: ID_AVALIADOR_RESPONDEU_AVALIACAO -> raw.dbo__COLABORADOR.ID
-- @fk: ID_AVALIADOR_RESPONDEU_FEEDBACK -> raw.dbo__COLABORADOR.ID
-- @fk: ID_FUNCAO -> raw.competences__FUNCAO.ID
-- @fk: ID_PESO_TIPO_AVALIADOR -> raw.competences__PESO_TIPO_AVALIADOR.ID
-- @fk: ID_PROJETO -> raw.dbo__PROJETO_AVALIACAO.ID
CREATE TABLE IF NOT EXISTS raw.competences__FORMULARIO_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_AVALIADO INT,
  ID_AVALIADOR INT,
  ID_FUNCAO INT,
  DT_DEADLINE TIMESTAMP,
  DT_ENVIO TIMESTAMP,
  DT_REENVIO TIMESTAMP,
  DT_FINALIZACAO_FORMULARIO TIMESTAMP,
  DT_CANCELAMENTO_ENVIO TIMESTAMP,
  DT_ENVIO_FEEDBACK TIMESTAMP,
  FEEDBACK_LIBERADO INT,
  ID_COLABORADOR_AVALIADOR INT,
  DT_DEADLINE_FEEDBACK TIMESTAMP,
  ID_PESO_TIPO_AVALIADOR INT,
  FEEDBACK_SEM_FORMULARIO_LIDER INT,
  RESULTADO_FEEDBACK_LIBERADO INT,
  DISPONIBILIZAR_ONEPAGE INT,
  STATUS_FEEDBACK INT,
  STATUS INT,
  JUSTIFICATIVA_RECUSA STRING,
  DATA_RECUSA TIMESTAMP,
  ID_COLABORADOR_CRIADOR INT,
  DT_DEADLINE_PRE_CALIBRAGEM TIMESTAMP,
  FEEDBACK_INFORMAL_RECEBIDO INT,
  ID_PROJETO INT,
  POSSUI_INTERESSE_MUDANCA_LOCALIDADE INT,
  DT_LIBERACAO_RESULTADO TIMESTAMP,
  ID_AVALIADOR_RESPONDEU_AVALIACAO INT,
  ID_AVALIADOR_RESPONDEU_FEEDBACK INT,
  EvaluationAnsweredFromMobile INT,
  FeedbackAnsweredFromMobile INT,
  HasInterestChangeArea INT,
  HasSuccessorIndication INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_funcao_competencia
-- @fk: ID_COMPETENCIA -> raw.competences__COMPETENCIA.ID
-- @fk: ID_FATOR_AVALIACAO -> raw.competences__FATOR_AVALIACAO.ID
-- @fk: ID_FUNCAO -> raw.competences__FUNCAO.ID
CREATE TABLE IF NOT EXISTS raw.competences__FUNCAO_COMPETENCIA (
  tenant_slug STRING,
  ID INT,
  ID_FUNCAO INT,
  ID_COMPETENCIA INT,
  ID_FATOR_AVALIACAO INT,
  PROFICIENCIA INT,
  EXPERIENCIA_ANO INT,
  AUTO DECIMAL(28,8),
  LIDER DECIMAL(28,8),
  PAR DECIMAL(28,8),
  TIME DECIMAL(28,8),
  COMITE DECIMAL(28,8),
  CLIENTE DECIMAL(28,8),
  FORNECEDOR DECIMAL(28,8),
  PESO_GERAL_POR_FATOR DECIMAL(18,5),
  POSSUI_PESOS_DETALHADO INT,
  PROJETO DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_funcao_pergunta_livre
-- @fk: ID_FUNCAO -> raw.competences__FUNCAO.ID
-- @fk: ID_TOPICO -> raw.competences__TOPICO_PERGUNTA_LIVRE.ID
CREATE TABLE IF NOT EXISTS raw.competences__FUNCAO_PERGUNTA_LIVRE (
  tenant_slug STRING,
  ID INT,
  ID_FUNCAO INT,
  PERGUNTA_LIVRE STRING,
  ORDENACAO INT,
  AUTO INT,
  LIDER INT,
  PAR INT,
  TIME INT,
  COMITE INT,
  CLIENTE INT,
  FORNECEDOR INT,
  ID_TOPICO INT,
  TIPO_RESPOSTA INT,
  PERGUNTA_LIVRE_CONFIDENCIAL INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_individual_development_action
-- @fk: ActionSuggestedId -> raw.competences__ACAO_SUGERIDA_PDI.ID
-- @fk: CategoryActionSuggestedId -> raw.competences__CATEGORIA_PDI_ACAO.ID
-- @fk: CompetenceId -> raw.competences__COMPETENCIA.ID
-- @fk: EvaluationCycleId -> raw.competences__AVALIACAO.ID
-- @fk: EvaluationFactorId -> raw.competences__FATOR_AVALIACAO.ID
-- @fk: Id -> raw.dbo__ActionBase.Id
CREATE TABLE IF NOT EXISTS raw.competences__IndividualDevelopmentAction (
  tenant_slug STRING,
  Id INT,
  Origin INT,
  EvaluationCycleId INT,
  CompetenceId INT,
  EvaluationFactorId INT,
  ActionSuggestedId INT,
  CategoryActionSuggestedId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_opcao_funcao_pergunta_livre
-- @fk: ID_FUNCAO_PERGUNTA_LIVRE -> raw.competences__FUNCAO_PERGUNTA_LIVRE.ID
CREATE TABLE IF NOT EXISTS raw.competences__OPCAO_FUNCAO_PERGUNTA_LIVRE (
  tenant_slug STRING,
  ID INT,
  ID_FUNCAO_PERGUNTA_LIVRE INT,
  DESCRICAO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_resposta
-- @fk: ID_FORMULARIO_AVALIACAO -> raw.competences__FORMULARIO_AVALIACAO.ID
-- @fk: ID_FUNCAO_COMPETENCIA -> raw.competences__FUNCAO_COMPETENCIA.ID
-- @fk: ID_NOTA_CALIBRADA -> raw.competences__CURVA_PONTUACAO_AVALIACAO.ID
-- @fk: ID_NOTA_CONSENSO -> raw.competences__CURVA_PONTUACAO_AVALIACAO.ID
-- @fk: ID_NOTA_RESPOSTA -> raw.competences__CURVA_PONTUACAO_AVALIACAO.ID
CREATE TABLE IF NOT EXISTS raw.competences__RESPOSTA_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  ID_FORMULARIO_AVALIACAO INT,
  ID_FUNCAO_COMPETENCIA INT,
  ID_NOTA_RESPOSTA INT,
  ID_NOTA_CONSENSO INT,
  COMENTARIO_RESPOSTA STRING,
  DT_RESPOSTA TIMESTAMP,
  DT_RESPOSTA_CONSENSO TIMESTAMP,
  COMENTARIO_RESPOSTA_CONSENSO STRING,
  ID_NOTA_CALIBRADA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_resposta_livre_avaliacao
-- @fk: ID_FORMULARIO_AVALIACAO -> raw.competences__FORMULARIO_AVALIACAO.ID
-- @fk: ID_FUNCAO_PERGUNTA_LIVRE -> raw.competences__FUNCAO_PERGUNTA_LIVRE.ID
-- @fk: ID_OPCAO_FUNCAO_PERGUNTA_LIVRE -> raw.competences__OPCAO_FUNCAO_PERGUNTA_LIVRE.ID
CREATE TABLE IF NOT EXISTS raw.competences__RESPOSTA_LIVRE_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  ID_FORMULARIO_AVALIACAO INT,
  ID_FUNCAO_PERGUNTA_LIVRE INT,
  RESPOSTA_LIVRE STRING,
  DT_RESPOSTA TIMESTAMP,
  RESPOSTA_CONSOLIDADO STRING,
  ID_OPCAO_FUNCAO_PERGUNTA_LIVRE INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: Plano de ação vinculado a meta
-- @fk: ID_CAUSA -> raw.dbo__CAUSA.ID
-- @fk: ID_CONTRAMEDIDA -> raw.dbo__CONTRAMEDIDA.ID
-- @fk: ID_CRIADOR_ACAO -> raw.dbo__COLABORADOR.ID
-- @fk: ID_META -> raw.dbo__META.ID
-- @fk: ID_META -> raw.dbo__META.ID
-- @fk: ID_RESPONSAVEL_ACAO -> raw.dbo__COLABORADOR.ID
-- @fk: ID_RESPONSAVEL_ACAO -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ACAO (
  tenant_slug STRING,
  ID INT,
  ID_META INT,
  ID_CRIADOR_ACAO INT,
  ID_RESPONSAVEL_ACAO INT,
  ID_CONTRAMEDIDA INT,
  ID_CAUSA INT,
  COD_ACAO STRING,
  OQUE STRING,
  COMO STRING,
  PORQUE STRING,
  ONDE STRING,
  JUSTIFICATIVA_CANCELAMENTO STRING,
  JUSTIFICATIVA_NEGACAO STRING,
  INVESTIMENTO DOUBLE,
  RETORNO DOUBLE,
  DT_CRIACAO_ACAO TIMESTAMP,
  DT_INI_PLANEJADA TIMESTAMP,
  DT_FIM_PLANEJADA TIMESTAMP,
  DT_INI_REALIZADA TIMESTAMP,
  DT_FIM_REALIZADA TIMESTAMP,
  PERC_REALIZADO DOUBLE,
  ORIGEM_ACAO INT,
  STATUS_ACAO INT,
  STATUS_APROVACAO INT,
  DIAS_ANTECEDENCIA INT,
  EMAIL_ALERT INT,
  OBSERVACAO STRING,
  DT_UPD TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_anexo_acao
-- @fk: ID_ACAO -> raw.dbo__ACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ANEXO_ACAO (
  tenant_slug STRING,
  ID INT,
  ID_ACAO INT,
  ID_UPLOADER INT,
  NOME_ARQUIVO STRING,
  ARQUIVO BINARY,
  DT_ENVIO TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_avaliador_forum
-- @fk: ID_COLABORADOR_AVALIADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_FORUM -> raw.dbo__NINE_BOX.ID
CREATE TABLE IF NOT EXISTS raw.dbo__AVALIADOR_FORUM (
  tenant_slug STRING,
  ID INT,
  ID_COLABORADOR_AVALIADOR INT,
  ID_FORUM INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_accept_agreement_history
CREATE TABLE IF NOT EXISTS raw.dbo__AcceptAgreementHistory (
  tenant_slug STRING,
  Id INT,
  CreatedOn TIMESTAMP,
  AgreementDetails STRING,
  AcceptAgreementID INT,
  AcceptAgreementSignatureID INT,
  AcceptAgreementLastSignature STRING,
  Motive STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_action_base
-- @fk: AcceptedById -> raw.dbo__COLABORADOR.ID
-- @fk: CreatorId -> raw.dbo__COLABORADOR.ID
-- @fk: DeniedById -> raw.dbo__COLABORADOR.ID
-- @fk: ModuleId -> raw.dbo__Modules.Id
-- @fk: ResponsibleId -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ActionBase (
  tenant_slug STRING,
  Id INT,
  CreatorId INT,
  ResponsibleId INT,
  CreationTime TIMESTAMP,
  LastModificationTime TIMESTAMP,
  WorkflowStep INT,
  Status INT,
  Code STRING,
  Description STRING,
  How STRING,
  Where STRING,
  Why STRING,
  CancellationJustification STRING,
  DenyJustification STRING,
  Observation STRING,
  PlannedStartDate TIMESTAMP,
  PlannedEndDate TIMESTAMP,
  ActualStartDate TIMESTAMP,
  ActualEndDate TIMESTAMP,
  ActualPercentage DECIMAL(18,2),
  ModuleId INT,
  ActionType INT,
  DaysInAdvance INT,
  EmailNotificationEnabled INT,
  Investment DECIMAL(18,2),
  Return DECIMAL(18,2),
  DeniedById INT,
  AcceptedById INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_activity_history
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: ModuleId -> raw.dbo__Modules.Id
CREATE TABLE IF NOT EXISTS raw.dbo__ActivityHistory (
  tenant_slug STRING,
  Id BIGINT,
  Title STRING,
  Description STRING,
  NotificationType INT,
  EmployeeId INT,
  ModuleId INT,
  Read INT,
  CreatorUserId BIGINT,
  CreationTime TIMESTAMP,
  ObjectId INT,
  ReadOnly INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_area_history
-- @fk: Area_Id -> raw.dbo__AREA.ID
-- @fk: Employee_Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__AreaHistory (
  tenant_slug STRING,
  Id INT,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  Area_Id INT,
  Employee_Id INT,
  Score DECIMAL(28,8),
  StartDateRef TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_contramedida
-- @fk: ID_META -> raw.dbo__META.ID
CREATE TABLE IF NOT EXISTS raw.dbo__CONTRAMEDIDA (
  tenant_slug STRING,
  ID INT,
  ID_META INT,
  DT_CRIACAO TIMESTAMP,
  DT_REF TIMESTAMP,
  IsReference INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_discretionary_score_import
CREATE TABLE IF NOT EXISTS raw.dbo__DiscretionaryScoreImport (
  tenant_slug STRING,
  ImportLogId INT,
  Line INT,
  CalculationPeriod INT,
  EmployeeId INT,
  UserName STRING,
  Score DOUBLE,
  Description STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_expressao_calculo
-- @fk: ID_META -> raw.dbo__META.ID
-- @fk: ID_META_REF -> raw.dbo__META.ID
CREATE TABLE IF NOT EXISTS raw.dbo__EXPRESSAO_CALCULO_META (
  tenant_slug STRING,
  ID INT,
  ID_META INT,
  ID_META_REF INT,
  ID_GRUPO_CONTA_REF INT,
  ID_ENTIDADE_REF INT,
  ID_MATRIZ INT,
  TIPO_PROCESSO_REF INT,
  TIPO_MATRIZ_REF INT,
  VALOR_REF DOUBLE,
  PESO_META_REF DECIMAL(28,8),
  OPERADOR INT,
  DESC_EXPRESSAO STRING,
  ORDEM INT,
  ID_EIXO_X INT,
  ID_EIXO_Y INT,
  ID_EIXO_Z INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_education
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__Education (
  tenant_slug STRING,
  Id INT,
  InstitutionName STRING,
  Degree STRING,
  FieldOfStudy STRING,
  Start TIMESTAMP,
  End TIMESTAMP,
  EmployeeId INT,
  Logo STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_eligible_discretionary
-- @fk: CalibrationGroupDiscretionary_Id -> raw.dbo__CalibrationGroupDiscretionary.ID
-- @fk: FinalRange_Id -> raw.dbo__RangeDiscretionary.Id
-- @fk: MediumRange_Id -> raw.dbo__RangeDiscretionary.Id
-- @fk: RVParticipant_Id -> raw.dbo__PARTICIPANTE_RV.ID
CREATE TABLE IF NOT EXISTS raw.dbo__EligibleDiscretionary (
  tenant_slug STRING,
  Id INT,
  Status INT,
  RVParticipant_Id INT,
  CreateDate TIMESTAMP,
  CalibrationDate TIMESTAMP,
  FinalRange_Id INT,
  MediumRange_Id INT,
  GRUPO_CALIBRAGEM STRING,
  CalibrationGroupDiscretionary_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_employee_access_group
-- @fk: Employee_Id -> raw.dbo__COLABORADOR.ID
-- @fk: Module_Id -> raw.dbo__Modules.Id
CREATE TABLE IF NOT EXISTS raw.dbo__EmployeeAccessGroup (
  tenant_slug STRING,
  Id INT,
  Employee_Id INT,
  Module_Id INT,
  Type INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_employee_analytic_result
-- @fk: HistorySection_Id -> raw.dbo__HistorySection.Id
-- @fk: Participant_Id -> raw.dbo__PARTICIPANTE_RV.ID
CREATE TABLE IF NOT EXISTS raw.dbo__EmployeeAnalyticResult (
  tenant_slug STRING,
  Id INT,
  Score DECIMAL(28,8),
  Multiple DECIMAL(28,8),
  Salary DECIMAL(28,8),
  Score_Ref DECIMAL(28,8),
  Multiple_Ref DECIMAL(28,8),
  Salary_Ref DECIMAL(28,8),
  Participant_Id INT,
  PoolRedistribution DECIMAL(28,8),
  HistorySection_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_employee_modifier_value
-- @fk: Employee_Id -> raw.dbo__COLABORADOR.ID
-- @fk: Modifier_Id -> raw.dbo__Modifier.Id
CREATE TABLE IF NOT EXISTS raw.dbo__EmployeeModifierValue (
  tenant_slug STRING,
  Id INT,
  Value DECIMAL(28,8),
  Employee_Id INT,
  Modifier_Id INT,
  UpdateDate TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_evaluation_cycle_instance_participant
-- @fk: EmployeeResponsibleChangeId -> raw.dbo__COLABORADOR.ID
-- @fk: EvaluatedId -> raw.competences__AVALIADO.ID
-- @fk: InstanceId -> raw.dbo__EvaluationCycleInstance.Id
-- @fk: ParentId -> raw.dbo__EvaluationCycleInstanceParticipant.Id
-- @fk: QuadrantFromId -> raw.dbo__EvaluationCycleQuadrant.Id
-- @fk: QuadrantToId -> raw.dbo__EvaluationCycleQuadrant.Id
CREATE TABLE IF NOT EXISTS raw.dbo__EvaluationCycleInstanceParticipant (
  tenant_slug STRING,
  Id INT,
  InstanceId INT,
  EvaluatedId INT,
  QuadrantFromId INT,
  QuadrantToId INT,
  EmployeeXAxisCalibrated INT,
  EmployeeYAxisCalibrated INT,
  XAxisConsiderations STRING,
  YAxisConsiderations STRING,
  ChangeDate TIMESTAMP,
  EmployeeResponsibleChangeId INT,
  Active INT,
  ParentId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_evaluation_discretionary
-- @fk: Concept_Id -> raw.dbo__ConceptDiscretionary.Id
-- @fk: EligibleDiscretionary_Id -> raw.dbo__EligibleDiscretionary.Id
-- @fk: Evaluator_Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__EvaluationDiscretionary (
  tenant_slug STRING,
  Id INT,
  Concept_Id INT,
  EligibleDiscretionary_Id INT,
  Evaluator_Id INT,
  EvaluatedDate TIMESTAMP,
  Grade DECIMAL(7,2),
  CalibratedGrade DECIMAL(7,2),
  Status INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_goal_attachment
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: GoalId -> raw.dbo__META.ID
CREATE TABLE IF NOT EXISTS raw.dbo__GoalAttachment (
  tenant_slug STRING,
  Id INT,
  GoalId INT,
  EmployeeId INT,
  FileName STRING,
  UploadDate TIMESTAMP,
  ContentType STRING,
  Month INT,
  Origem INT,
  Key STRING,
  ContentLength INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_historico_cargo
-- @fk: ID_CARGO -> raw.dbo__CARGO.ID
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__HISTORICO_CARGO (
  tenant_slug STRING,
  ID INT,
  ID_CARGO INT,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  SALARIO DOUBLE,
  ID_COLABORADOR INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_historico_perc_realizado
-- @fk: ID_ACAO -> raw.dbo__ACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__HISTORICO_PERC_REALIZADO (
  tenant_slug STRING,
  ID INT,
  ID_ACAO INT,
  PERC_REALIZADO DOUBLE,
  DT_UPD TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_historico_workflow_acao
-- @fk: ID_ACAO -> raw.dbo__ACAO.ID
-- @fk: ID_RESPONSAVEL_ACAO -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__HISTORICO_WORKFLOW_ACAO (
  tenant_slug STRING,
  ID INT,
  ID_ACAO INT,
  ID_RESPONSAVEL_ACAO INT,
  DT_WORKFLOW TIMESTAMP,
  STATUS_APROVACAO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_history_section
-- @fk: AreaId -> raw.dbo__AREA.ID
-- @fk: CalculationPeriod_Id -> raw.dbo__PERIODO_APURACAO.ID
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: JobPositionId -> raw.dbo__CARGO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__HistorySection (
  tenant_slug STRING,
  Id INT,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  AreaHistory_Id INT,
  JobPositionHistory_Id INT,
  CalculationPeriod_Id INT,
  EmployeeId INT,
  AreaId INT,
  JobPositionId INT,
  AreaHistoryStartAt TIMESTAMP,
  AreaHistoryEndAt TIMESTAMP,
  AreaHistoryScore DECIMAL(28,8),
  AreaHistoryStartAtRef TIMESTAMP,
  JobPositionHistoryStartAt TIMESTAMP,
  JobPositionHistoryEndAt TIMESTAMP,
  JobPositionHistorySalary DOUBLE,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_info_nota_meta
-- @fk: ID_META -> raw.dbo__META.ID
CREATE TABLE IF NOT EXISTS raw.dbo__INFO_NOTA_META (
  tenant_slug STRING,
  ID INT,
  ID_META INT,
  TIPO_VALOR INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_job_position_level
-- @fk: JobPosition_Id -> raw.dbo__CARGO.ID
-- @fk: Level_Id -> raw.dbo__NIVEL.ID
CREATE TABLE IF NOT EXISTS raw.dbo__JobPositionLevel (
  tenant_slug STRING,
  JobPosition_Id INT,
  Level_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, JobPosition_Id, Level_Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_label_action
-- @fk: IdAction -> raw.dbo__ACAO.ID
-- @fk: IdLabel -> raw.core__Label.Id
CREATE TABLE IF NOT EXISTS raw.dbo__LabelAction (
  tenant_slug STRING,
  IdLabel INT,
  IdAction INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, IdLabel, IdAction)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_label_goal
-- @fk: IdGoal -> raw.dbo__META.ID
-- @fk: IdLabel -> raw.core__Label.Id
CREATE TABLE IF NOT EXISTS raw.dbo__LabelGoal (
  tenant_slug STRING,
  IdLabel INT,
  IdGoal INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, IdLabel, IdGoal)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_nine_box_calibrados
CREATE TABLE IF NOT EXISTS raw.dbo__NINE_BOX_CALIBRADOS (
  tenant_slug STRING,
  ID INT,
  ID_NINE_BOX INT,
  ID_COLABORADOR INT,
  CalibrationMarkup INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_nota_meta
-- @fk: ID_META -> raw.dbo__META.ID
-- @fk: ID_NOTA -> raw.dbo__NOTA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__NOTA_META (
  tenant_slug STRING,
  ID INT,
  ID_META INT,
  ID_NOTA INT,
  PERC_NOTA DOUBLE,
  VALOR_NOTA DOUBLE,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_notificacao_feedback
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__NOTIFICACAO_FEEDBACK_CONTINUO (
  tenant_slug STRING,
  Id INT,
  ID_COLABORADOR INT,
  ALERT_TYPE INT,
  FREQUENCY_TYPE INT,
  WEEK_DAY INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_perfil_grupo_usuario
-- @fk: ID_FUNCIONALIDADE -> raw.dbo__FUNCIONALIDADE.ID
-- @fk: ID_GRUPO_USUARIO -> raw.dbo__GRUPO_USUARIO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__PERFIL_GRUPO_USUARIO (
  tenant_slug STRING,
  ID INT,
  ID_GRUPO_USUARIO INT,
  ID_FUNCIONALIDADE STRING,
  PAGINA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_psw_colaborador
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__PSW_COLABORADOR (
  tenant_slug STRING,
  ID_COLABORADOR INT,
  CREATE_DATE TIMESTAMP,
  LAST_UPD TIMESTAMP,
  EXPIRED INT,
  ATTEMPTS INT,
  CURRENT_PSW STRING,
  PRIVATE_CURRENT_PSW BINARY,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID_COLABORADOR)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_participant_aggregated_extract
-- @fk: Participant_Id -> raw.dbo__PARTICIPANTE_RV.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ParticipantAggregatedExtract (
  tenant_slug STRING,
  Id INT,
  DtRef TIMESTAMP,
  Extract BINARY,
  Participant_Id INT,
  Multiple DECIMAL(28,8),
  Compensation DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_participant_extract
-- @fk: HistorySection_Id -> raw.dbo__HistorySection.Id
-- @fk: ParticipantAggregatedExtract_Id -> raw.dbo__ParticipantAggregatedExtract.Id
-- @fk: Participant_Id -> raw.dbo__PARTICIPANTE_RV.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ParticipantExtract (
  tenant_slug STRING,
  Id INT,
  DtRef TIMESTAMP,
  Extract BINARY,
  Released INT,
  HistorySection_Id INT,
  Participant_Id INT,
  ParticipantAggregatedExtract_Id INT,
  Score DECIMAL(28,8),
  Multiple DECIMAL(28,8),
  Compensation DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_participant_extract_control
-- @fk: HistorySectionId -> raw.dbo__HistorySection.Id
-- @fk: Participant_Id -> raw.dbo__PARTICIPANTE_RV.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ParticipantExtractControl (
  tenant_slug STRING,
  Id INT,
  DtRef TIMESTAMP,
  Released INT,
  Participant_Id INT,
  HistorySectionId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_score_values_rv
-- @fk: CalculationPeriod_Id -> raw.dbo__PERIODO_APURACAO.ID
-- @fk: EmployeeArea_Id -> raw.dbo__AREA.ID
-- @fk: Employee_Id -> raw.dbo__COLABORADOR.ID
-- @fk: ManagementCycle_Id -> raw.dbo__PERIODO_GESTAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ScoreValuesRV (
  tenant_slug STRING,
  Id INT,
  Individual DECIMAL(28,8),
  Area DECIMAL(28,8),
  Superior DECIMAL(28,8),
  Filial DECIMAL(28,8),
  Presidencia DECIMAL(28,8),
  AvaliacaoCompetencia DECIMAL(28,8),
  Discricionario DECIMAL(28,8),
  CalculationPeriod_Id INT,
  Employee_Id INT,
  ManagementCycle_Id INT,
  DtFim TIMESTAMP,
  EmployeeArea_Id INT,
  AvaliacaoDiscricionaria DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_succession_scores_details
-- @fk: SuccessionCycleSettingsId -> raw.dbo__SuccessionCycleSettings.ID
CREATE TABLE IF NOT EXISTS raw.dbo__SuccessionScoresDetails (
  tenant_slug STRING,
  Id INT,
  MaxScore DECIMAL(18,2),
  MinScore DECIMAL(18,2),
  ReferenceScore DECIMAL(18,2),
  Dimension INT,
  SuccessionCycleSettingsId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_termo_aceite_assinatura
-- @fk: ID_AREA_COLABORADOR -> raw.dbo__AREA.ID
-- @fk: ID_RESPONSAVEL_AREA -> raw.dbo__COLABORADOR.ID
-- @fk: ID_TERMO_ACEITE -> raw.dbo__TERMO_ACEITE.ID
CREATE TABLE IF NOT EXISTS raw.dbo__TERMO_ACEITE_ASSINATURA (
  tenant_slug STRING,
  ID INT,
  ID_TERMO_ACEITE INT,
  ID_AREA_COLABORADOR INT,
  ID_COLABORADOR INT,
  ASSINATURA_COLABORADOR INT,
  DATA_ASSINATURA_COLABORADOR TIMESTAMP,
  ID_RESPONSAVEL_AREA INT,
  ASSINATURA_RESPONSAVEL_AREA INT,
  DATA_ASSINATURA_RESPONSAVEL_AREA TIMESTAMP,
  TIPO_ASSINATURA_COLABORADOR INT,
  TIPO_ASSINATURA_RESPONSAVEL_AREA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_theme_share
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: ThemeId -> raw.dbo__Theme.Id
CREATE TABLE IF NOT EXISTS raw.dbo__ThemeShare (
  tenant_slug STRING,
  Id INT,
  ThemeId INT,
  EmployeeId INT,
  PermissionType INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: FACT → edw.fact_trigger_area
-- @fk: Area_Id -> raw.dbo__AREA.ID
-- @fk: Trigger_Id -> raw.dbo__Trigger.Id
CREATE TABLE IF NOT EXISTS raw.dbo__TriggerArea (
  tenant_slug STRING,
  Id INT,
  Area_Id INT,
  Trigger_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: fatos
-- @note: Valores previsto/realizado por meta e data
-- @fk: ID_META -> raw.dbo__META.ID
-- @fk: ID_META -> raw.dbo__META.ID
CREATE TABLE IF NOT EXISTS raw.dbo__VALOR_META (
  tenant_slug STRING,
  ID INT,
  ID_META INT,
  DT_REF TIMESTAMP,
  PONTUAL_PREVISTO DOUBLE,
  PONTUAL_FORECAST1 DOUBLE,
  PONTUAL_FORECAST2 DOUBLE,
  PONTUAL_REALIZADO DOUBLE,
  ACUM_PREVISTO DOUBLE,
  ACUM_FORECAST1 DOUBLE,
  ACUM_FORECAST2 DOUBLE,
  ACUM_REALIZADO DOUBLE,
  NA INT,
  NA_PREVISTO INT,
  NA_REALIZADO INT,
  NA_FORECAST1 INT,
  NA_FORECAST2 INT,
  NA_ACUM_PREVISTO INT,
  NA_ACUM_REALIZADO INT,
  NA_ACUM_FORECAST1 INT,
  NA_ACUM_FORECAST2 INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_acao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_REUNIAO -> raw.dbo__REUNIAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ANEXO_REUNIAO (
  tenant_slug STRING,
  ID INT,
  ID_REUNIAO INT,
  ID_UPLOADER INT,
  NOME_ARQUIVO STRING,
  ARQUIVO BINARY,
  DT_ENVIO TIMESTAMP,
  ARQUIVO_TYPE STRING,
  ARQUIVO_LENGTH INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_acao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_COLABORADOR_CRIADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_COLABORADOR_PROPRIETARIO -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__DIARIO_DE_BORDO (
  tenant_slug STRING,
  ID INT,
  DESCRICAO STRING,
  TIPO_DE_ITEM INT,
  ID_COLABORADOR_PROPRIETARIO INT,
  ARQUIVADO INT,
  ID_COLABORADOR_CRIADOR INT,
  DATA_CRIACAO TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_acao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_GESTOR_MARCADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_MARCADOR_ACAO -> raw.dbo__MARCADOR_ACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__GESTOR_MARCADOR_ACAO (
  tenant_slug STRING,
  ID INT,
  ID_GESTOR_MARCADOR INT,
  ID_MARCADOR_ACAO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_acao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Action_Id -> raw.dbo__ACAO.ID
-- @fk: Cause_Id -> raw.dbo__CAUSA.ID
-- @fk: CounterMeasure_Id -> raw.dbo__CONTRAMEDIDA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__KnowledgeManagement (
  tenant_slug STRING,
  Id INT,
  Action_Id INT,
  Cause_Id INT,
  CounterMeasure_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_acao
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__MARCADOR_ACAO (
  tenant_slug STRING,
  ID INT,
  TAG STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_acao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_ACAO -> raw.dbo__ACAO.ID
-- @fk: ID_MARCADOR_ACAO -> raw.dbo__MARCADOR_ACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__MARCADOR_ACAO_ITEM (
  tenant_slug STRING,
  ID INT,
  ID_MARCADOR_ACAO INT,
  ID_ACAO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_acao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_PARTICIPANTE -> raw.dbo__COLABORADOR.ID
-- @fk: ID_REUNIAO -> raw.dbo__REUNIAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__PARTICIPANTE_REUNIAO (
  tenant_slug STRING,
  ID INT,
  ID_REUNIAO INT,
  ID_PARTICIPANTE INT,
  PARTICIPANDO INT,
  PARTICIPAR INT,
  PARTICIPAR_RECORRENTE STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_acao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_CRIADOR_ACAO -> raw.dbo__COLABORADOR.ID
-- @fk: ID_RESPONSAVEL_ACAO -> raw.dbo__COLABORADOR.ID
-- @fk: ID_REUNIAO -> raw.dbo__REUNIAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__QUICK_MEETING (
  tenant_slug STRING,
  ID INT,
  ID_CRIADOR_ACAO INT,
  ID_RESPONSAVEL_ACAO INT,
  ID_REUNIAO INT,
  COD_ACAO STRING,
  OQUE STRING,
  DT_CRIACAO_ACAO TIMESTAMP,
  DT_INI_PLANEJADA TIMESTAMP,
  DT_FIM_PLANEJADA TIMESTAMP,
  DT_INI_REALIZADA TIMESTAMP,
  DT_FIM_REALIZADA TIMESTAMP,
  PERC_REALIZADO DOUBLE,
  STATUS_ACAO INT,
  PRIORITY INT,
  ATTENTION_LAST TIMESTAMP,
  ATTENTION_COUNT INT,
  LAST_UPDATE TIMESTAMP,
  MOTIVO_CANCEL STRING,
  OBSERVACAO STRING,
  DIAS_NOTIFICAR INT,
  NOTIFICADO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_acao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_CONTRAMEDIDA -> raw.dbo__CONTRAMEDIDA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__REFERENCIA_CONTRAMEDIDA (
  tenant_slug STRING,
  ID INT,
  ID_CONTRAMEDIDA INT,
  DT_REF TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_acao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_CRIADOR_REUNIAO -> raw.dbo__COLABORADOR.ID
-- @fk: RECORRENTE_DE -> raw.dbo__REUNIAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__REUNIAO (
  tenant_slug STRING,
  ID INT,
  ID_CRIADOR_REUNIAO INT,
  TIPO_REUNIAO INT,
  STATUS_REUNIAO INT,
  ASSUNTO STRING,
  DT_REUNIAO TIMESTAMP,
  HR_INI STRING,
  HR_FIM STRING,
  DT_INI_EFETIVA TIMESTAMP,
  DT_FIM_EFETIVA TIMESTAMP,
  ALERTA_EMAIL INT,
  OBJETIVO STRING,
  TEMAS_DISCUTIDOS STRING,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  DIA_TODO INT,
  RECORRENTE INT,
  ONDE STRING,
  OBSERVACAO STRING,
  NOTIFICACAO INT,
  NOT_PERIDIOCIDADE_QUANTIDADE INT,
  NOT_PERIDIOCIDADE_TIPO INT,
  LAST_UPDATE TIMESTAMP,
  RECORRENTE_DE INT,
  RECORRENTE_LIMITE TIMESTAMP,
  RECORRENTE_TIPO INT,
  TIMEZONE STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_acao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_REUNIAO -> raw.dbo__REUNIAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__REUNIAO_PAUSE (
  tenant_slug STRING,
  ID INT,
  ID_REUNIAO INT,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_acao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_REUNIAO -> raw.dbo__REUNIAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__TOPICO_REUNIAO (
  tenant_slug STRING,
  ID INT,
  ID_REUNIAO INT,
  TITULO STRING,
  ANOTACOES STRING,
  CONCLUIDO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_acao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_CAUSA -> raw.dbo__CAUSA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__VOTACAO_CAUSA (
  tenant_slug STRING,
  ID INT,
  ID_CAUSA INT,
  NUM_PARTICIPANTE INT,
  VOTO INT,
  SELECIONADA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.competences__ItensSenderToReleaseAppraiseesQueue (
  tenant_slug STRING,
  Id INT,
  IdentifierRequest STRING,
  LocalizationCulture STRING,
  ManagementCycleId INT,
  ClientName STRING,
  AppraiseeId INT,
  TransitionType STRING,
  UserId INT,
  CreatedAt TIMESTAMP,
  Status INT,
  ProcessedAt TIMESTAMP,
  ErrorMessage STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_AVALIADO -> raw.competences__AVALIADO.ID
CREATE TABLE IF NOT EXISTS raw.competences__LOCALIDADE_INTERESSE_MUDANCA_AVALIADO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIADO INT,
  ID_PAIS INT,
  ID_REGIAO INT,
  ID_CIDADE INT,
  NOME_PAIS STRING,
  NOME_REGIAO STRING,
  NOME_CIDADE STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: CICLO_AVALIACAO -> raw.competences__AVALIACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__AVALIACAO_CONTINUA (
  tenant_slug STRING,
  Id INT,
  CICLO_AVALIACAO INT,
  MENSAGEM_EMAIL_PADRAO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__CALC_RESULTADO_AVALIADOR_TIPO_COMPETENCIA (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_AVALIADO INT,
  ID_COLABORADOR_AVALIADO INT,
  ID_AVALIADOR INT,
  ID_COLABORADOR_AVALIADOR INT,
  TIPO_COMPETENCIA INT,
  NOTA_FINAL DOUBLE,
  NOTA_FINAL_NUMERIC DECIMAL(18,5),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_AVALIADO_SUCESSAO -> raw.dbo__AVALIADO_SUCESSAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__CALC_RESULTADO_IMPACTO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIADO_SUCESSAO INT,
  NOTA_FINAL DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_AVALIADO_SUCESSAO -> raw.dbo__AVALIADO_SUCESSAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__CALC_RESULTADO_RISCO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIADO_SUCESSAO INT,
  NOTA_FINAL DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__CALC_RESULTADO_TIPO_AVALIADOR_TIPO_COMPETENCIA (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_AVALIADO INT,
  ID_COLABORADOR_AVALIADO INT,
  TIPO_AVALIADOR INT,
  TIPO_COMPETENCIA INT,
  NOTA_FINAL DOUBLE,
  NOTA_FINAL_NUMERIC DECIMAL(18,5),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__CALIBRADOS_PERFORMANCE (
  tenant_slug STRING,
  ID INT,
  NINE_BOX_ID INT,
  ID_INSTANCIA INT,
  ID_AVALIADO INT,
  NOME STRING,
  NOTA_PERFORMANCE DECIMAL(18,2),
  NOTA_COMPETENCIA DECIMAL(18,2),
  CLASSIFICACAO STRING,
  NOVA_CLASSIFICACAO STRING,
  ID_COLABORADOR_AVALIADO INT,
  ID_CLASSIFICACAO_DE INT,
  ID_CLASSIFICACAO_PARA INT,
  CLASSIFICACAO_COMPETENCIA STRING,
  NOVA_CLASSIFICACAO_COMPETENCIA STRING,
  NOTA_PERFORMANCE_CALIBRADA DECIMAL(18,9),
  NOTA_COMPETENCIA_CALIBRADA DECIMAL(18,9),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_AVALIADO_SUCESSAO -> raw.dbo__AVALIADO_SUCESSAO.ID
-- @fk: ID_FORUM_SUCESSAO -> raw.dbo__FORUM_CALIBRAGEM_SUCESSAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__COMENTARIO_AVALIADO_FORUM_SUCESSAO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIADO_SUCESSAO INT,
  ID_FORUM_SUCESSAO INT,
  COMENTARIO STRING,
  DT_ATUALIZACAO TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__DeliberationOption (
  tenant_slug STRING,
  Id INT,
  SuccessionCycleSettingsId INT,
  DeliberationDescription STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Id -> raw.dbo__TrainingClass.Id
CREATE TABLE IF NOT EXISTS raw.dbo__EffectivenessEvaluation (
  tenant_slug STRING,
  Id INT,
  InitialDescription STRING,
  CreationDate TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: EvaluationCycleForumId -> raw.dbo__NINE_BOX.ID
-- @fk: QuadrantId -> raw.dbo__EvaluationCycleQuadrant.Id
CREATE TABLE IF NOT EXISTS raw.dbo__EvaluationCycleQuadrantPersonalization (
  tenant_slug STRING,
  Id INT,
  EvaluationCycleForumId INT,
  QuadrantId INT,
  Title STRING,
  Description STRING,
  BackgroundColor STRING,
  TitleColor STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_AVALIACAO -> raw.competences__AVALIACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FORMULARIO_AVALIACAO_ABA (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  DESCRICAO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_FORMULARIO_AVALIACAO_ABA -> raw.dbo__FORMULARIO_AVALIACAO_ABA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FORMULARIO_AVALIACAO_ABA_ITEM (
  tenant_slug STRING,
  ID INT,
  ID_FORMULARIO_AVALIACAO_ABA INT,
  TIPO_CONTEUDO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_AVALIACAO -> raw.competences__AVALIACAO.ID
-- @fk: ID_GRUPO_CARGO -> raw.dbo__GRUPO_CARGO.ID
-- @fk: RoleId -> raw.competences__FUNCAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__GRUPO_CARGO_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_GRUPO_CARGO INT,
  RoleId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_CURVA_PONTUACAO_AVALIACAO -> raw.competences__CURVA_PONTUACAO_AVALIACAO.ID
-- @fk: ID_FATOR_AVALIACAO -> raw.competences__FATOR_AVALIACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__INSTANCIA_PARTICIPANTE_COMPETENCIA (
  tenant_slug STRING,
  ID INT,
  ID_FATOR_AVALIACAO INT,
  ID_CURVA_PONTUACAO_AVALIACAO INT,
  InstanceParticipantId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_FEEDBACK -> raw.dbo__FEEDBACK_CONTINUO.Id
-- @fk: ID_ITEM -> raw.dbo__ITEM_LISTA_PERSONALIZADA_FEEDBACK_CONTINUO.Id
CREATE TABLE IF NOT EXISTS raw.dbo__ITEM_FEEDBACK (
  tenant_slug STRING,
  ID INT,
  ID_ITEM INT,
  ID_FEEDBACK INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ManagerSuccessionId -> raw.dbo__ManagerSuccession.Id
CREATE TABLE IF NOT EXISTS raw.dbo__JobEvaluationSuccession (
  tenant_slug STRING,
  Id INT,
  Status INT,
  SendDate TIMESTAMP,
  DeadlineDate TIMESTAMP,
  EndDate TIMESTAMP,
  LastUpdate TIMESTAMP,
  ManagerSuccessionId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_PULSE -> raw.dbo__PULSE_FEEDBACK_CONTINUO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__OPCAO_PULSE_FEEDBACK_CONTINUO (
  tenant_slug STRING,
  ID INT,
  DESCRICAO STRING,
  ID_PULSE INT,
  EXCLUIDO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_PULSE -> raw.dbo__PULSE_FEEDBACK_CONTINUO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__PARTICIPANTE_PULSE_FEEDBACK_CONTINUO (
  tenant_slug STRING,
  ID INT,
  ID_PULSE INT,
  ID_COLABORADOR INT,
  NOTIFICADO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_AVALIACAO -> raw.competences__AVALIACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__PERIODO_AVALIACAO_PROJETO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  DT_INI_PERIODO TIMESTAMP,
  DT_FIM_PERIODO TIMESTAMP,
  DT_DEADLINE_SOLICITACAO TIMESTAMP,
  DT_DEADLINE_FEEDBACK TIMESTAMP,
  MENSAGEM STRING,
  DT_DEADLINE_PRE_CALIBRAGEM TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_AVALIACAO -> raw.competences__AVALIACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__PROJETO_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  NOME STRING,
  DESCRICAO STRING,
  DATA_INICIO TIMESTAMP,
  DATA_FIM TIMESTAMP,
  ID_AVALIACAO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_COLABORADOR_PROPRIETARIO -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__PULSE_FEEDBACK_CONTINUO (
  tenant_slug STRING,
  ID INT,
  DESCRICAO STRING,
  TIPO_RESPOSTA INT,
  ATIVO INT,
  EXCLUIDO INT,
  DATA_ENVIO TIMESTAMP,
  ID_COLABORADOR_PROPRIETARIO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Label_Id -> raw.core__Label.Id
CREATE TABLE IF NOT EXISTS raw.dbo__Question (
  tenant_slug STRING,
  Id INT,
  Description STRING,
  Type INT,
  Status INT,
  CreationDate TIMESTAMP,
  Source INT,
  Label_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: EffectivenessEvaluation_Id -> raw.dbo__EffectivenessEvaluation.Id
-- @fk: Question_Id -> raw.dbo__Question.Id
CREATE TABLE IF NOT EXISTS raw.dbo__QuestionsEffectivenessEvaluations (
  tenant_slug STRING,
  EffectivenessEvaluation_Id INT,
  Question_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, EffectivenessEvaluation_Id, Question_Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Question_Id -> raw.dbo__Question.Id
-- @fk: ReactionEvaluation_Id -> raw.dbo__ReactionEvaluation.Id
CREATE TABLE IF NOT EXISTS raw.dbo__QuestionsReactionEvaluations (
  tenant_slug STRING,
  ReactionEvaluation_Id INT,
  Question_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ReactionEvaluation_Id, Question_Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_CURVA_PONTUACAO_IMPACTO -> raw.dbo__ScoreCurveImpactSuccession.Id
-- @fk: ID_CURVA_PONTUACAO_RISCO -> raw.dbo__ScoreCurveRiskSuccession.Id
-- @fk: ID_CURVA_PONTUACAO_SUCESSAO -> raw.dbo__ScoreCurveSuccession.ID
-- @fk: ID_FORMULARIO_AVALIACAO_SUCESSAO -> raw.dbo__FORMULARIO_AVALIACAO_SUCESSAO.ID
-- @fk: ID_FUNCAO_IMPACTO -> raw.dbo__FUNCAO_IMPACTO_SUCESSAO.ID
-- @fk: ID_FUNCAO_POTENCIAL -> raw.dbo__FUNCAO_POTENCIAL_SUCESSAO.ID
-- @fk: ID_FUNCAO_RISCO -> raw.dbo__FUNCAO_RISCO_SUCESSAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__RESPOSTA_AVALIACAO_SUCESSAO (
  tenant_slug STRING,
  ID INT,
  ID_FORMULARIO_AVALIACAO_SUCESSAO INT,
  ID_FUNCAO_RISCO INT,
  ID_FUNCAO_POTENCIAL INT,
  ID_CURVA_PONTUACAO_SUCESSAO INT,
  COMENTARIO_RISCO STRING,
  COMENTARIO_POTENCIAL STRING,
  DT_RESPOSTA TIMESTAMP,
  SELECTION INT,
  ID_CURVA_PONTUACAO_RISCO INT,
  ID_FUNCAO_IMPACTO INT,
  ID_CURVA_PONTUACAO_IMPACTO INT,
  COMENTARIO_IMPACTO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_OPCAO_PULSE -> raw.dbo__OPCAO_PULSE_FEEDBACK_CONTINUO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__RESPOSTA_PULSE_FEEDBACK_CONTINUO (
  tenant_slug STRING,
  ID INT,
  ID_OPCAO_PULSE INT,
  ID_COLABORADOR INT,
  DATA_RESPOSTA TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_avaliacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Id -> raw.dbo__TrainingClass.Id
CREATE TABLE IF NOT EXISTS raw.dbo__ReactionEvaluation (
  tenant_slug STRING,
  Id INT,
  InitialDescription STRING,
  CreationDate TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: JobPositionHistory_Id -> raw.dbo__HISTORICO_CARGO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__Absence (
  tenant_slug STRING,
  Id INT,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  JobPositionHistory_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__COLABORADOR_DATA_EXTRACT (
  tenant_slug STRING,
  ID INT,
  ID_DATA_EXTRACT INT,
  NOME STRING,
  USER_LOGIN STRING,
  SCORE DECIMAL(18,6),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Demand_Id -> raw.dbo__Demand.Id
-- @fk: Employee_Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ChangeHistory (
  tenant_slug STRING,
  Id INT,
  Status INT,
  Justification STRING,
  Date TIMESTAMP,
  Demand_Id INT,
  Employee_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Creator_Id -> raw.dbo__COLABORADOR.ID
-- @fk: TrainingPackage_Id -> raw.dbo__TrainingPackage.Id
-- @fk: Training_Id -> raw.dbo__Training.Id
CREATE TABLE IF NOT EXISTS raw.dbo__Demand (
  tenant_slug STRING,
  Id INT,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  Justification STRING,
  Cost DECIMAL(28,8),
  Observation STRING,
  Status INT,
  CreationDate TIMESTAMP,
  Creator_Id INT,
  Training_Id INT,
  TrainingPackage_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Demand_Id -> raw.dbo__Demand.Id
-- @fk: Employee_Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__DemandsParticipants (
  tenant_slug STRING,
  Demand_Id INT,
  Employee_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Demand_Id, Employee_Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: ForumId -> raw.dbo__NINE_BOX.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ForumSyncLog (
  tenant_slug STRING,
  Id INT,
  ForumId INT,
  EmployeeId INT,
  StatusBeforeSync INT,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  StatusLog INT,
  ErrorLog STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: IdAuditor -> raw.dbo__COLABORADOR.ID
-- @fk: IdGoalAudit -> raw.dbo__GoalAudit.Id
CREATE TABLE IF NOT EXISTS raw.dbo__GoalAuditHistory (
  tenant_slug STRING,
  Id INT,
  IdGoalAudit INT,
  IdAuditor INT,
  Approved INT,
  Note STRING,
  Date TIMESTAMP,
  AuditStep INT,
  AuditAction INT,
  AuditInvalidationType INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: GoalId -> raw.dbo__METABOOK.ID
CREATE TABLE IF NOT EXISTS raw.dbo__GoalBookAttachment (
  tenant_slug STRING,
  Id INT,
  GoalId INT,
  EmployeeId INT,
  FileName STRING,
  Content BINARY,
  UploadDate TIMESTAMP,
  Month INT,
  Origem INT,
  ContentType STRING,
  ContentLength INT,
  Key STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Responsible_Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__GroupOfEmployees (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  Responsible_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Employee_Id -> raw.dbo__COLABORADOR.ID
-- @fk: GroupOfEmployees_Id -> raw.dbo__GroupOfEmployees.Id
CREATE TABLE IF NOT EXISTS raw.dbo__GroupOfEmployeesParticipants (
  tenant_slug STRING,
  GroupOfEmployees_Id INT,
  Employee_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, GroupOfEmployees_Id, Employee_Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: COLABORADOR_ID -> raw.dbo__COLABORADOR.ID
-- @fk: ID_FAIXA_CLASSIFICACAO_DE -> raw.competences__FAIXA_CLASSIFICACAO_AVALIACAO.ID
-- @fk: ID_FAIXA_CLASSIFICACAO_PARA -> raw.competences__FAIXA_CLASSIFICACAO_AVALIACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__INSTANCIA_CALIBRADOS (
  tenant_slug STRING,
  ID INT,
  COLABORADOR_ID INT,
  INSTANCIA_ID INT,
  ID_FAIXA_CLASSIFICACAO_DE INT,
  ID_FAIXA_CLASSIFICACAO_PARA INT,
  JUSTIFICATIVA STRING,
  OBSERVACAO STRING,
  NOTA_FINAL_CALIBRADA DECIMAL(18,9),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: COLABORADOR_ID -> raw.dbo__COLABORADOR.ID
-- @fk: ID_FAIXA_CLASSIFICACAO_PERFORMANCE_DE -> raw.competences__FAIXA_CLASSIFICACAO_PERFORMANCE_AVALIACAO.ID
-- @fk: ID_FAIXA_CLASSIFICACAO_PERFORMANCE_PARA -> raw.competences__FAIXA_CLASSIFICACAO_PERFORMANCE_AVALIACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__INSTANCIA_CALIBRADOS_PERFORMANCE (
  tenant_slug STRING,
  ID INT,
  COLABORADOR_ID INT,
  INSTANCIA_ID INT,
  ID_FAIXA_CLASSIFICACAO_PERFORMANCE_DE INT,
  ID_FAIXA_CLASSIFICACAO_PERFORMANCE_PARA INT,
  JUSTIFICATIVA STRING,
  OBSERVACAO STRING,
  NOTA_FINAL_CALIBRADA_PERFORMANCE DECIMAL(18,9),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: JobEvaluationFormId -> raw.dbo__JobEvaluationSuccession.Id
-- @fk: NomineeId -> raw.dbo__COLABORADOR.ID
-- @fk: ReadinessId -> raw.dbo__Readiness.Id
CREATE TABLE IF NOT EXISTS raw.dbo__JobEvaluationAnswerSuccession (
  tenant_slug STRING,
  Id INT,
  JobEvaluationFormId INT,
  NomineeId INT,
  ReadinessId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: KpiId -> raw.dbo__INDICADOR.ID
-- @fk: StakeholderId -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__KPIStakeholder (
  tenant_slug STRING,
  KpiId INT,
  StakeholderId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, KpiId, StakeholderId)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: IdEmployee -> raw.dbo__COLABORADOR.ID
-- @fk: IdLabel -> raw.core__Label.Id
CREATE TABLE IF NOT EXISTS raw.dbo__LabelEmployee (
  tenant_slug STRING,
  IdLabel INT,
  IdEmployee INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, IdLabel, IdEmployee)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__META_DATA_EXTRACT (
  tenant_slug STRING,
  ID_COLABORADOR INT,
  ID_DATA_EXTRACT INT,
  OBJETIVO STRING,
  PILAR_ESTRATEGICO STRING,
  VALOR_ACUM_PREVISTO DECIMAL(18,6),
  VALOR_ACUM_REALIZADO DECIMAL(18,6),
  PESO DECIMAL(18,2),
  SCORE DECIMAL(18,6),
  SCORE_PONDERADO DECIMAL(18,6),
  POLARIDADE STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Creator_Id -> raw.dbo__COLABORADOR.ID
-- @fk: Stakeholder_Id -> raw.dbo__Stakeholder.Id
CREATE TABLE IF NOT EXISTS raw.dbo__Need (
  tenant_slug STRING,
  Id INT,
  Description STRING,
  Urgency INT,
  Importancy INT,
  Creator_Id INT,
  Stakeholder_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
-- @fk: ID_MENU -> raw.dbo__MENU.ID_PK
CREATE TABLE IF NOT EXISTS raw.dbo__PERMISSAO_DASHBOARD (
  tenant_slug STRING,
  ID_COLABORADOR INT,
  ID_MENU INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: IdColaborador -> raw.dbo__COLABORADOR.ID
-- @fk: IdDimensao -> raw.dbo__Dimensao.Id
-- @fk: IdMatriz -> raw.dbo__Matriz.Id
-- @fk: IdMembroDimensao -> raw.dbo__MembroDimensao.Id
-- @fk: IdVisao -> raw.dbo__Visao.Id
CREATE TABLE IF NOT EXISTS raw.dbo__PermissaoFinanceira (
  tenant_slug STRING,
  Id INT,
  IdVisao INT,
  IdColaborador INT,
  IdMatriz INT,
  IdDimensao INT,
  IdMembroDimensao INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: EffectivenessEvaluation_Id -> raw.dbo__EffectivenessEvaluation.Id
-- @fk: Employee_Id -> raw.dbo__COLABORADOR.ID
-- @fk: Question_Id -> raw.dbo__Question.Id
-- @fk: ReactionEvaluation_Id -> raw.dbo__ReactionEvaluation.Id
CREATE TABLE IF NOT EXISTS raw.dbo__Response (
  tenant_slug STRING,
  Id INT,
  Quantitative DOUBLE,
  Descriptive STRING,
  Date TIMESTAMP,
  EffectivenessEvaluation_Id INT,
  Employee_Id INT,
  Question_Id INT,
  ReactionEvaluation_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Creator_Id -> raw.dbo__COLABORADOR.ID
-- @fk: Cycle_Id -> raw.dbo__StrategyCycle.Id
-- @fk: Responsible_Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__Stakeholder (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  Creator_Id INT,
  Cycle_Id INT,
  Responsible_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Employee_Id -> raw.dbo__COLABORADOR.ID
-- @fk: Stakeholder_Id -> raw.dbo__Stakeholder.Id
CREATE TABLE IF NOT EXISTS raw.dbo__StakeholdersCommittees (
  tenant_slug STRING,
  Stakeholder_Id INT,
  Employee_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Stakeholder_Id, Employee_Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Employee_Id -> raw.dbo__COLABORADOR.ID
-- @fk: StrategyGoalProject_Id -> raw.dbo__StrategyGoalProject.Id
CREATE TABLE IF NOT EXISTS raw.dbo__StakeholdersProject (
  tenant_slug STRING,
  StrategyGoalProject_Id INT,
  Employee_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, StrategyGoalProject_Id, Employee_Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_colaborador
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__WelcomeSupportEmployee (
  tenant_slug STRING,
  Id INT,
  Active INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__ACAO_BOOK (
  tenant_slug STRING,
  ID INT,
  ID_META INT,
  ID_CRIADOR_ACAO INT,
  ID_RESPONSAVEL_ACAO INT,
  ID_CONTRAMEDIDA INT,
  ID_CAUSA INT,
  COD_ACAO STRING,
  OQUE STRING,
  COMO STRING,
  PORQUE STRING,
  ONDE STRING,
  JUSTIFICATIVA_CANCELAMENTO STRING,
  JUSTIFICATIVA_NEGACAO STRING,
  INVESTIMENTO DOUBLE,
  RETORNO DOUBLE,
  DT_CRIACAO_ACAO TIMESTAMP,
  DT_INI_PLANEJADA TIMESTAMP,
  DT_FIM_PLANEJADA TIMESTAMP,
  DT_INI_REALIZADA TIMESTAMP,
  DT_FIM_REALIZADA TIMESTAMP,
  PERC_REALIZADO DOUBLE,
  ORIGEM_ACAO INT,
  STATUS_ACAO INT,
  STATUS_APROVACAO INT,
  DIAS_ANTECEDENCIA INT,
  EMAIL_ALERT INT,
  OBSERVACAO STRING,
  DT_UPD TIMESTAMP,
  KnowledgeManagement_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__ANEXO_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_UPLOADER INT,
  NOME_ARQUIVO STRING,
  ARQUIVO BINARY,
  DT_ENVIO TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__ANEXO_QUICK_MEETING (
  tenant_slug STRING,
  ID INT,
  ID_QUICK_MEETING INT,
  ID_UPLOADER INT,
  NOME_ARQUIVO STRING,
  ARQUIVO BINARY,
  DT_ENVIO TIMESTAMP,
  ARQUIVO_TYPE STRING,
  ARQUIVO_LENGTH INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__ActionBaseAttachment (
  tenant_slug STRING,
  Id INT,
  ActionId INT,
  FileName STRING,
  Key STRING,
  UploadDate TIMESTAMP,
  ContentType STRING,
  ContentLength INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__ActionCategoryCompetence (
  tenant_slug STRING,
  ActionCategory_Id INT,
  Competence_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ActionCategory_Id, Competence_Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__ActionEffectiveness (
  tenant_slug STRING,
  Id INT,
  UpVotes INT,
  DownVotes INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__ActionVote (
  tenant_slug STRING,
  Id INT,
  ActionId INT,
  EmployeeId INT,
  Type INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__AreaScoreRV (
  tenant_slug STRING,
  Id INT,
  Score DECIMAL(28,8),
  Date TIMESTAMP,
  Area_Id INT,
  ManagementCycle_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__AreasGroupScoreAreasMemoryRV (
  tenant_slug STRING,
  Id INT,
  AreaScoreRV_Id INT,
  AreasGroupScoreRV_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__AreasGroupScoreRV (
  tenant_slug STRING,
  Id INT,
  Score DECIMAL(28,8),
  Date TIMESTAMP,
  AreasGroup_Id INT,
  ManagementCycle_Id INT,
  Modifier_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__BKP_ACAO (
  tenant_slug STRING,
  ID INT,
  ID_META INT,
  ID_CRIADOR_ACAO INT,
  ID_RESPONSAVEL_ACAO INT,
  ID_CONTRAMEDIDA INT,
  ID_CAUSA INT,
  COD_ACAO STRING,
  OQUE STRING,
  COMO STRING,
  PORQUE STRING,
  ONDE STRING,
  JUSTIFICATIVA_CANCELAMENTO STRING,
  JUSTIFICATIVA_NEGACAO STRING,
  INVESTIMENTO DOUBLE,
  RETORNO DOUBLE,
  DT_CRIACAO_ACAO TIMESTAMP,
  DT_INI_PLANEJADA TIMESTAMP,
  DT_FIM_PLANEJADA TIMESTAMP,
  DT_INI_REALIZADA TIMESTAMP,
  DT_FIM_REALIZADA TIMESTAMP,
  PERC_REALIZADO DOUBLE,
  ORIGEM_ACAO INT,
  STATUS_ACAO INT,
  STATUS_APROVACAO INT,
  DIAS_ANTECEDENCIA INT,
  EMAIL_ALERT INT,
  OBSERVACAO STRING,
  DT_UPD TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__BKP_ACAO2 (
  tenant_slug STRING,
  ID INT,
  ID_META INT,
  ID_CRIADOR_ACAO INT,
  ID_RESPONSAVEL_ACAO INT,
  ID_CONTRAMEDIDA INT,
  ID_CAUSA INT,
  COD_ACAO STRING,
  OQUE STRING,
  COMO STRING,
  PORQUE STRING,
  ONDE STRING,
  JUSTIFICATIVA_CANCELAMENTO STRING,
  JUSTIFICATIVA_NEGACAO STRING,
  INVESTIMENTO DOUBLE,
  RETORNO DOUBLE,
  DT_CRIACAO_ACAO TIMESTAMP,
  DT_INI_PLANEJADA TIMESTAMP,
  DT_FIM_PLANEJADA TIMESTAMP,
  DT_INI_REALIZADA TIMESTAMP,
  DT_FIM_REALIZADA TIMESTAMP,
  PERC_REALIZADO DOUBLE,
  ORIGEM_ACAO INT,
  STATUS_ACAO INT,
  STATUS_APROVACAO INT,
  DIAS_ANTECEDENCIA INT,
  EMAIL_ALERT INT,
  OBSERVACAO STRING,
  DT_UPD TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__Breakdown (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  TechnicalName STRING,
  Type INT,
  ObjectCode STRING,
  ObjectDescription STRING,
  View STRING,
  Filter STRING,
  SyncStrategy INT,
  BreakdownList STRING,
  BreakdownvaluesOptionsLastSync TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__BreakdownValue (
  tenant_slug STRING,
  Id INT,
  Code STRING,
  Description STRING,
  BreakdownId INT,
  GoalId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__BreakdownValueOption (
  tenant_slug STRING,
  Id STRING,
  Code STRING,
  Description STRING,
  BreakdownId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__BrfGoalSyncLog (
  tenant_slug STRING,
  Id INT,
  GoalId INT,
  Success INT,
  Message STRING,
  Command STRING,
  ExecutionDate TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__CALCULO_MANUAL_PERFORMANCE (
  tenant_slug STRING,
  ID INT,
  ID_COLABORADOR INT,
  SCORE DECIMAL(28,8),
  DATA_REFERENCIA TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__CALC_RESULTADO_POTENCIAL (
  tenant_slug STRING,
  ID INT,
  ID_AVALIADO_SUCESSAO INT,
  NOTA_FINAL DOUBLE,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__CALC_RESULTADO_PROJETO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_AVALIADO INT,
  ID_COLABORADOR_AVALIADO INT,
  ID_PROJETO_AVALIACAO INT,
  NOTA_FINAL DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__CALENDARIO_EVENTO (
  tenant_slug STRING,
  ID INT,
  ID_CRIADOR_EVENTO INT,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  TITULO STRING,
  ONDE STRING,
  DESC_EVENTO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__CATCH_BALL_BOOK (
  tenant_slug STRING,
  ID INT,
  ID_META INT,
  ID_INDICADOR_PROPOSTO INT,
  ID_DIRETRIZ_PROPOSTO INT,
  ID_PROCESSO_PROPOSTO INT,
  ID_META_SUPERIOR_PROPOSTO INT,
  ID_DATA_PROVIDER_PROPOSTO INT,
  DT_WORKFLOW TIMESTAMP,
  OBJETIVO_PROPOSTO STRING,
  PESO_META_PROPOSTO DOUBLE,
  VALOR_META_PROPOSTO DOUBLE,
  DT_INI_PROPOSTO TIMESTAMP,
  DT_FIM_PROPOSTO TIMESTAMP,
  TIPO_ACUMULACAO_PROPOSTO INT,
  INDICADOR_JUSTIFICATIVA STRING,
  DIRETRIZ_JUSTIFICATIVA STRING,
  PROCESSO_JUSTIFICATIVA STRING,
  META_SUPERIOR_JUSTIFICATIVA STRING,
  DATA_PROVIDER_JUSTIFICATIVA STRING,
  OBJETIVO_JUSTIFICATIVA STRING,
  PESO_META_JUSTIFICATIVA STRING,
  VALOR_META_JUSTIFICATIVA STRING,
  DT_INI_JUSTIFICATIVA STRING,
  DT_FIM_JUSTIFICATIVA STRING,
  TIPO_ACUMULACAO_JUSTIFICATIVA STRING,
  OBSERVACAO STRING,
  StrategicPillarBook_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__CAUSA_BOOK (
  tenant_slug STRING,
  ID INT,
  ID_INDICADOR INT,
  ID_CONTRAMEDIDA INT,
  DESC_CAUSA STRING,
  SUB_CAUSA1 STRING,
  SUB_CAUSA2 STRING,
  SUB_CAUSA3 STRING,
  SUB_CAUSA4 STRING,
  SUB_CAUSA5 STRING,
  GESTAO_CONHECIMENTO_ATIVO INT,
  SELECIONADA INT,
  ID_CRIADOR_CAUSA INT,
  COD_CAUSA STRING,
  ID_ULTIMO_EDITOR_CAUSA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__COMENTARIO (
  tenant_slug STRING,
  ID INT,
  ID_SECAO INT,
  COD_COMENTARIO STRING,
  TITULO_COMENTARIO STRING,
  DESC_COMENTARIO STRING,
  TIPO_COMENTARIO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__COMPORTAMENTO (
  tenant_slug STRING,
  ID INT,
  ID_VALOR INT,
  COD_COMPORTAMENTO STRING,
  DESC_COMPORTAMENTO STRING,
  TITULO_COMPORTAMENTO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__Country (
  tenant_slug STRING,
  Id INT,
  Code STRING,
  Description STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__DIRETRIZ_BOOK (
  tenant_slug STRING,
  ID INT,
  COD_DIRETRIZ STRING,
  DESC_DIRETRIZ STRING,
  ID_PERIODO_GESTAO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__EMAIL_ENVIADO (
  tenant_slug STRING,
  USER_LOGIN STRING,
  DT_ENVIO DATE,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__EmployeeGuest (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  Email STRING,
  Demand_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__EmployeeModifierMonthlyGoal (
  tenant_slug STRING,
  Id INT,
  Employee_Id INT,
  Goal_Id INT,
  Modifier_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__EmployeeModifierMonthlyValue (
  tenant_slug STRING,
  Id INT,
  Date TIMESTAMP,
  Value DECIMAL(28,8),
  Employee_Id INT,
  Modifier_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__ExtractMigration (
  tenant_slug STRING,
  Id INT,
  Extract BINARY,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__FORMULARIO (
  tenant_slug STRING,
  ID INT,
  COD_FORMULARIO STRING,
  TITULO_FORMULARIO STRING,
  DESC_FORMULARIO STRING,
  LEGENDA_FORMULARIO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__FUNCAO_CARGO (
  tenant_slug STRING,
  ID INT,
  ID_FUNCAO INT,
  ID_CARGO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__FilePermission (
  tenant_slug STRING,
  Id INT,
  FileName STRING,
  FileType INT,
  LastModificationTime TIMESTAMP,
  CreationTime TIMESTAMP,
  Owner_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__GRUPO_INDICADOR_ASSOCIADO_BOOK (
  tenant_slug STRING,
  ID INT,
  ID_GRUPO_INDICADOR INT,
  ID_INDICADOR INT,
  ID_META INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__GRUPO_INDICADOR_BOOK (
  tenant_slug STRING,
  ID INT,
  ID_GRANDEZA INT,
  ID_DIRETRIZ INT,
  DESC_GRUPO_INDICADOR STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__Goal (
  tenant_slug STRING,
  Id INT,
  Objective STRING,
  KpiId INT,
  AggregationType INT,
  CalculationMemory STRING,
  DataProviderId INT,
  Currency STRING,
  ManagementCycleId INT,
  ShouldDelete INT,
  LastExecutionDate TIMESTAMP,
  LastExecutionSuccess INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__GoalCache (
  tenant_slug STRING,
  Id INT,
  Cache BINARY,
  LastUpdateTime TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__GoalCacheQueue (
  tenant_slug STRING,
  Id INT,
  LastUpdateTime TIMESTAMP,
  Goal_Id INT,
  JobId STRING,
  Status INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__GoalResponsible (
  tenant_slug STRING,
  Id INT,
  EmployeeId INT,
  GoalType INT,
  Weight DECIMAL(18,2),
  GoalId INT,
  CoreGoalId INT,
  ShouldDelete INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__GoalValue (
  tenant_slug STRING,
  Id INT,
  Period TIMESTAMP,
  GoalId INT,
  PunctualPlanned DECIMAL(28,8),
  PunctualActual DECIMAL(28,8),
  PunctualForecast1 DECIMAL(28,8),
  PunctualForecast2 DECIMAL(28,8),
  PunctualNaPlanned INT,
  PunctualNaForecast1 INT,
  PunctualNaForecast2 INT,
  PunctualNaActual INT,
  AccumulatedPlanned DECIMAL(28,8),
  AccumulatedActual DECIMAL(28,8),
  AccumulatedForecast1 DECIMAL(28,8),
  AccumulatedForecast2 DECIMAL(28,8),
  AccumulatedNaPlanned INT,
  AccumulatedNaForecast1 INT,
  AccumulatedNaForecast2 INT,
  AccumulatedNaActual INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__GroupJobAccessGroup (
  tenant_slug STRING,
  Id INT,
  Type INT,
  GroupJob_Id INT,
  Module_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__HISTORICO_COLABORADOR_CARGO (
  tenant_slug STRING,
  ID INT,
  ID_COLABORADOR INT,
  COD_CARGO STRING,
  DT_INICIO TIMESTAMP,
  DT_FIM TIMESTAMP,
  SCORE DECIMAL(20,8),
  TIPO_BONIFICACAO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__IPRestriction (
  tenant_slug STRING,
  Id INT,
  LowerIP STRING,
  UpperIP STRING,
  Type INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__ImpValorMatriz (
  tenant_slug STRING,
  IdLogImp INT,
  Line INT,
  IdValorMatriz INT,
  FkMatriz INT,
  FkMembroDimensao1 INT,
  FkMembroDimensao2 INT,
  FkMembroDimensao3 INT,
  IdUOM INT,
  FkItem INT,
  DtRef TIMESTAMP,
  PontualPrevisto DECIMAL(28,8),
  PontualForecast1 DECIMAL(28,8),
  PontualForecast2 DECIMAL(28,8),
  PontualRealizado DECIMAL(28,8),
  AcumuladoPrevisto DECIMAL(28,8),
  AcumuladoForecast1 DECIMAL(28,8),
  AcumuladoForecast2 DECIMAL(28,8),
  AcumuladoRealizado DECIMAL(28,8),
  Id INT,
  ConvertedPontualPrevisto DECIMAL(28,8),
  ConvertedPontualForecast1 DECIMAL(28,8),
  ConvertedPontualForecast2 DECIMAL(28,8),
  ConvertedPontualRealizado DECIMAL(28,8),
  ConvertedAcumPrevisto DECIMAL(28,8),
  ConvertedAcumForecast1 DECIMAL(28,8),
  ConvertedAcumForecast2 DECIMAL(28,8),
  ConvertedAcumRealizado DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__KPI (
  tenant_slug STRING,
  Id INT,
  Code STRING,
  Description STRING,
  AggregationType INT,
  Polarity INT,
  GoalDefaultValue INT,
  StrategicPillarId INT,
  IgnoredByAutomatedRobot INT,
  ReleaseDate TIMESTAMP,
  CanEditCalculationMemory INT,
  CanEditAggregationType INT,
  CanEditDataProvider INT,
  Currencies STRING,
  DataProviderId INT,
  CalculationMemory STRING,
  AutomatedKPI INT,
  View STRING,
  ActualField STRING,
  PeriodField STRING,
  FilterField STRING,
  DayOfMonth INT,
  ReferenceDate INT,
  PlannedField STRING,
  AutomatePlannedValues INT,
  CanEditPlannedValues INT,
  Enabled INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__KPIBreakdown (
  tenant_slug STRING,
  Id INT,
  KPIId INT,
  BreakdownId INT,
  LinkType INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__KPIGrouping (
  tenant_slug STRING,
  Id INT,
  IdEmployee INT,
  IdKpi INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__KPIStakeholderBook (
  tenant_slug STRING,
  KpiId INT,
  StakeholderId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, KpiId, StakeholderId)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__LISTA_PLANO_TIPO_AVALIADOR (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  ID_FUNCAO INT,
  NOME_PLANO STRING,
  DESCRICAO STRING,
  ATIVO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__META_RELACIONADA (
  tenant_slug STRING,
  ID INT,
  ID_META_ORIGEM INT,
  ID_META_RELACIONADA INT,
  COD_META_ORIGEM STRING,
  COD_META_RELACIONADA STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__MULTIPLO_NOTA (
  tenant_slug STRING,
  ID INT,
  ID_PERIODO_APURACAO INT,
  ID_NIVEL INT,
  NOTA DOUBLE,
  MULTIPLO_NOTA DOUBLE,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__ManagementCycle (
  tenant_slug STRING,
  Id INT,
  CoreManagementCycleId INT,
  CanChangeGoal INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__PDF_EXPLICATIVO_AVALIACAO (
  tenant_slug STRING,
  ID INT,
  NAME STRING,
  CONTENT_TYPE STRING,
  DATA BINARY,
  ID_AVALIACAO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__PLANO_PESO_AVALIADOR (
  tenant_slug STRING,
  ID INT,
  ID_AVALIACAO INT,
  NOME_PLANO STRING,
  AUTO INT,
  LIDER INT,
  PAR INT,
  TIME INT,
  COMITE INT,
  CLIENTE INT,
  FORNECEDOR INT,
  ATIVO INT,
  HABILITA_AUTO INT,
  HABILITA_LIDER INT,
  HABILITA_PAR INT,
  HABILITA_TIME INT,
  HABILITA_COMITE INT,
  HABILITA_CLIENTE INT,
  HABILITA_FORNECEDOR INT,
  SIGNIFICADO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__PRE_TRABALHO_AVALIADO_SUCESSAO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIADO_SUCESSAO INT,
  ID_CLASSIFICACAO_DESEMPENHO INT,
  ID_CLASSIFICACAO_POTENCIAL INT,
  COMENTARIO_DESEMPENHO STRING,
  COMENTARIO_POTENCIAL STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__ParticipantAggregatedAdvancePaymentDiscount (
  tenant_slug STRING,
  Id INT,
  Type INT,
  Value DECIMAL(28,8),
  Percentage DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__RECURRING_JOB_LOG (
  tenant_slug STRING,
  ID INT,
  ID_RECURRING_LOG INT,
  LAST_JOB_ID INT,
  DT_LOG TIMESTAMP,
  MSG STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__REFERENCIA_CAUSA (
  tenant_slug STRING,
  ID_CAUSA_DESTINO INT,
  ID_CAUSA_ORIGEM INT,
  ID_COPIADOR_CAUSA INT,
  DATA_CRIACAO TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID_CAUSA_DESTINO)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__RESPOSTA_COMENTARIO (
  tenant_slug STRING,
  ID INT,
  ID_COMENTARIO INT,
  RESPOSTA_NUMERICA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__RESPOSTA_COMPORTAMENTO (
  tenant_slug STRING,
  ID INT,
  ID_COMPORTAMENTO INT,
  RESPOSTA_NUMERICA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__SECAO (
  tenant_slug STRING,
  ID INT,
  ID_FORM INT,
  COD_SECAO STRING,
  DESC_SECAO STRING,
  TIPO_SECAO STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__TEMPLATE_USUARIO (
  tenant_slug STRING,
  ID INT,
  ID_UPLOADER INT,
  NOME_TEMPLATE STRING,
  ARQUIVO BINARY,
  DT_ENVIO TIMESTAMP,
  ATIVO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__TERMO_CONSENTIMENTO (
  tenant_slug STRING,
  Id INT,
  IdEvaluationForm INT,
  FileName STRING,
  Key STRING,
  UploadDate TIMESTAMP,
  ContentType STRING,
  ContentLength INT,
  EvaluationForm_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__TemporaryBulkInsert (
  tenant_slug STRING,
  idLogImp INT,
  line INT,
  idValorMatriz INT,
  fkMatriz INT,
  fkMembroDimensao1 INT,
  fkMembroDimensao2 INT,
  fkMembroDimensao3 INT,
  idUOM INT,
  codigoMatriz STRING,
  codigoMembroDimensao1 STRING,
  codigoMembroDimensao2 STRING,
  codigoMembroDimensao3 STRING,
  codUOM STRING,
  fkItem INT,
  item STRING,
  dtRef STRING,
  pontualPrevisto DECIMAL(28,8),
  pontualForecast1 DECIMAL(28,8),
  pontualForecast2 DECIMAL(28,8),
  pontualRealizado DECIMAL(28,8),
  acumPrevisto DECIMAL(28,8),
  acumForecast1 DECIMAL(28,8),
  acumForecast2 DECIMAL(28,8),
  acumRealizado DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__TrainingClassTimeDaily (
  tenant_slug STRING,
  Id INT,
  Date TIMESTAMP,
  StartTime TIMESTAMP,
  EndTime TIMESTAMP,
  TrainingClass_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__VALOR_SECAO (
  tenant_slug STRING,
  ID INT,
  ID_SECAO INT,
  COD_VALOR STRING,
  DESC_VALOR STRING,
  TITULO_VALOR STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__VW_AREA_QUEUE (
  tenant_slug STRING,
  ID INT,
  ID_AREA INT,
  ID_PERIODO_GESTAO INT,
  COD_FILIAL STRING,
  COD_AREA STRING,
  CURRENT_DESC_AREA STRING,
  DESC_AREA STRING,
  COD_PARENT STRING,
  INSERT_DATE TIMESTAMP,
  OPERATION INT,
  CURRENT_COD_AREA_SUP STRING,
  CURRENT_DESC_AREA_SUP STRING,
  CURRENT_ID_AREA_SUP INT,
  NEW_DESC_AREA_SUP STRING,
  NEW_ID_AREA_SUP INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__VW_COLABORADOR_INATIVADO_QUEUE (
  tenant_slug STRING,
  Id INT,
  COD_AREA STRING,
  DESC_AREA STRING,
  USER_LOGIN STRING,
  NOME STRING,
  INSERT_DATE TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__VW_COLABORADOR_QUEUE (
  tenant_slug STRING,
  ID INT,
  ID_COLABORADOR INT,
  ID_PERIODO_GESTAO INT,
  COD_AREA STRING,
  DESC_AREA STRING,
  USER_LOGIN STRING,
  AREAS_UNDER_RESP STRING,
  COD_GRUPO_USUARIO STRING,
  NOME STRING,
  ID_IDIOMA INT,
  EMAIL STRING,
  WORKFLOW_ACOES INT,
  ACTIVE INT,
  INSERT_DATE TIMESTAMP,
  OPERATION INT,
  OBSERVATION STRING,
  CURRENT_COD_AREA STRING,
  CURRENT_DESC_AREA STRING,
  CURRENT_ID_AREA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__VW_GOAL_RESPONSIBLE (
  tenant_slug STRING,
  Id INT,
  GoalId INT,
  CoreGoalId INT,
  CoreGoalCode STRING,
  ResponsibleId INT,
  ResponsibleName STRING,
  ResponsiblePhoto STRING,
  GoalType INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__VW_GOAL_WEIGHT (
  tenant_slug STRING,
  CoreGoalId INT,
  PluginGoalId INT,
  Weight DECIMAL(18,2),
  GoalResponsibleId INT,
  ManagementCycleId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, CoreGoalId)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__VW_KPI (
  tenant_slug STRING,
  Id INT,
  Code STRING,
  Description STRING,
  AggregationType INT,
  Polarity INT,
  GoalDefaultValue INT,
  StrategicPillar STRING,
  StrategicPillarId INT,
  IgnoredByAutomatedRobot INT,
  ReleaseDate TIMESTAMP,
  CanEditCalculationMemory INT,
  CanEditAggregationType INT,
  CanEditDataProvider INT,
  Currencies STRING,
  DataProvider STRING,
  CalculationMemory STRING,
  AutomatedKPI INT,
  View STRING,
  ActualField STRING,
  PeriodField STRING,
  FilterField STRING,
  DayOfMonth INT,
  ReferenceDate INT,
  PlannedField STRING,
  AutomatePlannedValues INT,
  CanEditPlannedValues INT,
  Enabled INT,
  UnitOfMeasurementDescription STRING,
  TrafficLightRange STRING,
  FollowUpFrequency STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__VW_MANAGEMENT_CYCLE (
  tenant_slug STRING,
  CoreManagementCycleId INT,
  Description STRING,
  PluginManagementCycleId INT,
  CanChangeGoal INT,
  Status INT,
  PlanningStatus INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, CoreManagementCycleId, Description)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__vw_goal (
  tenant_slug STRING,
  Id INT,
  Objective STRING,
  ResponsibleId INT,
  ResponsibleLogin STRING,
  ResponsibleName STRING,
  ProfilePhoto STRING,
  COD_AREA STRING,
  DESC_AREA STRING,
  ID_AREA INT,
  ManagementCycleId INT,
  LastExecutionDate TIMESTAMP,
  LastExecutionSuccess INT,
  KpiCode STRING,
  KpiDescription STRING,
  Polarity INT,
  CoreGoalId INT,
  CoreGoalCode STRING,
  DataProviderId INT,
  KpiId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_erp
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.import__ImportItem (
  tenant_slug STRING,
  ID INT,
  ID_LOG_IMP INT,
  LINE INT,
  STATUS INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__AREA_BOOK (
  tenant_slug STRING,
  ID INT,
  ID_PERIODO_GESTAO INT,
  ID_FILIAL INT,
  ID_RESPONSAVEL_AREA INT,
  ID_SOURCE INT,
  LEVEL_TREE STRING,
  COD_AREA STRING,
  DESC_AREA STRING,
  ATIVO INT,
  SCORE_AREA DOUBLE,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Id -> raw.dbo__PERIODO_APURACAO.ID
-- @fk: NextResultPeriod_Id -> raw.dbo__PERIODO_APURACAO.ID
-- @fk: PreviousResultPeriod_Id -> raw.dbo__PERIODO_APURACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__AdvancePaymentConfig (
  tenant_slug STRING,
  Id INT,
  AdvancePercentage DECIMAL(28,8),
  NextResultPeriod_Id INT,
  PreviousResultPeriod_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ManagementCycle_Id -> raw.dbo__PERIODO_GESTAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__AreasGroup (
  tenant_slug STRING,
  Id INT,
  Code STRING,
  Description STRING,
  ManagementCycle_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__ArvoreMembrosQuebra (
  tenant_slug STRING,
  id INT,
  Membro1 INT,
  Membro2 INT,
  Membro3 INT,
  Membro4 INT,
  Membro5 INT,
  Membro6 INT,
  Membro7 INT,
  Membro8 INT,
  Membro9 INT,
  Membro10 INT,
  IdDimensaoXYZ INT,
  idParent INT,
  idNivel STRING,
  nome STRING,
  nivel INT,
  TipoComponente INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__COLABORADOR_SCORE (
  tenant_slug STRING,
  ID INT,
  ID_PERIODO_GESTAO INT,
  ID_PERIODO_APURACAO INT,
  ID_COLABORADOR INT,
  SCORE_MANUAL DOUBLE,
  SCORE DOUBLE,
  ID_AREA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__CURVA_PONTUACAO (
  tenant_slug STRING,
  ID INT,
  CRITERIO_PONTUACAO STRING,
  SIGNIFICADO_PONTUACAO STRING,
  NOTA_REFERENCIA INT,
  NOTA_PONTUACAO INT,
  PERC_ALCANCE DOUBLE,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__CategoryAnalysis (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__Dimensao (
  tenant_slug STRING,
  Id INT,
  Codigo STRING,
  Nome STRING,
  Descricao STRING,
  IdOrigem INT,
  Bloqueada INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: CalculationPeriod_Id -> raw.dbo__PERIODO_APURACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ExtractControl (
  tenant_slug STRING,
  Id INT,
  Date TIMESTAMP,
  Enabled INT,
  CalculationPeriod_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__FAIXA_CLASSIFICACAO (
  tenant_slug STRING,
  ID INT,
  DESCRICAO STRING,
  NOTA_DE DOUBLE,
  NOTA_ATE DOUBLE,
  PORCENTAGEM_CURVA_ESPERADA DOUBLE,
  NOTA_DE_NUMERIC DECIMAL(18,5),
  NOTA_ATE_NUMERIC DECIMAL(18,5),
  MESCLAR_COM_FAIXA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__FAIXA_CLASSIFICACAO_PERFORMANCE (
  tenant_slug STRING,
  ID INT,
  DESCRICAO STRING,
  NOTA_DE DOUBLE,
  NOTA_ATE DOUBLE,
  PORCENTAGEM_CURVA_ESPERADA DOUBLE,
  MESCLAR_COM_FAIXA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_GRUPO_INDICADOR -> raw.dbo__GRUPO_INDICADOR.ID
-- @fk: ID_INDICADOR -> raw.dbo__INDICADOR.ID
-- @fk: ID_META -> raw.dbo__META.ID
CREATE TABLE IF NOT EXISTS raw.dbo__GRUPO_INDICADOR_ASSOCIADO (
  tenant_slug STRING,
  ID INT,
  ID_GRUPO_INDICADOR INT,
  ID_INDICADOR INT,
  ID_META INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: GoalId -> raw.dbo__META.ID
CREATE TABLE IF NOT EXISTS raw.dbo__GoalObservation (
  tenant_slug STRING,
  Id INT,
  GoalId INT,
  Date TIMESTAMP,
  Description STRING,
  Type INT,
  LastUpdatedDate TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_INDICADOR -> raw.dbo__INDICADOR_BOOK.ID
CREATE TABLE IF NOT EXISTS raw.dbo__INDICADOR_TIPOMETA_BOOK (
  tenant_slug STRING,
  ID INT,
  ID_INDICADOR INT,
  TIPO_META INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Project_Id -> raw.dbo__StrategyGoalProject.Id
-- @fk: Responsible_Id -> raw.dbo__COLABORADOR.ID
-- @fk: StrategyEntity_Id -> raw.core__Label.Id
CREATE TABLE IF NOT EXISTS raw.dbo__Initiative (
  tenant_slug STRING,
  Id INT,
  Description STRING,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  Project_Id INT,
  Responsible_Id INT,
  FinancialIndex INT,
  StrategyEntity_Id INT,
  StartDateRealized TIMESTAMP,
  EndDateRealized TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Analysis_Id -> raw.dbo__StrategyAnalysis.Id
-- @fk: Swot_Id -> raw.dbo__SwotAnalysis.Id
CREATE TABLE IF NOT EXISTS raw.dbo__ItemSwotAnalysis (
  tenant_slug STRING,
  Id INT,
  Type INT,
  Gravity INT,
  Urgency INT,
  Tendency INT,
  Description STRING,
  Analysis_Id INT,
  Swot_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Goal_Id -> raw.dbo__StrategyGoal.Id
-- @fk: Swot_Id -> raw.dbo__SwotAnalysis.Id
CREATE TABLE IF NOT EXISTS raw.dbo__ItemSwotAnalysisRelationship (
  tenant_slug STRING,
  Id INT,
  Goal_Id INT,
  Swot_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ItemSwotAnalysisRelationship_Id -> raw.dbo__ItemSwotAnalysisRelationship.Id
-- @fk: ItemSwotAnalysis_Id -> raw.dbo__ItemSwotAnalysis.Id
CREATE TABLE IF NOT EXISTS raw.dbo__ItemSwotAnalysisRelationshipItemSwotAnalysis (
  tenant_slug STRING,
  ItemSwotAnalysisRelationship_Id INT,
  ItemSwotAnalysis_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ItemSwotAnalysisRelationship_Id, ItemSwotAnalysis_Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Area_Id -> raw.dbo__AREA_BOOK.ID
-- @fk: IdBook -> raw.dbo__BOOK.ID
-- @fk: KPI_Id -> raw.dbo__INDICADOR_BOOK.ID
-- @fk: StrategicPillarBook_Id -> raw.dbo__DIRETRIZ_BOOK.ID
CREATE TABLE IF NOT EXISTS raw.dbo__METABOOK (
  tenant_slug STRING,
  ID INT,
  IdBook INT,
  ID_META_ORIGEM INT,
  ID_PERIODO_GESTAO INT,
  ID_AREA INT,
  ID_INDICADOR INT,
  ID_RESPONSAVEL_META INT,
  ID_DATA_PROVIDER INT,
  ID_DIRETRIZ INT,
  ID_CURVA_PREMIACAO INT,
  ID_SOURCE INT,
  COD_META STRING,
  OBJETIVO STRING,
  FONTE_DADOS STRING,
  MEMORIA_CALCULO STRING,
  PESO_META DOUBLE,
  SCORE_META DOUBLE,
  SCORE_PONDERADO DOUBLE,
  VALOR_META DOUBLE,
  DT_INI TIMESTAMP,
  DT_FIM TIMESTAMP,
  TIPO_META INT,
  META_QUALIFICADORA INT,
  TIPO_ACUMULACAO INT,
  TIPO_VALOR_META INT,
  STATUS_VALIDACAO INT,
  PASSO_VALIDACAO INT,
  LOCK_FORECAST INT,
  StrategicPillarBook_Id INT,
  KPI_Id INT,
  Area_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: FkEixoX -> raw.dbo__Dimensao.Id
-- @fk: FkEixoY -> raw.dbo__Dimensao.Id
-- @fk: FkEixoZ -> raw.dbo__Dimensao.Id
-- @fk: FkIndicador -> raw.dbo__INDICADOR.ID
-- @fk: FkTipoAcumulacao -> raw.dbo__TipoAcumulacao.Id
CREATE TABLE IF NOT EXISTS raw.dbo__Matriz (
  tenant_slug STRING,
  Id INT,
  Codigo STRING,
  Nome STRING,
  FkTipoAcumulacao INT,
  FkIndicador INT,
  FkEixoX INT,
  FkEixoY INT,
  FkEixoZ INT,
  revisao INT,
  dataCriacao TIMESTAMP,
  bloqueada INT,
  IdOrigem INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: FkDimensao -> raw.dbo__Dimensao.Id
-- @fk: FkFilial -> raw.dbo__FILIAL.ID
-- @fk: FkResponsavel -> raw.dbo__COLABORADOR.ID
-- @fk: IdParent -> raw.dbo__MembroDimensao.Id
CREATE TABLE IF NOT EXISTS raw.dbo__MembroDimensao (
  tenant_slug STRING,
  Id INT,
  Nome STRING,
  Codigo STRING,
  FkDimensao INT,
  FkResponsavel INT,
  FkFilial INT,
  LevelTree STRING,
  IdParent INT,
  TipoComponente INT,
  IdOrigem INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__MonthlyGoal (
  tenant_slug STRING,
  Id INT,
  Description STRING,
  GoalType INT,
  CreationDate TIMESTAMP,
  Year INT,
  Month INT,
  Goal DECIMAL(18,2),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_CURVA_PREMIACAO -> raw.dbo__CURVA_PREMIACAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__NOTA_BOOK (
  tenant_slug STRING,
  ID INT,
  ID_CURVA_PREMIACAO INT,
  NUM_NOTA DOUBLE,
  NOTA_META INT,
  OBRIGATORIA INT,
  ID_NOTA_ORIGEM INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_META -> raw.dbo__METABOOK.ID
-- @fk: ID_NOTA -> raw.dbo__NOTA_BOOK.ID
CREATE TABLE IF NOT EXISTS raw.dbo__NOTA_META_BOOK (
  tenant_slug STRING,
  ID INT,
  ID_META INT,
  ID_NOTA INT,
  PERC_NOTA DOUBLE,
  VALOR_NOTA DOUBLE,
  ID_NOTA_META_ORIGEM INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__NivelMembros (
  tenant_slug STRING,
  IdDimensao INT,
  idParent INT,
  Id INT,
  idNivel STRING,
  nome STRING,
  nivel INT,
  TipoComponente INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__Perspective (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  PositionOnScreen INT,
  Bgcolor STRING,
  Color STRING,
  ColorText STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Id -> raw.dbo__ActionBase.Id
-- @fk: Initiative_Id -> raw.dbo__Initiative.Id
CREATE TABLE IF NOT EXISTS raw.dbo__StrategyAction (
  tenant_slug STRING,
  Id INT,
  Initiative_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Category_Id -> raw.dbo__CategoryAnalysis.Id
-- @fk: Creator_Id -> raw.dbo__COLABORADOR.ID
-- @fk: Cycle_Id -> raw.dbo__StrategyCycle.Id
-- @fk: Responsible_Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__StrategyAnalysis (
  tenant_slug STRING,
  Id INT,
  Title STRING,
  Conclusion STRING,
  Type INT,
  Category_Id INT,
  Creator_Id INT,
  Cycle_Id INT,
  Responsible_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Analysis_Id -> raw.dbo__StrategyAnalysis.Id
CREATE TABLE IF NOT EXISTS raw.dbo__StrategyAnalysisAttachment (
  tenant_slug STRING,
  Id INT,
  FileName STRING,
  Key STRING,
  UploadDate TIMESTAMP,
  ContentType STRING,
  ContentLength INT,
  Analysis_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__StrategyCycle (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  IsCurrentCycle INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Cycle_Id -> raw.dbo__StrategyCycle.Id
-- @fk: Perspective_Id -> raw.dbo__Perspective.Id
CREATE TABLE IF NOT EXISTS raw.dbo__StrategyGoal (
  tenant_slug STRING,
  Id INT,
  Description STRING,
  Urgency INT,
  Importancy INT,
  Cycle_Id INT,
  Perspective_Id INT,
  Priority INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Creator_Id -> raw.dbo__COLABORADOR.ID
-- @fk: Goal_Id -> raw.dbo__StrategyGoal.Id
-- @fk: Kpi_Id -> raw.dbo__INDICADOR.ID
-- @fk: Responsible_Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__StrategyGoalMetric (
  tenant_slug STRING,
  Id INT,
  Description STRING,
  Weight DECIMAL(18,2),
  Creator_Id INT,
  Goal_Id INT,
  Kpi_Id INT,
  Responsible_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Goal_Id -> raw.dbo__META.ID
-- @fk: Metric_Id -> raw.dbo__StrategyGoalMetric.Id
CREATE TABLE IF NOT EXISTS raw.dbo__StrategyGoalMetricValue (
  tenant_slug STRING,
  Id INT,
  ReferenceYear INT,
  Goal_Id INT,
  Metric_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: StrategyCostCenter_Id -> raw.core__Label.Id
-- @fk: StrategyGoalResponsible_Id -> raw.dbo__COLABORADOR.ID
-- @fk: StrategyGoal_Id -> raw.dbo__StrategyGoal.Id
CREATE TABLE IF NOT EXISTS raw.dbo__StrategyGoalProject (
  tenant_slug STRING,
  Id INT,
  Description STRING,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  Weight DECIMAL(18,2),
  StrategyGoal_Id INT,
  StrategyGoalResponsible_Id INT,
  StartDateRealized TIMESTAMP,
  EndDateRealized TIMESTAMP,
  ProjectCostLinkedToCostOfActions INT,
  StrategyCostCenter_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Initiative_Id -> raw.dbo__Initiative.Id
-- @fk: Project_Id -> raw.dbo__StrategyGoalProject.Id
CREATE TABLE IF NOT EXISTS raw.dbo__StrategyGoalProjectValue (
  tenant_slug STRING,
  Id INT,
  Date TIMESTAMP,
  Planned DECIMAL(28,8),
  Forecast1 DECIMAL(28,8),
  Forecast2 DECIMAL(28,8),
  Realized DECIMAL(28,8),
  Initiative_Id INT,
  Project_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Id -> raw.dbo__StrategyCycle.Id
CREATE TABLE IF NOT EXISTS raw.dbo__SwotAnalysis (
  tenant_slug STRING,
  Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_META -> raw.dbo__METABOOK.ID
CREATE TABLE IF NOT EXISTS raw.dbo__VALOR_META_BOOK (
  tenant_slug STRING,
  ID INT,
  ID_META INT,
  DT_REF TIMESTAMP,
  PONTUAL_PREVISTO DOUBLE,
  PONTUAL_FORECAST1 DOUBLE,
  PONTUAL_FORECAST2 DOUBLE,
  PONTUAL_REALIZADO DOUBLE,
  ACUM_PREVISTO DOUBLE,
  ACUM_FORECAST1 DOUBLE,
  ACUM_FORECAST2 DOUBLE,
  ACUM_REALIZADO DOUBLE,
  NA INT,
  NA_PREVISTO INT,
  NA_REALIZADO INT,
  NA_FORECAST1 INT,
  NA_FORECAST2 INT,
  NA_ACUM_PREVISTO INT,
  NA_ACUM_FORECAST1 INT,
  NA_ACUM_FORECAST2 INT,
  NA_ACUM_REALIZADO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: FkItem -> raw.dbo__Item.Id
-- @fk: FkMatriz -> raw.dbo__Matriz.Id
-- @fk: FkMembroDimensao1 -> raw.dbo__MembroDimensao.Id
-- @fk: FkMembroDimensao2 -> raw.dbo__MembroDimensao.Id
-- @fk: FkMembroDimensao3 -> raw.dbo__MembroDimensao.Id
-- @fk: FkUnidadeMedida -> raw.dbo__UNIDADE_MEDIDA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ValorMatriz (
  tenant_slug STRING,
  Id INT,
  FkMatriz INT,
  FkMembroDimensao1 INT,
  FkMembroDimensao2 INT,
  FkMembroDimensao3 INT,
  FkUnidadeMedida INT,
  FkItem INT,
  DtRef TIMESTAMP,
  PontualPrevisto DECIMAL(28,8),
  PontualForecast1 DECIMAL(28,8),
  PontualForecast2 DECIMAL(28,8),
  PontualRealizado DECIMAL(28,8),
  AcumPrevisto DECIMAL(28,8),
  AcumForecast1 DECIMAL(28,8),
  AcumForecast2 DECIMAL(28,8),
  AcumRealizado DECIMAL(28,8),
  ConvertedPontualPrevisto DECIMAL(28,8),
  ConvertedPontualForecast1 DECIMAL(28,8),
  ConvertedPontualForecast2 DECIMAL(28,8),
  ConvertedPontualRealizado DECIMAL(28,8),
  ConvertedAcumPrevisto DECIMAL(28,8),
  ConvertedAcumForecast1 DECIMAL(28,8),
  ConvertedAcumForecast2 DECIMAL(28,8),
  ConvertedAcumRealizado DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__Visao (
  tenant_slug STRING,
  Id INT,
  Nome STRING,
  AnaliseDesvio INT,
  Flag INT,
  Acoes INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: KeyResultId -> raw.okr__KeyResult.Id
CREATE TABLE IF NOT EXISTS raw.okr__EmployeeKeyResult (
  tenant_slug STRING,
  Id INT,
  Weight DECIMAL(28,8),
  Active INT,
  EmployeeId INT,
  KeyResultId INT,
  Removed INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: MeasurementUnityId -> raw.dbo__UNIDADE_MEDIDA.ID
-- @fk: ObjectiveId -> raw.okr__Objective.Id
CREATE TABLE IF NOT EXISTS raw.okr__KeyResult (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  Code STRING,
  Active INT,
  ObjectiveId INT,
  MeasurementUnityId INT,
  CreationDate TIMESTAMP,
  Removed INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: KeyResultId -> raw.okr__KeyResult.Id
-- @fk: KeyResultValueId -> raw.okr__KeyResultValue.Id
CREATE TABLE IF NOT EXISTS raw.okr__KeyResultProgress (
  tenant_slug STRING,
  Id INT,
  KeyResultId INT,
  Value DECIMAL(28,8),
  Date TIMESTAMP,
  Active INT,
  Removed INT,
  KeyResultValueId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: KeyResultId -> raw.okr__KeyResult.Id
CREATE TABLE IF NOT EXISTS raw.okr__KeyResultValue (
  tenant_slug STRING,
  Id INT,
  Value DECIMAL(28,8),
  Comment STRING,
  Date TIMESTAMP,
  ValueType INT,
  Active INT,
  KeyResultId INT,
  EmployeeId INT,
  Removed INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.okr__Objective (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  Code STRING,
  Active INT,
  CreationDate TIMESTAMP,
  Removed INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: KeyResultProgressId -> raw.okr__KeyResultProgress.Id
-- @fk: ObjectiveId -> raw.okr__Objective.Id
CREATE TABLE IF NOT EXISTS raw.okr__ObjectiveProgress (
  tenant_slug STRING,
  Id INT,
  ObjectiveId INT,
  Value DECIMAL(28,8),
  Date TIMESTAMP,
  Active INT,
  Removed INT,
  KeyResultProgressId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ChildId -> raw.okr__Objective.Id
-- @fk: ParentId -> raw.okr__Objective.Id
CREATE TABLE IF NOT EXISTS raw.okr__ObjectiveTree (
  tenant_slug STRING,
  Id INT,
  ParentId INT,
  ChildId INT,
  Active INT,
  Removed INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_metricas
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: KrId -> raw.okr__KeyResult.Id
-- @fk: ToDoId -> raw.Tasks__ToDo.Id
CREATE TABLE IF NOT EXISTS raw.okr__ToDoKR (
  tenant_slug STRING,
  Id INT,
  ToDoId INT,
  KrId INT,
  Active INT,
  Removed INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_organizacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_AREA -> raw.dbo__AREA.ID
-- @fk: ID_AVALIADO -> raw.competences__AVALIADO.ID
CREATE TABLE IF NOT EXISTS raw.competences__AREA_INTERESSE_MUDANCA_AVALIADO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIADO INT,
  ID_AREA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_organizacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Area_Id -> raw.dbo__AREA.ID
-- @fk: Group_Id -> raw.dbo__AreasGroup.Id
CREATE TABLE IF NOT EXISTS raw.dbo__AreasGroupItem (
  tenant_slug STRING,
  Id INT,
  Area_Id INT,
  Group_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_organizacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: AreaId -> raw.dbo__AREA.ID
-- @fk: ID_COLABORADOR -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__BOOK (
  tenant_slug STRING,
  ID INT,
  DATA TIMESTAMP,
  ID_COLABORADOR_CRIADOR INT,
  ID_COLABORADOR INT,
  DATA_INICIO_PRAZO TIMESTAMP,
  DATA_FIM_PRAZO TIMESTAMP,
  DATA_INICIO_SCORE TIMESTAMP,
  DATA_FIM_SCORE TIMESTAMP,
  AreaId INT,
  ManagementCycleId INT,
  Score DECIMAL(28,8),
  DATA_ULTIMO_UPDATE TIMESTAMP,
  NOTA_PONDERADA DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_organizacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_AREA_REMANEJAMENTO -> raw.dbo__AREA.ID
-- @fk: ID_AVALIADO_SUCESSAO -> raw.dbo__AVALIADO_SUCESSAO.ID
-- @fk: ID_FORUM_SUCESSAO -> raw.dbo__FORUM_CALIBRAGEM_SUCESSAO.ID
-- @fk: ID_OPCAO_DELIBERACAO -> raw.dbo__DeliberationOption.Id
-- @fk: ID_RESPONSAVEL_DELIBERACAO -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__DELIBERACAO_FORUM_AVALIADO (
  tenant_slug STRING,
  ID INT,
  ID_AVALIADO_SUCESSAO INT,
  ID_FORUM_SUCESSAO INT,
  ID_RESPONSAVEL_DELIBERACAO INT,
  PROMOCAO_SALARIAL INT,
  PROMOCAO_POSICAO INT,
  ID_AREA_REMANEJAMENTO INT,
  DT_ATUALIZACAO TIMESTAMP,
  ID_OPCAO_DELIBERACAO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_organizacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_AREA -> raw.dbo__AREA.ID
-- @fk: ID_FUNCAO -> raw.competences__FUNCAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FUNCAO_AREA (
  tenant_slug STRING,
  ID INT,
  ID_FUNCAO INT,
  ID_AREA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_organizacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: IdArea -> raw.dbo__AREA.ID
-- @fk: IdEmployee -> raw.dbo__COLABORADOR.ID
-- @fk: IdGoal -> raw.dbo__META.ID
CREATE TABLE IF NOT EXISTS raw.dbo__GoalAudit (
  tenant_slug STRING,
  Id INT,
  IdEmployee INT,
  IdArea INT,
  AuditStatus INT,
  AuditStep INT,
  IdGoal INT,
  Month INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_organizacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: IdArea -> raw.dbo__AREA.ID
-- @fk: IdEmployee -> raw.dbo__COLABORADOR.ID
-- @fk: IdGoalWorkflowCustomStep -> raw.dbo__GoalWorkflowCustomStep.Id
CREATE TABLE IF NOT EXISTS raw.dbo__GoalWorkflowAreaEmployeeApprover (
  tenant_slug STRING,
  Id INT,
  IdGoalWorkflowCustomStep INT,
  IdEmployee INT,
  IdArea INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_organizacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: GroupJob_Id -> raw.dbo__GRUPO_CARGO.ID
-- @fk: jobPositionId -> raw.dbo__CARGO.ID
-- @fk: successionCycleId -> raw.dbo__SuccessionCycle.ID
CREATE TABLE IF NOT EXISTS raw.dbo__JobPositionSuccession (
  tenant_slug STRING,
  Id INT,
  successionCycleId INT,
  jobPositionId INT,
  jobPositionGoupId INT,
  criticalJobPosition INT,
  GroupJob_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_organizacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: JobId -> raw.dbo__CARGO.ID
-- @fk: ManagerId -> raw.dbo__COLABORADOR.ID
-- @fk: SuccessionCycleId -> raw.dbo__SuccessionCycle.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ManagerSuccession (
  tenant_slug STRING,
  Id INT,
  ManagerId INT,
  SuccessionCycleId INT,
  Status INT,
  JobId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_organizacao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Id -> raw.dbo__StrategyCycle.Id
CREATE TABLE IF NOT EXISTS raw.dbo__OrganizationIdentity (
  tenant_slug STRING,
  Id INT,
  Vision STRING,
  Mission STRING,
  Values STRING,
  CriticalFactors STRING,
  Purpose STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_pdi
-- @note: DEFER — stub EDW; sem dados piloto
CREATE TABLE IF NOT EXISTS raw.dbo__HISTORICO_PDI (
  tenant_slug STRING,
  ID INT,
  ID_PDI INT,
  ID_COLABORADOR INT,
  OBSERVACAO STRING,
  DT_CRIACAO TIMESTAMP,
  DT_INI_PLANEJADA TIMESTAMP,
  DT_FIM_PLANEJADA TIMESTAMP,
  DT_INI_REALIZADA TIMESTAMP,
  DT_FIM_REALIZADA TIMESTAMP,
  PROGRESSO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_pdi
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Label_Id -> raw.core__Label.Id
-- @fk: Training_Id -> raw.dbo__Training.Id
CREATE TABLE IF NOT EXISTS raw.dbo__LabelsTagTrainings (
  tenant_slug STRING,
  Training_Id INT,
  Label_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Training_Id, Label_Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_pdi
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Training_Id -> raw.dbo__Training.Id
CREATE TABLE IF NOT EXISTS raw.dbo__NecessaryResourcesOfTraining (
  tenant_slug STRING,
  Id INT,
  Description STRING,
  Training_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_pdi
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: LoggedUser_Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__QualificationCenterConfig (
  tenant_slug STRING,
  Id INT,
  Workflow INT,
  RequestType INT,
  ReactionEvaluationDescription STRING,
  PeriodType INT,
  Periods INT,
  EffectivenessEvaluationDescription STRING,
  CreationDate TIMESTAMP,
  StartDemandRequest TIMESTAMP,
  EndDemandRequest TIMESTAMP,
  LoggedUser_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_pdi
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Responsible_Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__QualificationManager (
  tenant_slug STRING,
  Id INT,
  Responsible_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_pdi
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Employee_Id -> raw.dbo__COLABORADOR.ID
-- @fk: QualificationManager_Id -> raw.dbo__QualificationManager.Id
CREATE TABLE IF NOT EXISTS raw.dbo__QualificationManagersSubordinates (
  tenant_slug STRING,
  QualificationManager_Id INT,
  Employee_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, QualificationManager_Id, Employee_Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_pdi
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: CategoryOfTrainning_Id -> raw.core__Label.Id
-- @fk: Creator_Id -> raw.dbo__COLABORADOR.ID
-- @fk: EducationalInstitution_Id -> raw.core__Label.Id
-- @fk: InternalInstructor_Id -> raw.dbo__COLABORADOR.ID
-- @fk: Language_Id -> raw.dbo__IDIOMA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__Training (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  Description STRING,
  Mode INT,
  CostType INT,
  Status INT,
  Workload INT,
  OnLine INT,
  Instructor STRING,
  InstructorEmail STRING,
  Observations STRING,
  StudentCounter INT,
  Score DOUBLE,
  NumberOfParticipants INT,
  ContentDescription STRING,
  Cost DECIMAL(18,2),
  Place STRING,
  Site STRING,
  CreationDate TIMESTAMP,
  CategoryOfTrainning_Id INT,
  EducationalInstitution_Id INT,
  Creator_Id INT,
  Language_Id INT,
  InstructorType INT,
  InternalInstructor_Id INT,
  NumberReactionEvaluationsAnswered INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_pdi
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Id -> raw.dbo__Training.Id
CREATE TABLE IF NOT EXISTS raw.dbo__TrainingAttachment (
  tenant_slug STRING,
  Id INT,
  FileName STRING,
  Key STRING,
  UploadDate TIMESTAMP,
  ContentType STRING,
  ContentLength INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_pdi
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Creator_Id -> raw.dbo__COLABORADOR.ID
-- @fk: TrainingPackage_Id -> raw.dbo__TrainingPackage.Id
-- @fk: Training_Id -> raw.dbo__Training.Id
CREATE TABLE IF NOT EXISTS raw.dbo__TrainingClass (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  Description STRING,
  Status INT,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  TimeType INT,
  StartTime TIMESTAMP,
  EndTime TIMESTAMP,
  CreationDate TIMESTAMP,
  Creator_Id INT,
  Training_Id INT,
  TrainingPackage_Id INT,
  Cost DECIMAL(18,2),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_pdi
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Demand_Id -> raw.dbo__Demand.Id
-- @fk: TrainingClass_Id -> raw.dbo__TrainingClass.Id
CREATE TABLE IF NOT EXISTS raw.dbo__TrainingClassDemands (
  tenant_slug STRING,
  Demand_Id INT,
  TrainingClass_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Demand_Id, TrainingClass_Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_pdi
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Employee_Id -> raw.dbo__COLABORADOR.ID
-- @fk: TrainingClass_Id -> raw.dbo__TrainingClass.Id
CREATE TABLE IF NOT EXISTS raw.dbo__TrainingClassParticipants (
  tenant_slug STRING,
  TrainingClass_Id INT,
  Employee_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, TrainingClass_Id, Employee_Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_pdi
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Employee_Id -> raw.dbo__COLABORADOR.ID
-- @fk: TrainingClass_Id -> raw.dbo__TrainingClass.Id
CREATE TABLE IF NOT EXISTS raw.dbo__TrainingClassParticipantsConfirmed (
  tenant_slug STRING,
  TrainingClass_Id INT,
  Employee_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, TrainingClass_Id, Employee_Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_pdi
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: TrainingClass_Id -> raw.dbo__TrainingClass.Id
CREATE TABLE IF NOT EXISTS raw.dbo__TrainingClassTimeWeekly (
  tenant_slug STRING,
  Id INT,
  Weekday INT,
  StartTime TIMESTAMP,
  EndTime TIMESTAMP,
  TrainingClass_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_pdi
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Id -> raw.dbo__Demand.Id
CREATE TABLE IF NOT EXISTS raw.dbo__TrainingDraft (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  Description STRING,
  EducationalInstitution STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_pdi
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Creator_Id -> raw.dbo__COLABORADOR.ID
CREATE TABLE IF NOT EXISTS raw.dbo__TrainingPackage (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  Description STRING,
  Cost DECIMAL(18,2),
  Status INT,
  StartDate TIMESTAMP,
  EndDate TIMESTAMP,
  CreationDate TIMESTAMP,
  Creator_Id INT,
  CostApportionmentType INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_pdi
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: TrainingPackage_Id -> raw.dbo__TrainingPackage.Id
-- @fk: Training_Id -> raw.dbo__Training.Id
CREATE TABLE IF NOT EXISTS raw.dbo__TrainingPackagesTrainings (
  tenant_slug STRING,
  TrainingPackage_Id INT,
  Training_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, TrainingPackage_Id, Training_Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_referencia
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_MOEDA_DESTINO -> raw.dbo__UNIDADE_MEDIDA.ID
-- @fk: ID_MOEDA_ORIGEM -> raw.dbo__UNIDADE_MEDIDA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__COTACAO_MOEDA (
  tenant_slug STRING,
  ID INT,
  ID_MOEDA_ORIGEM INT,
  ID_MOEDA_DESTINO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_referencia
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_DIRETRIZ -> raw.dbo__DIRETRIZ.ID
-- @fk: ID_GRANDEZA -> raw.dbo__GRANDEZA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__GRUPO_INDICADOR (
  tenant_slug STRING,
  ID INT,
  ID_GRANDEZA INT,
  ID_DIRETRIZ INT,
  DESC_GRUPO_INDICADOR STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_referencia
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_FAIXA_FAROL -> raw.dbo__FAIXA_FAROL.ID
-- @fk: ID_FREQUENCIA_ACOMP -> raw.dbo__FREQUENCIA_ACOMP.ID
-- @fk: ID_UNIDADE_MEDIDA -> raw.dbo__UNIDADE_MEDIDA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__INDICADOR_BOOK (
  tenant_slug STRING,
  ID INT,
  ID_UNIDADE_MEDIDA INT,
  ID_FREQUENCIA_ACOMP INT,
  ID_FAIXA_FAROL INT,
  COD_INDICADOR STRING,
  DESC_INDICADOR STRING,
  MEMORIA_CALCULO STRING,
  POLARIDADE INT,
  ATIVO INT,
  AlertDataProviderDay INT,
  AlertDataProviderAdvance INT,
  AlertDataProviderFreq INT,
  EnableEditionAlertDataProvider INT,
  AlertStakeholderDay INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_remuneracao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_COTACAO_MOEDA -> raw.dbo__COTACAO_MOEDA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__COTACAO_MOEDA_ITEM (
  tenant_slug STRING,
  ID INT,
  ID_COTACAO_MOEDA INT,
  DT_COTACAO TIMESTAMP,
  VALOR_PREVISTO DECIMAL(28,8),
  VALOR_FORECAST1 DECIMAL(28,8),
  VALOR_FORECAST2 DECIMAL(28,8),
  VALOR_REALIZADO DECIMAL(28,8),
  VALOR_ACUMULADO_PREVISTO DECIMAL(28,8),
  VALOR_ACUMULADO_FORECAST1 DECIMAL(28,8),
  VALOR_ACUMULADO_FORECAST2 DECIMAL(28,8),
  VALOR_ACUMULADO_REALIZADO DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_remuneracao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: HistorySectionId -> raw.dbo__HistorySection.Id
-- @fk: Participant_Id -> raw.dbo__PARTICIPANTE_RV.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ExtractEmployeeOptions (
  tenant_slug STRING,
  Id INT,
  ManualValue DECIMAL(28,8),
  Justification STRING,
  Participant_Id INT,
  HistorySectionId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_remuneracao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Id -> raw.dbo__ParticipantExtract.Id
CREATE TABLE IF NOT EXISTS raw.dbo__ParticipantAdvancePayment (
  tenant_slug STRING,
  Id INT,
  Type INT,
  Value DECIMAL(28,8),
  Percentage DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_remuneracao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Id -> raw.dbo__ParticipantExtract.Id
CREATE TABLE IF NOT EXISTS raw.dbo__ParticipantAdvancePaymentDiscount (
  tenant_slug STRING,
  Id INT,
  Type INT,
  Value DECIMAL(28,8),
  Percentage DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_remuneracao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: Id -> raw.dbo__ParticipantAggregatedExtract.Id
CREATE TABLE IF NOT EXISTS raw.dbo__ParticipantAggregatedAdvancePayment (
  tenant_slug STRING,
  Id INT,
  Type INT,
  Value DECIMAL(28,8),
  Percentage DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_sucessao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: SuccessionCycleId -> raw.dbo__SuccessionCycle.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ClassificationImpactOfLoss (
  tenant_slug STRING,
  Id INT,
  SuccessionCycleId INT,
  Description STRING,
  ScoreFrom DOUBLE,
  ScoreTo DOUBLE,
  ExpectedCurve DOUBLE,
  MergeWith INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_sucessao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: SuccessionCycleId -> raw.dbo__SuccessionCycle.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ClassificationRiskOfLoss (
  tenant_slug STRING,
  Id INT,
  SuccessionCycleId INT,
  Description STRING,
  ScoreFrom DOUBLE,
  ScoreTo DOUBLE,
  ExpectedCurve DOUBLE,
  MergeWith INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_sucessao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_AVALIADO_SUCESSAO -> raw.dbo__AVALIADO_SUCESSAO.ID
-- @fk: ID_CICLO_SUCESSAO -> raw.dbo__SuccessionCycle.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FORMULARIO_AVALIACAO_SUCESSAO (
  tenant_slug STRING,
  ID INT,
  ID_CICLO_SUCESSAO INT,
  ID_AVALIADO_SUCESSAO INT,
  STATUS INT,
  DT_DEADLINE TIMESTAMP,
  DT_ENVIO TIMESTAMP,
  DT_FINALIZACAO TIMESTAMP,
  DT_RASCUNHO TIMESTAMP,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_sucessao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_FORUM -> raw.dbo__FORUM_CALIBRAGEM_SUCESSAO.ID
-- @fk: ID_FUNCAO_SUCESSAO -> raw.dbo__FUNCAO_SUCESSAO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FUNCAO_FORUM_SUCESSAO (
  tenant_slug STRING,
  ID INT,
  ID_FORUM INT,
  ID_FUNCAO_SUCESSAO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_sucessao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_FUNCAO_SUCESSAO -> raw.dbo__FUNCAO_SUCESSAO.ID
-- @fk: ID_IMPACTO -> raw.dbo__IMPACTO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FUNCAO_IMPACTO_SUCESSAO (
  tenant_slug STRING,
  ID INT,
  ID_FUNCAO_SUCESSAO INT,
  ID_IMPACTO INT,
  PESO_FUNCAO_IMPACTO DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_sucessao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_FUNCAO_SUCESSAO -> raw.dbo__FUNCAO_SUCESSAO.ID
-- @fk: ID_POTENCIAL -> raw.dbo__POTENCIAL.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FUNCAO_POTENCIAL_SUCESSAO (
  tenant_slug STRING,
  ID INT,
  ID_FUNCAO_SUCESSAO INT,
  ID_POTENCIAL INT,
  PESO_FUNCAO_POTENCIAL DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_sucessao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_FUNCAO_SUCESSAO -> raw.dbo__FUNCAO_SUCESSAO.ID
-- @fk: ID_RISCO -> raw.dbo__RISCO.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FUNCAO_RISCO_SUCESSAO (
  tenant_slug STRING,
  ID INT,
  ID_FUNCAO_SUCESSAO INT,
  ID_RISCO INT,
  PESO_FUNCAO_RISCO DECIMAL(28,8),
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_sucessao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_CICLO_SUCESSAO -> raw.dbo__SuccessionCycle.ID
CREATE TABLE IF NOT EXISTS raw.dbo__FUNCAO_SUCESSAO (
  tenant_slug STRING,
  ID INT,
  COD_FUNCAO STRING,
  DESC_FUNCAO STRING,
  ID_CICLO_SUCESSAO INT,
  ID_PARENT INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_sucessao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_CICLO_SUCESSAO -> raw.dbo__SuccessionCycle.ID
CREATE TABLE IF NOT EXISTS raw.dbo__IMPACTO (
  tenant_slug STRING,
  ID INT,
  ID_CICLO_SUCESSAO INT,
  ID_PARENT INT,
  DESCRICAO STRING,
  TIPO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_sucessao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_CICLO_SUCESSAO -> raw.dbo__SuccessionCycle.ID
CREATE TABLE IF NOT EXISTS raw.dbo__POTENCIAL (
  tenant_slug STRING,
  ID INT,
  ID_CICLO_SUCESSAO INT,
  ID_PARENT INT,
  DESCRICAO STRING,
  TIPO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_sucessao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: ID_CICLO_SUCESSAO -> raw.dbo__SuccessionCycle.ID
CREATE TABLE IF NOT EXISTS raw.dbo__RISCO (
  tenant_slug STRING,
  ID INT,
  ID_CICLO_SUCESSAO INT,
  ID_PARENT INT,
  DESCRICAO STRING,
  TIPO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_sucessao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: SuccessionCycleId -> raw.dbo__SuccessionCycle.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ScoreCurveImpactSuccession (
  tenant_slug STRING,
  Id INT,
  SuccessionCycleId INT,
  Criteria STRING,
  Meaning STRING,
  ReferenceScore INT,
  Score INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_sucessao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: SuccessionCycleId -> raw.dbo__SuccessionCycle.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ScoreCurveRiskSuccession (
  tenant_slug STRING,
  Id INT,
  SuccessionCycleId INT,
  Criteria STRING,
  Meaning STRING,
  ReferenceScore INT,
  Score INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_sucessao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: SuccessionCycleId -> raw.dbo__SuccessionCycle.ID
CREATE TABLE IF NOT EXISTS raw.dbo__ScoreCurveSuccession (
  tenant_slug STRING,
  ID INT,
  SuccessionCycleId INT,
  Criteria STRING,
  Meaning STRING,
  ReferenceScore INT,
  Score INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_sucessao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: EvaluationFormOriginId -> raw.dbo__FORMULARIO_AVALIACAO_SUCESSAO.ID
-- @fk: JobPositionSuccessionId -> raw.dbo__JobPositionSuccession.Id
-- @fk: ReadinessSuccessionId -> raw.dbo__Readiness.Id
-- @fk: SuccessionCycleId -> raw.dbo__SuccessionCycle.ID
CREATE TABLE IF NOT EXISTS raw.dbo__SuccessionJobPositionReadiness (
  tenant_slug STRING,
  Id INT,
  SuccessionCycleId INT,
  MovementOrientationType INT,
  JobPositionSuccessionId INT,
  ReadinessSuccessionId INT,
  EvaluationFormOriginId INT,
  EvaluatedId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ingestao_sucessao
-- @note: DEFER — stub EDW; sem dados piloto
-- @fk: EmployeeEvalId -> raw.dbo__FORMULARIO_AVALIACAO_SUCESSAO.ID
-- @fk: EmployeeId -> raw.dbo__COLABORADOR.ID
-- @fk: EmployeeResponsibleChangeId -> raw.dbo__COLABORADOR.ID
-- @fk: JobEvalId -> raw.dbo__JobEvaluationSuccession.Id
-- @fk: JobPositionId -> raw.dbo__CARGO.ID
-- @fk: ParentId -> raw.dbo__SuccessionNomination.Id
-- @fk: ReadinessId -> raw.dbo__Readiness.Id
-- @fk: SuccessionCycleId -> raw.dbo__SuccessionCycle.ID
CREATE TABLE IF NOT EXISTS raw.dbo__SuccessionNomination (
  tenant_slug STRING,
  Id INT,
  SuccessionCycleId INT,
  FormOrigin INT,
  MovementOrientation INT,
  CreationDate TIMESTAMP,
  ChangeDate TIMESTAMP,
  EmployeeEvalId INT,
  JobEvalId INT,
  EmployeeId INT,
  EmployeeResponsibleChangeId INT,
  JobPositionId INT,
  ParentId INT,
  ReadinessId INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ref
-- @note: REF → edw.ref_customer_bound_translate_tag
-- @fk: Culture_Id -> raw.dbo__TranslateTagCulture.Id
-- @fk: Handle_Id -> raw.dbo__TranslateTagHandle.Id
CREATE TABLE IF NOT EXISTS raw.dbo__CustomerBoundTranslateTag (
  tenant_slug STRING,
  Id INT,
  Contents STRING,
  Culture_Id INT,
  Handle_Id INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ref
-- @note: REF → edw.ref_grandeza
CREATE TABLE IF NOT EXISTS raw.dbo__GRANDEZA (
  tenant_slug STRING,
  ID INT,
  DESC_GRANDEZA STRING,
  TIPO_CONVERSAO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ref
-- @note: REF → edw.ref_idioma
CREATE TABLE IF NOT EXISTS raw.dbo__IDIOMA (
  tenant_slug STRING,
  ID INT,
  DESC_IDIOMA STRING,
  IdiomaticDescription STRING,
  Locale STRING,
  SortOrder INT,
  IsActive INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ref
-- @note: REF → edw.ref_mail_config
-- @fk: ID_MODULO -> raw.dbo__Modules.Id
CREATE TABLE IF NOT EXISTS raw.dbo__MAIL_CONFIG (
  tenant_slug STRING,
  ID INT,
  TIPO_ENVIO INT,
  DESC_TIPO_ENVIO STRING,
  ATIVO INT,
  PARAMETRO STRING,
  ID_MODULO INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ref
-- @note: REF → edw.ref_plugin_info
CREATE TABLE IF NOT EXISTS raw.dbo__PLUGIN_INFO (
  tenant_slug STRING,
  PLUGIN_CODE STRING,
  ASSEMBLY_NAME STRING,
  CLASS_NAME STRING,
  METHOD_NAME STRING,
  PLUGIN_DESCRIPTION STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, PLUGIN_CODE)
) USING DELTA;

-- @layer: raw
-- @group: ref
-- @note: REF → edw.ref_system_config
CREATE TABLE IF NOT EXISTS raw.dbo__SYSTEM_CONFIG (
  tenant_slug STRING,
  CLIENT_NAME STRING,
  CLIENT_URL STRING,
  SYSTEM_VERSION STRING,
  PSW_TRY INT,
  PSW_UPPER INT,
  PSW_LOWER INT,
  PSW_NUMBER INT,
  PSW_ESPECIAL_CHAR INT,
  PSW_MIN_LENGTH INT,
  PSW_DAYS INT,
  PSW_REUSABLE INT,
  LIMIT_TREE_AREA INT,
  LIMIT_TREE_ENTIDADE INT,
  LIMIT_TREE_GRUPO_CONTA INT,
  MAIN_PAGE STRING,
  TIPO_COTACAO INT,
  FORECAST1_LABEL STRING,
  FORECAST2_LABEL STRING,
  ACCESS_GROUP_ADMIN_MANAGEMENT INT,
  ID INT,
  ClientOptions STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: raw
-- @group: ref
-- @note: REF → edw.ref_tipo_acumulacao
CREATE TABLE IF NOT EXISTS raw.dbo__TipoAcumulacao (
  tenant_slug STRING,
  Id INT,
  Nome STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ref
-- @note: REF → edw.ref_translate_tag_culture
CREATE TABLE IF NOT EXISTS raw.dbo__TranslateTagCulture (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ref
-- @note: REF → edw.ref_translate_tag_handle
CREATE TABLE IF NOT EXISTS raw.dbo__TranslateTagHandle (
  tenant_slug STRING,
  Id INT,
  Name STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, Id)
) USING DELTA;

-- @layer: raw
-- @group: ref
-- @note: Lookup unidade de medida
-- @fk: ID_GRANDEZA -> raw.dbo__GRANDEZA.ID
CREATE TABLE IF NOT EXISTS raw.dbo__UNIDADE_MEDIDA (
  tenant_slug STRING,
  ID INT,
  ID_GRANDEZA INT,
  ID_MOEDA_CONVERSAO INT,
  COD_UNIDADE_MEDIDA STRING,
  DESC_UNIDADE_MEDIDA STRING,
  SIMBOLO STRING,
  PRECISAO_DECIMAL INT,
  FATOR_CONVERSAO DOUBLE,
  REFERENCIA INT,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, ID)
) USING DELTA;

-- @layer: raw
-- @group: ref
-- @note: REF → edw.ref_versao
CREATE TABLE IF NOT EXISTS raw.dbo__VERSAO (
  tenant_slug STRING,
  NUM_VERSAO STRING,
  DT_VERSAO TIMESTAMP,
  TEXTO_PT_BR STRING,
  TEXTO_EN_US STRING,
  TEXTO_DE_DE STRING,
  TEXTO_ES_ES STRING,
  TEXTO_FR_FR STRING,
  TEXTO_ZN_CN STRING,
  _ts_ms BIGINT,
  _deleted INT,
  PRIMARY KEY (tenant_slug, NUM_VERSAO)
) USING DELTA;

-- =============================================================================
-- STAGING — cleanse/tipagem (DIM/FACT/BRIDGE/REF; DEFER fica só em raw)
-- =============================================================================

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

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.ActionBase — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ActionBase
CREATE TABLE IF NOT EXISTS staging.stg_acao_actionbase (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__ActionBase.Id
  creator_id INT, -- @map <- raw.dbo__ActionBase.CreatorId
  responsible_id INT, -- @map <- raw.dbo__ActionBase.ResponsibleId
  creation_time TIMESTAMP, -- @map <- raw.dbo__ActionBase.CreationTime
  last_modification_time TIMESTAMP, -- @map <- raw.dbo__ActionBase.LastModificationTime
  workflow_step INT, -- @map <- raw.dbo__ActionBase.WorkflowStep
  status INT, -- @map <- raw.dbo__ActionBase.Status
  code STRING, -- @map <- raw.dbo__ActionBase.Code
  description STRING, -- @map <- raw.dbo__ActionBase.Description
  how STRING, -- @map <- raw.dbo__ActionBase.How
  where STRING, -- @map <- raw.dbo__ActionBase.Where
  why STRING, -- @map <- raw.dbo__ActionBase.Why
  cancellation_justification STRING, -- @map <- raw.dbo__ActionBase.CancellationJustification
  deny_justification STRING, -- @map <- raw.dbo__ActionBase.DenyJustification
  observation STRING, -- @map <- raw.dbo__ActionBase.Observation
  planned_start_date TIMESTAMP, -- @map <- raw.dbo__ActionBase.PlannedStartDate
  planned_end_date TIMESTAMP, -- @map <- raw.dbo__ActionBase.PlannedEndDate
  actual_start_date TIMESTAMP, -- @map <- raw.dbo__ActionBase.ActualStartDate
  actual_end_date TIMESTAMP, -- @map <- raw.dbo__ActionBase.ActualEndDate
  actual_percentage DECIMAL(18,2), -- @map <- raw.dbo__ActionBase.ActualPercentage
  module_id INT, -- @map <- raw.dbo__ActionBase.ModuleId
  action_type INT, -- @map <- raw.dbo__ActionBase.ActionType
  days_in_advance INT, -- @map <- raw.dbo__ActionBase.DaysInAdvance
  email_notification_enabled INT, -- @map <- raw.dbo__ActionBase.EmailNotificationEnabled
  investment DECIMAL(18,2), -- @map <- raw.dbo__ActionBase.Investment
  return DECIMAL(18,2), -- @map <- raw.dbo__ActionBase.Return
  denied_by_id INT, -- @map <- raw.dbo__ActionBase.DeniedById
  accepted_by_id INT, -- @map <- raw.dbo__ActionBase.AcceptedById
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.ActionBaseLabel — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ActionBaseLabel
CREATE TABLE IF NOT EXISTS staging.stg_acao_actionbaselabel (
  tenant_slug STRING,
  action_base_id INT, -- @map <- raw.dbo__ActionBaseLabel.ActionBase_Id
  label_id INT, -- @map <- raw.dbo__ActionBaseLabel.Label_Id
  PRIMARY KEY (tenant_slug, action_base_id, label_id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.ANEXO_ACAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ANEXO_ACAO
CREATE TABLE IF NOT EXISTS staging.stg_acao_anexo_acao (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__ANEXO_ACAO.ID
  id_acao INT, -- @map <- raw.dbo__ANEXO_ACAO.ID_ACAO
  id_uploader INT, -- @map <- raw.dbo__ANEXO_ACAO.ID_UPLOADER
  nome_arquivo STRING, -- @map <- raw.dbo__ANEXO_ACAO.NOME_ARQUIVO
  arquivo BINARY, -- @map <- raw.dbo__ANEXO_ACAO.ARQUIVO
  dt_envio TIMESTAMP, -- @map <- raw.dbo__ANEXO_ACAO.DT_ENVIO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.CATCH_BALL — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__CATCH_BALL
CREATE TABLE IF NOT EXISTS staging.stg_acao_catch_ball (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__CATCH_BALL.ID
  id_meta INT, -- @map <- raw.dbo__CATCH_BALL.ID_META
  id_indicador_proposto INT, -- @map <- raw.dbo__CATCH_BALL.ID_INDICADOR_PROPOSTO
  id_diretriz_proposto INT, -- @map <- raw.dbo__CATCH_BALL.ID_DIRETRIZ_PROPOSTO
  id_processo_proposto INT, -- @map <- raw.dbo__CATCH_BALL.ID_PROCESSO_PROPOSTO
  id_meta_superior_proposto INT, -- @map <- raw.dbo__CATCH_BALL.ID_META_SUPERIOR_PROPOSTO
  id_data_provider_proposto INT, -- @map <- raw.dbo__CATCH_BALL.ID_DATA_PROVIDER_PROPOSTO
  dt_workflow TIMESTAMP, -- @map <- raw.dbo__CATCH_BALL.DT_WORKFLOW
  objetivo_proposto STRING, -- @map <- raw.dbo__CATCH_BALL.OBJETIVO_PROPOSTO
  peso_meta_proposto DOUBLE, -- @map <- raw.dbo__CATCH_BALL.PESO_META_PROPOSTO
  valor_meta_proposto DOUBLE, -- @map <- raw.dbo__CATCH_BALL.VALOR_META_PROPOSTO
  dt_ini_proposto TIMESTAMP, -- @map <- raw.dbo__CATCH_BALL.DT_INI_PROPOSTO
  dt_fim_proposto TIMESTAMP, -- @map <- raw.dbo__CATCH_BALL.DT_FIM_PROPOSTO
  tipo_acumulacao_proposto INT, -- @map <- raw.dbo__CATCH_BALL.TIPO_ACUMULACAO_PROPOSTO
  indicador_justificativa STRING, -- @map <- raw.dbo__CATCH_BALL.INDICADOR_JUSTIFICATIVA
  diretriz_justificativa STRING, -- @map <- raw.dbo__CATCH_BALL.DIRETRIZ_JUSTIFICATIVA
  processo_justificativa STRING, -- @map <- raw.dbo__CATCH_BALL.PROCESSO_JUSTIFICATIVA
  meta_superior_justificativa STRING, -- @map <- raw.dbo__CATCH_BALL.META_SUPERIOR_JUSTIFICATIVA
  data_provider_justificativa STRING, -- @map <- raw.dbo__CATCH_BALL.DATA_PROVIDER_JUSTIFICATIVA
  objetivo_justificativa STRING, -- @map <- raw.dbo__CATCH_BALL.OBJETIVO_JUSTIFICATIVA
  peso_meta_justificativa STRING, -- @map <- raw.dbo__CATCH_BALL.PESO_META_JUSTIFICATIVA
  valor_meta_justificativa STRING, -- @map <- raw.dbo__CATCH_BALL.VALOR_META_JUSTIFICATIVA
  dt_ini_justificativa STRING, -- @map <- raw.dbo__CATCH_BALL.DT_INI_JUSTIFICATIVA
  dt_fim_justificativa STRING, -- @map <- raw.dbo__CATCH_BALL.DT_FIM_JUSTIFICATIVA
  tipo_acumulacao_justificativa STRING, -- @map <- raw.dbo__CATCH_BALL.TIPO_ACUMULACAO_JUSTIFICATIVA
  observacao STRING, -- @map <- raw.dbo__CATCH_BALL.OBSERVACAO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.CAUSA — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__CAUSA
CREATE TABLE IF NOT EXISTS staging.stg_acao_causa (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__CAUSA.ID
  id_indicador INT, -- @map <- raw.dbo__CAUSA.ID_INDICADOR
  id_contramedida INT, -- @map <- raw.dbo__CAUSA.ID_CONTRAMEDIDA
  desc_causa STRING, -- @map <- raw.dbo__CAUSA.DESC_CAUSA
  sub_causa1 STRING, -- @map <- raw.dbo__CAUSA.SUB_CAUSA1
  sub_causa2 STRING, -- @map <- raw.dbo__CAUSA.SUB_CAUSA2
  sub_causa3 STRING, -- @map <- raw.dbo__CAUSA.SUB_CAUSA3
  sub_causa4 STRING, -- @map <- raw.dbo__CAUSA.SUB_CAUSA4
  sub_causa5 STRING, -- @map <- raw.dbo__CAUSA.SUB_CAUSA5
  gestao_conhecimento_ativo INT, -- @map <- raw.dbo__CAUSA.GESTAO_CONHECIMENTO_ATIVO
  selecionada INT, -- @map <- raw.dbo__CAUSA.SELECIONADA
  id_criador_causa INT, -- @map <- raw.dbo__CAUSA.ID_CRIADOR_CAUSA
  cod_causa STRING, -- @map <- raw.dbo__CAUSA.COD_CAUSA
  id_ultimo_editor_causa INT, -- @map <- raw.dbo__CAUSA.ID_ULTIMO_EDITOR_CAUSA
  parent_cause INT, -- @map <- raw.dbo__CAUSA.ParentCause
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.CONTRAMEDIDA — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__CONTRAMEDIDA
CREATE TABLE IF NOT EXISTS staging.stg_acao_contramedida (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__CONTRAMEDIDA.ID
  id_meta INT, -- @map <- raw.dbo__CONTRAMEDIDA.ID_META
  dt_criacao TIMESTAMP, -- @map <- raw.dbo__CONTRAMEDIDA.DT_CRIACAO
  dt_ref TIMESTAMP, -- @map <- raw.dbo__CONTRAMEDIDA.DT_REF
  is_reference INT, -- @map <- raw.dbo__CONTRAMEDIDA.IsReference
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.EFETIVIDADE_ACAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__EFETIVIDADE_ACAO
CREATE TABLE IF NOT EXISTS staging.stg_acao_efetividade_acao (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__EFETIVIDADE_ACAO.ID
  id_colaborador INT, -- @map <- raw.dbo__EFETIVIDADE_ACAO.ID_COLABORADOR
  id_acao INT, -- @map <- raw.dbo__EFETIVIDADE_ACAO.ID_ACAO
  tipo INT, -- @map <- raw.dbo__EFETIVIDADE_ACAO.TIPO
  atual INT, -- @map <- raw.dbo__EFETIVIDADE_ACAO.ATUAL
  dt_log TIMESTAMP, -- @map <- raw.dbo__EFETIVIDADE_ACAO.DT_LOG
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.HISTORICO_PERC_REALIZADO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__HISTORICO_PERC_REALIZADO
CREATE TABLE IF NOT EXISTS staging.stg_acao_historico_perc_realizado (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__HISTORICO_PERC_REALIZADO.ID
  id_acao INT, -- @map <- raw.dbo__HISTORICO_PERC_REALIZADO.ID_ACAO
  perc_realizado DOUBLE, -- @map <- raw.dbo__HISTORICO_PERC_REALIZADO.PERC_REALIZADO
  dt_upd TIMESTAMP, -- @map <- raw.dbo__HISTORICO_PERC_REALIZADO.DT_UPD
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.HISTORICO_WORKFLOW_ACAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__HISTORICO_WORKFLOW_ACAO
CREATE TABLE IF NOT EXISTS staging.stg_acao_historico_workflow_acao (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__HISTORICO_WORKFLOW_ACAO.ID
  id_acao INT, -- @map <- raw.dbo__HISTORICO_WORKFLOW_ACAO.ID_ACAO
  id_responsavel_acao INT, -- @map <- raw.dbo__HISTORICO_WORKFLOW_ACAO.ID_RESPONSAVEL_ACAO
  dt_workflow TIMESTAMP, -- @map <- raw.dbo__HISTORICO_WORKFLOW_ACAO.DT_WORKFLOW
  status_aprovacao INT, -- @map <- raw.dbo__HISTORICO_WORKFLOW_ACAO.STATUS_APROVACAO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.LabelAction — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__LabelAction
CREATE TABLE IF NOT EXISTS staging.stg_acao_labelaction (
  tenant_slug STRING,
  id_label INT, -- @map <- raw.dbo__LabelAction.IdLabel
  id_action INT, -- @map <- raw.dbo__LabelAction.IdAction
  PRIMARY KEY (tenant_slug, id_label, id_action)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.NOTIFICACAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__NOTIFICACAO
CREATE TABLE IF NOT EXISTS staging.stg_acao_notificacao (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__NOTIFICACAO.ID
  titulo_modal STRING, -- @map <- raw.dbo__NOTIFICACAO.TITULO_MODAL
  descricao_notificacao STRING, -- @map <- raw.dbo__NOTIFICACAO.DESCRICAO_NOTIFICACAO
  ativo INT, -- @map <- raw.dbo__NOTIFICACAO.ATIVO
  tipo_notificacao INT, -- @map <- raw.dbo__NOTIFICACAO.TIPO_NOTIFICACAO
  data_expiracao TIMESTAMP, -- @map <- raw.dbo__NOTIFICACAO.DATA_EXPIRACAO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.RECURRING_JOB — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__RECURRING_JOB
CREATE TABLE IF NOT EXISTS staging.stg_acao_recurring_job (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__RECURRING_JOB.ID
  job_id STRING, -- @map <- raw.dbo__RECURRING_JOB.JOB_ID
  tipo_job INT, -- @map <- raw.dbo__RECURRING_JOB.TIPO_JOB
  cron_expression STRING, -- @map <- raw.dbo__RECURRING_JOB.CRON_EXPRESSION
  job_description STRING, -- @map <- raw.dbo__RECURRING_JOB.JOB_DESCRIPTION
  ativo INT, -- @map <- raw.dbo__RECURRING_JOB.ATIVO
  parameters STRING, -- @map <- raw.dbo__RECURRING_JOB.PARAMETERS
  PRIMARY KEY (tenant_slug, id)
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
-- @note: Cleanse competences.AVALIADO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__AVALIADO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_avaliado (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__AVALIADO.ID
  id_avaliacao INT, -- @map <- raw.competences__AVALIADO.ID_AVALIACAO
  id_colaborador_avaliado INT, -- @map <- raw.competences__AVALIADO.ID_COLABORADOR_AVALIADO
  id_colaborador_funcao INT, -- @map <- raw.competences__AVALIADO.ID_COLABORADOR_FUNCAO
  email_boas_vindas_recebido INT, -- @map <- raw.competences__AVALIADO.EMAIL_BOAS_VINDAS_RECEBIDO
  area_de_interesse_de_mudanca INT, -- @map <- raw.competences__AVALIADO.AREA_DE_INTERESSE_DE_MUDANCA
  status INT, -- @map <- raw.competences__AVALIADO.Status
  migrado_novo_gt INT, -- @map <- raw.competences__AVALIADO.MIGRADO_NOVO_GT
  id_colaborador_sucessor INT, -- @map <- raw.competences__AVALIADO.ID_COLABORADOR_SUCESSOR
  tempo_necessario_sucessor INT, -- @map <- raw.competences__AVALIADO.TEMPO_NECESSARIO_SUCESSOR
  tipo_tempo_sucessor INT, -- @map <- raw.competences__AVALIADO.TIPO_TEMPO_SUCESSOR
  data_indicacao TIMESTAMP, -- @map <- raw.competences__AVALIADO.DATA_INDICACAO
  data_aprovacao_indicacao TIMESTAMP, -- @map <- raw.competences__AVALIADO.DATA_APROVACAO_INDICACAO
  bloqueado_para_liberacao INT, -- @map <- raw.competences__AVALIADO.BLOQUEADO_PARA_LIBERACAO
  bloqueado_para_liberacao_indicacao INT, -- @map <- raw.competences__AVALIADO.BLOQUEADO_PARA_LIBERACAO_INDICACAO
  bloqueado_para_liberacao_aprovacao_indicacao INT, -- @map <- raw.competences__AVALIADO.BLOQUEADO_PARA_LIBERACAO_APROVACAO_INDICACAO
  indication_comment STRING, -- @map <- raw.competences__AVALIADO.IndicationComment
  leader_indication_comment STRING, -- @map <- raw.competences__AVALIADO.LeaderIndicationComment
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.AVALIADOR — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__AVALIADOR
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_avaliador (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__AVALIADOR.ID
  id_avaliacao INT, -- @map <- raw.competences__AVALIADOR.ID_AVALIACAO
  id_avaliado INT, -- @map <- raw.competences__AVALIADOR.ID_AVALIADO
  id_colaborador_avaliador INT, -- @map <- raw.competences__AVALIADOR.ID_COLABORADOR_AVALIADOR
  tipo_avaliador INT, -- @map <- raw.competences__AVALIADOR.TIPO_AVALIADOR
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.CALC_RESPOSTA — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__CALC_RESPOSTA
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_calc_resposta (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__CALC_RESPOSTA.ID
  id_avaliacao INT, -- @map <- raw.competences__CALC_RESPOSTA.ID_AVALIACAO
  id_formulario_avaliacao INT, -- @map <- raw.competences__CALC_RESPOSTA.ID_FORMULARIO_AVALIACAO
  id_avaliado INT, -- @map <- raw.competences__CALC_RESPOSTA.ID_AVALIADO
  id_avaliador INT, -- @map <- raw.competences__CALC_RESPOSTA.ID_AVALIADOR
  id_funcao INT, -- @map <- raw.competences__CALC_RESPOSTA.ID_FUNCAO
  id_resposta_avaliacao INT, -- @map <- raw.competences__CALC_RESPOSTA.ID_RESPOSTA_AVALIACAO
  peso_funcao_competencia DECIMAL(28,8), -- @map <- raw.competences__CALC_RESPOSTA.PESO_FUNCAO_COMPETENCIA
  nota_referencia DECIMAL(28,8), -- @map <- raw.competences__CALC_RESPOSTA.NOTA_REFERENCIA
  perc_alcance_referencia DECIMAL(28,8), -- @map <- raw.competences__CALC_RESPOSTA.PERC_ALCANCE_REFERENCIA
  nota_resposta DECIMAL(28,8), -- @map <- raw.competences__CALC_RESPOSTA.NOTA_RESPOSTA
  perc_alcance_resposta DECIMAL(28,8), -- @map <- raw.competences__CALC_RESPOSTA.PERC_ALCANCE_RESPOSTA
  nota_consenso DECIMAL(28,8), -- @map <- raw.competences__CALC_RESPOSTA.NOTA_CONSENSO
  perc_alcance_consenso DECIMAL(28,8), -- @map <- raw.competences__CALC_RESPOSTA.PERC_ALCANCE_CONSENSO
  nota_ponderada DECIMAL(28,8), -- @map <- raw.competences__CALC_RESPOSTA.NOTA_PONDERADA
  perc_ponderado DECIMAL(28,8), -- @map <- raw.competences__CALC_RESPOSTA.PERC_PONDERADO
  nota_consenso_ponderada DECIMAL(28,8), -- @map <- raw.competences__CALC_RESPOSTA.NOTA_CONSENSO_PONDERADA
  perc_consenso_ponderado DECIMAL(28,8), -- @map <- raw.competences__CALC_RESPOSTA.PERC_CONSENSO_PONDERADO
  nota_ponderada_numeric DECIMAL(18,5), -- @map <- raw.competences__CALC_RESPOSTA.NOTA_PONDERADA_NUMERIC
  nota_consenso_ponderada_numeric DECIMAL(18,5), -- @map <- raw.competences__CALC_RESPOSTA.NOTA_CONSENSO_PONDERADA_NUMERIC
  feedback_enviado INT, -- @map <- raw.competences__CALC_RESPOSTA.FEEDBACK_ENVIADO
  nota_calibrada DECIMAL(28,8), -- @map <- raw.competences__CALC_RESPOSTA.NOTA_CALIBRADA
  nota_calibrada_ponderada DECIMAL(28,8), -- @map <- raw.competences__CALC_RESPOSTA.NOTA_CALIBRADA_PONDERADA
  weighted_assessmet_competence_type_score DECIMAL(28,8), -- @map <- raw.competences__CALC_RESPOSTA.WeightedAssessmetCompetenceTypeScore
  applied_weight_general_score DECIMAL(28,8), -- @map <- raw.competences__CALC_RESPOSTA.AppliedWeightGeneralScore
  applied_weight_competence_type_score DECIMAL(28,8), -- @map <- raw.competences__CALC_RESPOSTA.AppliedWeightCompetenceTypeScore
  PRIMARY KEY (tenant_slug, id)
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
-- @note: Cleanse competences.CALC_RESULTADO_AVALIADOR — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__CALC_RESULTADO_AVALIADOR
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_calc_resultado_avaliador (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__CALC_RESULTADO_AVALIADOR.ID
  id_avaliacao INT, -- @map <- raw.competences__CALC_RESULTADO_AVALIADOR.ID_AVALIACAO
  id_avaliado INT, -- @map <- raw.competences__CALC_RESULTADO_AVALIADOR.ID_AVALIADO
  id_colaborador_avaliado INT, -- @map <- raw.competences__CALC_RESULTADO_AVALIADOR.ID_COLABORADOR_AVALIADO
  id_avaliador INT, -- @map <- raw.competences__CALC_RESULTADO_AVALIADOR.ID_AVALIADOR
  id_colaborador_avaliador INT, -- @map <- raw.competences__CALC_RESULTADO_AVALIADOR.ID_COLABORADOR_AVALIADOR
  nota_final DECIMAL(28,8), -- @map <- raw.competences__CALC_RESULTADO_AVALIADOR.NOTA_FINAL
  nota_final_numeric DECIMAL(28,8), -- @map <- raw.competences__CALC_RESULTADO_AVALIADOR.NOTA_FINAL_NUMERIC
  nota_final_habilidade DECIMAL(28,8), -- @map <- raw.competences__CALC_RESULTADO_AVALIADOR.NOTA_FINAL_HABILIDADE
  nota_final_comportamental DECIMAL(28,8), -- @map <- raw.competences__CALC_RESULTADO_AVALIADOR.NOTA_FINAL_COMPORTAMENTAL
  nota_final_numeric_habilidade DECIMAL(28,8), -- @map <- raw.competences__CALC_RESULTADO_AVALIADOR.NOTA_FINAL_NUMERIC_HABILIDADE
  nota_final_numeric_comportamental DECIMAL(28,8), -- @map <- raw.competences__CALC_RESULTADO_AVALIADOR.NOTA_FINAL_NUMERIC_COMPORTAMENTAL
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.CALC_RESULTADO_COLABORADOR_PERFORMANCE — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__CALC_RESULTADO_COLABORADOR_PERFORMANCE
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_calc_resultado_colaborador_performance (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__CALC_RESULTADO_COLABORADOR_PERFORMANCE.ID
  id_avaliado INT, -- @map <- raw.competences__CALC_RESULTADO_COLABORADOR_PERFORMANCE.ID_AVALIADO
  nota_final DECIMAL(28,8), -- @map <- raw.competences__CALC_RESULTADO_COLABORADOR_PERFORMANCE.NOTA_FINAL
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.CALC_RESULTADO_COMPETENCIA — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__CALC_RESULTADO_COMPETENCIA
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_calc_resultado_competencia (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__CALC_RESULTADO_COMPETENCIA.ID
  id_avaliacao INT, -- @map <- raw.competences__CALC_RESULTADO_COMPETENCIA.ID_AVALIACAO
  id_avaliado INT, -- @map <- raw.competences__CALC_RESULTADO_COMPETENCIA.ID_AVALIADO
  id_colaborador_avaliado INT, -- @map <- raw.competences__CALC_RESULTADO_COMPETENCIA.ID_COLABORADOR_AVALIADO
  id_competencia INT, -- @map <- raw.competences__CALC_RESULTADO_COMPETENCIA.ID_COMPETENCIA
  nota_final DECIMAL(28,8), -- @map <- raw.competences__CALC_RESULTADO_COMPETENCIA.NOTA_FINAL
  nota_final_consensada DECIMAL(28,8), -- @map <- raw.competences__CALC_RESULTADO_COMPETENCIA.NOTA_FINAL_CONSENSADA
  nota_final_calibrada DECIMAL(28,8), -- @map <- raw.competences__CALC_RESULTADO_COMPETENCIA.NOTA_FINAL_CALIBRADA
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.CALC_RESULTADO_FATOR_AVALIACAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__CALC_RESULTADO_FATOR_AVALIACAO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_calc_resultado_fator_avaliacao (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__CALC_RESULTADO_FATOR_AVALIACAO.ID
  id_avaliacao INT, -- @map <- raw.competences__CALC_RESULTADO_FATOR_AVALIACAO.ID_AVALIACAO
  id_avaliado INT, -- @map <- raw.competences__CALC_RESULTADO_FATOR_AVALIACAO.ID_AVALIADO
  id_colaborador_avaliado INT, -- @map <- raw.competences__CALC_RESULTADO_FATOR_AVALIACAO.ID_COLABORADOR_AVALIADO
  id_funcao_competencia INT, -- @map <- raw.competences__CALC_RESULTADO_FATOR_AVALIACAO.ID_FUNCAO_COMPETENCIA
  id_competencia INT, -- @map <- raw.competences__CALC_RESULTADO_FATOR_AVALIACAO.ID_COMPETENCIA
  id_fator_avaliacao INT, -- @map <- raw.competences__CALC_RESULTADO_FATOR_AVALIACAO.ID_FATOR_AVALIACAO
  nota_final DECIMAL(28,8), -- @map <- raw.competences__CALC_RESULTADO_FATOR_AVALIACAO.NOTA_FINAL
  nota_final_consensada DECIMAL(28,8), -- @map <- raw.competences__CALC_RESULTADO_FATOR_AVALIACAO.NOTA_FINAL_CONSENSADA
  nota_final_calibrada DECIMAL(28,8), -- @map <- raw.competences__CALC_RESULTADO_FATOR_AVALIACAO.NOTA_FINAL_CALIBRADA
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.CALC_RESULTADO_TIPO_AVALIADOR — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__CALC_RESULTADO_TIPO_AVALIADOR
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_calc_resultado_tipo_avaliador (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__CALC_RESULTADO_TIPO_AVALIADOR.ID
  id_avaliacao INT, -- @map <- raw.competences__CALC_RESULTADO_TIPO_AVALIADOR.ID_AVALIACAO
  id_avaliado INT, -- @map <- raw.competences__CALC_RESULTADO_TIPO_AVALIADOR.ID_AVALIADO
  id_colaborador_avaliado INT, -- @map <- raw.competences__CALC_RESULTADO_TIPO_AVALIADOR.ID_COLABORADOR_AVALIADO
  tipo_avaliador INT, -- @map <- raw.competences__CALC_RESULTADO_TIPO_AVALIADOR.TIPO_AVALIADOR
  nota_final DECIMAL(28,8), -- @map <- raw.competences__CALC_RESULTADO_TIPO_AVALIADOR.NOTA_FINAL
  nota_final_numeric DECIMAL(28,8), -- @map <- raw.competences__CALC_RESULTADO_TIPO_AVALIADOR.NOTA_FINAL_NUMERIC
  technical_final_score DECIMAL(28,8), -- @map <- raw.competences__CALC_RESULTADO_TIPO_AVALIADOR.TechnicalFinalScore
  behavioral_final_score DECIMAL(28,8), -- @map <- raw.competences__CALC_RESULTADO_TIPO_AVALIADOR.BehavioralFinalScore
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.COMENTARIO_AVALIADO_NINE_BOX — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__COMENTARIO_AVALIADO_NINE_BOX
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_comentario_avaliado_nine_box (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__COMENTARIO_AVALIADO_NINE_BOX.ID
  id_avaliado INT, -- @map <- raw.competences__COMENTARIO_AVALIADO_NINE_BOX.ID_AVALIADO
  id_nine_box INT, -- @map <- raw.competences__COMENTARIO_AVALIADO_NINE_BOX.ID_NINE_BOX
  comentario STRING, -- @map <- raw.competences__COMENTARIO_AVALIADO_NINE_BOX.COMENTARIO
  dt_atualizacao TIMESTAMP, -- @map <- raw.competences__COMENTARIO_AVALIADO_NINE_BOX.DT_ATUALIZACAO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.COMENTARIO_COMPETENCIA — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__COMENTARIO_COMPETENCIA
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_comentario_competencia (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__COMENTARIO_COMPETENCIA.ID
  id_formulario_avaliacao INT, -- @map <- raw.competences__COMENTARIO_COMPETENCIA.ID_FORMULARIO_AVALIACAO
  id_competencia INT, -- @map <- raw.competences__COMENTARIO_COMPETENCIA.ID_COMPETENCIA
  comentario STRING, -- @map <- raw.competences__COMENTARIO_COMPETENCIA.COMENTARIO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.CompetenceTypeComment — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__CompetenceTypeComment
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_competencetypecomment (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__CompetenceTypeComment.Id
  evaluation_form_id INT, -- @map <- raw.competences__CompetenceTypeComment.EvaluationFormId
  competence_type INT, -- @map <- raw.competences__CompetenceTypeComment.CompetenceType
  comment STRING, -- @map <- raw.competences__CompetenceTypeComment.Comment
  PRIMARY KEY (tenant_slug, id)
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
-- @note: Cleanse dbo.CONFIGURACOES_GERAIS_FEEDBACK_CONTINUO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__CONFIGURACOES_GERAIS_FEEDBACK_CONTINUO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_configuracoes_gerais_feedback_continuo (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__CONFIGURACOES_GERAIS_FEEDBACK_CONTINUO.ID
  feedback_anonimo_ativo INT, -- @map <- raw.dbo__CONFIGURACOES_GERAIS_FEEDBACK_CONTINUO.FEEDBACK_ANONIMO_ATIVO
  feedback_direto_ativo INT, -- @map <- raw.dbo__CONFIGURACOES_GERAIS_FEEDBACK_CONTINUO.FEEDBACK_DIRETO_ATIVO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.CONSIDERACAO_FINAL — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__CONSIDERACAO_FINAL
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_consideracao_final (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__CONSIDERACAO_FINAL.ID
  id_formulario_avaliacao INT, -- @map <- raw.competences__CONSIDERACAO_FINAL.ID_FORMULARIO_AVALIACAO
  pontos_positivos STRING, -- @map <- raw.competences__CONSIDERACAO_FINAL.PONTOS_POSITIVOS
  pontos_desenvolver STRING, -- @map <- raw.competences__CONSIDERACAO_FINAL.PONTOS_DESENVOLVER
  comentario_final STRING, -- @map <- raw.competences__CONSIDERACAO_FINAL.COMENTARIO_FINAL
  comentario_lider STRING, -- @map <- raw.competences__CONSIDERACAO_FINAL.COMENTARIO_LIDER
  comentario_avaliado STRING, -- @map <- raw.competences__CONSIDERACAO_FINAL.COMENTARIO_AVALIADO
  comentario_qualidade STRING, -- @map <- raw.competences__CONSIDERACAO_FINAL.COMENTARIO_QUALIDADE
  nota_qualidade INT, -- @map <- raw.competences__CONSIDERACAO_FINAL.NOTA_QUALIDADE
  data_feedback TIMESTAMP, -- @map <- raw.competences__CONSIDERACAO_FINAL.DATA_FEEDBACK
  qualidade_avaliada INT, -- @map <- raw.competences__CONSIDERACAO_FINAL.QUALIDADE_AVALIADA
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.CURVA_PONTUACAO_AVALIACAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__CURVA_PONTUACAO_AVALIACAO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_curva_pontuacao_avaliacao (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__CURVA_PONTUACAO_AVALIACAO.ID
  id_avaliacao INT, -- @map <- raw.competences__CURVA_PONTUACAO_AVALIACAO.ID_AVALIACAO
  criterio_pontuacao STRING, -- @map <- raw.competences__CURVA_PONTUACAO_AVALIACAO.CRITERIO_PONTUACAO
  significado_pontuacao STRING, -- @map <- raw.competences__CURVA_PONTUACAO_AVALIACAO.SIGNIFICADO_PONTUACAO
  nota_referencia INT, -- @map <- raw.competences__CURVA_PONTUACAO_AVALIACAO.NOTA_REFERENCIA
  nota_pontuacao INT, -- @map <- raw.competences__CURVA_PONTUACAO_AVALIACAO.NOTA_PONTUACAO
  perc_alcance DECIMAL(28,8), -- @map <- raw.competences__CURVA_PONTUACAO_AVALIACAO.PERC_ALCANCE
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.EvaluationCycleCalcResultEvaluated — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__EvaluationCycleCalcResultEvaluated
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_evaluationcyclecalcresultevaluated (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__EvaluationCycleCalcResultEvaluated.Id
  evaluation_cycle_id INT, -- @map <- raw.competences__EvaluationCycleCalcResultEvaluated.EvaluationCycleId
  evaluated_id INT, -- @map <- raw.competences__EvaluationCycleCalcResultEvaluated.EvaluatedId
  employee_evaluated_id INT, -- @map <- raw.competences__EvaluationCycleCalcResultEvaluated.EmployeeEvaluatedId
  final_score DECIMAL(28,8), -- @map <- raw.competences__EvaluationCycleCalcResultEvaluated.FinalScore
  final_score_consensus DECIMAL(28,8), -- @map <- raw.competences__EvaluationCycleCalcResultEvaluated.FinalScoreConsensus
  final_score_calib DECIMAL(28,8), -- @map <- raw.competences__EvaluationCycleCalcResultEvaluated.FinalScoreCalib
  pdf_history_url STRING, -- @map <- raw.competences__EvaluationCycleCalcResultEvaluated.PDFHistoryUrl
  final_score_behavior DECIMAL(28,8), -- @map <- raw.competences__EvaluationCycleCalcResultEvaluated.FinalScoreBehavior
  final_score_behavior_consensus DECIMAL(28,8), -- @map <- raw.competences__EvaluationCycleCalcResultEvaluated.FinalScoreBehaviorConsensus
  final_score_behavior_calib DECIMAL(28,8), -- @map <- raw.competences__EvaluationCycleCalcResultEvaluated.FinalScoreBehaviorCalib
  final_score_technical DECIMAL(28,8), -- @map <- raw.competences__EvaluationCycleCalcResultEvaluated.FinalScoreTechnical
  final_score_technical_consensus DECIMAL(28,8), -- @map <- raw.competences__EvaluationCycleCalcResultEvaluated.FinalScoreTechnicalConsensus
  final_score_technical_calib DECIMAL(28,8), -- @map <- raw.competences__EvaluationCycleCalcResultEvaluated.FinalScoreTechnicalCalib
  calibration_ranking_evaluated DECIMAL(28,8), -- @map <- raw.competences__EvaluationCycleCalcResultEvaluated.CalibrationRankingEvaluated
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.EvaluationCycleInstance — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__EvaluationCycleInstance
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_evaluationcycleinstance (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__EvaluationCycleInstance.Id
  forum_id INT, -- @map <- raw.dbo__EvaluationCycleInstance.ForumId
  description STRING, -- @map <- raw.dbo__EvaluationCycleInstance.Description
  creation_date TIMESTAMP, -- @map <- raw.dbo__EvaluationCycleInstance.CreationDate
  start_date TIMESTAMP, -- @map <- raw.dbo__EvaluationCycleInstance.StartDate
  end_date TIMESTAMP, -- @map <- raw.dbo__EvaluationCycleInstance.EndDate
  status INT, -- @map <- raw.dbo__EvaluationCycleInstance.Status
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.EvaluationCycleInstanceParticipant — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__EvaluationCycleInstanceParticipant
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_evaluationcycleinstanceparticipant (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__EvaluationCycleInstanceParticipant.Id
  instance_id INT, -- @map <- raw.dbo__EvaluationCycleInstanceParticipant.InstanceId
  evaluated_id INT, -- @map <- raw.dbo__EvaluationCycleInstanceParticipant.EvaluatedId
  quadrant_from_id INT, -- @map <- raw.dbo__EvaluationCycleInstanceParticipant.QuadrantFromId
  quadrant_to_id INT, -- @map <- raw.dbo__EvaluationCycleInstanceParticipant.QuadrantToId
  employee_x_axis_calibrated INT, -- @map <- raw.dbo__EvaluationCycleInstanceParticipant.EmployeeXAxisCalibrated
  employee_y_axis_calibrated INT, -- @map <- raw.dbo__EvaluationCycleInstanceParticipant.EmployeeYAxisCalibrated
  x_axis_considerations STRING, -- @map <- raw.dbo__EvaluationCycleInstanceParticipant.XAxisConsiderations
  y_axis_considerations STRING, -- @map <- raw.dbo__EvaluationCycleInstanceParticipant.YAxisConsiderations
  change_date TIMESTAMP, -- @map <- raw.dbo__EvaluationCycleInstanceParticipant.ChangeDate
  employee_responsible_change_id INT, -- @map <- raw.dbo__EvaluationCycleInstanceParticipant.EmployeeResponsibleChangeId
  active INT, -- @map <- raw.dbo__EvaluationCycleInstanceParticipant.Active
  parent_id INT, -- @map <- raw.dbo__EvaluationCycleInstanceParticipant.ParentId
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.EvaluationCycleQuadrant — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__EvaluationCycleQuadrant
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_evaluationcyclequadrant (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__EvaluationCycleQuadrant.Id
  evaluation_cycle_id INT, -- @map <- raw.dbo__EvaluationCycleQuadrant.EvaluationCycleId
  x_axis_classification_id INT, -- @map <- raw.dbo__EvaluationCycleQuadrant.XAxisClassificationId
  y_axis_classification_id INT, -- @map <- raw.dbo__EvaluationCycleQuadrant.YAxisClassificationId
  title STRING, -- @map <- raw.dbo__EvaluationCycleQuadrant.Title
  description STRING, -- @map <- raw.dbo__EvaluationCycleQuadrant.Description
  background_color STRING, -- @map <- raw.dbo__EvaluationCycleQuadrant.BackgroundColor
  title_color STRING, -- @map <- raw.dbo__EvaluationCycleQuadrant.TitleColor
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.FAIXA_CLASSIFICACAO_AVALIACAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__FAIXA_CLASSIFICACAO_AVALIACAO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_faixa_classificacao_avaliacao (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__FAIXA_CLASSIFICACAO_AVALIACAO.ID
  id_avaliacao INT, -- @map <- raw.competences__FAIXA_CLASSIFICACAO_AVALIACAO.ID_AVALIACAO
  descricao STRING, -- @map <- raw.competences__FAIXA_CLASSIFICACAO_AVALIACAO.DESCRICAO
  nota_de DECIMAL(28,8), -- @map <- raw.competences__FAIXA_CLASSIFICACAO_AVALIACAO.NOTA_DE
  nota_ate DECIMAL(28,8), -- @map <- raw.competences__FAIXA_CLASSIFICACAO_AVALIACAO.NOTA_ATE
  porcentagem_curva_esperada DECIMAL(28,8), -- @map <- raw.competences__FAIXA_CLASSIFICACAO_AVALIACAO.PORCENTAGEM_CURVA_ESPERADA
  nota_de_numeric DECIMAL(28,8), -- @map <- raw.competences__FAIXA_CLASSIFICACAO_AVALIACAO.NOTA_DE_NUMERIC
  nota_ate_numeric DECIMAL(28,8), -- @map <- raw.competences__FAIXA_CLASSIFICACAO_AVALIACAO.NOTA_ATE_NUMERIC
  mesclar_com_faixa INT, -- @map <- raw.competences__FAIXA_CLASSIFICACAO_AVALIACAO.MESCLAR_COM_FAIXA
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.FAIXA_CLASSIFICACAO_PERFORMANCE_AVALIACAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__FAIXA_CLASSIFICACAO_PERFORMANCE_AVALIACAO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_faixa_classificacao_performance_avaliacao (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__FAIXA_CLASSIFICACAO_PERFORMANCE_AVALIACAO.ID
  id_avaliacao INT, -- @map <- raw.competences__FAIXA_CLASSIFICACAO_PERFORMANCE_AVALIACAO.ID_AVALIACAO
  descricao STRING, -- @map <- raw.competences__FAIXA_CLASSIFICACAO_PERFORMANCE_AVALIACAO.DESCRICAO
  nota_de DECIMAL(28,8), -- @map <- raw.competences__FAIXA_CLASSIFICACAO_PERFORMANCE_AVALIACAO.NOTA_DE
  nota_ate DECIMAL(28,8), -- @map <- raw.competences__FAIXA_CLASSIFICACAO_PERFORMANCE_AVALIACAO.NOTA_ATE
  porcentagem_curva_esperada DECIMAL(28,8), -- @map <- raw.competences__FAIXA_CLASSIFICACAO_PERFORMANCE_AVALIACAO.PORCENTAGEM_CURVA_ESPERADA
  mesclar_com_faixa INT, -- @map <- raw.competences__FAIXA_CLASSIFICACAO_PERFORMANCE_AVALIACAO.MESCLAR_COM_FAIXA
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.FATOR_AVALIACAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__FATOR_AVALIACAO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_fator_avaliacao (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__FATOR_AVALIACAO.ID
  id_competencia INT, -- @map <- raw.competences__FATOR_AVALIACAO.ID_COMPETENCIA
  detalhe_fator_avaliacao STRING, -- @map <- raw.competences__FATOR_AVALIACAO.DETALHE_FATOR_AVALIACAO
  desc_fator_avaliacao STRING, -- @map <- raw.competences__FATOR_AVALIACAO.DESC_FATOR_AVALIACAO
  codigo STRING, -- @map <- raw.competences__FATOR_AVALIACAO.CODIGO
  PRIMARY KEY (tenant_slug, id)
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
-- @note: Cleanse dbo.FeedbackHistory — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__FeedbackHistory
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_feedbackhistory (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__FeedbackHistory.Id
  feedback_id INT, -- @map <- raw.dbo__FeedbackHistory.FeedbackId
  text STRING, -- @map <- raw.dbo__FeedbackHistory.Text
  date TIMESTAMP, -- @map <- raw.dbo__FeedbackHistory.Date
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.FeedbackParticipant — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__FeedbackParticipant
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_feedbackparticipant (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__FeedbackParticipant.Id
  employee_id INT, -- @map <- raw.dbo__FeedbackParticipant.EmployeeId
  feedback_id INT, -- @map <- raw.dbo__FeedbackParticipant.FeedbackId
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.FORMULARIO_AVALIACAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__FORMULARIO_AVALIACAO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_formulario_avaliacao (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.ID
  id_avaliacao INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.ID_AVALIACAO
  id_avaliado INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.ID_AVALIADO
  id_avaliador INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.ID_AVALIADOR
  id_funcao INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.ID_FUNCAO
  dt_deadline TIMESTAMP, -- @map <- raw.competences__FORMULARIO_AVALIACAO.DT_DEADLINE
  dt_envio TIMESTAMP, -- @map <- raw.competences__FORMULARIO_AVALIACAO.DT_ENVIO
  dt_reenvio TIMESTAMP, -- @map <- raw.competences__FORMULARIO_AVALIACAO.DT_REENVIO
  dt_finalizacao_formulario TIMESTAMP, -- @map <- raw.competences__FORMULARIO_AVALIACAO.DT_FINALIZACAO_FORMULARIO
  dt_cancelamento_envio TIMESTAMP, -- @map <- raw.competences__FORMULARIO_AVALIACAO.DT_CANCELAMENTO_ENVIO
  dt_envio_feedback TIMESTAMP, -- @map <- raw.competences__FORMULARIO_AVALIACAO.DT_ENVIO_FEEDBACK
  feedback_liberado INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.FEEDBACK_LIBERADO
  id_colaborador_avaliador INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.ID_COLABORADOR_AVALIADOR
  dt_deadline_feedback TIMESTAMP, -- @map <- raw.competences__FORMULARIO_AVALIACAO.DT_DEADLINE_FEEDBACK
  id_peso_tipo_avaliador INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.ID_PESO_TIPO_AVALIADOR
  feedback_sem_formulario_lider INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.FEEDBACK_SEM_FORMULARIO_LIDER
  resultado_feedback_liberado INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.RESULTADO_FEEDBACK_LIBERADO
  disponibilizar_onepage INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.DISPONIBILIZAR_ONEPAGE
  status_feedback INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.STATUS_FEEDBACK
  status INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.STATUS
  justificativa_recusa STRING, -- @map <- raw.competences__FORMULARIO_AVALIACAO.JUSTIFICATIVA_RECUSA
  data_recusa TIMESTAMP, -- @map <- raw.competences__FORMULARIO_AVALIACAO.DATA_RECUSA
  id_colaborador_criador INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.ID_COLABORADOR_CRIADOR
  dt_deadline_pre_calibragem TIMESTAMP, -- @map <- raw.competences__FORMULARIO_AVALIACAO.DT_DEADLINE_PRE_CALIBRAGEM
  feedback_informal_recebido INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.FEEDBACK_INFORMAL_RECEBIDO
  id_projeto INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.ID_PROJETO
  possui_interesse_mudanca_localidade INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.POSSUI_INTERESSE_MUDANCA_LOCALIDADE
  dt_liberacao_resultado TIMESTAMP, -- @map <- raw.competences__FORMULARIO_AVALIACAO.DT_LIBERACAO_RESULTADO
  id_avaliador_respondeu_avaliacao INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.ID_AVALIADOR_RESPONDEU_AVALIACAO
  id_avaliador_respondeu_feedback INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.ID_AVALIADOR_RESPONDEU_FEEDBACK
  evaluation_answered_from_mobile INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.EvaluationAnsweredFromMobile
  feedback_answered_from_mobile INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.FeedbackAnsweredFromMobile
  has_interest_change_area INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.HasInterestChangeArea
  has_successor_indication INT, -- @map <- raw.competences__FORMULARIO_AVALIACAO.HasSuccessorIndication
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.FORMULARIO_FEEDBACK_ABA — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__FORMULARIO_FEEDBACK_ABA
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_formulario_feedback_aba (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__FORMULARIO_FEEDBACK_ABA.ID
  id_avaliacao INT, -- @map <- raw.dbo__FORMULARIO_FEEDBACK_ABA.ID_AVALIACAO
  descricao STRING, -- @map <- raw.dbo__FORMULARIO_FEEDBACK_ABA.DESCRICAO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.FORMULARIO_FEEDBACK_ABA_ITEM — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__FORMULARIO_FEEDBACK_ABA_ITEM
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_formulario_feedback_aba_item (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__FORMULARIO_FEEDBACK_ABA_ITEM.ID
  id_formulario_feedback_aba INT, -- @map <- raw.dbo__FORMULARIO_FEEDBACK_ABA_ITEM.ID_FORMULARIO_FEEDBACK_ABA
  tipo_conteudo INT, -- @map <- raw.dbo__FORMULARIO_FEEDBACK_ABA_ITEM.TIPO_CONTEUDO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.FUNCAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__FUNCAO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_funcao (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__FUNCAO.ID
  cod_funcao STRING, -- @map <- raw.competences__FUNCAO.COD_FUNCAO
  desc_funcao STRING, -- @map <- raw.competences__FUNCAO.DESC_FUNCAO
  id_parent INT, -- @map <- raw.competences__FUNCAO.ID_PARENT
  id_parent_ajuste INT, -- @map <- raw.competences__FUNCAO.ID_PARENT_AJUSTE
  id_avaliacao INT, -- @map <- raw.competences__FUNCAO.ID_AVALIACAO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.FUNCAO_COMPETENCIA — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__FUNCAO_COMPETENCIA
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_funcao_competencia (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__FUNCAO_COMPETENCIA.ID
  id_funcao INT, -- @map <- raw.competences__FUNCAO_COMPETENCIA.ID_FUNCAO
  id_competencia INT, -- @map <- raw.competences__FUNCAO_COMPETENCIA.ID_COMPETENCIA
  id_fator_avaliacao INT, -- @map <- raw.competences__FUNCAO_COMPETENCIA.ID_FATOR_AVALIACAO
  proficiencia INT, -- @map <- raw.competences__FUNCAO_COMPETENCIA.PROFICIENCIA
  experiencia_ano INT, -- @map <- raw.competences__FUNCAO_COMPETENCIA.EXPERIENCIA_ANO
  auto DECIMAL(28,8), -- @map <- raw.competences__FUNCAO_COMPETENCIA.AUTO
  lider DECIMAL(28,8), -- @map <- raw.competences__FUNCAO_COMPETENCIA.LIDER
  par DECIMAL(28,8), -- @map <- raw.competences__FUNCAO_COMPETENCIA.PAR
  time DECIMAL(28,8), -- @map <- raw.competences__FUNCAO_COMPETENCIA.TIME
  comite DECIMAL(28,8), -- @map <- raw.competences__FUNCAO_COMPETENCIA.COMITE
  cliente DECIMAL(28,8), -- @map <- raw.competences__FUNCAO_COMPETENCIA.CLIENTE
  fornecedor DECIMAL(28,8), -- @map <- raw.competences__FUNCAO_COMPETENCIA.FORNECEDOR
  peso_geral_por_fator DECIMAL(18,5), -- @map <- raw.competences__FUNCAO_COMPETENCIA.PESO_GERAL_POR_FATOR
  possui_pesos_detalhado INT, -- @map <- raw.competences__FUNCAO_COMPETENCIA.POSSUI_PESOS_DETALHADO
  projeto DECIMAL(28,8), -- @map <- raw.competences__FUNCAO_COMPETENCIA.PROJETO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.FUNCAO_PERGUNTA_LIVRE — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__FUNCAO_PERGUNTA_LIVRE
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_funcao_pergunta_livre (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__FUNCAO_PERGUNTA_LIVRE.ID
  id_funcao INT, -- @map <- raw.competences__FUNCAO_PERGUNTA_LIVRE.ID_FUNCAO
  pergunta_livre STRING, -- @map <- raw.competences__FUNCAO_PERGUNTA_LIVRE.PERGUNTA_LIVRE
  ordenacao INT, -- @map <- raw.competences__FUNCAO_PERGUNTA_LIVRE.ORDENACAO
  auto INT, -- @map <- raw.competences__FUNCAO_PERGUNTA_LIVRE.AUTO
  lider INT, -- @map <- raw.competences__FUNCAO_PERGUNTA_LIVRE.LIDER
  par INT, -- @map <- raw.competences__FUNCAO_PERGUNTA_LIVRE.PAR
  time INT, -- @map <- raw.competences__FUNCAO_PERGUNTA_LIVRE.TIME
  comite INT, -- @map <- raw.competences__FUNCAO_PERGUNTA_LIVRE.COMITE
  cliente INT, -- @map <- raw.competences__FUNCAO_PERGUNTA_LIVRE.CLIENTE
  fornecedor INT, -- @map <- raw.competences__FUNCAO_PERGUNTA_LIVRE.FORNECEDOR
  id_topico INT, -- @map <- raw.competences__FUNCAO_PERGUNTA_LIVRE.ID_TOPICO
  tipo_resposta INT, -- @map <- raw.competences__FUNCAO_PERGUNTA_LIVRE.TIPO_RESPOSTA
  pergunta_livre_confidencial INT, -- @map <- raw.competences__FUNCAO_PERGUNTA_LIVRE.PERGUNTA_LIVRE_CONFIDENCIAL
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.ITEM_LISTA_PERSONALIZADA_FEEDBACK_CONTINUO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ITEM_LISTA_PERSONALIZADA_FEEDBACK_CONTINUO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_item_lista_personalizada_feedback_continuo (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__ITEM_LISTA_PERSONALIZADA_FEEDBACK_CONTINUO.Id
  descricao STRING, -- @map <- raw.dbo__ITEM_LISTA_PERSONALIZADA_FEEDBACK_CONTINUO.DESCRICAO
  feedback_type_id INT, -- @map <- raw.dbo__ITEM_LISTA_PERSONALIZADA_FEEDBACK_CONTINUO.FeedbackTypeId
  ativo INT, -- @map <- raw.dbo__ITEM_LISTA_PERSONALIZADA_FEEDBACK_CONTINUO.ATIVO
  cor_texto STRING, -- @map <- raw.dbo__ITEM_LISTA_PERSONALIZADA_FEEDBACK_CONTINUO.COR_TEXTO
  cor_fundo STRING, -- @map <- raw.dbo__ITEM_LISTA_PERSONALIZADA_FEEDBACK_CONTINUO.COR_FUNDO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.METODO_CALCULO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__METODO_CALCULO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_metodo_calculo (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__METODO_CALCULO.ID
  nome STRING, -- @map <- raw.competences__METODO_CALCULO.NOME
  auto DECIMAL(28,8), -- @map <- raw.competences__METODO_CALCULO.AUTO
  lider DECIMAL(28,8), -- @map <- raw.competences__METODO_CALCULO.LIDER
  par DECIMAL(28,8), -- @map <- raw.competences__METODO_CALCULO.PAR
  time DECIMAL(28,8), -- @map <- raw.competences__METODO_CALCULO.TIME
  comite DECIMAL(28,8), -- @map <- raw.competences__METODO_CALCULO.COMITE
  cliente DECIMAL(28,8), -- @map <- raw.competences__METODO_CALCULO.CLIENTE
  fornecedor DECIMAL(28,8), -- @map <- raw.competences__METODO_CALCULO.FORNECEDOR
  ativo INT, -- @map <- raw.competences__METODO_CALCULO.ATIVO
  id_avaliacao INT, -- @map <- raw.competences__METODO_CALCULO.ID_AVALIACAO
  id_parent INT, -- @map <- raw.competences__METODO_CALCULO.ID_PARENT
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.NINE_BOX — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__NINE_BOX
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_nine_box (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__NINE_BOX.ID
  descricao STRING, -- @map <- raw.dbo__NINE_BOX.DESCRICAO
  dt_criacao TIMESTAMP, -- @map <- raw.dbo__NINE_BOX.DT_CRIACAO
  ativo INT, -- @map <- raw.dbo__NINE_BOX.ATIVO
  id_avaliacao INT, -- @map <- raw.dbo__NINE_BOX.ID_AVALIACAO
  status INT, -- @map <- raw.dbo__NINE_BOX.STATUS
  dt_encerramento TIMESTAMP, -- @map <- raw.dbo__NINE_BOX.DT_ENCERRAMENTO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.NOTIFICACAO_FEEDBACK_CONTINUO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__NOTIFICACAO_FEEDBACK_CONTINUO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_notificacao_feedback_continuo (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__NOTIFICACAO_FEEDBACK_CONTINUO.Id
  id_colaborador INT, -- @map <- raw.dbo__NOTIFICACAO_FEEDBACK_CONTINUO.ID_COLABORADOR
  alert_type INT, -- @map <- raw.dbo__NOTIFICACAO_FEEDBACK_CONTINUO.ALERT_TYPE
  frequency_type INT, -- @map <- raw.dbo__NOTIFICACAO_FEEDBACK_CONTINUO.FREQUENCY_TYPE
  week_day INT, -- @map <- raw.dbo__NOTIFICACAO_FEEDBACK_CONTINUO.WEEK_DAY
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.OPCAO_FUNCAO_PERGUNTA_LIVRE — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__OPCAO_FUNCAO_PERGUNTA_LIVRE
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_opcao_funcao_pergunta_livre (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__OPCAO_FUNCAO_PERGUNTA_LIVRE.ID
  id_funcao_pergunta_livre INT, -- @map <- raw.competences__OPCAO_FUNCAO_PERGUNTA_LIVRE.ID_FUNCAO_PERGUNTA_LIVRE
  descricao STRING, -- @map <- raw.competences__OPCAO_FUNCAO_PERGUNTA_LIVRE.DESCRICAO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.PESO_TIPO_AVALIADOR — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__PESO_TIPO_AVALIADOR
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_peso_tipo_avaliador (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__PESO_TIPO_AVALIADOR.ID
  id_funcao INT, -- @map <- raw.competences__PESO_TIPO_AVALIADOR.ID_FUNCAO
  id_metodo_calculo INT, -- @map <- raw.competences__PESO_TIPO_AVALIADOR.ID_METODO_CALCULO
  id_avaliacao INT, -- @map <- raw.competences__PESO_TIPO_AVALIADOR.ID_AVALIACAO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.RESPOSTA_AVALIACAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__RESPOSTA_AVALIACAO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_resposta_avaliacao (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__RESPOSTA_AVALIACAO.ID
  id_formulario_avaliacao INT, -- @map <- raw.competences__RESPOSTA_AVALIACAO.ID_FORMULARIO_AVALIACAO
  id_funcao_competencia INT, -- @map <- raw.competences__RESPOSTA_AVALIACAO.ID_FUNCAO_COMPETENCIA
  id_nota_resposta INT, -- @map <- raw.competences__RESPOSTA_AVALIACAO.ID_NOTA_RESPOSTA
  id_nota_consenso INT, -- @map <- raw.competences__RESPOSTA_AVALIACAO.ID_NOTA_CONSENSO
  comentario_resposta STRING, -- @map <- raw.competences__RESPOSTA_AVALIACAO.COMENTARIO_RESPOSTA
  dt_resposta TIMESTAMP, -- @map <- raw.competences__RESPOSTA_AVALIACAO.DT_RESPOSTA
  dt_resposta_consenso TIMESTAMP, -- @map <- raw.competences__RESPOSTA_AVALIACAO.DT_RESPOSTA_CONSENSO
  comentario_resposta_consenso STRING, -- @map <- raw.competences__RESPOSTA_AVALIACAO.COMENTARIO_RESPOSTA_CONSENSO
  id_nota_calibrada INT, -- @map <- raw.competences__RESPOSTA_AVALIACAO.ID_NOTA_CALIBRADA
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.RESPOSTA_LIVRE_AVALIACAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__RESPOSTA_LIVRE_AVALIACAO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_resposta_livre_avaliacao (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__RESPOSTA_LIVRE_AVALIACAO.ID
  id_formulario_avaliacao INT, -- @map <- raw.competences__RESPOSTA_LIVRE_AVALIACAO.ID_FORMULARIO_AVALIACAO
  id_funcao_pergunta_livre INT, -- @map <- raw.competences__RESPOSTA_LIVRE_AVALIACAO.ID_FUNCAO_PERGUNTA_LIVRE
  resposta_livre STRING, -- @map <- raw.competences__RESPOSTA_LIVRE_AVALIACAO.RESPOSTA_LIVRE
  dt_resposta TIMESTAMP, -- @map <- raw.competences__RESPOSTA_LIVRE_AVALIACAO.DT_RESPOSTA
  resposta_consolidado STRING, -- @map <- raw.competences__RESPOSTA_LIVRE_AVALIACAO.RESPOSTA_CONSOLIDADO
  id_opcao_funcao_pergunta_livre INT, -- @map <- raw.competences__RESPOSTA_LIVRE_AVALIACAO.ID_OPCAO_FUNCAO_PERGUNTA_LIVRE
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.settings — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__settings
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_settings (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__settings.id
  name STRING, -- @map <- raw.competences__settings.name
  value STRING, -- @map <- raw.competences__settings.value
  type STRING, -- @map <- raw.competences__settings.type
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.TAG_FEEDBACK — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__TAG_FEEDBACK
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_tag_feedback (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__TAG_FEEDBACK.Id
  id_tag INT, -- @map <- raw.dbo__TAG_FEEDBACK.ID_TAG
  id_feedback INT, -- @map <- raw.dbo__TAG_FEEDBACK.ID_FEEDBACK
  tipo_tag INT, -- @map <- raw.dbo__TAG_FEEDBACK.TIPO_TAG
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.TAG_FEEDBACK_CONTINUO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__TAG_FEEDBACK_CONTINUO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_tag_feedback_continuo (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__TAG_FEEDBACK_CONTINUO.ID
  ponto_positivo STRING, -- @map <- raw.dbo__TAG_FEEDBACK_CONTINUO.PONTO_POSITIVO
  ponto_a_desenvolver STRING, -- @map <- raw.dbo__TAG_FEEDBACK_CONTINUO.PONTO_A_DESENVOLVER
  ativo INT, -- @map <- raw.dbo__TAG_FEEDBACK_CONTINUO.ATIVO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.TIMELINE_FEEDBACK_CONTINUO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__TIMELINE_FEEDBACK_CONTINUO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_timeline_feedback_continuo (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__TIMELINE_FEEDBACK_CONTINUO.Id
  id_colaborador INT, -- @map <- raw.dbo__TIMELINE_FEEDBACK_CONTINUO.ID_COLABORADOR
  id_feedback INT, -- @map <- raw.dbo__TIMELINE_FEEDBACK_CONTINUO.ID_FEEDBACK
  arquivado INT, -- @map <- raw.dbo__TIMELINE_FEEDBACK_CONTINUO.ARQUIVADO
  lido INT, -- @map <- raw.dbo__TIMELINE_FEEDBACK_CONTINUO.LIDO
  id_pulse_respondido INT, -- @map <- raw.dbo__TIMELINE_FEEDBACK_CONTINUO.ID_PULSE_RESPONDIDO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.TIPO_AVALIACAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__TIPO_AVALIACAO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_tipo_avaliacao (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__TIPO_AVALIACAO.ID
  descricao STRING, -- @map <- raw.competences__TIPO_AVALIACAO.DESCRICAO
  ativo INT, -- @map <- raw.competences__TIPO_AVALIACAO.ATIVO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.TIPO_AVALIADOR — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__TIPO_AVALIADOR
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_tipo_avaliador (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__TIPO_AVALIADOR.ID
  pt_br STRING, -- @map <- raw.competences__TIPO_AVALIADOR.PT_BR
  en_us STRING, -- @map <- raw.competences__TIPO_AVALIADOR.EN_US
  es_es STRING, -- @map <- raw.competences__TIPO_AVALIADOR.ES_ES
  tipo STRING, -- @map <- raw.competences__TIPO_AVALIADOR.TIPO
  descricao STRING, -- @map <- raw.competences__TIPO_AVALIADOR.DESCRICAO
  radar_chart_color STRING, -- @map <- raw.competences__TIPO_AVALIADOR.RadarChartColor
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.TIPO_FEEDBACK_CONTINUO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__TIPO_FEEDBACK_CONTINUO
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_tipo_feedback_continuo (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__TIPO_FEEDBACK_CONTINUO.ID
  descricao STRING, -- @map <- raw.dbo__TIPO_FEEDBACK_CONTINUO.DESCRICAO
  ativo INT, -- @map <- raw.dbo__TIPO_FEEDBACK_CONTINUO.ATIVO
  tipo_feedback INT, -- @map <- raw.dbo__TIPO_FEEDBACK_CONTINUO.TIPO_FEEDBACK
  edicao_permitida INT, -- @map <- raw.dbo__TIPO_FEEDBACK_CONTINUO.EDICAO_PERMITIDA
  excluido INT, -- @map <- raw.dbo__TIPO_FEEDBACK_CONTINUO.EXCLUIDO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.TOPICO_PERGUNTA_LIVRE — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__TOPICO_PERGUNTA_LIVRE
CREATE TABLE IF NOT EXISTS staging.stg_avaliacao_topico_pergunta_livre (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__TOPICO_PERGUNTA_LIVRE.ID
  descricao STRING, -- @map <- raw.competences__TOPICO_PERGUNTA_LIVRE.DESCRICAO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.AcceptAgreementHistory — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__AcceptAgreementHistory
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_acceptagreementhistory (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__AcceptAgreementHistory.Id
  created_on TIMESTAMP, -- @map <- raw.dbo__AcceptAgreementHistory.CreatedOn
  agreement_details STRING, -- @map <- raw.dbo__AcceptAgreementHistory.AgreementDetails
  accept_agreement_id INT, -- @map <- raw.dbo__AcceptAgreementHistory.AcceptAgreementID
  accept_agreement_signature_id INT, -- @map <- raw.dbo__AcceptAgreementHistory.AcceptAgreementSignatureID
  accept_agreement_last_signature STRING, -- @map <- raw.dbo__AcceptAgreementHistory.AcceptAgreementLastSignature
  motive STRING, -- @map <- raw.dbo__AcceptAgreementHistory.Motive
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.AcceptAgreementSignatureAttachment — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__AcceptAgreementSignatureAttachment
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_acceptagreementsignatureattachment (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__AcceptAgreementSignatureAttachment.Id
  file_name STRING, -- @map <- raw.dbo__AcceptAgreementSignatureAttachment.FileName
  key STRING, -- @map <- raw.dbo__AcceptAgreementSignatureAttachment.Key
  upload_date TIMESTAMP, -- @map <- raw.dbo__AcceptAgreementSignatureAttachment.UploadDate
  content_type STRING, -- @map <- raw.dbo__AcceptAgreementSignatureAttachment.ContentType
  content_length INT, -- @map <- raw.dbo__AcceptAgreementSignatureAttachment.ContentLength
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.ActivityHistory — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ActivityHistory
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_activityhistory (
  tenant_slug STRING,
  id BIGINT, -- @map <- raw.dbo__ActivityHistory.Id
  title STRING, -- @map <- raw.dbo__ActivityHistory.Title
  description STRING, -- @map <- raw.dbo__ActivityHistory.Description
  notification_type INT, -- @map <- raw.dbo__ActivityHistory.NotificationType
  employee_id INT, -- @map <- raw.dbo__ActivityHistory.EmployeeId
  module_id INT, -- @map <- raw.dbo__ActivityHistory.ModuleId
  read INT, -- @map <- raw.dbo__ActivityHistory.Read
  creator_user_id BIGINT, -- @map <- raw.dbo__ActivityHistory.CreatorUserId
  creation_time TIMESTAMP, -- @map <- raw.dbo__ActivityHistory.CreationTime
  object_id INT, -- @map <- raw.dbo__ActivityHistory.ObjectId
  read_only INT, -- @map <- raw.dbo__ActivityHistory.ReadOnly
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.ADMINISTRADOR_LOCAL — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ADMINISTRADOR_LOCAL
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_administrador_local (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__ADMINISTRADOR_LOCAL.ID
  id_colaborador INT, -- @map <- raw.dbo__ADMINISTRADOR_LOCAL.ID_COLABORADOR
  id_modulo INT, -- @map <- raw.dbo__ADMINISTRADOR_LOCAL.ID_MODULO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.AVALIADO_SUCESSAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__AVALIADO_SUCESSAO
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_avaliado_sucessao (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__AVALIADO_SUCESSAO.ID
  id_ciclo_sucessao INT, -- @map <- raw.dbo__AVALIADO_SUCESSAO.ID_CICLO_SUCESSAO
  id_colaborador_avaliado INT, -- @map <- raw.dbo__AVALIADO_SUCESSAO.ID_COLABORADOR_AVALIADO
  id_funcao INT, -- @map <- raw.dbo__AVALIADO_SUCESSAO.ID_FUNCAO
  status INT, -- @map <- raw.dbo__AVALIADO_SUCESSAO.STATUS
  id_colaborador_avaliador INT, -- @map <- raw.dbo__AVALIADO_SUCESSAO.ID_COLABORADOR_AVALIADOR
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.AVALIADOR_FORUM — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__AVALIADOR_FORUM
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_avaliador_forum (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__AVALIADOR_FORUM.ID
  id_colaborador_avaliador INT, -- @map <- raw.dbo__AVALIADOR_FORUM.ID_COLABORADOR_AVALIADOR
  id_forum INT, -- @map <- raw.dbo__AVALIADOR_FORUM.ID_FORUM
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.AVALIADOR_FORUM_SUCESSAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__AVALIADOR_FORUM_SUCESSAO
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_avaliador_forum_sucessao (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__AVALIADOR_FORUM_SUCESSAO.ID
  id_colaborador_avaliador INT, -- @map <- raw.dbo__AVALIADOR_FORUM_SUCESSAO.ID_COLABORADOR_AVALIADOR
  id_forum INT, -- @map <- raw.dbo__AVALIADOR_FORUM_SUCESSAO.ID_FORUM
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.CauseAnalysisPermission — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__CauseAnalysisPermission
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_causeanalysispermission (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__CauseAnalysisPermission.Id
  countermeasure_id INT, -- @map <- raw.dbo__CauseAnalysisPermission.Countermeasure_Id
  employee_id INT, -- @map <- raw.dbo__CauseAnalysisPermission.Employee_Id
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.Certificate — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__Certificate
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_certificate (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__Certificate.Id
  logo STRING, -- @map <- raw.dbo__Certificate.Logo
  title STRING, -- @map <- raw.dbo__Certificate.Title
  issuer STRING, -- @map <- raw.dbo__Certificate.Issuer
  license STRING, -- @map <- raw.dbo__Certificate.License
  start TIMESTAMP, -- @map <- raw.dbo__Certificate.Start
  end TIMESTAMP, -- @map <- raw.dbo__Certificate.End
  employee_id INT, -- @map <- raw.dbo__Certificate.EmployeeId
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.CertificateAttachment — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__CertificateAttachment
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_certificateattachment (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__CertificateAttachment.Id
  file_name STRING, -- @map <- raw.dbo__CertificateAttachment.FileName
  key STRING, -- @map <- raw.dbo__CertificateAttachment.Key
  upload_date TIMESTAMP, -- @map <- raw.dbo__CertificateAttachment.UploadDate
  content_type STRING, -- @map <- raw.dbo__CertificateAttachment.ContentType
  content_length INT, -- @map <- raw.dbo__CertificateAttachment.ContentLength
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

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
-- @note: Cleanse competences.COLABORADOR_FUNCAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__COLABORADOR_FUNCAO
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_colaborador_funcao (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__COLABORADOR_FUNCAO.ID
  id_colaborador INT, -- @map <- raw.competences__COLABORADOR_FUNCAO.ID_COLABORADOR
  id_funcao INT, -- @map <- raw.competences__COLABORADOR_FUNCAO.ID_FUNCAO
  dt_ini TIMESTAMP, -- @map <- raw.competences__COLABORADOR_FUNCAO.DT_INI
  dt_fim TIMESTAMP, -- @map <- raw.competences__COLABORADOR_FUNCAO.DT_FIM
  funcao_atual INT, -- @map <- raw.competences__COLABORADOR_FUNCAO.FUNCAO_ATUAL
  id_avaliacao INT, -- @map <- raw.competences__COLABORADOR_FUNCAO.ID_AVALIACAO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.ConsentAgreement — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ConsentAgreement
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_consentagreement (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__ConsentAgreement.Id
  description STRING, -- @map <- raw.dbo__ConsentAgreement.Description
  subject STRING, -- @map <- raw.dbo__ConsentAgreement.Subject
  version STRING, -- @map <- raw.dbo__ConsentAgreement.Version
  last_update TIMESTAMP, -- @map <- raw.dbo__ConsentAgreement.LastUpdate
  active INT, -- @map <- raw.dbo__ConsentAgreement.Active
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.CurriculumAttachment — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__CurriculumAttachment
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_curriculumattachment (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__CurriculumAttachment.Id
  file_name STRING, -- @map <- raw.dbo__CurriculumAttachment.FileName
  key STRING, -- @map <- raw.dbo__CurriculumAttachment.Key
  upload_date TIMESTAMP, -- @map <- raw.dbo__CurriculumAttachment.UploadDate
  content_type STRING, -- @map <- raw.dbo__CurriculumAttachment.ContentType
  content_length INT, -- @map <- raw.dbo__CurriculumAttachment.ContentLength
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.DiscretionaryScoreImport — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__DiscretionaryScoreImport
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_discretionaryscoreimport (
  tenant_slug STRING,
  import_log_id INT, -- @map <- raw.dbo__DiscretionaryScoreImport.ImportLogId
  line INT, -- @map <- raw.dbo__DiscretionaryScoreImport.Line
  calculation_period INT, -- @map <- raw.dbo__DiscretionaryScoreImport.CalculationPeriod
  employee_id INT, -- @map <- raw.dbo__DiscretionaryScoreImport.EmployeeId
  user_name STRING, -- @map <- raw.dbo__DiscretionaryScoreImport.UserName
  score DOUBLE, -- @map <- raw.dbo__DiscretionaryScoreImport.Score
  description STRING, -- @map <- raw.dbo__DiscretionaryScoreImport.Description
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.Dreams — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__Dreams
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_dreams (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__Dreams.Id
  personal STRING, -- @map <- raw.dbo__Dreams.Personal
  professional STRING, -- @map <- raw.dbo__Dreams.Professional
  values STRING, -- @map <- raw.dbo__Dreams.Values
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.Education — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__Education
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_education (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__Education.Id
  institution_name STRING, -- @map <- raw.dbo__Education.InstitutionName
  degree STRING, -- @map <- raw.dbo__Education.Degree
  field_of_study STRING, -- @map <- raw.dbo__Education.FieldOfStudy
  start TIMESTAMP, -- @map <- raw.dbo__Education.Start
  end TIMESTAMP, -- @map <- raw.dbo__Education.End
  employee_id INT, -- @map <- raw.dbo__Education.EmployeeId
  logo STRING, -- @map <- raw.dbo__Education.Logo
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.EducationAttachment — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__EducationAttachment
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_educationattachment (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__EducationAttachment.Id
  file_name STRING, -- @map <- raw.dbo__EducationAttachment.FileName
  upload_date TIMESTAMP, -- @map <- raw.dbo__EducationAttachment.UploadDate
  content_type STRING, -- @map <- raw.dbo__EducationAttachment.ContentType
  key STRING, -- @map <- raw.dbo__EducationAttachment.Key
  content_length INT, -- @map <- raw.dbo__EducationAttachment.ContentLength
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.EmployeeAccessGroup — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__EmployeeAccessGroup
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_employeeaccessgroup (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__EmployeeAccessGroup.Id
  employee_id INT, -- @map <- raw.dbo__EmployeeAccessGroup.Employee_Id
  module_id INT, -- @map <- raw.dbo__EmployeeAccessGroup.Module_Id
  type INT, -- @map <- raw.dbo__EmployeeAccessGroup.Type
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.EmployeeBranch — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__EmployeeBranch
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_employeebranch (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__EmployeeBranch.Id
  id_employee INT, -- @map <- raw.dbo__EmployeeBranch.IdEmployee
  id_branch INT, -- @map <- raw.dbo__EmployeeBranch.IdBranch
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.EmployeeModifierValue — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__EmployeeModifierValue
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_employeemodifiervalue (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__EmployeeModifierValue.Id
  value DECIMAL(28,8), -- @map <- raw.dbo__EmployeeModifierValue.Value
  employee_id INT, -- @map <- raw.dbo__EmployeeModifierValue.Employee_Id
  modifier_id INT, -- @map <- raw.dbo__EmployeeModifierValue.Modifier_Id
  update_date TIMESTAMP, -- @map <- raw.dbo__EmployeeModifierValue.UpdateDate
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.EvaluationDiscretionary — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__EvaluationDiscretionary
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_evaluationdiscretionary (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__EvaluationDiscretionary.Id
  concept_id INT, -- @map <- raw.dbo__EvaluationDiscretionary.Concept_Id
  eligible_discretionary_id INT, -- @map <- raw.dbo__EvaluationDiscretionary.EligibleDiscretionary_Id
  evaluator_id INT, -- @map <- raw.dbo__EvaluationDiscretionary.Evaluator_Id
  evaluated_date TIMESTAMP, -- @map <- raw.dbo__EvaluationDiscretionary.EvaluatedDate
  grade DECIMAL(7,2), -- @map <- raw.dbo__EvaluationDiscretionary.Grade
  calibrated_grade DECIMAL(7,2), -- @map <- raw.dbo__EvaluationDiscretionary.CalibratedGrade
  status INT, -- @map <- raw.dbo__EvaluationDiscretionary.Status
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.FORUM_PARTICIPANTE_SUCESSAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__FORUM_PARTICIPANTE_SUCESSAO
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_forum_participante_sucessao (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__FORUM_PARTICIPANTE_SUCESSAO.ID
  id_forum_sucessao INT, -- @map <- raw.dbo__FORUM_PARTICIPANTE_SUCESSAO.ID_FORUM_SUCESSAO
  id_colaborador INT, -- @map <- raw.dbo__FORUM_PARTICIPANTE_SUCESSAO.ID_COLABORADOR
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.GoalAttachment — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__GoalAttachment
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_goalattachment (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__GoalAttachment.Id
  goal_id INT, -- @map <- raw.dbo__GoalAttachment.GoalId
  employee_id INT, -- @map <- raw.dbo__GoalAttachment.EmployeeId
  file_name STRING, -- @map <- raw.dbo__GoalAttachment.FileName
  upload_date TIMESTAMP, -- @map <- raw.dbo__GoalAttachment.UploadDate
  content_type STRING, -- @map <- raw.dbo__GoalAttachment.ContentType
  month INT, -- @map <- raw.dbo__GoalAttachment.Month
  origem INT, -- @map <- raw.dbo__GoalAttachment.Origem
  key STRING, -- @map <- raw.dbo__GoalAttachment.Key
  content_length INT, -- @map <- raw.dbo__GoalAttachment.ContentLength
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.GoalDiscussion — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__GoalDiscussion
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_goaldiscussion (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__GoalDiscussion.Id
  goal_id INT, -- @map <- raw.dbo__GoalDiscussion.GoalId
  employee_id INT, -- @map <- raw.dbo__GoalDiscussion.EmployeeId
  message STRING, -- @map <- raw.dbo__GoalDiscussion.Message
  created_date TIMESTAMP, -- @map <- raw.dbo__GoalDiscussion.CreatedDate
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.HISTORICO_CARGO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__HISTORICO_CARGO
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_historico_cargo (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__HISTORICO_CARGO.ID
  id_cargo INT, -- @map <- raw.dbo__HISTORICO_CARGO.ID_CARGO
  dt_ini TIMESTAMP, -- @map <- raw.dbo__HISTORICO_CARGO.DT_INI
  dt_fim TIMESTAMP, -- @map <- raw.dbo__HISTORICO_CARGO.DT_FIM
  salario DOUBLE, -- @map <- raw.dbo__HISTORICO_CARGO.SALARIO
  id_colaborador INT, -- @map <- raw.dbo__HISTORICO_CARGO.ID_COLABORADOR
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.HISTORICO_COLABORADOR_AREA — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__HISTORICO_COLABORADOR_AREA
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_historico_colaborador_area (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__HISTORICO_COLABORADOR_AREA.ID
  id_colaborador INT, -- @map <- raw.dbo__HISTORICO_COLABORADOR_AREA.ID_COLABORADOR
  id_area INT, -- @map <- raw.dbo__HISTORICO_COLABORADOR_AREA.ID_AREA
  dt_upd TIMESTAMP, -- @map <- raw.dbo__HISTORICO_COLABORADOR_AREA.DT_UPD
  score DECIMAL(28,8), -- @map <- raw.dbo__HISTORICO_COLABORADOR_AREA.SCORE
  dt_fim TIMESTAMP, -- @map <- raw.dbo__HISTORICO_COLABORADOR_AREA.DT_FIM
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.Hobbies — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__Hobbies
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_hobbies (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__Hobbies.Id
  personal STRING, -- @map <- raw.dbo__Hobbies.Personal
  family STRING, -- @map <- raw.dbo__Hobbies.Family
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.INSTANCIA_COMITE — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__INSTANCIA_COMITE
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_instancia_comite (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__INSTANCIA_COMITE.ID
  instancia_id INT, -- @map <- raw.dbo__INSTANCIA_COMITE.INSTANCIA_ID
  colaborador_id INT, -- @map <- raw.dbo__INSTANCIA_COMITE.COLABORADOR_ID
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.INSTANCIA_COMITE_SUCESSAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__INSTANCIA_COMITE_SUCESSAO
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_instancia_comite_sucessao (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__INSTANCIA_COMITE_SUCESSAO.ID
  id_instancia_sucessao INT, -- @map <- raw.dbo__INSTANCIA_COMITE_SUCESSAO.ID_INSTANCIA_SUCESSAO
  id_colaborador INT, -- @map <- raw.dbo__INSTANCIA_COMITE_SUCESSAO.ID_COLABORADOR
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.INSTANCIA_PARTICIPANTE_SUCESSAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__INSTANCIA_PARTICIPANTE_SUCESSAO
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_instancia_participante_sucessao (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__INSTANCIA_PARTICIPANTE_SUCESSAO.ID
  id_instancia_sucessao INT, -- @map <- raw.dbo__INSTANCIA_PARTICIPANTE_SUCESSAO.ID_INSTANCIA_SUCESSAO
  id_avaliado_sucessao INT, -- @map <- raw.dbo__INSTANCIA_PARTICIPANTE_SUCESSAO.ID_AVALIADO_SUCESSAO
  id_quadrante_sucessao_de INT, -- @map <- raw.dbo__INSTANCIA_PARTICIPANTE_SUCESSAO.ID_QUADRANTE_SUCESSAO_DE
  id_quadrante_sucessao_para INT, -- @map <- raw.dbo__INSTANCIA_PARTICIPANTE_SUCESSAO.ID_QUADRANTE_SUCESSAO_PARA
  justificativa_desempenho STRING, -- @map <- raw.dbo__INSTANCIA_PARTICIPANTE_SUCESSAO.JUSTIFICATIVA_DESEMPENHO
  justificativa_potencial STRING, -- @map <- raw.dbo__INSTANCIA_PARTICIPANTE_SUCESSAO.JUSTIFICATIVA_POTENCIAL
  desempenho_participante_calibrado INT, -- @map <- raw.dbo__INSTANCIA_PARTICIPANTE_SUCESSAO.DESEMPENHO_PARTICIPANTE_CALIBRADO
  potencial_participante_calibrado INT, -- @map <- raw.dbo__INSTANCIA_PARTICIPANTE_SUCESSAO.POTENCIAL_PARTICIPANTE_CALIBRADO
  dt_alteracao TIMESTAMP, -- @map <- raw.dbo__INSTANCIA_PARTICIPANTE_SUCESSAO.DT_ALTERACAO
  id_colaborador_resposavel_alteracao INT, -- @map <- raw.dbo__INSTANCIA_PARTICIPANTE_SUCESSAO.ID_COLABORADOR_RESPOSAVEL_ALTERACAO
  ativo INT, -- @map <- raw.dbo__INSTANCIA_PARTICIPANTE_SUCESSAO.ATIVO
  id_parent INT, -- @map <- raw.dbo__INSTANCIA_PARTICIPANTE_SUCESSAO.ID_PARENT
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.LanguageLevel — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__LanguageLevel
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_languagelevel (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__LanguageLevel.Id
  proficiency INT, -- @map <- raw.dbo__LanguageLevel.Proficiency
  employee_id INT, -- @map <- raw.dbo__LanguageLevel.EmployeeId
  language_id INT, -- @map <- raw.dbo__LanguageLevel.LanguageId
  observation STRING, -- @map <- raw.dbo__LanguageLevel.Observation
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.Motivations — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__Motivations
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_motivations (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__Motivations.Id
  personal STRING, -- @map <- raw.dbo__Motivations.Personal
  demotivations STRING, -- @map <- raw.dbo__Motivations.Demotivations
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.NINE_BOX_CALIBRADOS — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__NINE_BOX_CALIBRADOS
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_nine_box_calibrados (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__NINE_BOX_CALIBRADOS.ID
  id_nine_box INT, -- @map <- raw.dbo__NINE_BOX_CALIBRADOS.ID_NINE_BOX
  id_colaborador INT, -- @map <- raw.dbo__NINE_BOX_CALIBRADOS.ID_COLABORADOR
  calibration_markup INT, -- @map <- raw.dbo__NINE_BOX_CALIBRADOS.CalibrationMarkup
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.NOTIFICACAO_LIDA — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__NOTIFICACAO_LIDA
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_notificacao_lida (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__NOTIFICACAO_LIDA.ID
  id_notificacao INT, -- @map <- raw.dbo__NOTIFICACAO_LIDA.ID_NOTIFICACAO
  id_colaborador INT, -- @map <- raw.dbo__NOTIFICACAO_LIDA.ID_COLABORADOR
  dt_leitura TIMESTAMP, -- @map <- raw.dbo__NOTIFICACAO_LIDA.DT_LEITURA
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.PERFIL_USUARIO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__PERFIL_USUARIO
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_perfil_usuario (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__PERFIL_USUARIO.ID
  id_colaborador INT, -- @map <- raw.dbo__PERFIL_USUARIO.ID_COLABORADOR
  id_funcionalidade STRING, -- @map <- raw.dbo__PERFIL_USUARIO.ID_FUNCIONALIDADE
  outras_areas INT, -- @map <- raw.dbo__PERFIL_USUARIO.OUTRAS_AREAS
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.PersonalCharacteristics — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__PersonalCharacteristics
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_personalcharacteristics (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__PersonalCharacteristics.Id
  personal STRING, -- @map <- raw.dbo__PersonalCharacteristics.Personal
  others STRING, -- @map <- raw.dbo__PersonalCharacteristics.Others
  what_will_not_give_up STRING, -- @map <- raw.dbo__PersonalCharacteristics.WhatWillNotGiveUp
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.PresentationFavoriteSlide — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__PresentationFavoriteSlide
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_presentationfavoriteslide (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__PresentationFavoriteSlide.Id
  employee_id INT, -- @map <- raw.dbo__PresentationFavoriteSlide.EmployeeId
  presentation_template_slide_id INT, -- @map <- raw.dbo__PresentationFavoriteSlide.PresentationTemplateSlideId
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.PROCESSO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__PROCESSO
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_processo (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__PROCESSO.ID
  id_indicador INT, -- @map <- raw.dbo__PROCESSO.ID_INDICADOR
  id_responsavel INT, -- @map <- raw.dbo__PROCESSO.ID_RESPONSAVEL
  cod_processo STRING, -- @map <- raw.dbo__PROCESSO.COD_PROCESSO
  desc_processo STRING, -- @map <- raw.dbo__PROCESSO.DESC_PROCESSO
  tipo_processo INT, -- @map <- raw.dbo__PROCESSO.TIPO_PROCESSO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.ProfessionalExperience — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ProfessionalExperience
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_professionalexperience (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__ProfessionalExperience.Id
  location_id INT, -- @map <- raw.dbo__ProfessionalExperience.LocationId
  location STRING, -- @map <- raw.dbo__ProfessionalExperience.Location
  start TIMESTAMP, -- @map <- raw.dbo__ProfessionalExperience.Start
  end TIMESTAMP, -- @map <- raw.dbo__ProfessionalExperience.End
  job_description STRING, -- @map <- raw.dbo__ProfessionalExperience.JobDescription
  current_job INT, -- @map <- raw.dbo__ProfessionalExperience.CurrentJob
  employee_id INT, -- @map <- raw.dbo__ProfessionalExperience.EmployeeId
  knowledge_area STRING, -- @map <- raw.dbo__ProfessionalExperience.KnowledgeArea
  company_id INT, -- @map <- raw.dbo__ProfessionalExperience.CompanyId
  job_position_id INT, -- @map <- raw.dbo__ProfessionalExperience.JobPositionId
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.ProfileEditPermission — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ProfileEditPermission
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_profileeditpermission (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__ProfileEditPermission.Id
  employee_id INT, -- @map <- raw.dbo__ProfileEditPermission.EmployeeId
  user_group_id INT, -- @map <- raw.dbo__ProfileEditPermission.UserGroupId
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.PSW_COLABORADOR — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__PSW_COLABORADOR
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_psw_colaborador (
  tenant_slug STRING,
  id_colaborador INT, -- @map <- raw.dbo__PSW_COLABORADOR.ID_COLABORADOR
  create_date TIMESTAMP, -- @map <- raw.dbo__PSW_COLABORADOR.CREATE_DATE
  last_upd TIMESTAMP, -- @map <- raw.dbo__PSW_COLABORADOR.LAST_UPD
  expired INT, -- @map <- raw.dbo__PSW_COLABORADOR.EXPIRED
  attempts INT, -- @map <- raw.dbo__PSW_COLABORADOR.ATTEMPTS
  current_psw STRING, -- @map <- raw.dbo__PSW_COLABORADOR.CURRENT_PSW
  private_current_psw BINARY, -- @map <- raw.dbo__PSW_COLABORADOR.PRIVATE_CURRENT_PSW
  PRIMARY KEY (tenant_slug, id_colaborador)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.PSW_COLABORADOR_ITEM — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__PSW_COLABORADOR_ITEM
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_psw_colaborador_item (
  tenant_slug STRING,
  id_colaborador INT, -- @map <- raw.dbo__PSW_COLABORADOR_ITEM.ID_COLABORADOR
  create_date TIMESTAMP, -- @map <- raw.dbo__PSW_COLABORADOR_ITEM.CREATE_DATE
  psw STRING, -- @map <- raw.dbo__PSW_COLABORADOR_ITEM.PSW
  private_current_psw BINARY, -- @map <- raw.dbo__PSW_COLABORADOR_ITEM.PRIVATE_CURRENT_PSW
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.ServerCachePreferencesManagementCycle — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ServerCachePreferencesManagementCycle
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_servercachepreferencesmanagementcycle (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__ServerCachePreferencesManagementCycle.Id
  sidebar_item_id INT, -- @map <- raw.dbo__ServerCachePreferencesManagementCycle.SidebarItemId
  management_cycle_id INT, -- @map <- raw.dbo__ServerCachePreferencesManagementCycle.ManagementCycleId
  employee_id INT, -- @map <- raw.dbo__ServerCachePreferencesManagementCycle.EmployeeId
  filter_json STRING, -- @map <- raw.dbo__ServerCachePreferencesManagementCycle.FilterJson
  operation_date TIMESTAMP, -- @map <- raw.dbo__ServerCachePreferencesManagementCycle.OperationDate
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.Sport — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__Sport
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_sport (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__Sport.Id
  name STRING, -- @map <- raw.dbo__Sport.Name
  sport_id INT, -- @map <- raw.dbo__Sport.SportId
  frequency INT, -- @map <- raw.dbo__Sport.Frequency
  employee_id INT, -- @map <- raw.dbo__Sport.EmployeeId
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.SystemKnowledge — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__SystemKnowledge
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_systemknowledge (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__SystemKnowledge.Id
  name STRING, -- @map <- raw.dbo__SystemKnowledge.Name
  level INT, -- @map <- raw.dbo__SystemKnowledge.Level
  employee_id INT, -- @map <- raw.dbo__SystemKnowledge.EmployeeId
  skill_category_id INT, -- @map <- raw.dbo__SystemKnowledge.SkillCategoryId
  skill_knowledge_id INT, -- @map <- raw.dbo__SystemKnowledge.SkillKnowledgeId
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.TERMO_ACEITE_SECAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__TERMO_ACEITE_SECAO
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_termo_aceite_secao (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__TERMO_ACEITE_SECAO.ID
  id_termo_aceite INT, -- @map <- raw.dbo__TERMO_ACEITE_SECAO.ID_TERMO_ACEITE
  ordem INT, -- @map <- raw.dbo__TERMO_ACEITE_SECAO.ORDEM
  tipo INT, -- @map <- raw.dbo__TERMO_ACEITE_SECAO.TIPO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.Theme — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__Theme
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_theme (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__Theme.Id
  name STRING, -- @map <- raw.dbo__Theme.Name
  owner_id INT, -- @map <- raw.dbo__Theme.OwnerId
  layout_setting STRING, -- @map <- raw.dbo__Theme.LayoutSetting
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.ThemeHistory — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ThemeHistory
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_themehistory (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__ThemeHistory.Id
  employee_id INT, -- @map <- raw.dbo__ThemeHistory.EmployeeId
  update_date TIMESTAMP, -- @map <- raw.dbo__ThemeHistory.UpdateDate
  theme_id INT, -- @map <- raw.dbo__ThemeHistory.ThemeId
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.ThemeShare — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ThemeShare
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_themeshare (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__ThemeShare.Id
  theme_id INT, -- @map <- raw.dbo__ThemeShare.ThemeId
  employee_id INT, -- @map <- raw.dbo__ThemeShare.EmployeeId
  permission_type INT, -- @map <- raw.dbo__ThemeShare.PermissionType
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.VolunteerExperience — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__VolunteerExperience
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_volunteerexperience (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__VolunteerExperience.Id
  start TIMESTAMP, -- @map <- raw.dbo__VolunteerExperience.Start
  end TIMESTAMP, -- @map <- raw.dbo__VolunteerExperience.End
  job_description STRING, -- @map <- raw.dbo__VolunteerExperience.JobDescription
  cause STRING, -- @map <- raw.dbo__VolunteerExperience.Cause
  current_job INT, -- @map <- raw.dbo__VolunteerExperience.CurrentJob
  employee_id INT, -- @map <- raw.dbo__VolunteerExperience.EmployeeId
  company_id INT, -- @map <- raw.dbo__VolunteerExperience.CompanyId
  function_id INT, -- @map <- raw.dbo__VolunteerExperience.FunctionId
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.VolunteerFunction — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__VolunteerFunction
CREATE TABLE IF NOT EXISTS staging.stg_colaborador_volunteerfunction (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__VolunteerFunction.Id
  description STRING, -- @map <- raw.dbo__VolunteerFunction.Description
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.AreaHistoryConfig — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__AreaHistoryConfig
CREATE TABLE IF NOT EXISTS staging.stg_metricas_areahistoryconfig (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__AreaHistoryConfig.Id
  last_sync_date TIMESTAMP, -- @map <- raw.dbo__AreaHistoryConfig.LastSyncDate
  management_cycle_id INT, -- @map <- raw.dbo__AreaHistoryConfig.ManagementCycle_Id
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.CalibrationGroupDiscretionary — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__CalibrationGroupDiscretionary
CREATE TABLE IF NOT EXISTS staging.stg_metricas_calibrationgroupdiscretionary (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__CalibrationGroupDiscretionary.ID
  calculation_period_id INT, -- @map <- raw.dbo__CalibrationGroupDiscretionary.CalculationPeriod_Id
  description STRING, -- @map <- raw.dbo__CalibrationGroupDiscretionary.Description
  score_calculation_information STRING, -- @map <- raw.dbo__CalibrationGroupDiscretionary.ScoreCalculationInformation
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.CODE_GENERATOR — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__CODE_GENERATOR
CREATE TABLE IF NOT EXISTS staging.stg_metricas_code_generator (
  tenant_slug STRING,
  table_name STRING, -- @map <- raw.dbo__CODE_GENERATOR.TABLE_NAME
  id_periodo_gestao INT, -- @map <- raw.dbo__CODE_GENERATOR.ID_PERIODO_GESTAO
  valor INT, -- @map <- raw.dbo__CODE_GENERATOR.VALOR
  automatica INT, -- @map <- raw.dbo__CODE_GENERATOR.AUTOMATICA
  id INT, -- @map <- raw.dbo__CODE_GENERATOR.Id
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.ConceptDiscretionary — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ConceptDiscretionary
CREATE TABLE IF NOT EXISTS staging.stg_metricas_conceptdiscretionary (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__ConceptDiscretionary.Id
  name STRING, -- @map <- raw.dbo__ConceptDiscretionary.Name
  grade DECIMAL(18,2), -- @map <- raw.dbo__ConceptDiscretionary.Grade
  periodo_apuracao_id INT, -- @map <- raw.dbo__ConceptDiscretionary.PeriodoApuracao_Id
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.CURVA_MULTIPLO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__CURVA_MULTIPLO
CREATE TABLE IF NOT EXISTS staging.stg_metricas_curva_multiplo (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__CURVA_MULTIPLO.ID
  id_nivel INT, -- @map <- raw.dbo__CURVA_MULTIPLO.ID_NIVEL
  id_periodo_apuracao INT, -- @map <- raw.dbo__CURVA_MULTIPLO.ID_PERIODO_APURACAO
  nota_curva_multiplo DOUBLE, -- @map <- raw.dbo__CURVA_MULTIPLO.NOTA_CURVA_MULTIPLO
  multiplo_curva_multiplo DOUBLE, -- @map <- raw.dbo__CURVA_MULTIPLO.MULTIPLO_CURVA_MULTIPLO
  concept STRING, -- @map <- raw.dbo__CURVA_MULTIPLO.Concept
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.CURVA_PREMIACAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__CURVA_PREMIACAO
CREATE TABLE IF NOT EXISTS staging.stg_metricas_curva_premiacao (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__CURVA_PREMIACAO.ID
  id_periodo_gestao INT, -- @map <- raw.dbo__CURVA_PREMIACAO.ID_PERIODO_GESTAO
  id_source INT, -- @map <- raw.dbo__CURVA_PREMIACAO.ID_SOURCE
  cod_curva_premiacao STRING, -- @map <- raw.dbo__CURVA_PREMIACAO.COD_CURVA_PREMIACAO
  desc_curva_premiacao STRING, -- @map <- raw.dbo__CURVA_PREMIACAO.DESC_CURVA_PREMIACAO
  tipo_interpolacao INT, -- @map <- raw.dbo__CURVA_PREMIACAO.TIPO_INTERPOLACAO
  use_min_score_instead_of_zero INT, -- @map <- raw.dbo__CURVA_PREMIACAO.UseMinScoreInsteadOfZero
  default_curve INT, -- @map <- raw.dbo__CURVA_PREMIACAO.DefaultCurve
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.DIRETRIZ — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__DIRETRIZ
CREATE TABLE IF NOT EXISTS staging.stg_metricas_diretriz (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__DIRETRIZ.ID
  id_periodo_gestao INT, -- @map <- raw.dbo__DIRETRIZ.ID_PERIODO_GESTAO
  cod_diretriz STRING, -- @map <- raw.dbo__DIRETRIZ.COD_DIRETRIZ
  desc_diretriz STRING, -- @map <- raw.dbo__DIRETRIZ.DESC_DIRETRIZ
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.EXPRESSAO_CALCULO_META — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__EXPRESSAO_CALCULO_META
CREATE TABLE IF NOT EXISTS staging.stg_metricas_expressao_calculo_meta (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__EXPRESSAO_CALCULO_META.ID
  id_meta INT, -- @map <- raw.dbo__EXPRESSAO_CALCULO_META.ID_META
  id_meta_ref INT, -- @map <- raw.dbo__EXPRESSAO_CALCULO_META.ID_META_REF
  id_grupo_conta_ref INT, -- @map <- raw.dbo__EXPRESSAO_CALCULO_META.ID_GRUPO_CONTA_REF
  id_entidade_ref INT, -- @map <- raw.dbo__EXPRESSAO_CALCULO_META.ID_ENTIDADE_REF
  id_matriz INT, -- @map <- raw.dbo__EXPRESSAO_CALCULO_META.ID_MATRIZ
  tipo_processo_ref INT, -- @map <- raw.dbo__EXPRESSAO_CALCULO_META.TIPO_PROCESSO_REF
  tipo_matriz_ref INT, -- @map <- raw.dbo__EXPRESSAO_CALCULO_META.TIPO_MATRIZ_REF
  valor_ref DOUBLE, -- @map <- raw.dbo__EXPRESSAO_CALCULO_META.VALOR_REF
  peso_meta_ref DECIMAL(28,8), -- @map <- raw.dbo__EXPRESSAO_CALCULO_META.PESO_META_REF
  operador INT, -- @map <- raw.dbo__EXPRESSAO_CALCULO_META.OPERADOR
  desc_expressao STRING, -- @map <- raw.dbo__EXPRESSAO_CALCULO_META.DESC_EXPRESSAO
  ordem INT, -- @map <- raw.dbo__EXPRESSAO_CALCULO_META.ORDEM
  id_eixo_x INT, -- @map <- raw.dbo__EXPRESSAO_CALCULO_META.ID_EIXO_X
  id_eixo_y INT, -- @map <- raw.dbo__EXPRESSAO_CALCULO_META.ID_EIXO_Y
  id_eixo_z INT, -- @map <- raw.dbo__EXPRESSAO_CALCULO_META.ID_EIXO_Z
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.FactorTriggerConfiguration — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__FactorTriggerConfiguration
CREATE TABLE IF NOT EXISTS staging.stg_metricas_factortriggerconfiguration (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__FactorTriggerConfiguration.Id
  type INT, -- @map <- raw.dbo__FactorTriggerConfiguration.Type
  value DECIMAL(28,8), -- @map <- raw.dbo__FactorTriggerConfiguration.Value
  payment_group_id INT, -- @map <- raw.dbo__FactorTriggerConfiguration.PaymentGroup_Id
  custom_grade_formation_id INT, -- @map <- raw.dbo__FactorTriggerConfiguration.CustomGradeFormation_Id
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.FAIXA_FAROL — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__FAIXA_FAROL
CREATE TABLE IF NOT EXISTS staging.stg_metricas_faixa_farol (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__FAIXA_FAROL.ID
  cod_faixa_farol STRING, -- @map <- raw.dbo__FAIXA_FAROL.COD_FAIXA_FAROL
  desc_faixa_farol STRING, -- @map <- raw.dbo__FAIXA_FAROL.DESC_FAIXA_FAROL
  comparador INT, -- @map <- raw.dbo__FAIXA_FAROL.COMPARADOR
  default_for_goals_book_score INT, -- @map <- raw.dbo__FAIXA_FAROL.DefaultForGoalsBookScore
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.FAIXA_FAROL_ITEM — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__FAIXA_FAROL_ITEM
CREATE TABLE IF NOT EXISTS staging.stg_metricas_faixa_farol_item (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__FAIXA_FAROL_ITEM.ID
  id_faixa_farol INT, -- @map <- raw.dbo__FAIXA_FAROL_ITEM.ID_FAIXA_FAROL
  id_farol INT, -- @map <- raw.dbo__FAIXA_FAROL_ITEM.ID_FAROL
  operador_mim INT, -- @map <- raw.dbo__FAIXA_FAROL_ITEM.OPERADOR_MIM
  valor_min DOUBLE, -- @map <- raw.dbo__FAIXA_FAROL_ITEM.VALOR_MIN
  operador_max INT, -- @map <- raw.dbo__FAIXA_FAROL_ITEM.OPERADOR_MAX
  valor_max DOUBLE, -- @map <- raw.dbo__FAIXA_FAROL_ITEM.VALOR_MAX
  habilitado INT, -- @map <- raw.dbo__FAIXA_FAROL_ITEM.HABILITADO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.FAROL — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__FAROL
CREATE TABLE IF NOT EXISTS staging.stg_metricas_farol (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__FAROL.ID
  desc_farol STRING, -- @map <- raw.dbo__FAROL.DESC_FAROL
  habilitado INT, -- @map <- raw.dbo__FAROL.HABILITADO
  cor_hexadecimal STRING, -- @map <- raw.dbo__FAROL.COR_HEXADECIMAL
  cor_rgb STRING, -- @map <- raw.dbo__FAROL.COR_RGB
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.FREQUENCIA_ACOMP — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__FREQUENCIA_ACOMP
CREATE TABLE IF NOT EXISTS staging.stg_metricas_frequencia_acomp (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__FREQUENCIA_ACOMP.ID
  desc_frequencia_acomp STRING, -- @map <- raw.dbo__FREQUENCIA_ACOMP.DESC_FREQUENCIA_ACOMP
  fator_periodo DOUBLE, -- @map <- raw.dbo__FREQUENCIA_ACOMP.FATOR_PERIODO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.FREQUENCIA_VISUALIZACAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__FREQUENCIA_VISUALIZACAO
CREATE TABLE IF NOT EXISTS staging.stg_metricas_frequencia_visualizacao (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__FREQUENCIA_VISUALIZACAO.ID
  desc_frequencia_visualizacao STRING, -- @map <- raw.dbo__FREQUENCIA_VISUALIZACAO.DESC_FREQUENCIA_VISUALIZACAO
  qte_mes INT, -- @map <- raw.dbo__FREQUENCIA_VISUALIZACAO.QTE_MES
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.GoalPendencyValueImport — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__GoalPendencyValueImport
CREATE TABLE IF NOT EXISTS staging.stg_metricas_goalpendencyvalueimport (
  tenant_slug STRING,
  import_log_id INT, -- @map <- raw.dbo__GoalPendencyValueImport.ImportLogId
  line INT, -- @map <- raw.dbo__GoalPendencyValueImport.Line
  goal_id INT, -- @map <- raw.dbo__GoalPendencyValueImport.GoalId
  goal_value_id INT, -- @map <- raw.dbo__GoalPendencyValueImport.GoalValueId
  reference_date TIMESTAMP, -- @map <- raw.dbo__GoalPendencyValueImport.ReferenceDate
  punctual_actual DECIMAL(28,8), -- @map <- raw.dbo__GoalPendencyValueImport.PunctualActual
  accumulated_actual DECIMAL(28,8), -- @map <- raw.dbo__GoalPendencyValueImport.AccumulatedActual
  punctual_na_actual INT, -- @map <- raw.dbo__GoalPendencyValueImport.PunctualNaActual
  accumulated_na_actual INT, -- @map <- raw.dbo__GoalPendencyValueImport.AccumulatedNaActual
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.GoalWorkflow — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__GoalWorkflow
CREATE TABLE IF NOT EXISTS staging.stg_metricas_goalworkflow (
  tenant_slug STRING,
  management_cycle_id INT, -- @map <- raw.dbo__GoalWorkflow.ManagementCycle_Id
  workflow_type INT, -- @map <- raw.dbo__GoalWorkflow.WorkflowType
  id INT, -- @map <- raw.dbo__GoalWorkflow.ID
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.GoalWorkflowCustomStep — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__GoalWorkflowCustomStep
CREATE TABLE IF NOT EXISTS staging.stg_metricas_goalworkflowcustomstep (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__GoalWorkflowCustomStep.Id
  title STRING, -- @map <- raw.dbo__GoalWorkflowCustomStep.Title
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.GoalWorkflowStep — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__GoalWorkflowStep
CREATE TABLE IF NOT EXISTS staging.stg_metricas_goalworkflowstep (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__GoalWorkflowStep.Id
  id_goal_workflow INT, -- @map <- raw.dbo__GoalWorkflowStep.IdGoalWorkflow
  order INT, -- @map <- raw.dbo__GoalWorkflowStep.Order
  type INT, -- @map <- raw.dbo__GoalWorkflowStep.Type
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.GRUPO_PAGTO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__GRUPO_PAGTO
CREATE TABLE IF NOT EXISTS staging.stg_metricas_grupo_pagto (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__GRUPO_PAGTO.ID
  id_periodo_apuracao INT, -- @map <- raw.dbo__GRUPO_PAGTO.ID_PERIODO_APURACAO
  cod_grupo_pagto STRING, -- @map <- raw.dbo__GRUPO_PAGTO.COD_GRUPO_PAGTO
  desc_grupo_pagto STRING, -- @map <- raw.dbo__GRUPO_PAGTO.DESC_GRUPO_PAGTO
  perc_individual DOUBLE, -- @map <- raw.dbo__GRUPO_PAGTO.PERC_INDIVIDUAL
  perc_area DOUBLE, -- @map <- raw.dbo__GRUPO_PAGTO.PERC_AREA
  perc_superior DOUBLE, -- @map <- raw.dbo__GRUPO_PAGTO.PERC_SUPERIOR
  perc_presidencia DOUBLE, -- @map <- raw.dbo__GRUPO_PAGTO.PERC_PRESIDENCIA
  pool_grupo_pagto DOUBLE, -- @map <- raw.dbo__GRUPO_PAGTO.POOL_GRUPO_PAGTO
  perc_avaliacao_competencia DOUBLE, -- @map <- raw.dbo__GRUPO_PAGTO.PERC_AVALIACAO_COMPETENCIA
  perc_discricionario DOUBLE, -- @map <- raw.dbo__GRUPO_PAGTO.PERC_DISCRICIONARIO
  id_pool INT, -- @map <- raw.dbo__GRUPO_PAGTO.ID_POOL
  perc_filial DOUBLE, -- @map <- raw.dbo__GRUPO_PAGTO.PERC_FILIAL
  valor_pool DECIMAL(28,8), -- @map <- raw.dbo__GRUPO_PAGTO.VALOR_POOL
  proportionality_modifier_id INT, -- @map <- raw.dbo__GRUPO_PAGTO.ProportionalityModifier_Id
  apply_cascade_effect INT, -- @map <- raw.dbo__GRUPO_PAGTO.ApplyCascadeEffect
  perc_avaliacao_discricionaria DOUBLE, -- @map <- raw.dbo__GRUPO_PAGTO.PERC_AVALIACAO_DISCRICIONARIA
  PRIMARY KEY (tenant_slug, id)
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
-- @note: Cleanse dbo.INDICADOR_TIPOMETA — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__INDICADOR_TIPOMETA
CREATE TABLE IF NOT EXISTS staging.stg_metricas_indicador_tipometa (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__INDICADOR_TIPOMETA.ID
  id_indicador INT, -- @map <- raw.dbo__INDICADOR_TIPOMETA.ID_INDICADOR
  tipo_meta INT, -- @map <- raw.dbo__INDICADOR_TIPOMETA.TIPO_META
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.INFO_NOTA_META — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__INFO_NOTA_META
CREATE TABLE IF NOT EXISTS staging.stg_metricas_info_nota_meta (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__INFO_NOTA_META.ID
  id_meta INT, -- @map <- raw.dbo__INFO_NOTA_META.ID_META
  tipo_valor INT, -- @map <- raw.dbo__INFO_NOTA_META.TIPO_VALOR
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.LabelGoal — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__LabelGoal
CREATE TABLE IF NOT EXISTS staging.stg_metricas_labelgoal (
  tenant_slug STRING,
  id_label INT, -- @map <- raw.dbo__LabelGoal.IdLabel
  id_goal INT, -- @map <- raw.dbo__LabelGoal.IdGoal
  PRIMARY KEY (tenant_slug, id_label, id_goal)
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
-- @note: Cleanse dbo.NIVEL — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__NIVEL
CREATE TABLE IF NOT EXISTS staging.stg_metricas_nivel (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__NIVEL.ID
  id_periodo_apuracao INT, -- @map <- raw.dbo__NIVEL.ID_PERIODO_APURACAO
  id_grupo_pagto INT, -- @map <- raw.dbo__NIVEL.ID_GRUPO_PAGTO
  cod_nivel STRING, -- @map <- raw.dbo__NIVEL.COD_NIVEL
  desc_nivel STRING, -- @map <- raw.dbo__NIVEL.DESC_NIVEL
  multiplo_salarial DOUBLE, -- @map <- raw.dbo__NIVEL.MULTIPLO_SALARIAL
  salario DOUBLE, -- @map <- raw.dbo__NIVEL.SALARIO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.NormalizationCurvePoint — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__NormalizationCurvePoint
CREATE TABLE IF NOT EXISTS staging.stg_metricas_normalizationcurvepoint (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__NormalizationCurvePoint.Id
  performance_score DECIMAL(28,8), -- @map <- raw.dbo__NormalizationCurvePoint.PerformanceScore
  evaluation_score DECIMAL(28,8), -- @map <- raw.dbo__NormalizationCurvePoint.EvaluationScore
  is_reference INT, -- @map <- raw.dbo__NormalizationCurvePoint.IsReference
  calculation_period_id INT, -- @map <- raw.dbo__NormalizationCurvePoint.CalculationPeriod_Id
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.NOTA_META — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__NOTA_META
CREATE TABLE IF NOT EXISTS staging.stg_metricas_nota_meta (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__NOTA_META.ID
  id_meta INT, -- @map <- raw.dbo__NOTA_META.ID_META
  id_nota INT, -- @map <- raw.dbo__NOTA_META.ID_NOTA
  perc_nota DOUBLE, -- @map <- raw.dbo__NOTA_META.PERC_NOTA
  valor_nota DOUBLE, -- @map <- raw.dbo__NOTA_META.VALOR_NOTA
  PRIMARY KEY (tenant_slug, id)
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
-- @note: Cleanse dbo.Pool — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__Pool
CREATE TABLE IF NOT EXISTS staging.stg_metricas_pool (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__Pool.Id
  code STRING, -- @map <- raw.dbo__Pool.Code
  description STRING, -- @map <- raw.dbo__Pool.Description
  value DECIMAL(28,8), -- @map <- raw.dbo__Pool.Value
  periodo_apuracao_id INT, -- @map <- raw.dbo__Pool.PeriodoApuracao_Id
  upper_pool_id INT, -- @map <- raw.dbo__Pool.UpperPool_Id
  path STRING, -- @map <- raw.dbo__Pool.Path
  redistribute_pool_by_score INT, -- @map <- raw.dbo__Pool.RedistributePoolByScore
  redistribute_pool_by_calculation_period INT, -- @map <- raw.dbo__Pool.RedistributePoolByCalculationPeriod
  advance_results_period_id INT, -- @map <- raw.dbo__Pool.AdvanceResultsPeriod_Id
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.RangeDiscretionary — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__RangeDiscretionary
CREATE TABLE IF NOT EXISTS staging.stg_metricas_rangediscretionary (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__RangeDiscretionary.Id
  name STRING, -- @map <- raw.dbo__RangeDiscretionary.Name
  minimum_grade DECIMAL(18,2), -- @map <- raw.dbo__RangeDiscretionary.MinimumGrade
  maximum_grade DECIMAL(18,2), -- @map <- raw.dbo__RangeDiscretionary.MaximumGrade
  periodo_apuracao_id INT, -- @map <- raw.dbo__RangeDiscretionary.PeriodoApuracao_Id
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.RelUpperGoal — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__RelUpperGoal
CREATE TABLE IF NOT EXISTS staging.stg_metricas_reluppergoal (
  tenant_slug STRING,
  goal_id INT, -- @map <- raw.dbo__RelUpperGoal.GoalId
  upper_goal_id INT, -- @map <- raw.dbo__RelUpperGoal.UpperGoalId
  PRIMARY KEY (tenant_slug, goal_id, upper_goal_id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.ScoreValuesRV — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ScoreValuesRV
CREATE TABLE IF NOT EXISTS staging.stg_metricas_scorevaluesrv (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__ScoreValuesRV.Id
  individual DECIMAL(28,8), -- @map <- raw.dbo__ScoreValuesRV.Individual
  area DECIMAL(28,8), -- @map <- raw.dbo__ScoreValuesRV.Area
  superior DECIMAL(28,8), -- @map <- raw.dbo__ScoreValuesRV.Superior
  filial DECIMAL(28,8), -- @map <- raw.dbo__ScoreValuesRV.Filial
  presidencia DECIMAL(28,8), -- @map <- raw.dbo__ScoreValuesRV.Presidencia
  avaliacao_competencia DECIMAL(28,8), -- @map <- raw.dbo__ScoreValuesRV.AvaliacaoCompetencia
  discricionario DECIMAL(28,8), -- @map <- raw.dbo__ScoreValuesRV.Discricionario
  calculation_period_id INT, -- @map <- raw.dbo__ScoreValuesRV.CalculationPeriod_Id
  employee_id INT, -- @map <- raw.dbo__ScoreValuesRV.Employee_Id
  management_cycle_id INT, -- @map <- raw.dbo__ScoreValuesRV.ManagementCycle_Id
  dt_fim TIMESTAMP, -- @map <- raw.dbo__ScoreValuesRV.DtFim
  employee_area_id INT, -- @map <- raw.dbo__ScoreValuesRV.EmployeeArea_Id
  avaliacao_discricionaria DECIMAL(28,8), -- @map <- raw.dbo__ScoreValuesRV.AvaliacaoDiscricionaria
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.TERMO_ACEITE — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__TERMO_ACEITE
CREATE TABLE IF NOT EXISTS staging.stg_metricas_termo_aceite (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__TERMO_ACEITE.ID
  id_periodo_gestao INT, -- @map <- raw.dbo__TERMO_ACEITE.ID_PERIODO_GESTAO
  texto STRING, -- @map <- raw.dbo__TERMO_ACEITE.TEXTO
  esconder_percentual INT, -- @map <- raw.dbo__TERMO_ACEITE.ESCONDER_PERCENTUAL
  last_update TIMESTAMP, -- @map <- raw.dbo__TERMO_ACEITE.LastUpdate
  agreements_restrictions_to_send STRING, -- @map <- raw.dbo__TERMO_ACEITE.AgreementsRestrictionsToSend
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.Trigger — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__Trigger
CREATE TABLE IF NOT EXISTS staging.stg_metricas_trigger (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__Trigger.Id
  code STRING, -- @map <- raw.dbo__Trigger.Code
  description STRING, -- @map <- raw.dbo__Trigger.Description
  type INT, -- @map <- raw.dbo__Trigger.Type
  area_id INT, -- @map <- raw.dbo__Trigger.Area_Id
  employee_id INT, -- @map <- raw.dbo__Trigger.Employee_Id
  goal_id INT, -- @map <- raw.dbo__Trigger.Goal_Id
  periodo_apuracao_id INT, -- @map <- raw.dbo__Trigger.PeriodoApuracao_Id
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.TriggerCurve — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__TriggerCurve
CREATE TABLE IF NOT EXISTS staging.stg_metricas_triggercurve (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__TriggerCurve.Id
  code STRING, -- @map <- raw.dbo__TriggerCurve.Code
  description STRING, -- @map <- raw.dbo__TriggerCurve.Description
  type INT, -- @map <- raw.dbo__TriggerCurve.Type
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.TriggerCurveItem — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__TriggerCurveItem
CREATE TABLE IF NOT EXISTS staging.stg_metricas_triggercurveitem (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__TriggerCurveItem.Id
  id_curve INT, -- @map <- raw.dbo__TriggerCurveItem.IdCurve
  value DECIMAL(28,8), -- @map <- raw.dbo__TriggerCurveItem.Value
  multiple_factor DECIMAL(28,8), -- @map <- raw.dbo__TriggerCurveItem.MultipleFactor
  PRIMARY KEY (tenant_slug, id)
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
-- @note: Cleanse dbo.YearPersonalGoal — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__YearPersonalGoal
CREATE TABLE IF NOT EXISTS staging.stg_metricas_yearpersonalgoal (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__YearPersonalGoal.Id
  personal_goal STRING, -- @map <- raw.dbo__YearPersonalGoal.PersonalGoal
  year INT, -- @map <- raw.dbo__YearPersonalGoal.Year
  motivations_id INT, -- @map <- raw.dbo__YearPersonalGoal.MotivationsId
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.ADMINISTRADOR_LOCAL_FILIAL — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ADMINISTRADOR_LOCAL_FILIAL
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_administrador_local_filial (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__ADMINISTRADOR_LOCAL_FILIAL.ID
  id_administrador_local INT, -- @map <- raw.dbo__ADMINISTRADOR_LOCAL_FILIAL.ID_ADMINISTRADOR_LOCAL
  id_filial INT, -- @map <- raw.dbo__ADMINISTRADOR_LOCAL_FILIAL.ID_FILIAL
  PRIMARY KEY (tenant_slug, id)
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
-- @note: Cleanse dbo.AREA_FORUM_SUCESSAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__AREA_FORUM_SUCESSAO
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_area_forum_sucessao (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__AREA_FORUM_SUCESSAO.ID
  id_area INT, -- @map <- raw.dbo__AREA_FORUM_SUCESSAO.ID_AREA
  id_forum INT, -- @map <- raw.dbo__AREA_FORUM_SUCESSAO.ID_FORUM
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.AreaHistory — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__AreaHistory
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_areahistory (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__AreaHistory.Id
  start_date TIMESTAMP, -- @map <- raw.dbo__AreaHistory.StartDate
  end_date TIMESTAMP, -- @map <- raw.dbo__AreaHistory.EndDate
  area_id INT, -- @map <- raw.dbo__AreaHistory.Area_Id
  employee_id INT, -- @map <- raw.dbo__AreaHistory.Employee_Id
  score DECIMAL(28,8), -- @map <- raw.dbo__AreaHistory.Score
  start_date_ref TIMESTAMP, -- @map <- raw.dbo__AreaHistory.StartDateRef
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cargo
-- @origen: raw.dbo__CARGO
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_cargo (
  tenant_slug STRING,
  job_id BIGINT,                -- @map <- raw.dbo__CARGO.ID
  job_code STRING,              -- @map <- raw.dbo__CARGO.COD_CARGO
  job_desc STRING,              -- @map <- raw.dbo__CARGO.DESC_CARGO
  job_group_id BIGINT,          -- @map <- raw.dbo__CARGO.ID_GRUPO_CARGO
  is_critical_job INT,          -- @map <- raw.dbo__CARGO.IsCriticalJob
  PRIMARY KEY (tenant_slug, job_id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.Company — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__Company
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_company (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__Company.Id
  logo STRING, -- @map <- raw.dbo__Company.Logo
  name STRING, -- @map <- raw.dbo__Company.Name
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.CustomGradeFormation — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__CustomGradeFormation
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_customgradeformation (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__CustomGradeFormation.Id
  description STRING, -- @map <- raw.dbo__CustomGradeFormation.Description
  percentage DOUBLE, -- @map <- raw.dbo__CustomGradeFormation.Percentage
  area_id INT, -- @map <- raw.dbo__CustomGradeFormation.Area_Id
  payment_group_id INT, -- @map <- raw.dbo__CustomGradeFormation.PaymentGroup_Id
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.FILIAL — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__FILIAL
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_filial (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__FILIAL.ID
  id_idioma INT, -- @map <- raw.dbo__FILIAL.ID_IDIOMA
  id_moeda INT, -- @map <- raw.dbo__FILIAL.ID_MOEDA
  cod_filial STRING, -- @map <- raw.dbo__FILIAL.COD_FILIAL
  desc_filial STRING, -- @map <- raw.dbo__FILIAL.DESC_FILIAL
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.GRUPO_CARGO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__GRUPO_CARGO
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_grupo_cargo (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__GRUPO_CARGO.ID
  cod_grupo_cargo STRING, -- @map <- raw.dbo__GRUPO_CARGO.COD_GRUPO_CARGO
  desc_grupo_cargo STRING, -- @map <- raw.dbo__GRUPO_CARGO.DESC_GRUPO_CARGO
  cor STRING, -- @map <- raw.dbo__GRUPO_CARGO.COR
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.GRUPO_FUNCIONALIDADE — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__GRUPO_FUNCIONALIDADE
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_grupo_funcionalidade (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__GRUPO_FUNCIONALIDADE.ID
  desc_grupo_funcionalidade STRING, -- @map <- raw.dbo__GRUPO_FUNCIONALIDADE.DESC_GRUPO_FUNCIONALIDADE
  ordem_exibicao INT, -- @map <- raw.dbo__GRUPO_FUNCIONALIDADE.ORDEM_EXIBICAO
  id_parent INT, -- @map <- raw.dbo__GRUPO_FUNCIONALIDADE.ID_PARENT
  id_modulo INT, -- @map <- raw.dbo__GRUPO_FUNCIONALIDADE.ID_MODULO
  icone STRING, -- @map <- raw.dbo__GRUPO_FUNCIONALIDADE.ICONE
  tag STRING, -- @map <- raw.dbo__GRUPO_FUNCIONALIDADE.TAG
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.GRUPO_USUARIO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__GRUPO_USUARIO
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_grupo_usuario (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__GRUPO_USUARIO.ID
  desc_grupo_usuario STRING, -- @map <- raw.dbo__GRUPO_USUARIO.DESC_GRUPO_USUARIO
  tipo_usuario INT, -- @map <- raw.dbo__GRUPO_USUARIO.TIPO_USUARIO
  cod_grupo_usuario STRING, -- @map <- raw.dbo__GRUPO_USUARIO.COD_GRUPO_USUARIO
  require_two_factor INT, -- @map <- raw.dbo__GRUPO_USUARIO.REQUIRE_TWO_FACTOR
  painel_inicial_layout_id INT, -- @map <- raw.dbo__GRUPO_USUARIO.PAINEL_INICIAL_LAYOUT_ID
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.HistorySection — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__HistorySection
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_historysection (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__HistorySection.Id
  start_date TIMESTAMP, -- @map <- raw.dbo__HistorySection.StartDate
  end_date TIMESTAMP, -- @map <- raw.dbo__HistorySection.EndDate
  area_history_id INT, -- @map <- raw.dbo__HistorySection.AreaHistory_Id
  job_position_history_id INT, -- @map <- raw.dbo__HistorySection.JobPositionHistory_Id
  calculation_period_id INT, -- @map <- raw.dbo__HistorySection.CalculationPeriod_Id
  employee_id INT, -- @map <- raw.dbo__HistorySection.EmployeeId
  area_id INT, -- @map <- raw.dbo__HistorySection.AreaId
  job_position_id INT, -- @map <- raw.dbo__HistorySection.JobPositionId
  area_history_start_at TIMESTAMP, -- @map <- raw.dbo__HistorySection.AreaHistoryStartAt
  area_history_end_at TIMESTAMP, -- @map <- raw.dbo__HistorySection.AreaHistoryEndAt
  area_history_score DECIMAL(28,8), -- @map <- raw.dbo__HistorySection.AreaHistoryScore
  area_history_start_at_ref TIMESTAMP, -- @map <- raw.dbo__HistorySection.AreaHistoryStartAtRef
  job_position_history_start_at TIMESTAMP, -- @map <- raw.dbo__HistorySection.JobPositionHistoryStartAt
  job_position_history_end_at TIMESTAMP, -- @map <- raw.dbo__HistorySection.JobPositionHistoryEndAt
  job_position_history_salary DOUBLE, -- @map <- raw.dbo__HistorySection.JobPositionHistorySalary
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.JobPositionCore — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__JobPositionCore
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_jobpositioncore (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__JobPositionCore.Id
  code STRING, -- @map <- raw.dbo__JobPositionCore.Code
  description STRING, -- @map <- raw.dbo__JobPositionCore.Description
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.JobPositionLevel — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__JobPositionLevel
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_jobpositionlevel (
  tenant_slug STRING,
  job_position_id INT, -- @map <- raw.dbo__JobPositionLevel.JobPosition_Id
  level_id INT, -- @map <- raw.dbo__JobPositionLevel.Level_Id
  PRIMARY KEY (tenant_slug, job_position_id, level_id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.Locality — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__Locality
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_locality (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__Locality.Id
  description STRING, -- @map <- raw.dbo__Locality.Description
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.PERFIL_AREA — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__PERFIL_AREA
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_perfil_area (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__PERFIL_AREA.ID
  id_colaborador INT, -- @map <- raw.dbo__PERFIL_AREA.ID_COLABORADOR
  id_area INT, -- @map <- raw.dbo__PERFIL_AREA.ID_AREA
  visualizar INT, -- @map <- raw.dbo__PERFIL_AREA.VISUALIZAR
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.PERFIL_GRUPO_USUARIO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__PERFIL_GRUPO_USUARIO
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_perfil_grupo_usuario (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__PERFIL_GRUPO_USUARIO.ID
  id_grupo_usuario INT, -- @map <- raw.dbo__PERFIL_GRUPO_USUARIO.ID_GRUPO_USUARIO
  id_funcionalidade STRING, -- @map <- raw.dbo__PERFIL_GRUPO_USUARIO.ID_FUNCIONALIDADE
  pagina INT, -- @map <- raw.dbo__PERFIL_GRUPO_USUARIO.PAGINA
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.TERMO_ACEITE_ASSINATURA — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__TERMO_ACEITE_ASSINATURA
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_termo_aceite_assinatura (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__TERMO_ACEITE_ASSINATURA.ID
  id_termo_aceite INT, -- @map <- raw.dbo__TERMO_ACEITE_ASSINATURA.ID_TERMO_ACEITE
  id_area_colaborador INT, -- @map <- raw.dbo__TERMO_ACEITE_ASSINATURA.ID_AREA_COLABORADOR
  id_colaborador INT, -- @map <- raw.dbo__TERMO_ACEITE_ASSINATURA.ID_COLABORADOR
  assinatura_colaborador INT, -- @map <- raw.dbo__TERMO_ACEITE_ASSINATURA.ASSINATURA_COLABORADOR
  data_assinatura_colaborador TIMESTAMP, -- @map <- raw.dbo__TERMO_ACEITE_ASSINATURA.DATA_ASSINATURA_COLABORADOR
  id_responsavel_area INT, -- @map <- raw.dbo__TERMO_ACEITE_ASSINATURA.ID_RESPONSAVEL_AREA
  assinatura_responsavel_area INT, -- @map <- raw.dbo__TERMO_ACEITE_ASSINATURA.ASSINATURA_RESPONSAVEL_AREA
  data_assinatura_responsavel_area TIMESTAMP, -- @map <- raw.dbo__TERMO_ACEITE_ASSINATURA.DATA_ASSINATURA_RESPONSAVEL_AREA
  tipo_assinatura_colaborador INT, -- @map <- raw.dbo__TERMO_ACEITE_ASSINATURA.TIPO_ASSINATURA_COLABORADOR
  tipo_assinatura_responsavel_area INT, -- @map <- raw.dbo__TERMO_ACEITE_ASSINATURA.TIPO_ASSINATURA_RESPONSAVEL_AREA
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.TriggerArea — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__TriggerArea
CREATE TABLE IF NOT EXISTS staging.stg_organizacao_triggerarea (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__TriggerArea.Id
  area_id INT, -- @map <- raw.dbo__TriggerArea.Area_Id
  trigger_id INT, -- @map <- raw.dbo__TriggerArea.Trigger_Id
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.ACAO_SUGERIDA_PDI — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__ACAO_SUGERIDA_PDI
CREATE TABLE IF NOT EXISTS staging.stg_pdi_acao_sugerida_pdi (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__ACAO_SUGERIDA_PDI.ID
  desc_acao_sugerida STRING, -- @map <- raw.competences__ACAO_SUGERIDA_PDI.DESC_ACAO_SUGERIDA
  id_categoria INT, -- @map <- raw.competences__ACAO_SUGERIDA_PDI.ID_CATEGORIA
  ativo INT, -- @map <- raw.competences__ACAO_SUGERIDA_PDI.ATIVO
  id_competencia INT, -- @map <- raw.competences__ACAO_SUGERIDA_PDI.ID_COMPETENCIA
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.BIBLIOTECA — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__BIBLIOTECA
CREATE TABLE IF NOT EXISTS staging.stg_pdi_biblioteca (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__BIBLIOTECA.ID
  desc_biblioteca STRING, -- @map <- raw.dbo__BIBLIOTECA.DESC_BIBLIOTECA
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.CATEGORIA_PDI_ACAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__CATEGORIA_PDI_ACAO
CREATE TABLE IF NOT EXISTS staging.stg_pdi_categoria_pdi_acao (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__CATEGORIA_PDI_ACAO.ID
  desc_categoria STRING, -- @map <- raw.competences__CATEGORIA_PDI_ACAO.DESC_CATEGORIA
  ativo INT, -- @map <- raw.competences__CATEGORIA_PDI_ACAO.ATIVO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse competences.IndividualDevelopmentAction — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.competences__IndividualDevelopmentAction
CREATE TABLE IF NOT EXISTS staging.stg_pdi_individualdevelopmentaction (
  tenant_slug STRING,
  id INT, -- @map <- raw.competences__IndividualDevelopmentAction.Id
  origin INT, -- @map <- raw.competences__IndividualDevelopmentAction.Origin
  evaluation_cycle_id INT, -- @map <- raw.competences__IndividualDevelopmentAction.EvaluationCycleId
  competence_id INT, -- @map <- raw.competences__IndividualDevelopmentAction.CompetenceId
  evaluation_factor_id INT, -- @map <- raw.competences__IndividualDevelopmentAction.EvaluationFactorId
  action_suggested_id INT, -- @map <- raw.competences__IndividualDevelopmentAction.ActionSuggestedId
  category_action_suggested_id INT, -- @map <- raw.competences__IndividualDevelopmentAction.CategoryActionSuggestedId
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.SkillCategory — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__SkillCategory
CREATE TABLE IF NOT EXISTS staging.stg_pdi_skillcategory (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__SkillCategory.Id
  description STRING, -- @map <- raw.dbo__SkillCategory.Description
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.SkillKnowledge — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__SkillKnowledge
CREATE TABLE IF NOT EXISTS staging.stg_pdi_skillknowledge (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__SkillKnowledge.Id
  description STRING, -- @map <- raw.dbo__SkillKnowledge.Description
  skill_category_id INT, -- @map <- raw.dbo__SkillKnowledge.SkillCategoryId
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.CustomerBoundTranslateTag — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__CustomerBoundTranslateTag
CREATE TABLE IF NOT EXISTS staging.stg_referencia_customerboundtranslatetag (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__CustomerBoundTranslateTag.Id
  contents STRING, -- @map <- raw.dbo__CustomerBoundTranslateTag.Contents
  culture_id INT, -- @map <- raw.dbo__CustomerBoundTranslateTag.Culture_Id
  handle_id INT, -- @map <- raw.dbo__CustomerBoundTranslateTag.Handle_Id
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.GRANDEZA — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__GRANDEZA
CREATE TABLE IF NOT EXISTS staging.stg_referencia_grandeza (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__GRANDEZA.ID
  desc_grandeza STRING, -- @map <- raw.dbo__GRANDEZA.DESC_GRANDEZA
  tipo_conversao INT, -- @map <- raw.dbo__GRANDEZA.TIPO_CONVERSAO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.IDIOMA — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__IDIOMA
CREATE TABLE IF NOT EXISTS staging.stg_referencia_idioma (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__IDIOMA.ID
  desc_idioma STRING, -- @map <- raw.dbo__IDIOMA.DESC_IDIOMA
  idiomatic_description STRING, -- @map <- raw.dbo__IDIOMA.IdiomaticDescription
  locale STRING, -- @map <- raw.dbo__IDIOMA.Locale
  sort_order INT, -- @map <- raw.dbo__IDIOMA.SortOrder
  is_active INT, -- @map <- raw.dbo__IDIOMA.IsActive
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.MAIL_CONFIG — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__MAIL_CONFIG
CREATE TABLE IF NOT EXISTS staging.stg_referencia_mail_config (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__MAIL_CONFIG.ID
  tipo_envio INT, -- @map <- raw.dbo__MAIL_CONFIG.TIPO_ENVIO
  desc_tipo_envio STRING, -- @map <- raw.dbo__MAIL_CONFIG.DESC_TIPO_ENVIO
  ativo INT, -- @map <- raw.dbo__MAIL_CONFIG.ATIVO
  parametro STRING, -- @map <- raw.dbo__MAIL_CONFIG.PARAMETRO
  id_modulo INT, -- @map <- raw.dbo__MAIL_CONFIG.ID_MODULO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.PLUGIN_INFO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__PLUGIN_INFO
CREATE TABLE IF NOT EXISTS staging.stg_referencia_plugin_info (
  tenant_slug STRING,
  plugin_code STRING, -- @map <- raw.dbo__PLUGIN_INFO.PLUGIN_CODE
  assembly_name STRING, -- @map <- raw.dbo__PLUGIN_INFO.ASSEMBLY_NAME
  class_name STRING, -- @map <- raw.dbo__PLUGIN_INFO.CLASS_NAME
  method_name STRING, -- @map <- raw.dbo__PLUGIN_INFO.METHOD_NAME
  plugin_description STRING, -- @map <- raw.dbo__PLUGIN_INFO.PLUGIN_DESCRIPTION
  PRIMARY KEY (tenant_slug, plugin_code)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.SYSTEM_CONFIG — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__SYSTEM_CONFIG
CREATE TABLE IF NOT EXISTS staging.stg_referencia_system_config (
  tenant_slug STRING,
  client_name STRING, -- @map <- raw.dbo__SYSTEM_CONFIG.CLIENT_NAME
  client_url STRING, -- @map <- raw.dbo__SYSTEM_CONFIG.CLIENT_URL
  system_version STRING, -- @map <- raw.dbo__SYSTEM_CONFIG.SYSTEM_VERSION
  psw_try INT, -- @map <- raw.dbo__SYSTEM_CONFIG.PSW_TRY
  psw_upper INT, -- @map <- raw.dbo__SYSTEM_CONFIG.PSW_UPPER
  psw_lower INT, -- @map <- raw.dbo__SYSTEM_CONFIG.PSW_LOWER
  psw_number INT, -- @map <- raw.dbo__SYSTEM_CONFIG.PSW_NUMBER
  psw_especial_char INT, -- @map <- raw.dbo__SYSTEM_CONFIG.PSW_ESPECIAL_CHAR
  psw_min_length INT, -- @map <- raw.dbo__SYSTEM_CONFIG.PSW_MIN_LENGTH
  psw_days INT, -- @map <- raw.dbo__SYSTEM_CONFIG.PSW_DAYS
  psw_reusable INT, -- @map <- raw.dbo__SYSTEM_CONFIG.PSW_REUSABLE
  limit_tree_area INT, -- @map <- raw.dbo__SYSTEM_CONFIG.LIMIT_TREE_AREA
  limit_tree_entidade INT, -- @map <- raw.dbo__SYSTEM_CONFIG.LIMIT_TREE_ENTIDADE
  limit_tree_grupo_conta INT, -- @map <- raw.dbo__SYSTEM_CONFIG.LIMIT_TREE_GRUPO_CONTA
  main_page STRING, -- @map <- raw.dbo__SYSTEM_CONFIG.MAIN_PAGE
  tipo_cotacao INT, -- @map <- raw.dbo__SYSTEM_CONFIG.TIPO_COTACAO
  forecast1_label STRING, -- @map <- raw.dbo__SYSTEM_CONFIG.FORECAST1_LABEL
  forecast2_label STRING, -- @map <- raw.dbo__SYSTEM_CONFIG.FORECAST2_LABEL
  access_group_admin_management INT, -- @map <- raw.dbo__SYSTEM_CONFIG.ACCESS_GROUP_ADMIN_MANAGEMENT
  id INT, -- @map <- raw.dbo__SYSTEM_CONFIG.ID
  client_options STRING, -- @map <- raw.dbo__SYSTEM_CONFIG.ClientOptions
  PRIMARY KEY (tenant_slug)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.TipoAcumulacao — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__TipoAcumulacao
CREATE TABLE IF NOT EXISTS staging.stg_referencia_tipoacumulacao (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__TipoAcumulacao.Id
  nome STRING, -- @map <- raw.dbo__TipoAcumulacao.Nome
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.TranslateTagCulture — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__TranslateTagCulture
CREATE TABLE IF NOT EXISTS staging.stg_referencia_translatetagculture (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__TranslateTagCulture.Id
  name STRING, -- @map <- raw.dbo__TranslateTagCulture.Name
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.TranslateTagHandle — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__TranslateTagHandle
CREATE TABLE IF NOT EXISTS staging.stg_referencia_translatetaghandle (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__TranslateTagHandle.Id
  name STRING, -- @map <- raw.dbo__TranslateTagHandle.Name
  PRIMARY KEY (tenant_slug, id)
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

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.VERSAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__VERSAO
CREATE TABLE IF NOT EXISTS staging.stg_referencia_versao (
  tenant_slug STRING,
  num_versao STRING, -- @map <- raw.dbo__VERSAO.NUM_VERSAO
  dt_versao TIMESTAMP, -- @map <- raw.dbo__VERSAO.DT_VERSAO
  texto_pt_br STRING, -- @map <- raw.dbo__VERSAO.TEXTO_PT_BR
  texto_en_us STRING, -- @map <- raw.dbo__VERSAO.TEXTO_EN_US
  texto_de_de STRING, -- @map <- raw.dbo__VERSAO.TEXTO_DE_DE
  texto_es_es STRING, -- @map <- raw.dbo__VERSAO.TEXTO_ES_ES
  texto_fr_fr STRING, -- @map <- raw.dbo__VERSAO.TEXTO_FR_FR
  texto_zn_cn STRING, -- @map <- raw.dbo__VERSAO.TEXTO_ZN_CN
  PRIMARY KEY (tenant_slug, num_versao)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.EligibleDiscretionary — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__EligibleDiscretionary
CREATE TABLE IF NOT EXISTS staging.stg_remuneracao_eligiblediscretionary (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__EligibleDiscretionary.Id
  status INT, -- @map <- raw.dbo__EligibleDiscretionary.Status
  rv_participant_id INT, -- @map <- raw.dbo__EligibleDiscretionary.RVParticipant_Id
  create_date TIMESTAMP, -- @map <- raw.dbo__EligibleDiscretionary.CreateDate
  calibration_date TIMESTAMP, -- @map <- raw.dbo__EligibleDiscretionary.CalibrationDate
  final_range_id INT, -- @map <- raw.dbo__EligibleDiscretionary.FinalRange_Id
  medium_range_id INT, -- @map <- raw.dbo__EligibleDiscretionary.MediumRange_Id
  grupo_calibragem STRING, -- @map <- raw.dbo__EligibleDiscretionary.GRUPO_CALIBRAGEM
  calibration_group_discretionary_id INT, -- @map <- raw.dbo__EligibleDiscretionary.CalibrationGroupDiscretionary_Id
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.EmployeeAnalyticResult — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__EmployeeAnalyticResult
CREATE TABLE IF NOT EXISTS staging.stg_remuneracao_employeeanalyticresult (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__EmployeeAnalyticResult.Id
  score DECIMAL(28,8), -- @map <- raw.dbo__EmployeeAnalyticResult.Score
  multiple DECIMAL(28,8), -- @map <- raw.dbo__EmployeeAnalyticResult.Multiple
  salary DECIMAL(28,8), -- @map <- raw.dbo__EmployeeAnalyticResult.Salary
  score_ref DECIMAL(28,8), -- @map <- raw.dbo__EmployeeAnalyticResult.Score_Ref
  multiple_ref DECIMAL(28,8), -- @map <- raw.dbo__EmployeeAnalyticResult.Multiple_Ref
  salary_ref DECIMAL(28,8), -- @map <- raw.dbo__EmployeeAnalyticResult.Salary_Ref
  participant_id INT, -- @map <- raw.dbo__EmployeeAnalyticResult.Participant_Id
  pool_redistribution DECIMAL(28,8), -- @map <- raw.dbo__EmployeeAnalyticResult.PoolRedistribution
  history_section_id INT, -- @map <- raw.dbo__EmployeeAnalyticResult.HistorySection_Id
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.Modifier — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__Modifier
CREATE TABLE IF NOT EXISTS staging.stg_remuneracao_modifier (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__Modifier.Id
  code STRING, -- @map <- raw.dbo__Modifier.Code
  description STRING, -- @map <- raw.dbo__Modifier.Description
  applies_to INT, -- @map <- raw.dbo__Modifier.AppliesTo
  type INT, -- @map <- raw.dbo__Modifier.Type
  value DECIMAL(28,8), -- @map <- raw.dbo__Modifier.Value
  payment_group_id INT, -- @map <- raw.dbo__Modifier.PaymentGroup_Id
  math_type INT, -- @map <- raw.dbo__Modifier.MathType
  config STRING, -- @map <- raw.dbo__Modifier.Config
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.ModifierItem — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ModifierItem
CREATE TABLE IF NOT EXISTS staging.stg_remuneracao_modifieritem (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__ModifierItem.Id
  id_modifier INT, -- @map <- raw.dbo__ModifierItem.IdModifier
  conditional DECIMAL(28,8), -- @map <- raw.dbo__ModifierItem.Conditional
  value DECIMAL(28,8), -- @map <- raw.dbo__ModifierItem.Value
  id_external_conditional INT, -- @map <- raw.dbo__ModifierItem.IdExternalConditional
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.ParticipantAggregatedExtract — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ParticipantAggregatedExtract
CREATE TABLE IF NOT EXISTS staging.stg_remuneracao_participantaggregatedextract (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__ParticipantAggregatedExtract.Id
  dt_ref TIMESTAMP, -- @map <- raw.dbo__ParticipantAggregatedExtract.DtRef
  extract BINARY, -- @map <- raw.dbo__ParticipantAggregatedExtract.Extract
  participant_id INT, -- @map <- raw.dbo__ParticipantAggregatedExtract.Participant_Id
  multiple DECIMAL(28,8), -- @map <- raw.dbo__ParticipantAggregatedExtract.Multiple
  compensation DECIMAL(28,8), -- @map <- raw.dbo__ParticipantAggregatedExtract.Compensation
  PRIMARY KEY (tenant_slug, id)
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
-- @note: Cleanse dbo.ParticipantExtract — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ParticipantExtract
CREATE TABLE IF NOT EXISTS staging.stg_remuneracao_participantextract (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__ParticipantExtract.Id
  dt_ref TIMESTAMP, -- @map <- raw.dbo__ParticipantExtract.DtRef
  extract BINARY, -- @map <- raw.dbo__ParticipantExtract.Extract
  released INT, -- @map <- raw.dbo__ParticipantExtract.Released
  history_section_id INT, -- @map <- raw.dbo__ParticipantExtract.HistorySection_Id
  participant_id INT, -- @map <- raw.dbo__ParticipantExtract.Participant_Id
  participant_aggregated_extract_id INT, -- @map <- raw.dbo__ParticipantExtract.ParticipantAggregatedExtract_Id
  score DECIMAL(28,8), -- @map <- raw.dbo__ParticipantExtract.Score
  multiple DECIMAL(28,8), -- @map <- raw.dbo__ParticipantExtract.Multiple
  compensation DECIMAL(28,8), -- @map <- raw.dbo__ParticipantExtract.Compensation
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.ParticipantExtractControl — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__ParticipantExtractControl
CREATE TABLE IF NOT EXISTS staging.stg_remuneracao_participantextractcontrol (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__ParticipantExtractControl.Id
  dt_ref TIMESTAMP, -- @map <- raw.dbo__ParticipantExtractControl.DtRef
  released INT, -- @map <- raw.dbo__ParticipantExtractControl.Released
  participant_id INT, -- @map <- raw.dbo__ParticipantExtractControl.Participant_Id
  history_section_id INT, -- @map <- raw.dbo__ParticipantExtractControl.HistorySectionId
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.SimulationRVCache — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__SimulationRVCache
CREATE TABLE IF NOT EXISTS staging.stg_remuneracao_simulationrvcache (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__SimulationRVCache.Id
  participant_id INT, -- @map <- raw.dbo__SimulationRVCache.Participant_Id
  cache BINARY, -- @map <- raw.dbo__SimulationRVCache.Cache
  date TIMESTAMP, -- @map <- raw.dbo__SimulationRVCache.Date
  last_connection TIMESTAMP, -- @map <- raw.dbo__SimulationRVCache.LastConnection
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.FORUM_CALIBRAGEM_SUCESSAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__FORUM_CALIBRAGEM_SUCESSAO
CREATE TABLE IF NOT EXISTS staging.stg_sucessao_forum_calibragem_sucessao (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__FORUM_CALIBRAGEM_SUCESSAO.ID
  id_ciclo_sucessao INT, -- @map <- raw.dbo__FORUM_CALIBRAGEM_SUCESSAO.ID_CICLO_SUCESSAO
  descricao STRING, -- @map <- raw.dbo__FORUM_CALIBRAGEM_SUCESSAO.DESCRICAO
  data_criacao TIMESTAMP, -- @map <- raw.dbo__FORUM_CALIBRAGEM_SUCESSAO.DATA_CRIACAO
  data_encerramento TIMESTAMP, -- @map <- raw.dbo__FORUM_CALIBRAGEM_SUCESSAO.DATA_ENCERRAMENTO
  status INT, -- @map <- raw.dbo__FORUM_CALIBRAGEM_SUCESSAO.STATUS
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.FORUM_QUADRANTE_SUCESSAO_MODELO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__FORUM_QUADRANTE_SUCESSAO_MODELO
CREATE TABLE IF NOT EXISTS staging.stg_sucessao_forum_quadrante_sucessao_modelo (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__FORUM_QUADRANTE_SUCESSAO_MODELO.ID
  id_ciclo_sucessao INT, -- @map <- raw.dbo__FORUM_QUADRANTE_SUCESSAO_MODELO.ID_CICLO_SUCESSAO
  id_classificacao_performance_sucessao INT, -- @map <- raw.dbo__FORUM_QUADRANTE_SUCESSAO_MODELO.ID_CLASSIFICACAO_PERFORMANCE_SUCESSAO
  id_classificacao_potencial INT, -- @map <- raw.dbo__FORUM_QUADRANTE_SUCESSAO_MODELO.ID_CLASSIFICACAO_POTENCIAL
  titulo STRING, -- @map <- raw.dbo__FORUM_QUADRANTE_SUCESSAO_MODELO.TITULO
  cor_fundo STRING, -- @map <- raw.dbo__FORUM_QUADRANTE_SUCESSAO_MODELO.COR_FUNDO
  cor_titulo STRING, -- @map <- raw.dbo__FORUM_QUADRANTE_SUCESSAO_MODELO.COR_TITULO
  descricao STRING, -- @map <- raw.dbo__FORUM_QUADRANTE_SUCESSAO_MODELO.DESCRICAO
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.INSTANCIA_SUCESSAO — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__INSTANCIA_SUCESSAO
CREATE TABLE IF NOT EXISTS staging.stg_sucessao_instancia_sucessao (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__INSTANCIA_SUCESSAO.ID
  id_forum_sucessao INT, -- @map <- raw.dbo__INSTANCIA_SUCESSAO.ID_FORUM_SUCESSAO
  descricao STRING, -- @map <- raw.dbo__INSTANCIA_SUCESSAO.DESCRICAO
  data_criacao TIMESTAMP, -- @map <- raw.dbo__INSTANCIA_SUCESSAO.DATA_CRIACAO
  data_inicio_instancia TIMESTAMP, -- @map <- raw.dbo__INSTANCIA_SUCESSAO.DATA_INICIO_INSTANCIA
  data_fim_instancia TIMESTAMP, -- @map <- raw.dbo__INSTANCIA_SUCESSAO.DATA_FIM_INSTANCIA
  status INT, -- @map <- raw.dbo__INSTANCIA_SUCESSAO.STATUS
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.Readiness — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__Readiness
CREATE TABLE IF NOT EXISTS staging.stg_sucessao_readiness (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__Readiness.Id
  succession_cycle_id INT, -- @map <- raw.dbo__Readiness.SuccessionCycleId
  time_slot STRING, -- @map <- raw.dbo__Readiness.TimeSlot
  order INT, -- @map <- raw.dbo__Readiness.Order
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.SuccessionCycle — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__SuccessionCycle
CREATE TABLE IF NOT EXISTS staging.stg_sucessao_successioncycle (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__SuccessionCycle.ID
  description STRING, -- @map <- raw.dbo__SuccessionCycle.Description
  start_date TIMESTAMP, -- @map <- raw.dbo__SuccessionCycle.StartDate
  end_date TIMESTAMP, -- @map <- raw.dbo__SuccessionCycle.EndDate
  status INT, -- @map <- raw.dbo__SuccessionCycle.STATUS
  decimal_precision INT, -- @map <- raw.dbo__SuccessionCycle.DecimalPrecision
  is_current_cycle INT, -- @map <- raw.dbo__SuccessionCycle.IsCurrentCycle
  flow_type INT, -- @map <- raw.dbo__SuccessionCycle.FlowType
  has_pendences INT, -- @map <- raw.dbo__SuccessionCycle.HasPendences
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.SuccessionCycleSettings — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__SuccessionCycleSettings
CREATE TABLE IF NOT EXISTS staging.stg_sucessao_successioncyclesettings (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__SuccessionCycleSettings.ID
  score_achievement_via_import INT, -- @map <- raw.dbo__SuccessionCycleSettings.ScoreAchievementViaImport
  x_axis_description STRING, -- @map <- raw.dbo__SuccessionCycleSettings.XAxisDescription
  y_axis_description STRING, -- @map <- raw.dbo__SuccessionCycleSettings.YAxisDescription
  score_competence_via_import INT, -- @map <- raw.dbo__SuccessionCycleSettings.ScoreCompetenceViaImport
  score_performance_via_import INT, -- @map <- raw.dbo__SuccessionCycleSettings.ScorePerformanceViaImport
  evaluation_cycle_id INT, -- @map <- raw.dbo__SuccessionCycleSettings.EvaluationCycleId
  management_cycle_id INT, -- @map <- raw.dbo__SuccessionCycleSettings.ManagementCycleId
  month_to INT, -- @map <- raw.dbo__SuccessionCycleSettings.MonthTo
  percentage_performance_score DECIMAL(28,8), -- @map <- raw.dbo__SuccessionCycleSettings.PercentagePerformanceScore
  percentage_competence_score DECIMAL(28,8), -- @map <- raw.dbo__SuccessionCycleSettings.PercentageCompetenceScore
  succession_cycle_id INT, -- @map <- raw.dbo__SuccessionCycleSettings.SuccessionCycleId
  hide_numerical_scores INT, -- @map <- raw.dbo__SuccessionCycleSettings.HideNumericalScores
  enable_deliberations_employee INT, -- @map <- raw.dbo__SuccessionCycleSettings.EnableDeliberationsEmployee
  deliberation_option_id INT, -- @map <- raw.dbo__SuccessionCycleSettings.DeliberationOption_Id
  percentage_potential_score DECIMAL(28,8), -- @map <- raw.dbo__SuccessionCycleSettings.PercentagePotentialScore
  x_axis_composition INT, -- @map <- raw.dbo__SuccessionCycleSettings.XAxisComposition
  y_axis_composition INT, -- @map <- raw.dbo__SuccessionCycleSettings.YAxisComposition
  show_button_to_open_form_competence INT, -- @map <- raw.dbo__SuccessionCycleSettings.ShowButtonToOpenFormCompetence
  hide_potential_block INT, -- @map <- raw.dbo__SuccessionCycleSettings.HidePotentialBlock
  hide_risk_block INT, -- @map <- raw.dbo__SuccessionCycleSettings.HideRiskBlock
  hide_performance_block INT, -- @map <- raw.dbo__SuccessionCycleSettings.HidePerformanceBlock
  enable_successor_selection INT, -- @map <- raw.dbo__SuccessionCycleSettings.EnableSuccessorSelection
  enable_vertical_successor_moves INT, -- @map <- raw.dbo__SuccessionCycleSettings.EnableVerticalSuccessorMoves
  enable_horizontal_succesor_moves INT, -- @map <- raw.dbo__SuccessionCycleSettings.EnableHorizontalSuccesorMoves
  minimum_vertical_successors INT, -- @map <- raw.dbo__SuccessionCycleSettings.MinimumVerticalSuccessors
  maximum_vertical_successors INT, -- @map <- raw.dbo__SuccessionCycleSettings.MaximumVerticalSuccessors
  minimum_horizontal_successors INT, -- @map <- raw.dbo__SuccessionCycleSettings.MinimumHorizontalSuccessors
  maximum_horizontal_successors INT, -- @map <- raw.dbo__SuccessionCycleSettings.MaximumHorizontalSuccessors
  comentario_quantitativo_obrigatorio INT, -- @map <- raw.dbo__SuccessionCycleSettings.COMENTARIO_QUANTITATIVO_OBRIGATORIO
  comentario_qualitativo_obrigatorio INT, -- @map <- raw.dbo__SuccessionCycleSettings.COMENTARIO_QUALITATIVO_OBRIGATORIO
  comentario_selecao_obrigatorio INT, -- @map <- raw.dbo__SuccessionCycleSettings.COMENTARIO_SELECAO_OBRIGATORIO
  hide_impact_block INT, -- @map <- raw.dbo__SuccessionCycleSettings.HideImpactBlock
  enable_classification_calibration_at_evaluation INT, -- @map <- raw.dbo__SuccessionCycleSettings.EnableClassificationCalibrationAtEvaluation
  enable_job_position_successor INT, -- @map <- raw.dbo__SuccessionCycleSettings.EnableJobPositionSuccessor
  hide_potential_summary INT, -- @map <- raw.dbo__SuccessionCycleSettings.HidePotentialSummary
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.SuccessionResults — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__SuccessionResults
CREATE TABLE IF NOT EXISTS staging.stg_sucessao_successionresults (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__SuccessionResults.Id
  evaluated_succession_id INT, -- @map <- raw.dbo__SuccessionResults.EvaluatedSuccessionId
  final_score_x_axis DECIMAL(28,8), -- @map <- raw.dbo__SuccessionResults.FinalScoreXAxis
  final_score_y_axis DECIMAL(28,8), -- @map <- raw.dbo__SuccessionResults.FinalScoreYAxis
  final_score_x_axis_classification_id INT, -- @map <- raw.dbo__SuccessionResults.FinalScoreXAxisClassificationId
  final_score_x_axis_classification_calib_id INT, -- @map <- raw.dbo__SuccessionResults.FinalScoreXAxisClassificationCalibId
  final_score_y_axis_classification_id INT, -- @map <- raw.dbo__SuccessionResults.FinalScoreYAxisClassificationId
  final_score_y_axis_classification_calib_id INT, -- @map <- raw.dbo__SuccessionResults.FinalScoreYAxisClassificationCalibId
  final_score_competence DECIMAL(28,8), -- @map <- raw.dbo__SuccessionResults.FinalScoreCompetence
  final_score_performance DECIMAL(28,8), -- @map <- raw.dbo__SuccessionResults.FinalScorePerformance
  final_score_potential DECIMAL(28,8), -- @map <- raw.dbo__SuccessionResults.FinalScorePotential
  data_source_competence_score INT, -- @map <- raw.dbo__SuccessionResults.DataSourceCompetenceScore
  data_source_performance_score INT, -- @map <- raw.dbo__SuccessionResults.DataSourcePerformanceScore
  data_source_potential_score INT, -- @map <- raw.dbo__SuccessionResults.DataSourcePotentialScore
  final_score_risk DECIMAL(28,8), -- @map <- raw.dbo__SuccessionResults.FinalScoreRisk
  final_score_impact DECIMAL(28,8), -- @map <- raw.dbo__SuccessionResults.FinalScoreImpact
  final_score_risk_calib_id INT, -- @map <- raw.dbo__SuccessionResults.FinalScoreRiskCalibId
  final_score_impact_calib_id INT, -- @map <- raw.dbo__SuccessionResults.FinalScoreImpactCalibId
  competence_sync_date TIMESTAMP, -- @map <- raw.dbo__SuccessionResults.CompetenceSyncDate
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.SuccessionScoresDetails — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__SuccessionScoresDetails
CREATE TABLE IF NOT EXISTS staging.stg_sucessao_successionscoresdetails (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__SuccessionScoresDetails.Id
  max_score DECIMAL(18,2), -- @map <- raw.dbo__SuccessionScoresDetails.MaxScore
  min_score DECIMAL(18,2), -- @map <- raw.dbo__SuccessionScoresDetails.MinScore
  reference_score DECIMAL(18,2), -- @map <- raw.dbo__SuccessionScoresDetails.ReferenceScore
  dimension INT, -- @map <- raw.dbo__SuccessionScoresDetails.Dimension
  succession_cycle_settings_id INT, -- @map <- raw.dbo__SuccessionScoresDetails.SuccessionCycleSettingsId
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.XAxisClassification — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__XAxisClassification
CREATE TABLE IF NOT EXISTS staging.stg_sucessao_xaxisclassification (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__XAxisClassification.ID
  id_succession_cycle INT, -- @map <- raw.dbo__XAxisClassification.IdSuccessionCycle
  description STRING, -- @map <- raw.dbo__XAxisClassification.Description
  score_from DOUBLE, -- @map <- raw.dbo__XAxisClassification.ScoreFrom
  score_to DOUBLE, -- @map <- raw.dbo__XAxisClassification.ScoreTo
  expected_curve DOUBLE, -- @map <- raw.dbo__XAxisClassification.ExpectedCurve
  merge_with INT, -- @map <- raw.dbo__XAxisClassification.MergeWith
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- @layer: staging
-- @group: staging
-- @note: Cleanse dbo.YAxisClassification — snake_case, tipagem, filtra _deleted=0
-- @origen: raw.dbo__YAxisClassification
CREATE TABLE IF NOT EXISTS staging.stg_sucessao_yaxisclassification (
  tenant_slug STRING,
  id INT, -- @map <- raw.dbo__YAxisClassification.ID
  id_succession_cycle INT, -- @map <- raw.dbo__YAxisClassification.IdSuccessionCycle
  description STRING, -- @map <- raw.dbo__YAxisClassification.Description
  score_from DECIMAL(28,8), -- @map <- raw.dbo__YAxisClassification.ScoreFrom
  score_to DECIMAL(28,8), -- @map <- raw.dbo__YAxisClassification.ScoreTo
  expected_curve DECIMAL(28,8), -- @map <- raw.dbo__YAxisClassification.ExpectedCurve
  merge_with INT, -- @map <- raw.dbo__YAxisClassification.MergeWith
  PRIMARY KEY (tenant_slug, id)
) USING DELTA;

-- =============================================================================
-- EDW — snowflake conformado (@origen SEMPRE via staging)
-- =============================================================================

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.ActionBaseLabel SCD1 — grain (tenant_slug, action_base_id, label_id)
-- @origen: staging.stg_acao_actionbaselabel
CREATE TABLE IF NOT EXISTS edw.dim_action_base_label (
  action_base_label_key BIGINT,
  tenant_slug STRING,
  action_base_id INT, -- @map <- staging.stg_acao_actionbaselabel.action_base_id
  label_id INT, -- @map <- staging.stg_acao_actionbaselabel.label_id
  PRIMARY KEY (action_base_label_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.CATCH_BALL SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_acao_catch_ball
-- @fk: diretriz_key -> edw.dim_diretriz.diretriz_key
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: meta_goal_key -> edw.dim_goal.goal_key
-- @fk: meta_superior_proposto_goal_key -> edw.dim_goal.goal_key
-- @fk: kpi_key -> edw.dim_kpi.kpi_key
-- @fk: processo_key -> edw.dim_processo.processo_key
CREATE TABLE IF NOT EXISTS edw.dim_catch_ball (
  catch_ball_key BIGINT,
  tenant_slug STRING,
  diretriz_key BIGINT,
  employee_key BIGINT,
  meta_goal_key BIGINT,
  meta_superior_proposto_goal_key BIGINT,
  kpi_key BIGINT,
  processo_key BIGINT,
  id INT, -- @map <- staging.stg_acao_catch_ball.id
  id_meta INT, -- @map <- staging.stg_acao_catch_ball.id_meta
  id_indicador_proposto INT, -- @map <- staging.stg_acao_catch_ball.id_indicador_proposto
  id_diretriz_proposto INT, -- @map <- staging.stg_acao_catch_ball.id_diretriz_proposto
  id_processo_proposto INT, -- @map <- staging.stg_acao_catch_ball.id_processo_proposto
  id_meta_superior_proposto INT, -- @map <- staging.stg_acao_catch_ball.id_meta_superior_proposto
  id_data_provider_proposto INT, -- @map <- staging.stg_acao_catch_ball.id_data_provider_proposto
  dt_workflow TIMESTAMP, -- @map <- staging.stg_acao_catch_ball.dt_workflow
  objetivo_proposto STRING, -- @map <- staging.stg_acao_catch_ball.objetivo_proposto
  peso_meta_proposto DOUBLE, -- @map <- staging.stg_acao_catch_ball.peso_meta_proposto
  valor_meta_proposto DOUBLE, -- @map <- staging.stg_acao_catch_ball.valor_meta_proposto
  dt_ini_proposto TIMESTAMP, -- @map <- staging.stg_acao_catch_ball.dt_ini_proposto
  dt_fim_proposto TIMESTAMP, -- @map <- staging.stg_acao_catch_ball.dt_fim_proposto
  tipo_acumulacao_proposto INT, -- @map <- staging.stg_acao_catch_ball.tipo_acumulacao_proposto
  indicador_justificativa STRING, -- @map <- staging.stg_acao_catch_ball.indicador_justificativa
  diretriz_justificativa STRING, -- @map <- staging.stg_acao_catch_ball.diretriz_justificativa
  processo_justificativa STRING, -- @map <- staging.stg_acao_catch_ball.processo_justificativa
  meta_superior_justificativa STRING, -- @map <- staging.stg_acao_catch_ball.meta_superior_justificativa
  data_provider_justificativa STRING, -- @map <- staging.stg_acao_catch_ball.data_provider_justificativa
  objetivo_justificativa STRING, -- @map <- staging.stg_acao_catch_ball.objetivo_justificativa
  peso_meta_justificativa STRING, -- @map <- staging.stg_acao_catch_ball.peso_meta_justificativa
  valor_meta_justificativa STRING, -- @map <- staging.stg_acao_catch_ball.valor_meta_justificativa
  dt_ini_justificativa STRING, -- @map <- staging.stg_acao_catch_ball.dt_ini_justificativa
  dt_fim_justificativa STRING, -- @map <- staging.stg_acao_catch_ball.dt_fim_justificativa
  tipo_acumulacao_justificativa STRING, -- @map <- staging.stg_acao_catch_ball.tipo_acumulacao_justificativa
  observacao STRING, -- @map <- staging.stg_acao_catch_ball.observacao
  PRIMARY KEY (catch_ball_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.CAUSA SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_acao_causa
-- @fk: parent_cause_causa_key -> edw.dim_causa.causa_key
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: kpi_key -> edw.dim_kpi.kpi_key
CREATE TABLE IF NOT EXISTS edw.dim_causa (
  causa_key BIGINT,
  tenant_slug STRING,
  parent_cause_causa_key BIGINT,
  employee_key BIGINT,
  kpi_key BIGINT,
  id INT, -- @map <- staging.stg_acao_causa.id
  id_indicador INT, -- @map <- staging.stg_acao_causa.id_indicador
  id_contramedida INT, -- @map <- staging.stg_acao_causa.id_contramedida
  desc_causa STRING, -- @map <- staging.stg_acao_causa.desc_causa
  sub_causa1 STRING, -- @map <- staging.stg_acao_causa.sub_causa1
  sub_causa2 STRING, -- @map <- staging.stg_acao_causa.sub_causa2
  sub_causa3 STRING, -- @map <- staging.stg_acao_causa.sub_causa3
  sub_causa4 STRING, -- @map <- staging.stg_acao_causa.sub_causa4
  sub_causa5 STRING, -- @map <- staging.stg_acao_causa.sub_causa5
  gestao_conhecimento_ativo INT, -- @map <- staging.stg_acao_causa.gestao_conhecimento_ativo
  selecionada INT, -- @map <- staging.stg_acao_causa.selecionada
  id_criador_causa INT, -- @map <- staging.stg_acao_causa.id_criador_causa
  cod_causa STRING, -- @map <- staging.stg_acao_causa.cod_causa
  id_ultimo_editor_causa INT, -- @map <- staging.stg_acao_causa.id_ultimo_editor_causa
  parent_cause INT, -- @map <- staging.stg_acao_causa.parent_cause
  PRIMARY KEY (causa_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.EFETIVIDADE_ACAO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_acao_efetividade_acao
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.dim_efetividade_acao (
  efetividade_acao_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_acao_efetividade_acao.id
  id_colaborador INT, -- @map <- staging.stg_acao_efetividade_acao.id_colaborador
  id_acao INT, -- @map <- staging.stg_acao_efetividade_acao.id_acao
  tipo INT, -- @map <- staging.stg_acao_efetividade_acao.tipo
  atual INT, -- @map <- staging.stg_acao_efetividade_acao.atual
  dt_log TIMESTAMP, -- @map <- staging.stg_acao_efetividade_acao.dt_log
  PRIMARY KEY (efetividade_acao_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.NOTIFICACAO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_acao_notificacao
CREATE TABLE IF NOT EXISTS edw.dim_notificacao (
  notificacao_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_acao_notificacao.id
  titulo_modal STRING, -- @map <- staging.stg_acao_notificacao.titulo_modal
  descricao_notificacao STRING, -- @map <- staging.stg_acao_notificacao.descricao_notificacao
  ativo INT, -- @map <- staging.stg_acao_notificacao.ativo
  tipo_notificacao INT, -- @map <- staging.stg_acao_notificacao.tipo_notificacao
  data_expiracao TIMESTAMP, -- @map <- staging.stg_acao_notificacao.data_expiracao
  PRIMARY KEY (notificacao_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.RECURRING_JOB SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_acao_recurring_job
CREATE TABLE IF NOT EXISTS edw.dim_recurring_job (
  recurring_job_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_acao_recurring_job.id
  job_id STRING, -- @map <- staging.stg_acao_recurring_job.job_id
  tipo_job INT, -- @map <- staging.stg_acao_recurring_job.tipo_job
  cron_expression STRING, -- @map <- staging.stg_acao_recurring_job.cron_expression
  job_description STRING, -- @map <- staging.stg_acao_recurring_job.job_description
  ativo INT, -- @map <- staging.stg_acao_recurring_job.ativo
  parameters STRING, -- @map <- staging.stg_acao_recurring_job.parameters
  PRIMARY KEY (recurring_job_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM competences.AVALIADO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_avaliado
-- @fk: colaborador_avaliado_employee_key -> edw.dim_employee.employee_key
-- @fk: colaborador_sucessor_employee_key -> edw.dim_employee.employee_key
-- @fk: eval_cycle_key -> edw.dim_eval_cycle.eval_cycle_key
CREATE TABLE IF NOT EXISTS edw.dim_avaliado (
  avaliado_key BIGINT,
  tenant_slug STRING,
  colaborador_avaliado_employee_key BIGINT,
  colaborador_sucessor_employee_key BIGINT,
  eval_cycle_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_avaliado.id
  id_avaliacao INT, -- @map <- staging.stg_avaliacao_avaliado.id_avaliacao
  id_colaborador_avaliado INT, -- @map <- staging.stg_avaliacao_avaliado.id_colaborador_avaliado
  id_colaborador_funcao INT, -- @map <- staging.stg_avaliacao_avaliado.id_colaborador_funcao
  email_boas_vindas_recebido INT, -- @map <- staging.stg_avaliacao_avaliado.email_boas_vindas_recebido
  area_de_interesse_de_mudanca INT, -- @map <- staging.stg_avaliacao_avaliado.area_de_interesse_de_mudanca
  status INT, -- @map <- staging.stg_avaliacao_avaliado.status
  migrado_novo_gt INT, -- @map <- staging.stg_avaliacao_avaliado.migrado_novo_gt
  id_colaborador_sucessor INT, -- @map <- staging.stg_avaliacao_avaliado.id_colaborador_sucessor
  tempo_necessario_sucessor INT, -- @map <- staging.stg_avaliacao_avaliado.tempo_necessario_sucessor
  tipo_tempo_sucessor INT, -- @map <- staging.stg_avaliacao_avaliado.tipo_tempo_sucessor
  data_indicacao TIMESTAMP, -- @map <- staging.stg_avaliacao_avaliado.data_indicacao
  data_aprovacao_indicacao TIMESTAMP, -- @map <- staging.stg_avaliacao_avaliado.data_aprovacao_indicacao
  bloqueado_para_liberacao INT, -- @map <- staging.stg_avaliacao_avaliado.bloqueado_para_liberacao
  bloqueado_para_liberacao_indicacao INT, -- @map <- staging.stg_avaliacao_avaliado.bloqueado_para_liberacao_indicacao
  bloqueado_para_liberacao_aprovacao_indicacao INT, -- @map <- staging.stg_avaliacao_avaliado.bloqueado_para_liberacao_aprovacao_indicacao
  indication_comment STRING, -- @map <- staging.stg_avaliacao_avaliado.indication_comment
  leader_indication_comment STRING, -- @map <- staging.stg_avaliacao_avaliado.leader_indication_comment
  PRIMARY KEY (avaliado_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM competences.CompetenceTypeComment SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_competencetypecomment
CREATE TABLE IF NOT EXISTS edw.dim_competence_type_comment (
  competence_type_comment_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_avaliacao_competencetypecomment.id
  evaluation_form_id INT, -- @map <- staging.stg_avaliacao_competencetypecomment.evaluation_form_id
  competence_type INT, -- @map <- staging.stg_avaliacao_competencetypecomment.competence_type
  comment STRING, -- @map <- staging.stg_avaliacao_competencetypecomment.comment
  PRIMARY KEY (competence_type_comment_key)
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

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.CONFIGURACOES_GERAIS_FEEDBACK_CONTINUO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_configuracoes_gerais_feedback_continuo
CREATE TABLE IF NOT EXISTS edw.dim_configuracoes_gerais_feedback_continuo (
  configuracoes_gerais_feedback_continuo_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_avaliacao_configuracoes_gerais_feedback_continuo.id
  feedback_anonimo_ativo INT, -- @map <- staging.stg_avaliacao_configuracoes_gerais_feedback_continuo.feedback_anonimo_ativo
  feedback_direto_ativo INT, -- @map <- staging.stg_avaliacao_configuracoes_gerais_feedback_continuo.feedback_direto_ativo
  PRIMARY KEY (configuracoes_gerais_feedback_continuo_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM competences.CURVA_PONTUACAO_AVALIACAO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_curva_pontuacao_avaliacao
CREATE TABLE IF NOT EXISTS edw.dim_curva_pontuacao_avaliacao (
  curva_pontuacao_avaliacao_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_avaliacao_curva_pontuacao_avaliacao.id
  id_avaliacao INT, -- @map <- staging.stg_avaliacao_curva_pontuacao_avaliacao.id_avaliacao
  criterio_pontuacao STRING, -- @map <- staging.stg_avaliacao_curva_pontuacao_avaliacao.criterio_pontuacao
  significado_pontuacao STRING, -- @map <- staging.stg_avaliacao_curva_pontuacao_avaliacao.significado_pontuacao
  nota_referencia INT, -- @map <- staging.stg_avaliacao_curva_pontuacao_avaliacao.nota_referencia
  nota_pontuacao INT, -- @map <- staging.stg_avaliacao_curva_pontuacao_avaliacao.nota_pontuacao
  perc_alcance DECIMAL(28,8), -- @map <- staging.stg_avaliacao_curva_pontuacao_avaliacao.perc_alcance
  PRIMARY KEY (curva_pontuacao_avaliacao_key)
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
-- @note: DIM dbo.EvaluationCycleInstance SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_evaluationcycleinstance
-- @fk: nine_box_key -> edw.dim_nine_box.nine_box_key
CREATE TABLE IF NOT EXISTS edw.dim_evaluation_cycle_instance (
  evaluation_cycle_instance_key BIGINT,
  tenant_slug STRING,
  nine_box_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_evaluationcycleinstance.id
  forum_id INT, -- @map <- staging.stg_avaliacao_evaluationcycleinstance.forum_id
  description STRING, -- @map <- staging.stg_avaliacao_evaluationcycleinstance.description
  creation_date TIMESTAMP, -- @map <- staging.stg_avaliacao_evaluationcycleinstance.creation_date
  start_date TIMESTAMP, -- @map <- staging.stg_avaliacao_evaluationcycleinstance.start_date
  end_date TIMESTAMP, -- @map <- staging.stg_avaliacao_evaluationcycleinstance.end_date
  status INT, -- @map <- staging.stg_avaliacao_evaluationcycleinstance.status
  PRIMARY KEY (evaluation_cycle_instance_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.EvaluationCycleQuadrant SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_evaluationcyclequadrant
-- @fk: eval_cycle_key -> edw.dim_eval_cycle.eval_cycle_key
-- @fk: faixa_classificacao_avaliacao_key -> edw.dim_faixa_classificacao_avaliacao.faixa_classificacao_avaliacao_key
-- @fk: faixa_classificacao_performance_avaliacao_key -> edw.dim_faixa_classificacao_performance_avaliacao.faixa_classificacao_performance_avaliacao_key
CREATE TABLE IF NOT EXISTS edw.dim_evaluation_cycle_quadrant (
  evaluation_cycle_quadrant_key BIGINT,
  tenant_slug STRING,
  eval_cycle_key BIGINT,
  faixa_classificacao_avaliacao_key BIGINT,
  faixa_classificacao_performance_avaliacao_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_evaluationcyclequadrant.id
  evaluation_cycle_id INT, -- @map <- staging.stg_avaliacao_evaluationcyclequadrant.evaluation_cycle_id
  x_axis_classification_id INT, -- @map <- staging.stg_avaliacao_evaluationcyclequadrant.x_axis_classification_id
  y_axis_classification_id INT, -- @map <- staging.stg_avaliacao_evaluationcyclequadrant.y_axis_classification_id
  title STRING, -- @map <- staging.stg_avaliacao_evaluationcyclequadrant.title
  description STRING, -- @map <- staging.stg_avaliacao_evaluationcyclequadrant.description
  background_color STRING, -- @map <- staging.stg_avaliacao_evaluationcyclequadrant.background_color
  title_color STRING, -- @map <- staging.stg_avaliacao_evaluationcyclequadrant.title_color
  PRIMARY KEY (evaluation_cycle_quadrant_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM competences.FAIXA_CLASSIFICACAO_AVALIACAO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_faixa_classificacao_avaliacao
-- @fk: eval_cycle_key -> edw.dim_eval_cycle.eval_cycle_key
CREATE TABLE IF NOT EXISTS edw.dim_faixa_classificacao_avaliacao (
  faixa_classificacao_avaliacao_key BIGINT,
  tenant_slug STRING,
  eval_cycle_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_faixa_classificacao_avaliacao.id
  id_avaliacao INT, -- @map <- staging.stg_avaliacao_faixa_classificacao_avaliacao.id_avaliacao
  descricao STRING, -- @map <- staging.stg_avaliacao_faixa_classificacao_avaliacao.descricao
  nota_de DECIMAL(28,8), -- @map <- staging.stg_avaliacao_faixa_classificacao_avaliacao.nota_de
  nota_ate DECIMAL(28,8), -- @map <- staging.stg_avaliacao_faixa_classificacao_avaliacao.nota_ate
  porcentagem_curva_esperada DECIMAL(28,8), -- @map <- staging.stg_avaliacao_faixa_classificacao_avaliacao.porcentagem_curva_esperada
  nota_de_numeric DECIMAL(28,8), -- @map <- staging.stg_avaliacao_faixa_classificacao_avaliacao.nota_de_numeric
  nota_ate_numeric DECIMAL(28,8), -- @map <- staging.stg_avaliacao_faixa_classificacao_avaliacao.nota_ate_numeric
  mesclar_com_faixa INT, -- @map <- staging.stg_avaliacao_faixa_classificacao_avaliacao.mesclar_com_faixa
  PRIMARY KEY (faixa_classificacao_avaliacao_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM competences.FAIXA_CLASSIFICACAO_PERFORMANCE_AVALIACAO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_faixa_classificacao_performance_avaliacao
-- @fk: eval_cycle_key -> edw.dim_eval_cycle.eval_cycle_key
CREATE TABLE IF NOT EXISTS edw.dim_faixa_classificacao_performance_avaliacao (
  faixa_classificacao_performance_avaliacao_key BIGINT,
  tenant_slug STRING,
  eval_cycle_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_faixa_classificacao_performance_avaliacao.id
  id_avaliacao INT, -- @map <- staging.stg_avaliacao_faixa_classificacao_performance_avaliacao.id_avaliacao
  descricao STRING, -- @map <- staging.stg_avaliacao_faixa_classificacao_performance_avaliacao.descricao
  nota_de DECIMAL(28,8), -- @map <- staging.stg_avaliacao_faixa_classificacao_performance_avaliacao.nota_de
  nota_ate DECIMAL(28,8), -- @map <- staging.stg_avaliacao_faixa_classificacao_performance_avaliacao.nota_ate
  porcentagem_curva_esperada DECIMAL(28,8), -- @map <- staging.stg_avaliacao_faixa_classificacao_performance_avaliacao.porcentagem_curva_esperada
  mesclar_com_faixa INT, -- @map <- staging.stg_avaliacao_faixa_classificacao_performance_avaliacao.mesclar_com_faixa
  PRIMARY KEY (faixa_classificacao_performance_avaliacao_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM competences.FATOR_AVALIACAO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_fator_avaliacao
-- @fk: competency_key -> edw.dim_competency.competency_key
CREATE TABLE IF NOT EXISTS edw.dim_fator_avaliacao (
  fator_avaliacao_key BIGINT,
  tenant_slug STRING,
  competency_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_fator_avaliacao.id
  id_competencia INT, -- @map <- staging.stg_avaliacao_fator_avaliacao.id_competencia
  detalhe_fator_avaliacao STRING, -- @map <- staging.stg_avaliacao_fator_avaliacao.detalhe_fator_avaliacao
  desc_fator_avaliacao STRING, -- @map <- staging.stg_avaliacao_fator_avaliacao.desc_fator_avaliacao
  codigo STRING, -- @map <- staging.stg_avaliacao_fator_avaliacao.codigo
  PRIMARY KEY (fator_avaliacao_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.FeedbackHistory SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_feedbackhistory
-- @fk: feedback_key -> edw.fact_feedback.feedback_key
CREATE TABLE IF NOT EXISTS edw.dim_feedback_history (
  feedback_history_key BIGINT,
  tenant_slug STRING,
  feedback_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_feedbackhistory.id
  feedback_id INT, -- @map <- staging.stg_avaliacao_feedbackhistory.feedback_id
  text STRING, -- @map <- staging.stg_avaliacao_feedbackhistory.text
  date TIMESTAMP, -- @map <- staging.stg_avaliacao_feedbackhistory.date
  PRIMARY KEY (feedback_history_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.FeedbackParticipant SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_feedbackparticipant
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: feedback_key -> edw.fact_feedback.feedback_key
CREATE TABLE IF NOT EXISTS edw.dim_feedback_participant (
  feedback_participant_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  feedback_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_feedbackparticipant.id
  employee_id INT, -- @map <- staging.stg_avaliacao_feedbackparticipant.employee_id
  feedback_id INT, -- @map <- staging.stg_avaliacao_feedbackparticipant.feedback_id
  PRIMARY KEY (feedback_participant_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.FORMULARIO_FEEDBACK_ABA SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_formulario_feedback_aba
-- @fk: eval_cycle_key -> edw.dim_eval_cycle.eval_cycle_key
CREATE TABLE IF NOT EXISTS edw.dim_formulario_feedback_aba (
  formulario_feedback_aba_key BIGINT,
  tenant_slug STRING,
  eval_cycle_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_formulario_feedback_aba.id
  id_avaliacao INT, -- @map <- staging.stg_avaliacao_formulario_feedback_aba.id_avaliacao
  descricao STRING, -- @map <- staging.stg_avaliacao_formulario_feedback_aba.descricao
  PRIMARY KEY (formulario_feedback_aba_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM competences.FUNCAO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_funcao
-- @fk: eval_cycle_key -> edw.dim_eval_cycle.eval_cycle_key
-- @fk: parent_funcao_key -> edw.dim_funcao.funcao_key
-- @fk: parent_ajuste_funcao_key -> edw.dim_funcao.funcao_key
CREATE TABLE IF NOT EXISTS edw.dim_funcao (
  funcao_key BIGINT,
  tenant_slug STRING,
  eval_cycle_key BIGINT,
  parent_funcao_key BIGINT,
  parent_ajuste_funcao_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_funcao.id
  cod_funcao STRING, -- @map <- staging.stg_avaliacao_funcao.cod_funcao
  desc_funcao STRING, -- @map <- staging.stg_avaliacao_funcao.desc_funcao
  id_parent INT, -- @map <- staging.stg_avaliacao_funcao.id_parent
  id_parent_ajuste INT, -- @map <- staging.stg_avaliacao_funcao.id_parent_ajuste
  id_avaliacao INT, -- @map <- staging.stg_avaliacao_funcao.id_avaliacao
  PRIMARY KEY (funcao_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.ITEM_LISTA_PERSONALIZADA_FEEDBACK_CONTINUO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_item_lista_personalizada_feedback_continuo
-- @fk: tipo_feedback_continuo_key -> edw.dim_tipo_feedback_continuo.tipo_feedback_continuo_key
CREATE TABLE IF NOT EXISTS edw.dim_item_lista_personalizada_feedback_continuo (
  item_lista_personalizada_feedback_continuo_key BIGINT,
  tenant_slug STRING,
  tipo_feedback_continuo_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_item_lista_personalizada_feedback_continuo.id
  descricao STRING, -- @map <- staging.stg_avaliacao_item_lista_personalizada_feedback_continuo.descricao
  feedback_type_id INT, -- @map <- staging.stg_avaliacao_item_lista_personalizada_feedback_continuo.feedback_type_id
  ativo INT, -- @map <- staging.stg_avaliacao_item_lista_personalizada_feedback_continuo.ativo
  cor_texto STRING, -- @map <- staging.stg_avaliacao_item_lista_personalizada_feedback_continuo.cor_texto
  cor_fundo STRING, -- @map <- staging.stg_avaliacao_item_lista_personalizada_feedback_continuo.cor_fundo
  PRIMARY KEY (item_lista_personalizada_feedback_continuo_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM competences.METODO_CALCULO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_metodo_calculo
-- @fk: eval_cycle_key -> edw.dim_eval_cycle.eval_cycle_key
-- @fk: parent_metodo_calculo_key -> edw.dim_metodo_calculo.metodo_calculo_key
CREATE TABLE IF NOT EXISTS edw.dim_metodo_calculo (
  metodo_calculo_key BIGINT,
  tenant_slug STRING,
  eval_cycle_key BIGINT,
  parent_metodo_calculo_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_metodo_calculo.id
  nome STRING, -- @map <- staging.stg_avaliacao_metodo_calculo.nome
  auto DECIMAL(28,8), -- @map <- staging.stg_avaliacao_metodo_calculo.auto
  lider DECIMAL(28,8), -- @map <- staging.stg_avaliacao_metodo_calculo.lider
  par DECIMAL(28,8), -- @map <- staging.stg_avaliacao_metodo_calculo.par
  time DECIMAL(28,8), -- @map <- staging.stg_avaliacao_metodo_calculo.time
  comite DECIMAL(28,8), -- @map <- staging.stg_avaliacao_metodo_calculo.comite
  cliente DECIMAL(28,8), -- @map <- staging.stg_avaliacao_metodo_calculo.cliente
  fornecedor DECIMAL(28,8), -- @map <- staging.stg_avaliacao_metodo_calculo.fornecedor
  ativo INT, -- @map <- staging.stg_avaliacao_metodo_calculo.ativo
  id_avaliacao INT, -- @map <- staging.stg_avaliacao_metodo_calculo.id_avaliacao
  id_parent INT, -- @map <- staging.stg_avaliacao_metodo_calculo.id_parent
  PRIMARY KEY (metodo_calculo_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.NINE_BOX SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_nine_box
CREATE TABLE IF NOT EXISTS edw.dim_nine_box (
  nine_box_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_avaliacao_nine_box.id
  descricao STRING, -- @map <- staging.stg_avaliacao_nine_box.descricao
  dt_criacao TIMESTAMP, -- @map <- staging.stg_avaliacao_nine_box.dt_criacao
  ativo INT, -- @map <- staging.stg_avaliacao_nine_box.ativo
  id_avaliacao INT, -- @map <- staging.stg_avaliacao_nine_box.id_avaliacao
  status INT, -- @map <- staging.stg_avaliacao_nine_box.status
  dt_encerramento TIMESTAMP, -- @map <- staging.stg_avaliacao_nine_box.dt_encerramento
  PRIMARY KEY (nine_box_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM competences.PESO_TIPO_AVALIADOR SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_peso_tipo_avaliador
-- @fk: eval_cycle_key -> edw.dim_eval_cycle.eval_cycle_key
-- @fk: funcao_key -> edw.dim_funcao.funcao_key
-- @fk: metodo_calculo_key -> edw.dim_metodo_calculo.metodo_calculo_key
CREATE TABLE IF NOT EXISTS edw.dim_peso_tipo_avaliador (
  peso_tipo_avaliador_key BIGINT,
  tenant_slug STRING,
  eval_cycle_key BIGINT,
  funcao_key BIGINT,
  metodo_calculo_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_peso_tipo_avaliador.id
  id_funcao INT, -- @map <- staging.stg_avaliacao_peso_tipo_avaliador.id_funcao
  id_metodo_calculo INT, -- @map <- staging.stg_avaliacao_peso_tipo_avaliador.id_metodo_calculo
  id_avaliacao INT, -- @map <- staging.stg_avaliacao_peso_tipo_avaliador.id_avaliacao
  PRIMARY KEY (peso_tipo_avaliador_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM competences.settings SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_settings
CREATE TABLE IF NOT EXISTS edw.dim_settings (
  settings_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_avaliacao_settings.id
  name STRING, -- @map <- staging.stg_avaliacao_settings.name
  value STRING, -- @map <- staging.stg_avaliacao_settings.value
  type STRING, -- @map <- staging.stg_avaliacao_settings.type
  PRIMARY KEY (settings_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.TAG_FEEDBACK SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_tag_feedback
-- @fk: tag_feedback_continuo_key -> edw.dim_tag_feedback_continuo.tag_feedback_continuo_key
-- @fk: feedback_key -> edw.fact_feedback.feedback_key
CREATE TABLE IF NOT EXISTS edw.dim_tag_feedback (
  tag_feedback_key BIGINT,
  tenant_slug STRING,
  tag_feedback_continuo_key BIGINT,
  feedback_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_tag_feedback.id
  id_tag INT, -- @map <- staging.stg_avaliacao_tag_feedback.id_tag
  id_feedback INT, -- @map <- staging.stg_avaliacao_tag_feedback.id_feedback
  tipo_tag INT, -- @map <- staging.stg_avaliacao_tag_feedback.tipo_tag
  PRIMARY KEY (tag_feedback_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.TAG_FEEDBACK_CONTINUO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_tag_feedback_continuo
CREATE TABLE IF NOT EXISTS edw.dim_tag_feedback_continuo (
  tag_feedback_continuo_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_avaliacao_tag_feedback_continuo.id
  ponto_positivo STRING, -- @map <- staging.stg_avaliacao_tag_feedback_continuo.ponto_positivo
  ponto_a_desenvolver STRING, -- @map <- staging.stg_avaliacao_tag_feedback_continuo.ponto_a_desenvolver
  ativo INT, -- @map <- staging.stg_avaliacao_tag_feedback_continuo.ativo
  PRIMARY KEY (tag_feedback_continuo_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.TIMELINE_FEEDBACK_CONTINUO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_timeline_feedback_continuo
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: feedback_key -> edw.fact_feedback.feedback_key
CREATE TABLE IF NOT EXISTS edw.dim_timeline_feedback (
  timeline_feedback_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  feedback_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_timeline_feedback_continuo.id
  id_colaborador INT, -- @map <- staging.stg_avaliacao_timeline_feedback_continuo.id_colaborador
  id_feedback INT, -- @map <- staging.stg_avaliacao_timeline_feedback_continuo.id_feedback
  arquivado INT, -- @map <- staging.stg_avaliacao_timeline_feedback_continuo.arquivado
  lido INT, -- @map <- staging.stg_avaliacao_timeline_feedback_continuo.lido
  id_pulse_respondido INT, -- @map <- staging.stg_avaliacao_timeline_feedback_continuo.id_pulse_respondido
  PRIMARY KEY (timeline_feedback_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM competences.TIPO_AVALIACAO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_tipo_avaliacao
CREATE TABLE IF NOT EXISTS edw.dim_tipo_avaliacao (
  tipo_avaliacao_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_avaliacao_tipo_avaliacao.id
  descricao STRING, -- @map <- staging.stg_avaliacao_tipo_avaliacao.descricao
  ativo INT, -- @map <- staging.stg_avaliacao_tipo_avaliacao.ativo
  PRIMARY KEY (tipo_avaliacao_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM competences.TIPO_AVALIADOR SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_tipo_avaliador
CREATE TABLE IF NOT EXISTS edw.dim_tipo_avaliador (
  tipo_avaliador_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_avaliacao_tipo_avaliador.id
  pt_br STRING, -- @map <- staging.stg_avaliacao_tipo_avaliador.pt_br
  en_us STRING, -- @map <- staging.stg_avaliacao_tipo_avaliador.en_us
  es_es STRING, -- @map <- staging.stg_avaliacao_tipo_avaliador.es_es
  tipo STRING, -- @map <- staging.stg_avaliacao_tipo_avaliador.tipo
  descricao STRING, -- @map <- staging.stg_avaliacao_tipo_avaliador.descricao
  radar_chart_color STRING, -- @map <- staging.stg_avaliacao_tipo_avaliador.radar_chart_color
  PRIMARY KEY (tipo_avaliador_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.TIPO_FEEDBACK_CONTINUO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_tipo_feedback_continuo
CREATE TABLE IF NOT EXISTS edw.dim_tipo_feedback_continuo (
  tipo_feedback_continuo_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_avaliacao_tipo_feedback_continuo.id
  descricao STRING, -- @map <- staging.stg_avaliacao_tipo_feedback_continuo.descricao
  ativo INT, -- @map <- staging.stg_avaliacao_tipo_feedback_continuo.ativo
  tipo_feedback INT, -- @map <- staging.stg_avaliacao_tipo_feedback_continuo.tipo_feedback
  edicao_permitida INT, -- @map <- staging.stg_avaliacao_tipo_feedback_continuo.edicao_permitida
  excluido INT, -- @map <- staging.stg_avaliacao_tipo_feedback_continuo.excluido
  PRIMARY KEY (tipo_feedback_continuo_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM competences.TOPICO_PERGUNTA_LIVRE SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_topico_pergunta_livre
CREATE TABLE IF NOT EXISTS edw.dim_topico_pergunta_livre (
  topico_pergunta_livre_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_avaliacao_topico_pergunta_livre.id
  descricao STRING, -- @map <- staging.stg_avaliacao_topico_pergunta_livre.descricao
  PRIMARY KEY (topico_pergunta_livre_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.AcceptAgreementSignatureAttachment SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_acceptagreementsignatureattachment
CREATE TABLE IF NOT EXISTS edw.dim_accept_agreement_signature_attachment (
  accept_agreement_signature_attachment_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_colaborador_acceptagreementsignatureattachment.id
  file_name STRING, -- @map <- staging.stg_colaborador_acceptagreementsignatureattachment.file_name
  key STRING, -- @map <- staging.stg_colaborador_acceptagreementsignatureattachment.key
  upload_date TIMESTAMP, -- @map <- staging.stg_colaborador_acceptagreementsignatureattachment.upload_date
  content_type STRING, -- @map <- staging.stg_colaborador_acceptagreementsignatureattachment.content_type
  content_length INT, -- @map <- staging.stg_colaborador_acceptagreementsignatureattachment.content_length
  PRIMARY KEY (accept_agreement_signature_attachment_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.ADMINISTRADOR_LOCAL SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_administrador_local
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.dim_administrador_local (
  administrador_local_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_administrador_local.id
  id_colaborador INT, -- @map <- staging.stg_colaborador_administrador_local.id_colaborador
  id_modulo INT, -- @map <- staging.stg_colaborador_administrador_local.id_modulo
  PRIMARY KEY (administrador_local_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.AVALIADO_SUCESSAO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_avaliado_sucessao
-- @fk: colaborador_avaliado_employee_key -> edw.dim_employee.employee_key
-- @fk: colaborador_avaliador_employee_key -> edw.dim_employee.employee_key
-- @fk: succession_cycle_key -> edw.dim_succession_cycle.succession_cycle_key
CREATE TABLE IF NOT EXISTS edw.dim_avaliado_sucessao (
  avaliado_sucessao_key BIGINT,
  tenant_slug STRING,
  colaborador_avaliado_employee_key BIGINT,
  colaborador_avaliador_employee_key BIGINT,
  succession_cycle_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_avaliado_sucessao.id
  id_ciclo_sucessao INT, -- @map <- staging.stg_colaborador_avaliado_sucessao.id_ciclo_sucessao
  id_colaborador_avaliado INT, -- @map <- staging.stg_colaborador_avaliado_sucessao.id_colaborador_avaliado
  id_funcao INT, -- @map <- staging.stg_colaborador_avaliado_sucessao.id_funcao
  status INT, -- @map <- staging.stg_colaborador_avaliado_sucessao.status
  id_colaborador_avaliador INT, -- @map <- staging.stg_colaborador_avaliado_sucessao.id_colaborador_avaliador
  PRIMARY KEY (avaliado_sucessao_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.AVALIADOR_FORUM_SUCESSAO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_avaliador_forum_sucessao
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: forum_calibragem_sucessao_key -> edw.dim_forum_calibragem_sucessao.forum_calibragem_sucessao_key
CREATE TABLE IF NOT EXISTS edw.dim_avaliador_forum_sucessao (
  avaliador_forum_sucessao_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  forum_calibragem_sucessao_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_avaliador_forum_sucessao.id
  id_colaborador_avaliador INT, -- @map <- staging.stg_colaborador_avaliador_forum_sucessao.id_colaborador_avaliador
  id_forum INT, -- @map <- staging.stg_colaborador_avaliador_forum_sucessao.id_forum
  PRIMARY KEY (avaliador_forum_sucessao_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.CauseAnalysisPermission SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_causeanalysispermission
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.dim_cause_analysis_permission (
  cause_analysis_permission_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_causeanalysispermission.id
  countermeasure_id INT, -- @map <- staging.stg_colaborador_causeanalysispermission.countermeasure_id
  employee_id INT, -- @map <- staging.stg_colaborador_causeanalysispermission.employee_id
  PRIMARY KEY (cause_analysis_permission_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.Certificate SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_certificate
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.dim_certificate (
  certificate_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_certificate.id
  logo STRING, -- @map <- staging.stg_colaborador_certificate.logo
  title STRING, -- @map <- staging.stg_colaborador_certificate.title
  issuer STRING, -- @map <- staging.stg_colaborador_certificate.issuer
  license STRING, -- @map <- staging.stg_colaborador_certificate.license
  start TIMESTAMP, -- @map <- staging.stg_colaborador_certificate.start
  end TIMESTAMP, -- @map <- staging.stg_colaborador_certificate.end
  employee_id INT, -- @map <- staging.stg_colaborador_certificate.employee_id
  PRIMARY KEY (certificate_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.CertificateAttachment SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_certificateattachment
-- @fk: certificate_key -> edw.dim_certificate.certificate_key
CREATE TABLE IF NOT EXISTS edw.dim_certificate_attachment (
  certificate_attachment_key BIGINT,
  tenant_slug STRING,
  certificate_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_certificateattachment.id
  file_name STRING, -- @map <- staging.stg_colaborador_certificateattachment.file_name
  key STRING, -- @map <- staging.stg_colaborador_certificateattachment.key
  upload_date TIMESTAMP, -- @map <- staging.stg_colaborador_certificateattachment.upload_date
  content_type STRING, -- @map <- staging.stg_colaborador_certificateattachment.content_type
  content_length INT, -- @map <- staging.stg_colaborador_certificateattachment.content_length
  PRIMARY KEY (certificate_attachment_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.ConsentAgreement SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_consentagreement
CREATE TABLE IF NOT EXISTS edw.dim_consent_agreement (
  consent_agreement_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_colaborador_consentagreement.id
  description STRING, -- @map <- staging.stg_colaborador_consentagreement.description
  subject STRING, -- @map <- staging.stg_colaborador_consentagreement.subject
  version STRING, -- @map <- staging.stg_colaborador_consentagreement.version
  last_update TIMESTAMP, -- @map <- staging.stg_colaborador_consentagreement.last_update
  active INT, -- @map <- staging.stg_colaborador_consentagreement.active
  PRIMARY KEY (consent_agreement_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.CurriculumAttachment SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_curriculumattachment
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.dim_curriculum_attachment (
  curriculum_attachment_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_curriculumattachment.id
  file_name STRING, -- @map <- staging.stg_colaborador_curriculumattachment.file_name
  key STRING, -- @map <- staging.stg_colaborador_curriculumattachment.key
  upload_date TIMESTAMP, -- @map <- staging.stg_colaborador_curriculumattachment.upload_date
  content_type STRING, -- @map <- staging.stg_colaborador_curriculumattachment.content_type
  content_length INT, -- @map <- staging.stg_colaborador_curriculumattachment.content_length
  PRIMARY KEY (curriculum_attachment_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.Dreams SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_dreams
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.dim_dreams (
  dreams_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_dreams.id
  personal STRING, -- @map <- staging.stg_colaborador_dreams.personal
  professional STRING, -- @map <- staging.stg_colaborador_dreams.professional
  values STRING, -- @map <- staging.stg_colaborador_dreams.values
  PRIMARY KEY (dreams_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.EducationAttachment SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_educationattachment
CREATE TABLE IF NOT EXISTS edw.dim_education_attachment (
  education_attachment_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_colaborador_educationattachment.id
  file_name STRING, -- @map <- staging.stg_colaborador_educationattachment.file_name
  upload_date TIMESTAMP, -- @map <- staging.stg_colaborador_educationattachment.upload_date
  content_type STRING, -- @map <- staging.stg_colaborador_educationattachment.content_type
  key STRING, -- @map <- staging.stg_colaborador_educationattachment.key
  content_length INT, -- @map <- staging.stg_colaborador_educationattachment.content_length
  PRIMARY KEY (education_attachment_key)
) USING DELTA;

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
-- @note: DIM dbo.EmployeeBranch SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_employeebranch
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: filial_key -> edw.dim_filial.filial_key
CREATE TABLE IF NOT EXISTS edw.dim_employee_branch (
  employee_branch_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  filial_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_employeebranch.id
  id_employee INT, -- @map <- staging.stg_colaborador_employeebranch.id_employee
  id_branch INT, -- @map <- staging.stg_colaborador_employeebranch.id_branch
  PRIMARY KEY (employee_branch_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.GoalDiscussion SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_goaldiscussion
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: goal_key -> edw.dim_goal.goal_key
CREATE TABLE IF NOT EXISTS edw.dim_goal_discussion (
  goal_discussion_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  goal_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_goaldiscussion.id
  goal_id INT, -- @map <- staging.stg_colaborador_goaldiscussion.goal_id
  employee_id INT, -- @map <- staging.stg_colaborador_goaldiscussion.employee_id
  message STRING, -- @map <- staging.stg_colaborador_goaldiscussion.message
  created_date TIMESTAMP, -- @map <- staging.stg_colaborador_goaldiscussion.created_date
  PRIMARY KEY (goal_discussion_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.Hobbies SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_hobbies
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.dim_hobbies (
  hobbies_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_hobbies.id
  personal STRING, -- @map <- staging.stg_colaborador_hobbies.personal
  family STRING, -- @map <- staging.stg_colaborador_hobbies.family
  PRIMARY KEY (hobbies_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.INSTANCIA_COMITE SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_instancia_comite
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: evaluation_cycle_instance_key -> edw.dim_evaluation_cycle_instance.evaluation_cycle_instance_key
CREATE TABLE IF NOT EXISTS edw.dim_instancia_comite (
  instancia_comite_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  evaluation_cycle_instance_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_instancia_comite.id
  instancia_id INT, -- @map <- staging.stg_colaborador_instancia_comite.instancia_id
  colaborador_id INT, -- @map <- staging.stg_colaborador_instancia_comite.colaborador_id
  PRIMARY KEY (instancia_comite_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.INSTANCIA_COMITE_SUCESSAO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_instancia_comite_sucessao
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: instancia_sucessao_key -> edw.dim_instancia_sucessao.instancia_sucessao_key
CREATE TABLE IF NOT EXISTS edw.dim_instancia_comite_sucessao (
  instancia_comite_sucessao_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  instancia_sucessao_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_instancia_comite_sucessao.id
  id_instancia_sucessao INT, -- @map <- staging.stg_colaborador_instancia_comite_sucessao.id_instancia_sucessao
  id_colaborador INT, -- @map <- staging.stg_colaborador_instancia_comite_sucessao.id_colaborador
  PRIMARY KEY (instancia_comite_sucessao_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.LanguageLevel SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_languagelevel
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.dim_language_level (
  language_level_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_languagelevel.id
  proficiency INT, -- @map <- staging.stg_colaborador_languagelevel.proficiency
  employee_id INT, -- @map <- staging.stg_colaborador_languagelevel.employee_id
  language_id INT, -- @map <- staging.stg_colaborador_languagelevel.language_id
  observation STRING, -- @map <- staging.stg_colaborador_languagelevel.observation
  PRIMARY KEY (language_level_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.Motivations SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_motivations
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.dim_motivations (
  motivations_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_motivations.id
  personal STRING, -- @map <- staging.stg_colaborador_motivations.personal
  demotivations STRING, -- @map <- staging.stg_colaborador_motivations.demotivations
  PRIMARY KEY (motivations_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.NOTIFICACAO_LIDA SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_notificacao_lida
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: notificacao_key -> edw.dim_notificacao.notificacao_key
CREATE TABLE IF NOT EXISTS edw.dim_notificacao_lida (
  notificacao_lida_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  notificacao_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_notificacao_lida.id
  id_notificacao INT, -- @map <- staging.stg_colaborador_notificacao_lida.id_notificacao
  id_colaborador INT, -- @map <- staging.stg_colaborador_notificacao_lida.id_colaborador
  dt_leitura TIMESTAMP, -- @map <- staging.stg_colaborador_notificacao_lida.dt_leitura
  PRIMARY KEY (notificacao_lida_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.PERFIL_USUARIO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_perfil_usuario
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.dim_perfil_usuario (
  perfil_usuario_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_perfil_usuario.id
  id_colaborador INT, -- @map <- staging.stg_colaborador_perfil_usuario.id_colaborador
  id_funcionalidade STRING, -- @map <- staging.stg_colaborador_perfil_usuario.id_funcionalidade
  outras_areas INT, -- @map <- staging.stg_colaborador_perfil_usuario.outras_areas
  PRIMARY KEY (perfil_usuario_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.PersonalCharacteristics SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_personalcharacteristics
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.dim_personal_characteristics (
  personal_characteristics_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_personalcharacteristics.id
  personal STRING, -- @map <- staging.stg_colaborador_personalcharacteristics.personal
  others STRING, -- @map <- staging.stg_colaborador_personalcharacteristics.others
  what_will_not_give_up STRING, -- @map <- staging.stg_colaborador_personalcharacteristics.what_will_not_give_up
  PRIMARY KEY (personal_characteristics_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.PresentationFavoriteSlide SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_presentationfavoriteslide
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.dim_presentation_favorite_slide (
  presentation_favorite_slide_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_presentationfavoriteslide.id
  employee_id INT, -- @map <- staging.stg_colaborador_presentationfavoriteslide.employee_id
  presentation_template_slide_id INT, -- @map <- staging.stg_colaborador_presentationfavoriteslide.presentation_template_slide_id
  PRIMARY KEY (presentation_favorite_slide_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.PROCESSO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_processo
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: kpi_key -> edw.dim_kpi.kpi_key
CREATE TABLE IF NOT EXISTS edw.dim_processo (
  processo_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  kpi_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_processo.id
  id_indicador INT, -- @map <- staging.stg_colaborador_processo.id_indicador
  id_responsavel INT, -- @map <- staging.stg_colaborador_processo.id_responsavel
  cod_processo STRING, -- @map <- staging.stg_colaborador_processo.cod_processo
  desc_processo STRING, -- @map <- staging.stg_colaborador_processo.desc_processo
  tipo_processo INT, -- @map <- staging.stg_colaborador_processo.tipo_processo
  PRIMARY KEY (processo_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.ProfessionalExperience SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_professionalexperience
-- @fk: company_key -> edw.dim_company.company_key
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: job_position_core_key -> edw.dim_job_position_core.job_position_core_key
CREATE TABLE IF NOT EXISTS edw.dim_professional_experience (
  professional_experience_key BIGINT,
  tenant_slug STRING,
  company_key BIGINT,
  employee_key BIGINT,
  job_position_core_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_professionalexperience.id
  location_id INT, -- @map <- staging.stg_colaborador_professionalexperience.location_id
  location STRING, -- @map <- staging.stg_colaborador_professionalexperience.location
  start TIMESTAMP, -- @map <- staging.stg_colaborador_professionalexperience.start
  end TIMESTAMP, -- @map <- staging.stg_colaborador_professionalexperience.end
  job_description STRING, -- @map <- staging.stg_colaborador_professionalexperience.job_description
  current_job INT, -- @map <- staging.stg_colaborador_professionalexperience.current_job
  employee_id INT, -- @map <- staging.stg_colaborador_professionalexperience.employee_id
  knowledge_area STRING, -- @map <- staging.stg_colaborador_professionalexperience.knowledge_area
  company_id INT, -- @map <- staging.stg_colaborador_professionalexperience.company_id
  job_position_id INT, -- @map <- staging.stg_colaborador_professionalexperience.job_position_id
  PRIMARY KEY (professional_experience_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.ProfileEditPermission SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_profileeditpermission
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: grupo_usuario_key -> edw.dim_grupo_usuario.grupo_usuario_key
CREATE TABLE IF NOT EXISTS edw.dim_profile_edit_permission (
  profile_edit_permission_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  grupo_usuario_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_profileeditpermission.id
  employee_id INT, -- @map <- staging.stg_colaborador_profileeditpermission.employee_id
  user_group_id INT, -- @map <- staging.stg_colaborador_profileeditpermission.user_group_id
  PRIMARY KEY (profile_edit_permission_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.ServerCachePreferencesManagementCycle SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_servercachepreferencesmanagementcycle
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: time_gestao_key -> edw.dim_time_gestao.time_gestao_key
CREATE TABLE IF NOT EXISTS edw.dim_server_cache_preferences_management_cycle (
  server_cache_preferences_management_cycle_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  time_gestao_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_servercachepreferencesmanagementcycle.id
  sidebar_item_id INT, -- @map <- staging.stg_colaborador_servercachepreferencesmanagementcycle.sidebar_item_id
  management_cycle_id INT, -- @map <- staging.stg_colaborador_servercachepreferencesmanagementcycle.management_cycle_id
  employee_id INT, -- @map <- staging.stg_colaborador_servercachepreferencesmanagementcycle.employee_id
  filter_json STRING, -- @map <- staging.stg_colaborador_servercachepreferencesmanagementcycle.filter_json
  operation_date TIMESTAMP, -- @map <- staging.stg_colaborador_servercachepreferencesmanagementcycle.operation_date
  PRIMARY KEY (server_cache_preferences_management_cycle_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.Sport SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_sport
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.dim_sport (
  sport_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_sport.id
  name STRING, -- @map <- staging.stg_colaborador_sport.name
  sport_id INT, -- @map <- staging.stg_colaborador_sport.sport_id
  frequency INT, -- @map <- staging.stg_colaborador_sport.frequency
  employee_id INT, -- @map <- staging.stg_colaborador_sport.employee_id
  PRIMARY KEY (sport_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.SystemKnowledge SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_systemknowledge
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: skill_category_key -> edw.dim_skill_category.skill_category_key
-- @fk: skill_knowledge_key -> edw.dim_skill_knowledge.skill_knowledge_key
CREATE TABLE IF NOT EXISTS edw.dim_system_knowledge (
  system_knowledge_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  skill_category_key BIGINT,
  skill_knowledge_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_systemknowledge.id
  name STRING, -- @map <- staging.stg_colaborador_systemknowledge.name
  level INT, -- @map <- staging.stg_colaborador_systemknowledge.level
  employee_id INT, -- @map <- staging.stg_colaborador_systemknowledge.employee_id
  skill_category_id INT, -- @map <- staging.stg_colaborador_systemknowledge.skill_category_id
  skill_knowledge_id INT, -- @map <- staging.stg_colaborador_systemknowledge.skill_knowledge_id
  PRIMARY KEY (system_knowledge_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.TERMO_ACEITE_SECAO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_termo_aceite_secao
-- @fk: termo_aceite_key -> edw.dim_termo_aceite.termo_aceite_key
CREATE TABLE IF NOT EXISTS edw.dim_termo_aceite_secao (
  termo_aceite_secao_key BIGINT,
  tenant_slug STRING,
  termo_aceite_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_termo_aceite_secao.id
  id_termo_aceite INT, -- @map <- staging.stg_colaborador_termo_aceite_secao.id_termo_aceite
  ordem INT, -- @map <- staging.stg_colaborador_termo_aceite_secao.ordem
  tipo INT, -- @map <- staging.stg_colaborador_termo_aceite_secao.tipo
  PRIMARY KEY (termo_aceite_secao_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.Theme SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_theme
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.dim_theme (
  theme_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_theme.id
  name STRING, -- @map <- staging.stg_colaborador_theme.name
  owner_id INT, -- @map <- staging.stg_colaborador_theme.owner_id
  layout_setting STRING, -- @map <- staging.stg_colaborador_theme.layout_setting
  PRIMARY KEY (theme_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.ThemeHistory SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_themehistory
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: theme_key -> edw.dim_theme.theme_key
CREATE TABLE IF NOT EXISTS edw.dim_theme_history (
  theme_history_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  theme_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_themehistory.id
  employee_id INT, -- @map <- staging.stg_colaborador_themehistory.employee_id
  update_date TIMESTAMP, -- @map <- staging.stg_colaborador_themehistory.update_date
  theme_id INT, -- @map <- staging.stg_colaborador_themehistory.theme_id
  PRIMARY KEY (theme_history_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.VolunteerExperience SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_volunteerexperience
-- @fk: company_key -> edw.dim_company.company_key
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: volunteer_function_key -> edw.dim_volunteer_function.volunteer_function_key
CREATE TABLE IF NOT EXISTS edw.dim_volunteer_experience (
  volunteer_experience_key BIGINT,
  tenant_slug STRING,
  company_key BIGINT,
  employee_key BIGINT,
  volunteer_function_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_volunteerexperience.id
  start TIMESTAMP, -- @map <- staging.stg_colaborador_volunteerexperience.start
  end TIMESTAMP, -- @map <- staging.stg_colaborador_volunteerexperience.end
  job_description STRING, -- @map <- staging.stg_colaborador_volunteerexperience.job_description
  cause STRING, -- @map <- staging.stg_colaborador_volunteerexperience.cause
  current_job INT, -- @map <- staging.stg_colaborador_volunteerexperience.current_job
  employee_id INT, -- @map <- staging.stg_colaborador_volunteerexperience.employee_id
  company_id INT, -- @map <- staging.stg_colaborador_volunteerexperience.company_id
  function_id INT, -- @map <- staging.stg_colaborador_volunteerexperience.function_id
  PRIMARY KEY (volunteer_experience_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.VolunteerFunction SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_volunteerfunction
CREATE TABLE IF NOT EXISTS edw.dim_volunteer_function (
  volunteer_function_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_colaborador_volunteerfunction.id
  description STRING, -- @map <- staging.stg_colaborador_volunteerfunction.description
  PRIMARY KEY (volunteer_function_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.AreaHistoryConfig SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_areahistoryconfig
-- @fk: time_gestao_key -> edw.dim_time_gestao.time_gestao_key
CREATE TABLE IF NOT EXISTS edw.dim_area_history_config (
  area_history_config_key BIGINT,
  tenant_slug STRING,
  time_gestao_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_areahistoryconfig.id
  last_sync_date TIMESTAMP, -- @map <- staging.stg_metricas_areahistoryconfig.last_sync_date
  management_cycle_id INT, -- @map <- staging.stg_metricas_areahistoryconfig.management_cycle_id
  PRIMARY KEY (area_history_config_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.CalibrationGroupDiscretionary SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_calibrationgroupdiscretionary
-- @fk: time_apuracao_key -> edw.dim_time_apuracao.time_apuracao_key
CREATE TABLE IF NOT EXISTS edw.dim_calibration_group_discretionary (
  calibration_group_discretionary_key BIGINT,
  tenant_slug STRING,
  time_apuracao_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_calibrationgroupdiscretionary.id
  calculation_period_id INT, -- @map <- staging.stg_metricas_calibrationgroupdiscretionary.calculation_period_id
  description STRING, -- @map <- staging.stg_metricas_calibrationgroupdiscretionary.description
  score_calculation_information STRING, -- @map <- staging.stg_metricas_calibrationgroupdiscretionary.score_calculation_information
  PRIMARY KEY (calibration_group_discretionary_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.CODE_GENERATOR SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_code_generator
-- @fk: time_gestao_key -> edw.dim_time_gestao.time_gestao_key
CREATE TABLE IF NOT EXISTS edw.dim_code_generator (
  code_generator_key BIGINT,
  tenant_slug STRING,
  time_gestao_key BIGINT,
  table_name STRING, -- @map <- staging.stg_metricas_code_generator.table_name
  id_periodo_gestao INT, -- @map <- staging.stg_metricas_code_generator.id_periodo_gestao
  valor INT, -- @map <- staging.stg_metricas_code_generator.valor
  automatica INT, -- @map <- staging.stg_metricas_code_generator.automatica
  id INT, -- @map <- staging.stg_metricas_code_generator.id
  PRIMARY KEY (code_generator_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.ConceptDiscretionary SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_conceptdiscretionary
-- @fk: time_apuracao_key -> edw.dim_time_apuracao.time_apuracao_key
CREATE TABLE IF NOT EXISTS edw.dim_concept_discretionary (
  concept_discretionary_key BIGINT,
  tenant_slug STRING,
  time_apuracao_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_conceptdiscretionary.id
  name STRING, -- @map <- staging.stg_metricas_conceptdiscretionary.name
  grade DECIMAL(18,2), -- @map <- staging.stg_metricas_conceptdiscretionary.grade
  periodo_apuracao_id INT, -- @map <- staging.stg_metricas_conceptdiscretionary.periodo_apuracao_id
  PRIMARY KEY (concept_discretionary_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.CURVA_MULTIPLO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_curva_multiplo
-- @fk: nivel_key -> edw.dim_nivel.nivel_key
-- @fk: time_apuracao_key -> edw.dim_time_apuracao.time_apuracao_key
CREATE TABLE IF NOT EXISTS edw.dim_curva_multiplo (
  curva_multiplo_key BIGINT,
  tenant_slug STRING,
  nivel_key BIGINT,
  time_apuracao_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_curva_multiplo.id
  id_nivel INT, -- @map <- staging.stg_metricas_curva_multiplo.id_nivel
  id_periodo_apuracao INT, -- @map <- staging.stg_metricas_curva_multiplo.id_periodo_apuracao
  nota_curva_multiplo DOUBLE, -- @map <- staging.stg_metricas_curva_multiplo.nota_curva_multiplo
  multiplo_curva_multiplo DOUBLE, -- @map <- staging.stg_metricas_curva_multiplo.multiplo_curva_multiplo
  concept STRING, -- @map <- staging.stg_metricas_curva_multiplo.concept
  PRIMARY KEY (curva_multiplo_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.CURVA_PREMIACAO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_curva_premiacao
CREATE TABLE IF NOT EXISTS edw.dim_curva_premiacao (
  curva_premiacao_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_metricas_curva_premiacao.id
  id_periodo_gestao INT, -- @map <- staging.stg_metricas_curva_premiacao.id_periodo_gestao
  id_source INT, -- @map <- staging.stg_metricas_curva_premiacao.id_source
  cod_curva_premiacao STRING, -- @map <- staging.stg_metricas_curva_premiacao.cod_curva_premiacao
  desc_curva_premiacao STRING, -- @map <- staging.stg_metricas_curva_premiacao.desc_curva_premiacao
  tipo_interpolacao INT, -- @map <- staging.stg_metricas_curva_premiacao.tipo_interpolacao
  use_min_score_instead_of_zero INT, -- @map <- staging.stg_metricas_curva_premiacao.use_min_score_instead_of_zero
  default_curve INT, -- @map <- staging.stg_metricas_curva_premiacao.default_curve
  PRIMARY KEY (curva_premiacao_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.DIRETRIZ SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_diretriz
-- @fk: time_gestao_key -> edw.dim_time_gestao.time_gestao_key
CREATE TABLE IF NOT EXISTS edw.dim_diretriz (
  diretriz_key BIGINT,
  tenant_slug STRING,
  time_gestao_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_diretriz.id
  id_periodo_gestao INT, -- @map <- staging.stg_metricas_diretriz.id_periodo_gestao
  cod_diretriz STRING, -- @map <- staging.stg_metricas_diretriz.cod_diretriz
  desc_diretriz STRING, -- @map <- staging.stg_metricas_diretriz.desc_diretriz
  PRIMARY KEY (diretriz_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.FactorTriggerConfiguration SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_factortriggerconfiguration
-- @fk: custom_grade_formation_key -> edw.dim_custom_grade_formation.custom_grade_formation_key
-- @fk: grupo_pagto_key -> edw.dim_grupo_pagto.grupo_pagto_key
CREATE TABLE IF NOT EXISTS edw.dim_factor_trigger_configuration (
  factor_trigger_configuration_key BIGINT,
  tenant_slug STRING,
  custom_grade_formation_key BIGINT,
  grupo_pagto_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_factortriggerconfiguration.id
  type INT, -- @map <- staging.stg_metricas_factortriggerconfiguration.type
  value DECIMAL(28,8), -- @map <- staging.stg_metricas_factortriggerconfiguration.value
  payment_group_id INT, -- @map <- staging.stg_metricas_factortriggerconfiguration.payment_group_id
  custom_grade_formation_id INT, -- @map <- staging.stg_metricas_factortriggerconfiguration.custom_grade_formation_id
  PRIMARY KEY (factor_trigger_configuration_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.FAIXA_FAROL SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_faixa_farol
CREATE TABLE IF NOT EXISTS edw.dim_faixa_farol (
  faixa_farol_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_metricas_faixa_farol.id
  cod_faixa_farol STRING, -- @map <- staging.stg_metricas_faixa_farol.cod_faixa_farol
  desc_faixa_farol STRING, -- @map <- staging.stg_metricas_faixa_farol.desc_faixa_farol
  comparador INT, -- @map <- staging.stg_metricas_faixa_farol.comparador
  default_for_goals_book_score INT, -- @map <- staging.stg_metricas_faixa_farol.default_for_goals_book_score
  PRIMARY KEY (faixa_farol_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.FAROL SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_farol
CREATE TABLE IF NOT EXISTS edw.dim_farol (
  farol_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_metricas_farol.id
  desc_farol STRING, -- @map <- staging.stg_metricas_farol.desc_farol
  habilitado INT, -- @map <- staging.stg_metricas_farol.habilitado
  cor_hexadecimal STRING, -- @map <- staging.stg_metricas_farol.cor_hexadecimal
  cor_rgb STRING, -- @map <- staging.stg_metricas_farol.cor_rgb
  PRIMARY KEY (farol_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.FREQUENCIA_ACOMP SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_frequencia_acomp
CREATE TABLE IF NOT EXISTS edw.dim_frequencia_acomp (
  frequencia_acomp_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_metricas_frequencia_acomp.id
  desc_frequencia_acomp STRING, -- @map <- staging.stg_metricas_frequencia_acomp.desc_frequencia_acomp
  fator_periodo DOUBLE, -- @map <- staging.stg_metricas_frequencia_acomp.fator_periodo
  PRIMARY KEY (frequencia_acomp_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.FREQUENCIA_VISUALIZACAO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_frequencia_visualizacao
CREATE TABLE IF NOT EXISTS edw.dim_frequencia_visualizacao (
  frequencia_visualizacao_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_metricas_frequencia_visualizacao.id
  desc_frequencia_visualizacao STRING, -- @map <- staging.stg_metricas_frequencia_visualizacao.desc_frequencia_visualizacao
  qte_mes INT, -- @map <- staging.stg_metricas_frequencia_visualizacao.qte_mes
  PRIMARY KEY (frequencia_visualizacao_key)
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
-- @note: DIM dbo.GoalPendencyValueImport SCD1 — grain (tenant_slug)
-- @origen: staging.stg_metricas_goalpendencyvalueimport
CREATE TABLE IF NOT EXISTS edw.dim_goal_pendency_value_import (
  goal_pendency_value_import_key BIGINT,
  tenant_slug STRING,
  import_log_id INT, -- @map <- staging.stg_metricas_goalpendencyvalueimport.import_log_id
  line INT, -- @map <- staging.stg_metricas_goalpendencyvalueimport.line
  goal_id INT, -- @map <- staging.stg_metricas_goalpendencyvalueimport.goal_id
  goal_value_id INT, -- @map <- staging.stg_metricas_goalpendencyvalueimport.goal_value_id
  reference_date TIMESTAMP, -- @map <- staging.stg_metricas_goalpendencyvalueimport.reference_date
  punctual_actual DECIMAL(28,8), -- @map <- staging.stg_metricas_goalpendencyvalueimport.punctual_actual
  accumulated_actual DECIMAL(28,8), -- @map <- staging.stg_metricas_goalpendencyvalueimport.accumulated_actual
  punctual_na_actual INT, -- @map <- staging.stg_metricas_goalpendencyvalueimport.punctual_na_actual
  accumulated_na_actual INT, -- @map <- staging.stg_metricas_goalpendencyvalueimport.accumulated_na_actual
  PRIMARY KEY (goal_pendency_value_import_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.GoalWorkflow SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_goalworkflow
-- @fk: time_gestao_key -> edw.dim_time_gestao.time_gestao_key
CREATE TABLE IF NOT EXISTS edw.dim_goal_workflow (
  goal_workflow_key BIGINT,
  tenant_slug STRING,
  time_gestao_key BIGINT,
  management_cycle_id INT, -- @map <- staging.stg_metricas_goalworkflow.management_cycle_id
  workflow_type INT, -- @map <- staging.stg_metricas_goalworkflow.workflow_type
  id INT, -- @map <- staging.stg_metricas_goalworkflow.id
  PRIMARY KEY (goal_workflow_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.GoalWorkflowCustomStep SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_goalworkflowcustomstep
-- @fk: time_gestao_key -> edw.dim_time_gestao.time_gestao_key
CREATE TABLE IF NOT EXISTS edw.dim_goal_workflow_custom_step (
  goal_workflow_custom_step_key BIGINT,
  tenant_slug STRING,
  time_gestao_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_goalworkflowcustomstep.id
  title STRING, -- @map <- staging.stg_metricas_goalworkflowcustomstep.title
  PRIMARY KEY (goal_workflow_custom_step_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.GoalWorkflowStep SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_goalworkflowstep
-- @fk: goal_workflow_key -> edw.dim_goal_workflow.goal_workflow_key
CREATE TABLE IF NOT EXISTS edw.dim_goal_workflow_step (
  goal_workflow_step_key BIGINT,
  tenant_slug STRING,
  goal_workflow_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_goalworkflowstep.id
  id_goal_workflow INT, -- @map <- staging.stg_metricas_goalworkflowstep.id_goal_workflow
  order INT, -- @map <- staging.stg_metricas_goalworkflowstep.order
  type INT, -- @map <- staging.stg_metricas_goalworkflowstep.type
  PRIMARY KEY (goal_workflow_step_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.GRUPO_PAGTO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_grupo_pagto
-- @fk: modifier_key -> edw.dim_modifier.modifier_key
-- @fk: pool_key -> edw.dim_pool.pool_key
-- @fk: time_apuracao_key -> edw.dim_time_apuracao.time_apuracao_key
CREATE TABLE IF NOT EXISTS edw.dim_grupo_pagto (
  grupo_pagto_key BIGINT,
  tenant_slug STRING,
  modifier_key BIGINT,
  pool_key BIGINT,
  time_apuracao_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_grupo_pagto.id
  id_periodo_apuracao INT, -- @map <- staging.stg_metricas_grupo_pagto.id_periodo_apuracao
  cod_grupo_pagto STRING, -- @map <- staging.stg_metricas_grupo_pagto.cod_grupo_pagto
  desc_grupo_pagto STRING, -- @map <- staging.stg_metricas_grupo_pagto.desc_grupo_pagto
  perc_individual DOUBLE, -- @map <- staging.stg_metricas_grupo_pagto.perc_individual
  perc_area DOUBLE, -- @map <- staging.stg_metricas_grupo_pagto.perc_area
  perc_superior DOUBLE, -- @map <- staging.stg_metricas_grupo_pagto.perc_superior
  perc_presidencia DOUBLE, -- @map <- staging.stg_metricas_grupo_pagto.perc_presidencia
  pool_grupo_pagto DOUBLE, -- @map <- staging.stg_metricas_grupo_pagto.pool_grupo_pagto
  perc_avaliacao_competencia DOUBLE, -- @map <- staging.stg_metricas_grupo_pagto.perc_avaliacao_competencia
  perc_discricionario DOUBLE, -- @map <- staging.stg_metricas_grupo_pagto.perc_discricionario
  id_pool INT, -- @map <- staging.stg_metricas_grupo_pagto.id_pool
  perc_filial DOUBLE, -- @map <- staging.stg_metricas_grupo_pagto.perc_filial
  valor_pool DECIMAL(28,8), -- @map <- staging.stg_metricas_grupo_pagto.valor_pool
  proportionality_modifier_id INT, -- @map <- staging.stg_metricas_grupo_pagto.proportionality_modifier_id
  apply_cascade_effect INT, -- @map <- staging.stg_metricas_grupo_pagto.apply_cascade_effect
  perc_avaliacao_discricionaria DOUBLE, -- @map <- staging.stg_metricas_grupo_pagto.perc_avaliacao_discricionaria
  PRIMARY KEY (grupo_pagto_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.INDICADOR_TIPOMETA SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_indicador_tipometa
-- @fk: kpi_key -> edw.dim_kpi.kpi_key
CREATE TABLE IF NOT EXISTS edw.dim_indicador_tipometa (
  indicador_tipometa_key BIGINT,
  tenant_slug STRING,
  kpi_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_indicador_tipometa.id
  id_indicador INT, -- @map <- staging.stg_metricas_indicador_tipometa.id_indicador
  tipo_meta INT, -- @map <- staging.stg_metricas_indicador_tipometa.tipo_meta
  PRIMARY KEY (indicador_tipometa_key)
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
-- @note: DIM dbo.NIVEL SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_nivel
-- @fk: grupo_pagto_key -> edw.dim_grupo_pagto.grupo_pagto_key
-- @fk: time_apuracao_key -> edw.dim_time_apuracao.time_apuracao_key
CREATE TABLE IF NOT EXISTS edw.dim_nivel (
  nivel_key BIGINT,
  tenant_slug STRING,
  grupo_pagto_key BIGINT,
  time_apuracao_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_nivel.id
  id_periodo_apuracao INT, -- @map <- staging.stg_metricas_nivel.id_periodo_apuracao
  id_grupo_pagto INT, -- @map <- staging.stg_metricas_nivel.id_grupo_pagto
  cod_nivel STRING, -- @map <- staging.stg_metricas_nivel.cod_nivel
  desc_nivel STRING, -- @map <- staging.stg_metricas_nivel.desc_nivel
  multiplo_salarial DOUBLE, -- @map <- staging.stg_metricas_nivel.multiplo_salarial
  salario DOUBLE, -- @map <- staging.stg_metricas_nivel.salario
  PRIMARY KEY (nivel_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.NormalizationCurvePoint SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_normalizationcurvepoint
-- @fk: time_apuracao_key -> edw.dim_time_apuracao.time_apuracao_key
CREATE TABLE IF NOT EXISTS edw.dim_normalization_curve_point (
  normalization_curve_point_key BIGINT,
  tenant_slug STRING,
  time_apuracao_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_normalizationcurvepoint.id
  performance_score DECIMAL(28,8), -- @map <- staging.stg_metricas_normalizationcurvepoint.performance_score
  evaluation_score DECIMAL(28,8), -- @map <- staging.stg_metricas_normalizationcurvepoint.evaluation_score
  is_reference INT, -- @map <- staging.stg_metricas_normalizationcurvepoint.is_reference
  calculation_period_id INT, -- @map <- staging.stg_metricas_normalizationcurvepoint.calculation_period_id
  PRIMARY KEY (normalization_curve_point_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.Pool SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_pool
-- @fk: upper_pool_pool_key -> edw.dim_pool.pool_key
-- @fk: advance_results_period_time_apuracao_key -> edw.dim_time_apuracao.time_apuracao_key
-- @fk: periodo_apuracao_time_apuracao_key -> edw.dim_time_apuracao.time_apuracao_key
CREATE TABLE IF NOT EXISTS edw.dim_pool (
  pool_key BIGINT,
  tenant_slug STRING,
  upper_pool_pool_key BIGINT,
  advance_results_period_time_apuracao_key BIGINT,
  periodo_apuracao_time_apuracao_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_pool.id
  code STRING, -- @map <- staging.stg_metricas_pool.code
  description STRING, -- @map <- staging.stg_metricas_pool.description
  value DECIMAL(28,8), -- @map <- staging.stg_metricas_pool.value
  periodo_apuracao_id INT, -- @map <- staging.stg_metricas_pool.periodo_apuracao_id
  upper_pool_id INT, -- @map <- staging.stg_metricas_pool.upper_pool_id
  path STRING, -- @map <- staging.stg_metricas_pool.path
  redistribute_pool_by_score INT, -- @map <- staging.stg_metricas_pool.redistribute_pool_by_score
  redistribute_pool_by_calculation_period INT, -- @map <- staging.stg_metricas_pool.redistribute_pool_by_calculation_period
  advance_results_period_id INT, -- @map <- staging.stg_metricas_pool.advance_results_period_id
  PRIMARY KEY (pool_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.RangeDiscretionary SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_rangediscretionary
-- @fk: time_apuracao_key -> edw.dim_time_apuracao.time_apuracao_key
CREATE TABLE IF NOT EXISTS edw.dim_range_discretionary (
  range_discretionary_key BIGINT,
  tenant_slug STRING,
  time_apuracao_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_rangediscretionary.id
  name STRING, -- @map <- staging.stg_metricas_rangediscretionary.name
  minimum_grade DECIMAL(18,2), -- @map <- staging.stg_metricas_rangediscretionary.minimum_grade
  maximum_grade DECIMAL(18,2), -- @map <- staging.stg_metricas_rangediscretionary.maximum_grade
  periodo_apuracao_id INT, -- @map <- staging.stg_metricas_rangediscretionary.periodo_apuracao_id
  PRIMARY KEY (range_discretionary_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.RelUpperGoal SCD1 — grain (tenant_slug, goal_id, upper_goal_id)
-- @origen: staging.stg_metricas_reluppergoal
-- @fk: goal_goal_key -> edw.dim_goal.goal_key
-- @fk: upper_goal_goal_key -> edw.dim_goal.goal_key
CREATE TABLE IF NOT EXISTS edw.dim_rel_upper_goal (
  rel_upper_goal_key BIGINT,
  tenant_slug STRING,
  goal_goal_key BIGINT,
  upper_goal_goal_key BIGINT,
  goal_id INT, -- @map <- staging.stg_metricas_reluppergoal.goal_id
  upper_goal_id INT, -- @map <- staging.stg_metricas_reluppergoal.upper_goal_id
  PRIMARY KEY (rel_upper_goal_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.TERMO_ACEITE SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_termo_aceite
-- @fk: time_gestao_key -> edw.dim_time_gestao.time_gestao_key
CREATE TABLE IF NOT EXISTS edw.dim_termo_aceite (
  termo_aceite_key BIGINT,
  tenant_slug STRING,
  time_gestao_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_termo_aceite.id
  id_periodo_gestao INT, -- @map <- staging.stg_metricas_termo_aceite.id_periodo_gestao
  texto STRING, -- @map <- staging.stg_metricas_termo_aceite.texto
  esconder_percentual INT, -- @map <- staging.stg_metricas_termo_aceite.esconder_percentual
  last_update TIMESTAMP, -- @map <- staging.stg_metricas_termo_aceite.last_update
  agreements_restrictions_to_send STRING, -- @map <- staging.stg_metricas_termo_aceite.agreements_restrictions_to_send
  PRIMARY KEY (termo_aceite_key)
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
-- @note: DIM dbo.Trigger SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_trigger
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: goal_key -> edw.dim_goal.goal_key
-- @fk: area_key -> edw.dim_org_area.area_key
-- @fk: time_apuracao_key -> edw.dim_time_apuracao.time_apuracao_key
CREATE TABLE IF NOT EXISTS edw.dim_trigger (
  trigger_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  goal_key BIGINT,
  area_key BIGINT,
  time_apuracao_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_trigger.id
  code STRING, -- @map <- staging.stg_metricas_trigger.code
  description STRING, -- @map <- staging.stg_metricas_trigger.description
  type INT, -- @map <- staging.stg_metricas_trigger.type
  area_id INT, -- @map <- staging.stg_metricas_trigger.area_id
  employee_id INT, -- @map <- staging.stg_metricas_trigger.employee_id
  goal_id INT, -- @map <- staging.stg_metricas_trigger.goal_id
  periodo_apuracao_id INT, -- @map <- staging.stg_metricas_trigger.periodo_apuracao_id
  PRIMARY KEY (trigger_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.TriggerCurve SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_triggercurve
-- @fk: trigger_key -> edw.dim_trigger.trigger_key
CREATE TABLE IF NOT EXISTS edw.dim_trigger_curve (
  trigger_curve_key BIGINT,
  tenant_slug STRING,
  trigger_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_triggercurve.id
  code STRING, -- @map <- staging.stg_metricas_triggercurve.code
  description STRING, -- @map <- staging.stg_metricas_triggercurve.description
  type INT, -- @map <- staging.stg_metricas_triggercurve.type
  PRIMARY KEY (trigger_curve_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.TriggerCurveItem SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_triggercurveitem
-- @fk: trigger_curve_key -> edw.dim_trigger_curve.trigger_curve_key
CREATE TABLE IF NOT EXISTS edw.dim_trigger_curve_item (
  trigger_curve_item_key BIGINT,
  tenant_slug STRING,
  trigger_curve_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_triggercurveitem.id
  id_curve INT, -- @map <- staging.stg_metricas_triggercurveitem.id_curve
  value DECIMAL(28,8), -- @map <- staging.stg_metricas_triggercurveitem.value
  multiple_factor DECIMAL(28,8), -- @map <- staging.stg_metricas_triggercurveitem.multiple_factor
  PRIMARY KEY (trigger_curve_item_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.YearPersonalGoal SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_yearpersonalgoal
-- @fk: motivations_key -> edw.dim_motivations.motivations_key
CREATE TABLE IF NOT EXISTS edw.dim_year_personal_goal (
  year_personal_goal_key BIGINT,
  tenant_slug STRING,
  motivations_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_yearpersonalgoal.id
  personal_goal STRING, -- @map <- staging.stg_metricas_yearpersonalgoal.personal_goal
  year INT, -- @map <- staging.stg_metricas_yearpersonalgoal.year
  motivations_id INT, -- @map <- staging.stg_metricas_yearpersonalgoal.motivations_id
  PRIMARY KEY (year_personal_goal_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.ADMINISTRADOR_LOCAL_FILIAL SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_organizacao_administrador_local_filial
-- @fk: administrador_local_key -> edw.dim_administrador_local.administrador_local_key
-- @fk: filial_key -> edw.dim_filial.filial_key
CREATE TABLE IF NOT EXISTS edw.dim_administrador_local_filial (
  administrador_local_filial_key BIGINT,
  tenant_slug STRING,
  administrador_local_key BIGINT,
  filial_key BIGINT,
  id INT, -- @map <- staging.stg_organizacao_administrador_local_filial.id
  id_administrador_local INT, -- @map <- staging.stg_organizacao_administrador_local_filial.id_administrador_local
  id_filial INT, -- @map <- staging.stg_organizacao_administrador_local_filial.id_filial
  PRIMARY KEY (administrador_local_filial_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.AREA_FORUM_SUCESSAO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_organizacao_area_forum_sucessao
-- @fk: forum_calibragem_sucessao_key -> edw.dim_forum_calibragem_sucessao.forum_calibragem_sucessao_key
-- @fk: area_key -> edw.dim_org_area.area_key
CREATE TABLE IF NOT EXISTS edw.dim_area_forum_sucessao (
  area_forum_sucessao_key BIGINT,
  tenant_slug STRING,
  forum_calibragem_sucessao_key BIGINT,
  area_key BIGINT,
  id INT, -- @map <- staging.stg_organizacao_area_forum_sucessao.id
  id_area INT, -- @map <- staging.stg_organizacao_area_forum_sucessao.id_area
  id_forum INT, -- @map <- staging.stg_organizacao_area_forum_sucessao.id_forum
  PRIMARY KEY (area_forum_sucessao_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.Company SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_organizacao_company
CREATE TABLE IF NOT EXISTS edw.dim_company (
  company_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_organizacao_company.id
  logo STRING, -- @map <- staging.stg_organizacao_company.logo
  name STRING, -- @map <- staging.stg_organizacao_company.name
  PRIMARY KEY (company_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.CustomGradeFormation SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_organizacao_customgradeformation
-- @fk: grupo_pagto_key -> edw.dim_grupo_pagto.grupo_pagto_key
-- @fk: area_key -> edw.dim_org_area.area_key
CREATE TABLE IF NOT EXISTS edw.dim_custom_grade_formation (
  custom_grade_formation_key BIGINT,
  tenant_slug STRING,
  grupo_pagto_key BIGINT,
  area_key BIGINT,
  id INT, -- @map <- staging.stg_organizacao_customgradeformation.id
  description STRING, -- @map <- staging.stg_organizacao_customgradeformation.description
  percentage DOUBLE, -- @map <- staging.stg_organizacao_customgradeformation.percentage
  area_id INT, -- @map <- staging.stg_organizacao_customgradeformation.area_id
  payment_group_id INT, -- @map <- staging.stg_organizacao_customgradeformation.payment_group_id
  PRIMARY KEY (custom_grade_formation_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.FILIAL SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_organizacao_filial
-- @fk: idioma_key -> edw.ref_idioma.idioma_key
-- @fk: uom_key -> edw.ref_unit_of_measure.uom_key
CREATE TABLE IF NOT EXISTS edw.dim_filial (
  filial_key BIGINT,
  tenant_slug STRING,
  idioma_key BIGINT,
  uom_key BIGINT,
  id INT, -- @map <- staging.stg_organizacao_filial.id
  id_idioma INT, -- @map <- staging.stg_organizacao_filial.id_idioma
  id_moeda INT, -- @map <- staging.stg_organizacao_filial.id_moeda
  cod_filial STRING, -- @map <- staging.stg_organizacao_filial.cod_filial
  desc_filial STRING, -- @map <- staging.stg_organizacao_filial.desc_filial
  PRIMARY KEY (filial_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.GRUPO_CARGO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_organizacao_grupo_cargo
CREATE TABLE IF NOT EXISTS edw.dim_grupo_cargo (
  grupo_cargo_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_organizacao_grupo_cargo.id
  cod_grupo_cargo STRING, -- @map <- staging.stg_organizacao_grupo_cargo.cod_grupo_cargo
  desc_grupo_cargo STRING, -- @map <- staging.stg_organizacao_grupo_cargo.desc_grupo_cargo
  cor STRING, -- @map <- staging.stg_organizacao_grupo_cargo.cor
  PRIMARY KEY (grupo_cargo_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.GRUPO_FUNCIONALIDADE SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_organizacao_grupo_funcionalidade
CREATE TABLE IF NOT EXISTS edw.dim_grupo_funcionalidade (
  grupo_funcionalidade_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_organizacao_grupo_funcionalidade.id
  desc_grupo_funcionalidade STRING, -- @map <- staging.stg_organizacao_grupo_funcionalidade.desc_grupo_funcionalidade
  ordem_exibicao INT, -- @map <- staging.stg_organizacao_grupo_funcionalidade.ordem_exibicao
  id_parent INT, -- @map <- staging.stg_organizacao_grupo_funcionalidade.id_parent
  id_modulo INT, -- @map <- staging.stg_organizacao_grupo_funcionalidade.id_modulo
  icone STRING, -- @map <- staging.stg_organizacao_grupo_funcionalidade.icone
  tag STRING, -- @map <- staging.stg_organizacao_grupo_funcionalidade.tag
  PRIMARY KEY (grupo_funcionalidade_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.GRUPO_USUARIO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_organizacao_grupo_usuario
CREATE TABLE IF NOT EXISTS edw.dim_grupo_usuario (
  grupo_usuario_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_organizacao_grupo_usuario.id
  desc_grupo_usuario STRING, -- @map <- staging.stg_organizacao_grupo_usuario.desc_grupo_usuario
  tipo_usuario INT, -- @map <- staging.stg_organizacao_grupo_usuario.tipo_usuario
  cod_grupo_usuario STRING, -- @map <- staging.stg_organizacao_grupo_usuario.cod_grupo_usuario
  require_two_factor INT, -- @map <- staging.stg_organizacao_grupo_usuario.require_two_factor
  painel_inicial_layout_id INT, -- @map <- staging.stg_organizacao_grupo_usuario.painel_inicial_layout_id
  PRIMARY KEY (grupo_usuario_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.JobPositionCore SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_organizacao_jobpositioncore
CREATE TABLE IF NOT EXISTS edw.dim_job_position_core (
  job_position_core_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_organizacao_jobpositioncore.id
  code STRING, -- @map <- staging.stg_organizacao_jobpositioncore.code
  description STRING, -- @map <- staging.stg_organizacao_jobpositioncore.description
  PRIMARY KEY (job_position_core_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.Locality SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_organizacao_locality
CREATE TABLE IF NOT EXISTS edw.dim_locality (
  locality_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_organizacao_locality.id
  description STRING, -- @map <- staging.stg_organizacao_locality.description
  PRIMARY KEY (locality_key)
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
  job_code STRING,
  job_desc STRING,
  is_critical_job INT,
  PRIMARY KEY (job_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM competences.ACAO_SUGERIDA_PDI SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_pdi_acao_sugerida_pdi
-- @fk: categoria_pdi_acao_key -> edw.dim_categoria_pdi_acao.categoria_pdi_acao_key
-- @fk: competency_key -> edw.dim_competency.competency_key
CREATE TABLE IF NOT EXISTS edw.dim_acao_sugerida_pdi (
  acao_sugerida_pdi_key BIGINT,
  tenant_slug STRING,
  categoria_pdi_acao_key BIGINT,
  competency_key BIGINT,
  id INT, -- @map <- staging.stg_pdi_acao_sugerida_pdi.id
  desc_acao_sugerida STRING, -- @map <- staging.stg_pdi_acao_sugerida_pdi.desc_acao_sugerida
  id_categoria INT, -- @map <- staging.stg_pdi_acao_sugerida_pdi.id_categoria
  ativo INT, -- @map <- staging.stg_pdi_acao_sugerida_pdi.ativo
  id_competencia INT, -- @map <- staging.stg_pdi_acao_sugerida_pdi.id_competencia
  PRIMARY KEY (acao_sugerida_pdi_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.BIBLIOTECA SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_pdi_biblioteca
CREATE TABLE IF NOT EXISTS edw.dim_biblioteca (
  biblioteca_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_pdi_biblioteca.id
  desc_biblioteca STRING, -- @map <- staging.stg_pdi_biblioteca.desc_biblioteca
  PRIMARY KEY (biblioteca_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM competences.CATEGORIA_PDI_ACAO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_pdi_categoria_pdi_acao
CREATE TABLE IF NOT EXISTS edw.dim_categoria_pdi_acao (
  categoria_pdi_acao_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_pdi_categoria_pdi_acao.id
  desc_categoria STRING, -- @map <- staging.stg_pdi_categoria_pdi_acao.desc_categoria
  ativo INT, -- @map <- staging.stg_pdi_categoria_pdi_acao.ativo
  PRIMARY KEY (categoria_pdi_acao_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.SkillCategory SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_pdi_skillcategory
CREATE TABLE IF NOT EXISTS edw.dim_skill_category (
  skill_category_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_pdi_skillcategory.id
  description STRING, -- @map <- staging.stg_pdi_skillcategory.description
  PRIMARY KEY (skill_category_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.SkillKnowledge SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_pdi_skillknowledge
-- @fk: skill_category_key -> edw.dim_skill_category.skill_category_key
CREATE TABLE IF NOT EXISTS edw.dim_skill_knowledge (
  skill_knowledge_key BIGINT,
  tenant_slug STRING,
  skill_category_key BIGINT,
  id INT, -- @map <- staging.stg_pdi_skillknowledge.id
  description STRING, -- @map <- staging.stg_pdi_skillknowledge.description
  skill_category_id INT, -- @map <- staging.stg_pdi_skillknowledge.skill_category_id
  PRIMARY KEY (skill_knowledge_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.Modifier SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_remuneracao_modifier
-- @fk: grupo_pagto_key -> edw.dim_grupo_pagto.grupo_pagto_key
CREATE TABLE IF NOT EXISTS edw.dim_modifier (
  modifier_key BIGINT,
  tenant_slug STRING,
  grupo_pagto_key BIGINT,
  id INT, -- @map <- staging.stg_remuneracao_modifier.id
  code STRING, -- @map <- staging.stg_remuneracao_modifier.code
  description STRING, -- @map <- staging.stg_remuneracao_modifier.description
  applies_to INT, -- @map <- staging.stg_remuneracao_modifier.applies_to
  type INT, -- @map <- staging.stg_remuneracao_modifier.type
  value DECIMAL(28,8), -- @map <- staging.stg_remuneracao_modifier.value
  payment_group_id INT, -- @map <- staging.stg_remuneracao_modifier.payment_group_id
  math_type INT, -- @map <- staging.stg_remuneracao_modifier.math_type
  config STRING, -- @map <- staging.stg_remuneracao_modifier.config
  PRIMARY KEY (modifier_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.ModifierItem SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_remuneracao_modifieritem
-- @fk: modifier_key -> edw.dim_modifier.modifier_key
CREATE TABLE IF NOT EXISTS edw.dim_modifier_item (
  modifier_item_key BIGINT,
  tenant_slug STRING,
  modifier_key BIGINT,
  id INT, -- @map <- staging.stg_remuneracao_modifieritem.id
  id_modifier INT, -- @map <- staging.stg_remuneracao_modifieritem.id_modifier
  conditional DECIMAL(28,8), -- @map <- staging.stg_remuneracao_modifieritem.conditional
  value DECIMAL(28,8), -- @map <- staging.stg_remuneracao_modifieritem.value
  id_external_conditional INT, -- @map <- staging.stg_remuneracao_modifieritem.id_external_conditional
  PRIMARY KEY (modifier_item_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.SimulationRVCache SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_remuneracao_simulationrvcache
CREATE TABLE IF NOT EXISTS edw.dim_simulation_rv_cache (
  simulation_rv_cache_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_remuneracao_simulationrvcache.id
  participant_id INT, -- @map <- staging.stg_remuneracao_simulationrvcache.participant_id
  cache BINARY, -- @map <- staging.stg_remuneracao_simulationrvcache.cache
  date TIMESTAMP, -- @map <- staging.stg_remuneracao_simulationrvcache.date
  last_connection TIMESTAMP, -- @map <- staging.stg_remuneracao_simulationrvcache.last_connection
  PRIMARY KEY (simulation_rv_cache_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.FORUM_CALIBRAGEM_SUCESSAO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_sucessao_forum_calibragem_sucessao
-- @fk: succession_cycle_key -> edw.dim_succession_cycle.succession_cycle_key
CREATE TABLE IF NOT EXISTS edw.dim_forum_calibragem_sucessao (
  forum_calibragem_sucessao_key BIGINT,
  tenant_slug STRING,
  succession_cycle_key BIGINT,
  id INT, -- @map <- staging.stg_sucessao_forum_calibragem_sucessao.id
  id_ciclo_sucessao INT, -- @map <- staging.stg_sucessao_forum_calibragem_sucessao.id_ciclo_sucessao
  descricao STRING, -- @map <- staging.stg_sucessao_forum_calibragem_sucessao.descricao
  data_criacao TIMESTAMP, -- @map <- staging.stg_sucessao_forum_calibragem_sucessao.data_criacao
  data_encerramento TIMESTAMP, -- @map <- staging.stg_sucessao_forum_calibragem_sucessao.data_encerramento
  status INT, -- @map <- staging.stg_sucessao_forum_calibragem_sucessao.status
  PRIMARY KEY (forum_calibragem_sucessao_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.FORUM_QUADRANTE_SUCESSAO_MODELO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_sucessao_forum_quadrante_sucessao_modelo
-- @fk: succession_cycle_key -> edw.dim_succession_cycle.succession_cycle_key
-- @fk: x_axis_classification_key -> edw.dim_x_axis_classification.x_axis_classification_key
-- @fk: y_axis_classification_key -> edw.dim_y_axis_classification.y_axis_classification_key
CREATE TABLE IF NOT EXISTS edw.dim_forum_quadrante_sucessao_modelo (
  forum_quadrante_sucessao_modelo_key BIGINT,
  tenant_slug STRING,
  succession_cycle_key BIGINT,
  x_axis_classification_key BIGINT,
  y_axis_classification_key BIGINT,
  id INT, -- @map <- staging.stg_sucessao_forum_quadrante_sucessao_modelo.id
  id_ciclo_sucessao INT, -- @map <- staging.stg_sucessao_forum_quadrante_sucessao_modelo.id_ciclo_sucessao
  id_classificacao_performance_sucessao INT, -- @map <- staging.stg_sucessao_forum_quadrante_sucessao_modelo.id_classificacao_performance_sucessao
  id_classificacao_potencial INT, -- @map <- staging.stg_sucessao_forum_quadrante_sucessao_modelo.id_classificacao_potencial
  titulo STRING, -- @map <- staging.stg_sucessao_forum_quadrante_sucessao_modelo.titulo
  cor_fundo STRING, -- @map <- staging.stg_sucessao_forum_quadrante_sucessao_modelo.cor_fundo
  cor_titulo STRING, -- @map <- staging.stg_sucessao_forum_quadrante_sucessao_modelo.cor_titulo
  descricao STRING, -- @map <- staging.stg_sucessao_forum_quadrante_sucessao_modelo.descricao
  PRIMARY KEY (forum_quadrante_sucessao_modelo_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.INSTANCIA_SUCESSAO SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_sucessao_instancia_sucessao
-- @fk: forum_calibragem_sucessao_key -> edw.dim_forum_calibragem_sucessao.forum_calibragem_sucessao_key
CREATE TABLE IF NOT EXISTS edw.dim_instancia_sucessao (
  instancia_sucessao_key BIGINT,
  tenant_slug STRING,
  forum_calibragem_sucessao_key BIGINT,
  id INT, -- @map <- staging.stg_sucessao_instancia_sucessao.id
  id_forum_sucessao INT, -- @map <- staging.stg_sucessao_instancia_sucessao.id_forum_sucessao
  descricao STRING, -- @map <- staging.stg_sucessao_instancia_sucessao.descricao
  data_criacao TIMESTAMP, -- @map <- staging.stg_sucessao_instancia_sucessao.data_criacao
  data_inicio_instancia TIMESTAMP, -- @map <- staging.stg_sucessao_instancia_sucessao.data_inicio_instancia
  data_fim_instancia TIMESTAMP, -- @map <- staging.stg_sucessao_instancia_sucessao.data_fim_instancia
  status INT, -- @map <- staging.stg_sucessao_instancia_sucessao.status
  PRIMARY KEY (instancia_sucessao_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.Readiness SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_sucessao_readiness
-- @fk: succession_cycle_key -> edw.dim_succession_cycle.succession_cycle_key
CREATE TABLE IF NOT EXISTS edw.dim_readiness (
  readiness_key BIGINT,
  tenant_slug STRING,
  succession_cycle_key BIGINT,
  id INT, -- @map <- staging.stg_sucessao_readiness.id
  succession_cycle_id INT, -- @map <- staging.stg_sucessao_readiness.succession_cycle_id
  time_slot STRING, -- @map <- staging.stg_sucessao_readiness.time_slot
  order INT, -- @map <- staging.stg_sucessao_readiness.order
  PRIMARY KEY (readiness_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.SuccessionCycle SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_sucessao_successioncycle
CREATE TABLE IF NOT EXISTS edw.dim_succession_cycle (
  succession_cycle_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_sucessao_successioncycle.id
  description STRING, -- @map <- staging.stg_sucessao_successioncycle.description
  start_date TIMESTAMP, -- @map <- staging.stg_sucessao_successioncycle.start_date
  end_date TIMESTAMP, -- @map <- staging.stg_sucessao_successioncycle.end_date
  status INT, -- @map <- staging.stg_sucessao_successioncycle.status
  decimal_precision INT, -- @map <- staging.stg_sucessao_successioncycle.decimal_precision
  is_current_cycle INT, -- @map <- staging.stg_sucessao_successioncycle.is_current_cycle
  flow_type INT, -- @map <- staging.stg_sucessao_successioncycle.flow_type
  has_pendences INT, -- @map <- staging.stg_sucessao_successioncycle.has_pendences
  PRIMARY KEY (succession_cycle_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.SuccessionCycleSettings SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_sucessao_successioncyclesettings
-- @fk: eval_cycle_key -> edw.dim_eval_cycle.eval_cycle_key
-- @fk: succession_cycle_key -> edw.dim_succession_cycle.succession_cycle_key
-- @fk: time_gestao_key -> edw.dim_time_gestao.time_gestao_key
CREATE TABLE IF NOT EXISTS edw.dim_succession_cycle_settings (
  succession_cycle_settings_key BIGINT,
  tenant_slug STRING,
  eval_cycle_key BIGINT,
  succession_cycle_key BIGINT,
  time_gestao_key BIGINT,
  id INT, -- @map <- staging.stg_sucessao_successioncyclesettings.id
  score_achievement_via_import INT, -- @map <- staging.stg_sucessao_successioncyclesettings.score_achievement_via_import
  x_axis_description STRING, -- @map <- staging.stg_sucessao_successioncyclesettings.x_axis_description
  y_axis_description STRING, -- @map <- staging.stg_sucessao_successioncyclesettings.y_axis_description
  score_competence_via_import INT, -- @map <- staging.stg_sucessao_successioncyclesettings.score_competence_via_import
  score_performance_via_import INT, -- @map <- staging.stg_sucessao_successioncyclesettings.score_performance_via_import
  evaluation_cycle_id INT, -- @map <- staging.stg_sucessao_successioncyclesettings.evaluation_cycle_id
  management_cycle_id INT, -- @map <- staging.stg_sucessao_successioncyclesettings.management_cycle_id
  month_to INT, -- @map <- staging.stg_sucessao_successioncyclesettings.month_to
  percentage_performance_score DECIMAL(28,8), -- @map <- staging.stg_sucessao_successioncyclesettings.percentage_performance_score
  percentage_competence_score DECIMAL(28,8), -- @map <- staging.stg_sucessao_successioncyclesettings.percentage_competence_score
  succession_cycle_id INT, -- @map <- staging.stg_sucessao_successioncyclesettings.succession_cycle_id
  hide_numerical_scores INT, -- @map <- staging.stg_sucessao_successioncyclesettings.hide_numerical_scores
  enable_deliberations_employee INT, -- @map <- staging.stg_sucessao_successioncyclesettings.enable_deliberations_employee
  deliberation_option_id INT, -- @map <- staging.stg_sucessao_successioncyclesettings.deliberation_option_id
  percentage_potential_score DECIMAL(28,8), -- @map <- staging.stg_sucessao_successioncyclesettings.percentage_potential_score
  x_axis_composition INT, -- @map <- staging.stg_sucessao_successioncyclesettings.x_axis_composition
  y_axis_composition INT, -- @map <- staging.stg_sucessao_successioncyclesettings.y_axis_composition
  show_button_to_open_form_competence INT, -- @map <- staging.stg_sucessao_successioncyclesettings.show_button_to_open_form_competence
  hide_potential_block INT, -- @map <- staging.stg_sucessao_successioncyclesettings.hide_potential_block
  hide_risk_block INT, -- @map <- staging.stg_sucessao_successioncyclesettings.hide_risk_block
  hide_performance_block INT, -- @map <- staging.stg_sucessao_successioncyclesettings.hide_performance_block
  enable_successor_selection INT, -- @map <- staging.stg_sucessao_successioncyclesettings.enable_successor_selection
  enable_vertical_successor_moves INT, -- @map <- staging.stg_sucessao_successioncyclesettings.enable_vertical_successor_moves
  enable_horizontal_succesor_moves INT, -- @map <- staging.stg_sucessao_successioncyclesettings.enable_horizontal_succesor_moves
  minimum_vertical_successors INT, -- @map <- staging.stg_sucessao_successioncyclesettings.minimum_vertical_successors
  maximum_vertical_successors INT, -- @map <- staging.stg_sucessao_successioncyclesettings.maximum_vertical_successors
  minimum_horizontal_successors INT, -- @map <- staging.stg_sucessao_successioncyclesettings.minimum_horizontal_successors
  maximum_horizontal_successors INT, -- @map <- staging.stg_sucessao_successioncyclesettings.maximum_horizontal_successors
  comentario_quantitativo_obrigatorio INT, -- @map <- staging.stg_sucessao_successioncyclesettings.comentario_quantitativo_obrigatorio
  comentario_qualitativo_obrigatorio INT, -- @map <- staging.stg_sucessao_successioncyclesettings.comentario_qualitativo_obrigatorio
  comentario_selecao_obrigatorio INT, -- @map <- staging.stg_sucessao_successioncyclesettings.comentario_selecao_obrigatorio
  hide_impact_block INT, -- @map <- staging.stg_sucessao_successioncyclesettings.hide_impact_block
  enable_classification_calibration_at_evaluation INT, -- @map <- staging.stg_sucessao_successioncyclesettings.enable_classification_calibration_at_evaluation
  enable_job_position_successor INT, -- @map <- staging.stg_sucessao_successioncyclesettings.enable_job_position_successor
  hide_potential_summary INT, -- @map <- staging.stg_sucessao_successioncyclesettings.hide_potential_summary
  PRIMARY KEY (succession_cycle_settings_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.SuccessionResults SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_sucessao_successionresults
-- @fk: avaliado_sucessao_key -> edw.dim_avaliado_sucessao.avaliado_sucessao_key
-- @fk: final_score_x_axis_classification_calib_x_axis_classification_key -> edw.dim_x_axis_classification.x_axis_classification_key
-- @fk: final_score_x_axis_classification_x_axis_classification_key -> edw.dim_x_axis_classification.x_axis_classification_key
-- @fk: final_score_y_axis_classification_calib_y_axis_classification_key -> edw.dim_y_axis_classification.y_axis_classification_key
-- @fk: final_score_y_axis_classification_y_axis_classification_key -> edw.dim_y_axis_classification.y_axis_classification_key
CREATE TABLE IF NOT EXISTS edw.dim_succession_results (
  succession_results_key BIGINT,
  tenant_slug STRING,
  avaliado_sucessao_key BIGINT,
  final_score_x_axis_classification_calib_x_axis_classification_key BIGINT,
  final_score_x_axis_classification_x_axis_classification_key BIGINT,
  final_score_y_axis_classification_calib_y_axis_classification_key BIGINT,
  final_score_y_axis_classification_y_axis_classification_key BIGINT,
  id INT, -- @map <- staging.stg_sucessao_successionresults.id
  evaluated_succession_id INT, -- @map <- staging.stg_sucessao_successionresults.evaluated_succession_id
  final_score_x_axis DECIMAL(28,8), -- @map <- staging.stg_sucessao_successionresults.final_score_x_axis
  final_score_y_axis DECIMAL(28,8), -- @map <- staging.stg_sucessao_successionresults.final_score_y_axis
  final_score_x_axis_classification_id INT, -- @map <- staging.stg_sucessao_successionresults.final_score_x_axis_classification_id
  final_score_x_axis_classification_calib_id INT, -- @map <- staging.stg_sucessao_successionresults.final_score_x_axis_classification_calib_id
  final_score_y_axis_classification_id INT, -- @map <- staging.stg_sucessao_successionresults.final_score_y_axis_classification_id
  final_score_y_axis_classification_calib_id INT, -- @map <- staging.stg_sucessao_successionresults.final_score_y_axis_classification_calib_id
  final_score_competence DECIMAL(28,8), -- @map <- staging.stg_sucessao_successionresults.final_score_competence
  final_score_performance DECIMAL(28,8), -- @map <- staging.stg_sucessao_successionresults.final_score_performance
  final_score_potential DECIMAL(28,8), -- @map <- staging.stg_sucessao_successionresults.final_score_potential
  data_source_competence_score INT, -- @map <- staging.stg_sucessao_successionresults.data_source_competence_score
  data_source_performance_score INT, -- @map <- staging.stg_sucessao_successionresults.data_source_performance_score
  data_source_potential_score INT, -- @map <- staging.stg_sucessao_successionresults.data_source_potential_score
  final_score_risk DECIMAL(28,8), -- @map <- staging.stg_sucessao_successionresults.final_score_risk
  final_score_impact DECIMAL(28,8), -- @map <- staging.stg_sucessao_successionresults.final_score_impact
  final_score_risk_calib_id INT, -- @map <- staging.stg_sucessao_successionresults.final_score_risk_calib_id
  final_score_impact_calib_id INT, -- @map <- staging.stg_sucessao_successionresults.final_score_impact_calib_id
  competence_sync_date TIMESTAMP, -- @map <- staging.stg_sucessao_successionresults.competence_sync_date
  PRIMARY KEY (succession_results_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.XAxisClassification SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_sucessao_xaxisclassification
-- @fk: succession_cycle_key -> edw.dim_succession_cycle.succession_cycle_key
CREATE TABLE IF NOT EXISTS edw.dim_x_axis_classification (
  x_axis_classification_key BIGINT,
  tenant_slug STRING,
  succession_cycle_key BIGINT,
  id INT, -- @map <- staging.stg_sucessao_xaxisclassification.id
  id_succession_cycle INT, -- @map <- staging.stg_sucessao_xaxisclassification.id_succession_cycle
  description STRING, -- @map <- staging.stg_sucessao_xaxisclassification.description
  score_from DOUBLE, -- @map <- staging.stg_sucessao_xaxisclassification.score_from
  score_to DOUBLE, -- @map <- staging.stg_sucessao_xaxisclassification.score_to
  expected_curve DOUBLE, -- @map <- staging.stg_sucessao_xaxisclassification.expected_curve
  merge_with INT, -- @map <- staging.stg_sucessao_xaxisclassification.merge_with
  PRIMARY KEY (x_axis_classification_key)
) USING DELTA;

-- @layer: edw
-- @group: dimensional
-- @note: DIM dbo.YAxisClassification SCD1 — grain (tenant_slug, id)
-- @origen: staging.stg_sucessao_yaxisclassification
-- @fk: succession_cycle_key -> edw.dim_succession_cycle.succession_cycle_key
CREATE TABLE IF NOT EXISTS edw.dim_y_axis_classification (
  y_axis_classification_key BIGINT,
  tenant_slug STRING,
  succession_cycle_key BIGINT,
  id INT, -- @map <- staging.stg_sucessao_yaxisclassification.id
  id_succession_cycle INT, -- @map <- staging.stg_sucessao_yaxisclassification.id_succession_cycle
  description STRING, -- @map <- staging.stg_sucessao_yaxisclassification.description
  score_from DECIMAL(28,8), -- @map <- staging.stg_sucessao_yaxisclassification.score_from
  score_to DECIMAL(28,8), -- @map <- staging.stg_sucessao_yaxisclassification.score_to
  expected_curve DECIMAL(28,8), -- @map <- staging.stg_sucessao_yaxisclassification.expected_curve
  merge_with INT, -- @map <- staging.stg_sucessao_yaxisclassification.merge_with
  PRIMARY KEY (y_axis_classification_key)
) USING DELTA;

-- @layer: edw
-- @group: ref
-- @note: REF dbo.CustomerBoundTranslateTag — grain (tenant_slug, id)
-- @origen: staging.stg_referencia_customerboundtranslatetag
-- @fk: translate_tag_culture_key -> edw.ref_translate_tag_culture.translate_tag_culture_key
-- @fk: translate_tag_handle_key -> edw.ref_translate_tag_handle.translate_tag_handle_key
CREATE TABLE IF NOT EXISTS edw.ref_customer_bound_translate_tag (
  customer_bound_translate_tag_key BIGINT,
  tenant_slug STRING,
  translate_tag_culture_key BIGINT,
  translate_tag_handle_key BIGINT,
  id INT, -- @map <- staging.stg_referencia_customerboundtranslatetag.id
  contents STRING, -- @map <- staging.stg_referencia_customerboundtranslatetag.contents
  culture_id INT, -- @map <- staging.stg_referencia_customerboundtranslatetag.culture_id
  handle_id INT, -- @map <- staging.stg_referencia_customerboundtranslatetag.handle_id
  PRIMARY KEY (customer_bound_translate_tag_key)
) USING DELTA;

-- @layer: edw
-- @group: ref
-- @note: REF dbo.GRANDEZA — grain (tenant_slug, id)
-- @origen: staging.stg_referencia_grandeza
CREATE TABLE IF NOT EXISTS edw.ref_grandeza (
  grandeza_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_referencia_grandeza.id
  desc_grandeza STRING, -- @map <- staging.stg_referencia_grandeza.desc_grandeza
  tipo_conversao INT, -- @map <- staging.stg_referencia_grandeza.tipo_conversao
  PRIMARY KEY (grandeza_key)
) USING DELTA;

-- @layer: edw
-- @group: ref
-- @note: REF dbo.IDIOMA — grain (tenant_slug, id)
-- @origen: staging.stg_referencia_idioma
CREATE TABLE IF NOT EXISTS edw.ref_idioma (
  idioma_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_referencia_idioma.id
  desc_idioma STRING, -- @map <- staging.stg_referencia_idioma.desc_idioma
  idiomatic_description STRING, -- @map <- staging.stg_referencia_idioma.idiomatic_description
  locale STRING, -- @map <- staging.stg_referencia_idioma.locale
  sort_order INT, -- @map <- staging.stg_referencia_idioma.sort_order
  is_active INT, -- @map <- staging.stg_referencia_idioma.is_active
  PRIMARY KEY (idioma_key)
) USING DELTA;

-- @layer: edw
-- @group: ref
-- @note: REF dbo.MAIL_CONFIG — grain (tenant_slug, id)
-- @origen: staging.stg_referencia_mail_config
CREATE TABLE IF NOT EXISTS edw.ref_mail_config (
  mail_config_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_referencia_mail_config.id
  tipo_envio INT, -- @map <- staging.stg_referencia_mail_config.tipo_envio
  desc_tipo_envio STRING, -- @map <- staging.stg_referencia_mail_config.desc_tipo_envio
  ativo INT, -- @map <- staging.stg_referencia_mail_config.ativo
  parametro STRING, -- @map <- staging.stg_referencia_mail_config.parametro
  id_modulo INT, -- @map <- staging.stg_referencia_mail_config.id_modulo
  PRIMARY KEY (mail_config_key)
) USING DELTA;

-- @layer: edw
-- @group: ref
-- @note: REF dbo.PLUGIN_INFO — grain (tenant_slug, plugin_code)
-- @origen: staging.stg_referencia_plugin_info
CREATE TABLE IF NOT EXISTS edw.ref_plugin_info (
  plugin_info_key BIGINT,
  tenant_slug STRING,
  plugin_code STRING, -- @map <- staging.stg_referencia_plugin_info.plugin_code
  assembly_name STRING, -- @map <- staging.stg_referencia_plugin_info.assembly_name
  class_name STRING, -- @map <- staging.stg_referencia_plugin_info.class_name
  method_name STRING, -- @map <- staging.stg_referencia_plugin_info.method_name
  plugin_description STRING, -- @map <- staging.stg_referencia_plugin_info.plugin_description
  PRIMARY KEY (plugin_info_key)
) USING DELTA;

-- @layer: edw
-- @group: ref
-- @note: REF dbo.SYSTEM_CONFIG — grain (tenant_slug)
-- @origen: staging.stg_referencia_system_config
CREATE TABLE IF NOT EXISTS edw.ref_system_config (
  system_config_key BIGINT,
  tenant_slug STRING,
  client_name STRING, -- @map <- staging.stg_referencia_system_config.client_name
  client_url STRING, -- @map <- staging.stg_referencia_system_config.client_url
  system_version STRING, -- @map <- staging.stg_referencia_system_config.system_version
  psw_try INT, -- @map <- staging.stg_referencia_system_config.psw_try
  psw_upper INT, -- @map <- staging.stg_referencia_system_config.psw_upper
  psw_lower INT, -- @map <- staging.stg_referencia_system_config.psw_lower
  psw_number INT, -- @map <- staging.stg_referencia_system_config.psw_number
  psw_especial_char INT, -- @map <- staging.stg_referencia_system_config.psw_especial_char
  psw_min_length INT, -- @map <- staging.stg_referencia_system_config.psw_min_length
  psw_days INT, -- @map <- staging.stg_referencia_system_config.psw_days
  psw_reusable INT, -- @map <- staging.stg_referencia_system_config.psw_reusable
  limit_tree_area INT, -- @map <- staging.stg_referencia_system_config.limit_tree_area
  limit_tree_entidade INT, -- @map <- staging.stg_referencia_system_config.limit_tree_entidade
  limit_tree_grupo_conta INT, -- @map <- staging.stg_referencia_system_config.limit_tree_grupo_conta
  main_page STRING, -- @map <- staging.stg_referencia_system_config.main_page
  tipo_cotacao INT, -- @map <- staging.stg_referencia_system_config.tipo_cotacao
  forecast1_label STRING, -- @map <- staging.stg_referencia_system_config.forecast1_label
  forecast2_label STRING, -- @map <- staging.stg_referencia_system_config.forecast2_label
  access_group_admin_management INT, -- @map <- staging.stg_referencia_system_config.access_group_admin_management
  id INT, -- @map <- staging.stg_referencia_system_config.id
  client_options STRING, -- @map <- staging.stg_referencia_system_config.client_options
  PRIMARY KEY (system_config_key)
) USING DELTA;

-- @layer: edw
-- @group: ref
-- @note: REF dbo.TipoAcumulacao — grain (tenant_slug, id)
-- @origen: staging.stg_referencia_tipoacumulacao
CREATE TABLE IF NOT EXISTS edw.ref_tipo_acumulacao (
  tipo_acumulacao_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_referencia_tipoacumulacao.id
  nome STRING, -- @map <- staging.stg_referencia_tipoacumulacao.nome
  PRIMARY KEY (tipo_acumulacao_key)
) USING DELTA;

-- @layer: edw
-- @group: ref
-- @note: REF dbo.TranslateTagCulture — grain (tenant_slug, id)
-- @origen: staging.stg_referencia_translatetagculture
CREATE TABLE IF NOT EXISTS edw.ref_translate_tag_culture (
  translate_tag_culture_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_referencia_translatetagculture.id
  name STRING, -- @map <- staging.stg_referencia_translatetagculture.name
  PRIMARY KEY (translate_tag_culture_key)
) USING DELTA;

-- @layer: edw
-- @group: ref
-- @note: REF dbo.TranslateTagHandle — grain (tenant_slug, id)
-- @origen: staging.stg_referencia_translatetaghandle
CREATE TABLE IF NOT EXISTS edw.ref_translate_tag_handle (
  translate_tag_handle_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_referencia_translatetaghandle.id
  name STRING, -- @map <- staging.stg_referencia_translatetaghandle.name
  PRIMARY KEY (translate_tag_handle_key)
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
-- @group: ref
-- @note: REF dbo.VERSAO — grain (tenant_slug, num_versao)
-- @origen: staging.stg_referencia_versao
CREATE TABLE IF NOT EXISTS edw.ref_versao (
  versao_key BIGINT,
  tenant_slug STRING,
  num_versao STRING, -- @map <- staging.stg_referencia_versao.num_versao
  dt_versao TIMESTAMP, -- @map <- staging.stg_referencia_versao.dt_versao
  texto_pt_br STRING, -- @map <- staging.stg_referencia_versao.texto_pt_br
  texto_en_us STRING, -- @map <- staging.stg_referencia_versao.texto_en_us
  texto_de_de STRING, -- @map <- staging.stg_referencia_versao.texto_de_de
  texto_es_es STRING, -- @map <- staging.stg_referencia_versao.texto_es_es
  texto_fr_fr STRING, -- @map <- staging.stg_referencia_versao.texto_fr_fr
  texto_zn_cn STRING, -- @map <- staging.stg_referencia_versao.texto_zn_cn
  PRIMARY KEY (versao_key)
) USING DELTA;

-- @layer: edw
-- @group: bridge
-- @note: BRIDGE dbo.FORMULARIO_FEEDBACK_ABA_ITEM — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_formulario_feedback_aba_item
-- @fk: formulario_feedback_aba_key -> edw.dim_formulario_feedback_aba.formulario_feedback_aba_key
CREATE TABLE IF NOT EXISTS edw.brg_formulario_feedback_aba_item (
  formulario_feedback_aba_item_key BIGINT,
  tenant_slug STRING,
  formulario_feedback_aba_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_formulario_feedback_aba_item.id
  id_formulario_feedback_aba INT, -- @map <- staging.stg_avaliacao_formulario_feedback_aba_item.id_formulario_feedback_aba
  tipo_conteudo INT, -- @map <- staging.stg_avaliacao_formulario_feedback_aba_item.tipo_conteudo
  PRIMARY KEY (formulario_feedback_aba_item_key)
) USING DELTA;

-- @layer: edw
-- @group: bridge
-- @note: BRIDGE competences.COLABORADOR_FUNCAO — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_colaborador_funcao
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: eval_cycle_key -> edw.dim_eval_cycle.eval_cycle_key
-- @fk: funcao_key -> edw.dim_funcao.funcao_key
CREATE TABLE IF NOT EXISTS edw.brg_colaborador_funcao (
  colaborador_funcao_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  eval_cycle_key BIGINT,
  funcao_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_colaborador_funcao.id
  id_colaborador INT, -- @map <- staging.stg_colaborador_colaborador_funcao.id_colaborador
  id_funcao INT, -- @map <- staging.stg_colaborador_colaborador_funcao.id_funcao
  dt_ini TIMESTAMP, -- @map <- staging.stg_colaborador_colaborador_funcao.dt_ini
  dt_fim TIMESTAMP, -- @map <- staging.stg_colaborador_colaborador_funcao.dt_fim
  funcao_atual INT, -- @map <- staging.stg_colaborador_colaborador_funcao.funcao_atual
  id_avaliacao INT, -- @map <- staging.stg_colaborador_colaborador_funcao.id_avaliacao
  PRIMARY KEY (colaborador_funcao_key)
) USING DELTA;

-- @layer: edw
-- @group: bridge
-- @note: BRIDGE dbo.FORUM_PARTICIPANTE_SUCESSAO — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_forum_participante_sucessao
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: forum_calibragem_sucessao_key -> edw.dim_forum_calibragem_sucessao.forum_calibragem_sucessao_key
CREATE TABLE IF NOT EXISTS edw.brg_forum_participante_sucessao (
  forum_participante_sucessao_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  forum_calibragem_sucessao_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_forum_participante_sucessao.id
  id_forum_sucessao INT, -- @map <- staging.stg_colaborador_forum_participante_sucessao.id_forum_sucessao
  id_colaborador INT, -- @map <- staging.stg_colaborador_forum_participante_sucessao.id_colaborador
  PRIMARY KEY (forum_participante_sucessao_key)
) USING DELTA;

-- @layer: edw
-- @group: bridge
-- @note: BRIDGE dbo.HISTORICO_COLABORADOR_AREA — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_historico_colaborador_area
CREATE TABLE IF NOT EXISTS edw.brg_historico_area (
  historico_area_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_colaborador_historico_colaborador_area.id
  id_colaborador INT, -- @map <- staging.stg_colaborador_historico_colaborador_area.id_colaborador
  id_area INT, -- @map <- staging.stg_colaborador_historico_colaborador_area.id_area
  dt_upd TIMESTAMP, -- @map <- staging.stg_colaborador_historico_colaborador_area.dt_upd
  score DECIMAL(28,8), -- @map <- staging.stg_colaborador_historico_colaborador_area.score
  dt_fim TIMESTAMP, -- @map <- staging.stg_colaborador_historico_colaborador_area.dt_fim
  PRIMARY KEY (historico_area_key)
) USING DELTA;

-- @layer: edw
-- @group: bridge
-- @note: BRIDGE dbo.INSTANCIA_PARTICIPANTE_SUCESSAO — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_instancia_participante_sucessao
-- @fk: avaliado_sucessao_key -> edw.dim_avaliado_sucessao.avaliado_sucessao_key
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: quadrante_sucessao_de_forum_quadrante_sucessao_modelo_key -> edw.dim_forum_quadrante_sucessao_modelo.forum_quadrante_sucessao_modelo_key
-- @fk: quadrante_sucessao_para_forum_quadrante_sucessao_modelo_key -> edw.dim_forum_quadrante_sucessao_modelo.forum_quadrante_sucessao_modelo_key
-- @fk: instancia_sucessao_key -> edw.dim_instancia_sucessao.instancia_sucessao_key
CREATE TABLE IF NOT EXISTS edw.brg_instancia_participante_sucessao (
  instancia_participante_sucessao_key BIGINT,
  tenant_slug STRING,
  avaliado_sucessao_key BIGINT,
  employee_key BIGINT,
  quadrante_sucessao_de_forum_quadrante_sucessao_modelo_key BIGINT,
  quadrante_sucessao_para_forum_quadrante_sucessao_modelo_key BIGINT,
  instancia_sucessao_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_instancia_participante_sucessao.id
  id_instancia_sucessao INT, -- @map <- staging.stg_colaborador_instancia_participante_sucessao.id_instancia_sucessao
  id_avaliado_sucessao INT, -- @map <- staging.stg_colaborador_instancia_participante_sucessao.id_avaliado_sucessao
  id_quadrante_sucessao_de INT, -- @map <- staging.stg_colaborador_instancia_participante_sucessao.id_quadrante_sucessao_de
  id_quadrante_sucessao_para INT, -- @map <- staging.stg_colaborador_instancia_participante_sucessao.id_quadrante_sucessao_para
  justificativa_desempenho STRING, -- @map <- staging.stg_colaborador_instancia_participante_sucessao.justificativa_desempenho
  justificativa_potencial STRING, -- @map <- staging.stg_colaborador_instancia_participante_sucessao.justificativa_potencial
  desempenho_participante_calibrado INT, -- @map <- staging.stg_colaborador_instancia_participante_sucessao.desempenho_participante_calibrado
  potencial_participante_calibrado INT, -- @map <- staging.stg_colaborador_instancia_participante_sucessao.potencial_participante_calibrado
  dt_alteracao TIMESTAMP, -- @map <- staging.stg_colaborador_instancia_participante_sucessao.dt_alteracao
  id_colaborador_resposavel_alteracao INT, -- @map <- staging.stg_colaborador_instancia_participante_sucessao.id_colaborador_resposavel_alteracao
  ativo INT, -- @map <- staging.stg_colaborador_instancia_participante_sucessao.ativo
  id_parent INT, -- @map <- staging.stg_colaborador_instancia_participante_sucessao.id_parent
  PRIMARY KEY (instancia_participante_sucessao_key)
) USING DELTA;

-- @layer: edw
-- @group: bridge
-- @note: BRIDGE dbo.PSW_COLABORADOR_ITEM — grain (tenant_slug)
-- @origen: staging.stg_colaborador_psw_colaborador_item
CREATE TABLE IF NOT EXISTS edw.brg_psw_colaborador_item (
  psw_colaborador_item_key BIGINT,
  tenant_slug STRING,
  id_colaborador INT, -- @map <- staging.stg_colaborador_psw_colaborador_item.id_colaborador
  create_date TIMESTAMP, -- @map <- staging.stg_colaborador_psw_colaborador_item.create_date
  psw STRING, -- @map <- staging.stg_colaborador_psw_colaborador_item.psw
  private_current_psw BINARY, -- @map <- staging.stg_colaborador_psw_colaborador_item.private_current_psw
  PRIMARY KEY (psw_colaborador_item_key)
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
-- @group: bridge
-- @note: BRIDGE dbo.FAIXA_FAROL_ITEM — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_faixa_farol_item
-- @fk: faixa_farol_key -> edw.dim_faixa_farol.faixa_farol_key
-- @fk: farol_key -> edw.dim_farol.farol_key
CREATE TABLE IF NOT EXISTS edw.brg_faixa_farol_item (
  faixa_farol_item_key BIGINT,
  tenant_slug STRING,
  faixa_farol_key BIGINT,
  farol_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_faixa_farol_item.id
  id_faixa_farol INT, -- @map <- staging.stg_metricas_faixa_farol_item.id_faixa_farol
  id_farol INT, -- @map <- staging.stg_metricas_faixa_farol_item.id_farol
  operador_mim INT, -- @map <- staging.stg_metricas_faixa_farol_item.operador_mim
  valor_min DOUBLE, -- @map <- staging.stg_metricas_faixa_farol_item.valor_min
  operador_max INT, -- @map <- staging.stg_metricas_faixa_farol_item.operador_max
  valor_max DOUBLE, -- @map <- staging.stg_metricas_faixa_farol_item.valor_max
  habilitado INT, -- @map <- staging.stg_metricas_faixa_farol_item.habilitado
  PRIMARY KEY (faixa_farol_item_key)
) USING DELTA;

-- @layer: edw
-- @group: bridge
-- @note: BRIDGE dbo.PERFIL_AREA — grain (tenant_slug, id)
-- @origen: staging.stg_organizacao_perfil_area
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: area_key -> edw.dim_org_area.area_key
CREATE TABLE IF NOT EXISTS edw.brg_perfil_area (
  perfil_area_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  area_key BIGINT,
  id INT, -- @map <- staging.stg_organizacao_perfil_area.id
  id_colaborador INT, -- @map <- staging.stg_organizacao_perfil_area.id_colaborador
  id_area INT, -- @map <- staging.stg_organizacao_perfil_area.id_area
  visualizar INT, -- @map <- staging.stg_organizacao_perfil_area.visualizar
  PRIMARY KEY (perfil_area_key)
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

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.ActionBase — grain (tenant_slug, id)
-- @origen: staging.stg_acao_actionbase
-- @fk: accepted_by_employee_key -> edw.dim_employee.employee_key
-- @fk: creator_employee_key -> edw.dim_employee.employee_key
-- @fk: denied_by_employee_key -> edw.dim_employee.employee_key
-- @fk: responsible_employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.fact_action_base (
  action_base_key BIGINT,
  tenant_slug STRING,
  accepted_by_employee_key BIGINT,
  creator_employee_key BIGINT,
  denied_by_employee_key BIGINT,
  responsible_employee_key BIGINT,
  id INT, -- @map <- staging.stg_acao_actionbase.id
  creator_id INT, -- @map <- staging.stg_acao_actionbase.creator_id
  responsible_id INT, -- @map <- staging.stg_acao_actionbase.responsible_id
  creation_time TIMESTAMP, -- @map <- staging.stg_acao_actionbase.creation_time
  last_modification_time TIMESTAMP, -- @map <- staging.stg_acao_actionbase.last_modification_time
  workflow_step INT, -- @map <- staging.stg_acao_actionbase.workflow_step
  status INT, -- @map <- staging.stg_acao_actionbase.status
  code STRING, -- @map <- staging.stg_acao_actionbase.code
  description STRING, -- @map <- staging.stg_acao_actionbase.description
  how STRING, -- @map <- staging.stg_acao_actionbase.how
  where STRING, -- @map <- staging.stg_acao_actionbase.where
  why STRING, -- @map <- staging.stg_acao_actionbase.why
  cancellation_justification STRING, -- @map <- staging.stg_acao_actionbase.cancellation_justification
  deny_justification STRING, -- @map <- staging.stg_acao_actionbase.deny_justification
  observation STRING, -- @map <- staging.stg_acao_actionbase.observation
  planned_start_date TIMESTAMP, -- @map <- staging.stg_acao_actionbase.planned_start_date
  planned_end_date TIMESTAMP, -- @map <- staging.stg_acao_actionbase.planned_end_date
  actual_start_date TIMESTAMP, -- @map <- staging.stg_acao_actionbase.actual_start_date
  actual_end_date TIMESTAMP, -- @map <- staging.stg_acao_actionbase.actual_end_date
  actual_percentage DECIMAL(18,2), -- @map <- staging.stg_acao_actionbase.actual_percentage
  module_id INT, -- @map <- staging.stg_acao_actionbase.module_id
  action_type INT, -- @map <- staging.stg_acao_actionbase.action_type
  days_in_advance INT, -- @map <- staging.stg_acao_actionbase.days_in_advance
  email_notification_enabled INT, -- @map <- staging.stg_acao_actionbase.email_notification_enabled
  investment DECIMAL(18,2), -- @map <- staging.stg_acao_actionbase.investment
  return DECIMAL(18,2), -- @map <- staging.stg_acao_actionbase.return
  denied_by_id INT, -- @map <- staging.stg_acao_actionbase.denied_by_id
  accepted_by_id INT, -- @map <- staging.stg_acao_actionbase.accepted_by_id
  PRIMARY KEY (action_base_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.ANEXO_ACAO — grain (tenant_slug, id)
-- @origen: staging.stg_acao_anexo_acao
CREATE TABLE IF NOT EXISTS edw.fact_anexo_acao (
  anexo_acao_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_acao_anexo_acao.id
  id_acao INT, -- @map <- staging.stg_acao_anexo_acao.id_acao
  id_uploader INT, -- @map <- staging.stg_acao_anexo_acao.id_uploader
  nome_arquivo STRING, -- @map <- staging.stg_acao_anexo_acao.nome_arquivo
  arquivo BINARY, -- @map <- staging.stg_acao_anexo_acao.arquivo
  dt_envio TIMESTAMP, -- @map <- staging.stg_acao_anexo_acao.dt_envio
  PRIMARY KEY (anexo_acao_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.CONTRAMEDIDA — grain (tenant_slug, id)
-- @origen: staging.stg_acao_contramedida
-- @fk: goal_key -> edw.dim_goal.goal_key
CREATE TABLE IF NOT EXISTS edw.fact_contramedida (
  contramedida_key BIGINT,
  tenant_slug STRING,
  goal_key BIGINT,
  id INT, -- @map <- staging.stg_acao_contramedida.id
  id_meta INT, -- @map <- staging.stg_acao_contramedida.id_meta
  dt_criacao TIMESTAMP, -- @map <- staging.stg_acao_contramedida.dt_criacao
  dt_ref TIMESTAMP, -- @map <- staging.stg_acao_contramedida.dt_ref
  is_reference INT, -- @map <- staging.stg_acao_contramedida.is_reference
  PRIMARY KEY (contramedida_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.HISTORICO_PERC_REALIZADO — grain (tenant_slug, id)
-- @origen: staging.stg_acao_historico_perc_realizado
CREATE TABLE IF NOT EXISTS edw.fact_historico_perc_realizado (
  historico_perc_realizado_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_acao_historico_perc_realizado.id
  id_acao INT, -- @map <- staging.stg_acao_historico_perc_realizado.id_acao
  perc_realizado DOUBLE, -- @map <- staging.stg_acao_historico_perc_realizado.perc_realizado
  dt_upd TIMESTAMP, -- @map <- staging.stg_acao_historico_perc_realizado.dt_upd
  PRIMARY KEY (historico_perc_realizado_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.HISTORICO_WORKFLOW_ACAO — grain (tenant_slug, id)
-- @origen: staging.stg_acao_historico_workflow_acao
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.fact_historico_workflow_acao (
  historico_workflow_acao_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_acao_historico_workflow_acao.id
  id_acao INT, -- @map <- staging.stg_acao_historico_workflow_acao.id_acao
  id_responsavel_acao INT, -- @map <- staging.stg_acao_historico_workflow_acao.id_responsavel_acao
  dt_workflow TIMESTAMP, -- @map <- staging.stg_acao_historico_workflow_acao.dt_workflow
  status_aprovacao INT, -- @map <- staging.stg_acao_historico_workflow_acao.status_aprovacao
  PRIMARY KEY (historico_workflow_acao_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.LabelAction — grain (tenant_slug, id_label, id_action)
-- @origen: staging.stg_acao_labelaction
CREATE TABLE IF NOT EXISTS edw.fact_label_action (
  label_action_key BIGINT,
  tenant_slug STRING,
  id_label INT, -- @map <- staging.stg_acao_labelaction.id_label
  id_action INT, -- @map <- staging.stg_acao_labelaction.id_action
  PRIMARY KEY (label_action_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT competences.AVALIADOR — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_avaliador
-- @fk: avaliado_key -> edw.dim_avaliado.avaliado_key
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: eval_cycle_key -> edw.dim_eval_cycle.eval_cycle_key
CREATE TABLE IF NOT EXISTS edw.fact_avaliador (
  avaliador_key BIGINT,
  tenant_slug STRING,
  avaliado_key BIGINT,
  employee_key BIGINT,
  eval_cycle_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_avaliador.id
  id_avaliacao INT, -- @map <- staging.stg_avaliacao_avaliador.id_avaliacao
  id_avaliado INT, -- @map <- staging.stg_avaliacao_avaliador.id_avaliado
  id_colaborador_avaliador INT, -- @map <- staging.stg_avaliacao_avaliador.id_colaborador_avaliador
  tipo_avaliador INT, -- @map <- staging.stg_avaliacao_avaliador.tipo_avaliador
  PRIMARY KEY (avaliador_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT competences.CALC_RESPOSTA — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_calc_resposta
CREATE TABLE IF NOT EXISTS edw.fact_calc_resposta (
  calc_resposta_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_avaliacao_calc_resposta.id
  id_avaliacao INT, -- @map <- staging.stg_avaliacao_calc_resposta.id_avaliacao
  id_formulario_avaliacao INT, -- @map <- staging.stg_avaliacao_calc_resposta.id_formulario_avaliacao
  id_avaliado INT, -- @map <- staging.stg_avaliacao_calc_resposta.id_avaliado
  id_avaliador INT, -- @map <- staging.stg_avaliacao_calc_resposta.id_avaliador
  id_funcao INT, -- @map <- staging.stg_avaliacao_calc_resposta.id_funcao
  id_resposta_avaliacao INT, -- @map <- staging.stg_avaliacao_calc_resposta.id_resposta_avaliacao
  peso_funcao_competencia DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resposta.peso_funcao_competencia
  nota_referencia DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resposta.nota_referencia
  perc_alcance_referencia DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resposta.perc_alcance_referencia
  nota_resposta DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resposta.nota_resposta
  perc_alcance_resposta DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resposta.perc_alcance_resposta
  nota_consenso DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resposta.nota_consenso
  perc_alcance_consenso DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resposta.perc_alcance_consenso
  nota_ponderada DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resposta.nota_ponderada
  perc_ponderado DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resposta.perc_ponderado
  nota_consenso_ponderada DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resposta.nota_consenso_ponderada
  perc_consenso_ponderado DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resposta.perc_consenso_ponderado
  nota_ponderada_numeric DECIMAL(18,5), -- @map <- staging.stg_avaliacao_calc_resposta.nota_ponderada_numeric
  nota_consenso_ponderada_numeric DECIMAL(18,5), -- @map <- staging.stg_avaliacao_calc_resposta.nota_consenso_ponderada_numeric
  feedback_enviado INT, -- @map <- staging.stg_avaliacao_calc_resposta.feedback_enviado
  nota_calibrada DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resposta.nota_calibrada
  nota_calibrada_ponderada DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resposta.nota_calibrada_ponderada
  weighted_assessmet_competence_type_score DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resposta.weighted_assessmet_competence_type_score
  applied_weight_general_score DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resposta.applied_weight_general_score
  applied_weight_competence_type_score DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resposta.applied_weight_competence_type_score
  PRIMARY KEY (calc_resposta_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT competences.CALC_RESULTADO_AVALIADOR — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_calc_resultado_avaliador
CREATE TABLE IF NOT EXISTS edw.fact_calc_resultado_avaliador (
  calc_resultado_avaliador_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_avaliacao_calc_resultado_avaliador.id
  id_avaliacao INT, -- @map <- staging.stg_avaliacao_calc_resultado_avaliador.id_avaliacao
  id_avaliado INT, -- @map <- staging.stg_avaliacao_calc_resultado_avaliador.id_avaliado
  id_colaborador_avaliado INT, -- @map <- staging.stg_avaliacao_calc_resultado_avaliador.id_colaborador_avaliado
  id_avaliador INT, -- @map <- staging.stg_avaliacao_calc_resultado_avaliador.id_avaliador
  id_colaborador_avaliador INT, -- @map <- staging.stg_avaliacao_calc_resultado_avaliador.id_colaborador_avaliador
  nota_final DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resultado_avaliador.nota_final
  nota_final_numeric DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resultado_avaliador.nota_final_numeric
  nota_final_habilidade DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resultado_avaliador.nota_final_habilidade
  nota_final_comportamental DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resultado_avaliador.nota_final_comportamental
  nota_final_numeric_habilidade DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resultado_avaliador.nota_final_numeric_habilidade
  nota_final_numeric_comportamental DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resultado_avaliador.nota_final_numeric_comportamental
  PRIMARY KEY (calc_resultado_avaliador_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT competences.CALC_RESULTADO_COLABORADOR_PERFORMANCE — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_calc_resultado_colaborador_performance
-- @fk: avaliado_key -> edw.dim_avaliado.avaliado_key
CREATE TABLE IF NOT EXISTS edw.fact_calc_resultado_colaborador_performance (
  calc_resultado_colaborador_performance_key BIGINT,
  tenant_slug STRING,
  avaliado_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_calc_resultado_colaborador_performance.id
  id_avaliado INT, -- @map <- staging.stg_avaliacao_calc_resultado_colaborador_performance.id_avaliado
  nota_final DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resultado_colaborador_performance.nota_final
  PRIMARY KEY (calc_resultado_colaborador_performance_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT competences.CALC_RESULTADO_COMPETENCIA — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_calc_resultado_competencia
CREATE TABLE IF NOT EXISTS edw.fact_calc_resultado_competencia (
  calc_resultado_competencia_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_avaliacao_calc_resultado_competencia.id
  id_avaliacao INT, -- @map <- staging.stg_avaliacao_calc_resultado_competencia.id_avaliacao
  id_avaliado INT, -- @map <- staging.stg_avaliacao_calc_resultado_competencia.id_avaliado
  id_colaborador_avaliado INT, -- @map <- staging.stg_avaliacao_calc_resultado_competencia.id_colaborador_avaliado
  id_competencia INT, -- @map <- staging.stg_avaliacao_calc_resultado_competencia.id_competencia
  nota_final DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resultado_competencia.nota_final
  nota_final_consensada DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resultado_competencia.nota_final_consensada
  nota_final_calibrada DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resultado_competencia.nota_final_calibrada
  PRIMARY KEY (calc_resultado_competencia_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT competences.CALC_RESULTADO_FATOR_AVALIACAO — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_calc_resultado_fator_avaliacao
CREATE TABLE IF NOT EXISTS edw.fact_calc_resultado_fator_avaliacao (
  calc_resultado_fator_avaliacao_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_avaliacao_calc_resultado_fator_avaliacao.id
  id_avaliacao INT, -- @map <- staging.stg_avaliacao_calc_resultado_fator_avaliacao.id_avaliacao
  id_avaliado INT, -- @map <- staging.stg_avaliacao_calc_resultado_fator_avaliacao.id_avaliado
  id_colaborador_avaliado INT, -- @map <- staging.stg_avaliacao_calc_resultado_fator_avaliacao.id_colaborador_avaliado
  id_funcao_competencia INT, -- @map <- staging.stg_avaliacao_calc_resultado_fator_avaliacao.id_funcao_competencia
  id_competencia INT, -- @map <- staging.stg_avaliacao_calc_resultado_fator_avaliacao.id_competencia
  id_fator_avaliacao INT, -- @map <- staging.stg_avaliacao_calc_resultado_fator_avaliacao.id_fator_avaliacao
  nota_final DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resultado_fator_avaliacao.nota_final
  nota_final_consensada DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resultado_fator_avaliacao.nota_final_consensada
  nota_final_calibrada DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resultado_fator_avaliacao.nota_final_calibrada
  PRIMARY KEY (calc_resultado_fator_avaliacao_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT competences.CALC_RESULTADO_TIPO_AVALIADOR — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_calc_resultado_tipo_avaliador
CREATE TABLE IF NOT EXISTS edw.fact_calc_resultado_tipo_avaliador (
  calc_resultado_tipo_avaliador_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_avaliacao_calc_resultado_tipo_avaliador.id
  id_avaliacao INT, -- @map <- staging.stg_avaliacao_calc_resultado_tipo_avaliador.id_avaliacao
  id_avaliado INT, -- @map <- staging.stg_avaliacao_calc_resultado_tipo_avaliador.id_avaliado
  id_colaborador_avaliado INT, -- @map <- staging.stg_avaliacao_calc_resultado_tipo_avaliador.id_colaborador_avaliado
  tipo_avaliador INT, -- @map <- staging.stg_avaliacao_calc_resultado_tipo_avaliador.tipo_avaliador
  nota_final DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resultado_tipo_avaliador.nota_final
  nota_final_numeric DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resultado_tipo_avaliador.nota_final_numeric
  technical_final_score DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resultado_tipo_avaliador.technical_final_score
  behavioral_final_score DECIMAL(28,8), -- @map <- staging.stg_avaliacao_calc_resultado_tipo_avaliador.behavioral_final_score
  PRIMARY KEY (calc_resultado_tipo_avaliador_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT competences.COMENTARIO_AVALIADO_NINE_BOX — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_comentario_avaliado_nine_box
-- @fk: avaliado_key -> edw.dim_avaliado.avaliado_key
-- @fk: nine_box_key -> edw.dim_nine_box.nine_box_key
CREATE TABLE IF NOT EXISTS edw.fact_comentario_avaliado_nine_box (
  comentario_avaliado_nine_box_key BIGINT,
  tenant_slug STRING,
  avaliado_key BIGINT,
  nine_box_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_comentario_avaliado_nine_box.id
  id_avaliado INT, -- @map <- staging.stg_avaliacao_comentario_avaliado_nine_box.id_avaliado
  id_nine_box INT, -- @map <- staging.stg_avaliacao_comentario_avaliado_nine_box.id_nine_box
  comentario STRING, -- @map <- staging.stg_avaliacao_comentario_avaliado_nine_box.comentario
  dt_atualizacao TIMESTAMP, -- @map <- staging.stg_avaliacao_comentario_avaliado_nine_box.dt_atualizacao
  PRIMARY KEY (comentario_avaliado_nine_box_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT competences.COMENTARIO_COMPETENCIA — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_comentario_competencia
-- @fk: competency_key -> edw.dim_competency.competency_key
CREATE TABLE IF NOT EXISTS edw.fact_comentario_competencia (
  comentario_competencia_key BIGINT,
  tenant_slug STRING,
  competency_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_comentario_competencia.id
  id_formulario_avaliacao INT, -- @map <- staging.stg_avaliacao_comentario_competencia.id_formulario_avaliacao
  id_competencia INT, -- @map <- staging.stg_avaliacao_comentario_competencia.id_competencia
  comentario STRING, -- @map <- staging.stg_avaliacao_comentario_competencia.comentario
  PRIMARY KEY (comentario_competencia_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT competences.CONSIDERACAO_FINAL — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_consideracao_final
CREATE TABLE IF NOT EXISTS edw.fact_consideracao_final (
  consideracao_final_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_avaliacao_consideracao_final.id
  id_formulario_avaliacao INT, -- @map <- staging.stg_avaliacao_consideracao_final.id_formulario_avaliacao
  pontos_positivos STRING, -- @map <- staging.stg_avaliacao_consideracao_final.pontos_positivos
  pontos_desenvolver STRING, -- @map <- staging.stg_avaliacao_consideracao_final.pontos_desenvolver
  comentario_final STRING, -- @map <- staging.stg_avaliacao_consideracao_final.comentario_final
  comentario_lider STRING, -- @map <- staging.stg_avaliacao_consideracao_final.comentario_lider
  comentario_avaliado STRING, -- @map <- staging.stg_avaliacao_consideracao_final.comentario_avaliado
  comentario_qualidade STRING, -- @map <- staging.stg_avaliacao_consideracao_final.comentario_qualidade
  nota_qualidade INT, -- @map <- staging.stg_avaliacao_consideracao_final.nota_qualidade
  data_feedback TIMESTAMP, -- @map <- staging.stg_avaliacao_consideracao_final.data_feedback
  qualidade_avaliada INT, -- @map <- staging.stg_avaliacao_consideracao_final.qualidade_avaliada
  PRIMARY KEY (consideracao_final_key)
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
-- @note: FACT competences.EvaluationCycleCalcResultEvaluated — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_evaluationcyclecalcresultevaluated
-- @fk: avaliado_key -> edw.dim_avaliado.avaliado_key
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: eval_cycle_key -> edw.dim_eval_cycle.eval_cycle_key
CREATE TABLE IF NOT EXISTS edw.fact_evaluation_cycle_calc_result_evaluated (
  evaluation_cycle_calc_result_evaluated_key BIGINT,
  tenant_slug STRING,
  avaliado_key BIGINT,
  employee_key BIGINT,
  eval_cycle_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_evaluationcyclecalcresultevaluated.id
  evaluation_cycle_id INT, -- @map <- staging.stg_avaliacao_evaluationcyclecalcresultevaluated.evaluation_cycle_id
  evaluated_id INT, -- @map <- staging.stg_avaliacao_evaluationcyclecalcresultevaluated.evaluated_id
  employee_evaluated_id INT, -- @map <- staging.stg_avaliacao_evaluationcyclecalcresultevaluated.employee_evaluated_id
  final_score DECIMAL(28,8), -- @map <- staging.stg_avaliacao_evaluationcyclecalcresultevaluated.final_score
  final_score_consensus DECIMAL(28,8), -- @map <- staging.stg_avaliacao_evaluationcyclecalcresultevaluated.final_score_consensus
  final_score_calib DECIMAL(28,8), -- @map <- staging.stg_avaliacao_evaluationcyclecalcresultevaluated.final_score_calib
  pdf_history_url STRING, -- @map <- staging.stg_avaliacao_evaluationcyclecalcresultevaluated.pdf_history_url
  final_score_behavior DECIMAL(28,8), -- @map <- staging.stg_avaliacao_evaluationcyclecalcresultevaluated.final_score_behavior
  final_score_behavior_consensus DECIMAL(28,8), -- @map <- staging.stg_avaliacao_evaluationcyclecalcresultevaluated.final_score_behavior_consensus
  final_score_behavior_calib DECIMAL(28,8), -- @map <- staging.stg_avaliacao_evaluationcyclecalcresultevaluated.final_score_behavior_calib
  final_score_technical DECIMAL(28,8), -- @map <- staging.stg_avaliacao_evaluationcyclecalcresultevaluated.final_score_technical
  final_score_technical_consensus DECIMAL(28,8), -- @map <- staging.stg_avaliacao_evaluationcyclecalcresultevaluated.final_score_technical_consensus
  final_score_technical_calib DECIMAL(28,8), -- @map <- staging.stg_avaliacao_evaluationcyclecalcresultevaluated.final_score_technical_calib
  calibration_ranking_evaluated DECIMAL(28,8), -- @map <- staging.stg_avaliacao_evaluationcyclecalcresultevaluated.calibration_ranking_evaluated
  PRIMARY KEY (evaluation_cycle_calc_result_evaluated_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.EvaluationCycleInstanceParticipant — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_evaluationcycleinstanceparticipant
-- @fk: avaliado_key -> edw.dim_avaliado.avaliado_key
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: evaluation_cycle_instance_key -> edw.dim_evaluation_cycle_instance.evaluation_cycle_instance_key
-- @fk: quadrant_from_evaluation_cycle_quadrant_key -> edw.dim_evaluation_cycle_quadrant.evaluation_cycle_quadrant_key
-- @fk: quadrant_to_evaluation_cycle_quadrant_key -> edw.dim_evaluation_cycle_quadrant.evaluation_cycle_quadrant_key
CREATE TABLE IF NOT EXISTS edw.fact_evaluation_cycle_instance_participant (
  evaluation_cycle_instance_participant_key BIGINT,
  tenant_slug STRING,
  avaliado_key BIGINT,
  employee_key BIGINT,
  evaluation_cycle_instance_key BIGINT,
  quadrant_from_evaluation_cycle_quadrant_key BIGINT,
  quadrant_to_evaluation_cycle_quadrant_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_evaluationcycleinstanceparticipant.id
  instance_id INT, -- @map <- staging.stg_avaliacao_evaluationcycleinstanceparticipant.instance_id
  evaluated_id INT, -- @map <- staging.stg_avaliacao_evaluationcycleinstanceparticipant.evaluated_id
  quadrant_from_id INT, -- @map <- staging.stg_avaliacao_evaluationcycleinstanceparticipant.quadrant_from_id
  quadrant_to_id INT, -- @map <- staging.stg_avaliacao_evaluationcycleinstanceparticipant.quadrant_to_id
  employee_x_axis_calibrated INT, -- @map <- staging.stg_avaliacao_evaluationcycleinstanceparticipant.employee_x_axis_calibrated
  employee_y_axis_calibrated INT, -- @map <- staging.stg_avaliacao_evaluationcycleinstanceparticipant.employee_y_axis_calibrated
  x_axis_considerations STRING, -- @map <- staging.stg_avaliacao_evaluationcycleinstanceparticipant.x_axis_considerations
  y_axis_considerations STRING, -- @map <- staging.stg_avaliacao_evaluationcycleinstanceparticipant.y_axis_considerations
  change_date TIMESTAMP, -- @map <- staging.stg_avaliacao_evaluationcycleinstanceparticipant.change_date
  employee_responsible_change_id INT, -- @map <- staging.stg_avaliacao_evaluationcycleinstanceparticipant.employee_responsible_change_id
  active INT, -- @map <- staging.stg_avaliacao_evaluationcycleinstanceparticipant.active
  parent_id INT, -- @map <- staging.stg_avaliacao_evaluationcycleinstanceparticipant.parent_id
  PRIMARY KEY (evaluation_cycle_instance_participant_key)
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
-- @note: FACT competences.FORMULARIO_AVALIACAO — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_formulario_avaliacao
-- @fk: avaliado_key -> edw.dim_avaliado.avaliado_key
-- @fk: avaliador_respondeu_avaliacao_employee_key -> edw.dim_employee.employee_key
-- @fk: avaliador_respondeu_feedback_employee_key -> edw.dim_employee.employee_key
-- @fk: eval_cycle_key -> edw.dim_eval_cycle.eval_cycle_key
-- @fk: funcao_key -> edw.dim_funcao.funcao_key
-- @fk: peso_tipo_avaliador_key -> edw.dim_peso_tipo_avaliador.peso_tipo_avaliador_key
CREATE TABLE IF NOT EXISTS edw.fact_formulario_avaliacao (
  formulario_avaliacao_key BIGINT,
  tenant_slug STRING,
  avaliado_key BIGINT,
  avaliador_respondeu_avaliacao_employee_key BIGINT,
  avaliador_respondeu_feedback_employee_key BIGINT,
  eval_cycle_key BIGINT,
  funcao_key BIGINT,
  peso_tipo_avaliador_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.id
  id_avaliacao INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.id_avaliacao
  id_avaliado INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.id_avaliado
  id_avaliador INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.id_avaliador
  id_funcao INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.id_funcao
  dt_deadline TIMESTAMP, -- @map <- staging.stg_avaliacao_formulario_avaliacao.dt_deadline
  dt_envio TIMESTAMP, -- @map <- staging.stg_avaliacao_formulario_avaliacao.dt_envio
  dt_reenvio TIMESTAMP, -- @map <- staging.stg_avaliacao_formulario_avaliacao.dt_reenvio
  dt_finalizacao_formulario TIMESTAMP, -- @map <- staging.stg_avaliacao_formulario_avaliacao.dt_finalizacao_formulario
  dt_cancelamento_envio TIMESTAMP, -- @map <- staging.stg_avaliacao_formulario_avaliacao.dt_cancelamento_envio
  dt_envio_feedback TIMESTAMP, -- @map <- staging.stg_avaliacao_formulario_avaliacao.dt_envio_feedback
  feedback_liberado INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.feedback_liberado
  id_colaborador_avaliador INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.id_colaborador_avaliador
  dt_deadline_feedback TIMESTAMP, -- @map <- staging.stg_avaliacao_formulario_avaliacao.dt_deadline_feedback
  id_peso_tipo_avaliador INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.id_peso_tipo_avaliador
  feedback_sem_formulario_lider INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.feedback_sem_formulario_lider
  resultado_feedback_liberado INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.resultado_feedback_liberado
  disponibilizar_onepage INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.disponibilizar_onepage
  status_feedback INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.status_feedback
  status INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.status
  justificativa_recusa STRING, -- @map <- staging.stg_avaliacao_formulario_avaliacao.justificativa_recusa
  data_recusa TIMESTAMP, -- @map <- staging.stg_avaliacao_formulario_avaliacao.data_recusa
  id_colaborador_criador INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.id_colaborador_criador
  dt_deadline_pre_calibragem TIMESTAMP, -- @map <- staging.stg_avaliacao_formulario_avaliacao.dt_deadline_pre_calibragem
  feedback_informal_recebido INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.feedback_informal_recebido
  id_projeto INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.id_projeto
  possui_interesse_mudanca_localidade INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.possui_interesse_mudanca_localidade
  dt_liberacao_resultado TIMESTAMP, -- @map <- staging.stg_avaliacao_formulario_avaliacao.dt_liberacao_resultado
  id_avaliador_respondeu_avaliacao INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.id_avaliador_respondeu_avaliacao
  id_avaliador_respondeu_feedback INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.id_avaliador_respondeu_feedback
  evaluation_answered_from_mobile INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.evaluation_answered_from_mobile
  feedback_answered_from_mobile INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.feedback_answered_from_mobile
  has_interest_change_area INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.has_interest_change_area
  has_successor_indication INT, -- @map <- staging.stg_avaliacao_formulario_avaliacao.has_successor_indication
  PRIMARY KEY (formulario_avaliacao_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT competences.FUNCAO_COMPETENCIA — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_funcao_competencia
-- @fk: competency_key -> edw.dim_competency.competency_key
-- @fk: fator_avaliacao_key -> edw.dim_fator_avaliacao.fator_avaliacao_key
-- @fk: funcao_key -> edw.dim_funcao.funcao_key
CREATE TABLE IF NOT EXISTS edw.fact_funcao_competencia (
  funcao_competencia_key BIGINT,
  tenant_slug STRING,
  competency_key BIGINT,
  fator_avaliacao_key BIGINT,
  funcao_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_funcao_competencia.id
  id_funcao INT, -- @map <- staging.stg_avaliacao_funcao_competencia.id_funcao
  id_competencia INT, -- @map <- staging.stg_avaliacao_funcao_competencia.id_competencia
  id_fator_avaliacao INT, -- @map <- staging.stg_avaliacao_funcao_competencia.id_fator_avaliacao
  proficiencia INT, -- @map <- staging.stg_avaliacao_funcao_competencia.proficiencia
  experiencia_ano INT, -- @map <- staging.stg_avaliacao_funcao_competencia.experiencia_ano
  auto DECIMAL(28,8), -- @map <- staging.stg_avaliacao_funcao_competencia.auto
  lider DECIMAL(28,8), -- @map <- staging.stg_avaliacao_funcao_competencia.lider
  par DECIMAL(28,8), -- @map <- staging.stg_avaliacao_funcao_competencia.par
  time DECIMAL(28,8), -- @map <- staging.stg_avaliacao_funcao_competencia.time
  comite DECIMAL(28,8), -- @map <- staging.stg_avaliacao_funcao_competencia.comite
  cliente DECIMAL(28,8), -- @map <- staging.stg_avaliacao_funcao_competencia.cliente
  fornecedor DECIMAL(28,8), -- @map <- staging.stg_avaliacao_funcao_competencia.fornecedor
  peso_geral_por_fator DECIMAL(18,5), -- @map <- staging.stg_avaliacao_funcao_competencia.peso_geral_por_fator
  possui_pesos_detalhado INT, -- @map <- staging.stg_avaliacao_funcao_competencia.possui_pesos_detalhado
  projeto DECIMAL(28,8), -- @map <- staging.stg_avaliacao_funcao_competencia.projeto
  PRIMARY KEY (funcao_competencia_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT competences.FUNCAO_PERGUNTA_LIVRE — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_funcao_pergunta_livre
-- @fk: funcao_key -> edw.dim_funcao.funcao_key
-- @fk: topico_pergunta_livre_key -> edw.dim_topico_pergunta_livre.topico_pergunta_livre_key
CREATE TABLE IF NOT EXISTS edw.fact_funcao_pergunta_livre (
  funcao_pergunta_livre_key BIGINT,
  tenant_slug STRING,
  funcao_key BIGINT,
  topico_pergunta_livre_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_funcao_pergunta_livre.id
  id_funcao INT, -- @map <- staging.stg_avaliacao_funcao_pergunta_livre.id_funcao
  pergunta_livre STRING, -- @map <- staging.stg_avaliacao_funcao_pergunta_livre.pergunta_livre
  ordenacao INT, -- @map <- staging.stg_avaliacao_funcao_pergunta_livre.ordenacao
  auto INT, -- @map <- staging.stg_avaliacao_funcao_pergunta_livre.auto
  lider INT, -- @map <- staging.stg_avaliacao_funcao_pergunta_livre.lider
  par INT, -- @map <- staging.stg_avaliacao_funcao_pergunta_livre.par
  time INT, -- @map <- staging.stg_avaliacao_funcao_pergunta_livre.time
  comite INT, -- @map <- staging.stg_avaliacao_funcao_pergunta_livre.comite
  cliente INT, -- @map <- staging.stg_avaliacao_funcao_pergunta_livre.cliente
  fornecedor INT, -- @map <- staging.stg_avaliacao_funcao_pergunta_livre.fornecedor
  id_topico INT, -- @map <- staging.stg_avaliacao_funcao_pergunta_livre.id_topico
  tipo_resposta INT, -- @map <- staging.stg_avaliacao_funcao_pergunta_livre.tipo_resposta
  pergunta_livre_confidencial INT, -- @map <- staging.stg_avaliacao_funcao_pergunta_livre.pergunta_livre_confidencial
  PRIMARY KEY (funcao_pergunta_livre_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.NOTIFICACAO_FEEDBACK_CONTINUO — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_notificacao_feedback_continuo
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.fact_notificacao_feedback (
  notificacao_feedback_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_notificacao_feedback_continuo.id
  id_colaborador INT, -- @map <- staging.stg_avaliacao_notificacao_feedback_continuo.id_colaborador
  alert_type INT, -- @map <- staging.stg_avaliacao_notificacao_feedback_continuo.alert_type
  frequency_type INT, -- @map <- staging.stg_avaliacao_notificacao_feedback_continuo.frequency_type
  week_day INT, -- @map <- staging.stg_avaliacao_notificacao_feedback_continuo.week_day
  PRIMARY KEY (notificacao_feedback_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT competences.OPCAO_FUNCAO_PERGUNTA_LIVRE — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_opcao_funcao_pergunta_livre
CREATE TABLE IF NOT EXISTS edw.fact_opcao_funcao_pergunta_livre (
  opcao_funcao_pergunta_livre_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_avaliacao_opcao_funcao_pergunta_livre.id
  id_funcao_pergunta_livre INT, -- @map <- staging.stg_avaliacao_opcao_funcao_pergunta_livre.id_funcao_pergunta_livre
  descricao STRING, -- @map <- staging.stg_avaliacao_opcao_funcao_pergunta_livre.descricao
  PRIMARY KEY (opcao_funcao_pergunta_livre_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT competences.RESPOSTA_AVALIACAO — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_resposta_avaliacao
-- @fk: nota_calibrada_curva_pontuacao_avaliacao_key -> edw.dim_curva_pontuacao_avaliacao.curva_pontuacao_avaliacao_key
-- @fk: nota_consenso_curva_pontuacao_avaliacao_key -> edw.dim_curva_pontuacao_avaliacao.curva_pontuacao_avaliacao_key
-- @fk: nota_resposta_curva_pontuacao_avaliacao_key -> edw.dim_curva_pontuacao_avaliacao.curva_pontuacao_avaliacao_key
CREATE TABLE IF NOT EXISTS edw.fact_resposta (
  resposta_key BIGINT,
  tenant_slug STRING,
  nota_calibrada_curva_pontuacao_avaliacao_key BIGINT,
  nota_consenso_curva_pontuacao_avaliacao_key BIGINT,
  nota_resposta_curva_pontuacao_avaliacao_key BIGINT,
  id INT, -- @map <- staging.stg_avaliacao_resposta_avaliacao.id
  id_formulario_avaliacao INT, -- @map <- staging.stg_avaliacao_resposta_avaliacao.id_formulario_avaliacao
  id_funcao_competencia INT, -- @map <- staging.stg_avaliacao_resposta_avaliacao.id_funcao_competencia
  id_nota_resposta INT, -- @map <- staging.stg_avaliacao_resposta_avaliacao.id_nota_resposta
  id_nota_consenso INT, -- @map <- staging.stg_avaliacao_resposta_avaliacao.id_nota_consenso
  comentario_resposta STRING, -- @map <- staging.stg_avaliacao_resposta_avaliacao.comentario_resposta
  dt_resposta TIMESTAMP, -- @map <- staging.stg_avaliacao_resposta_avaliacao.dt_resposta
  dt_resposta_consenso TIMESTAMP, -- @map <- staging.stg_avaliacao_resposta_avaliacao.dt_resposta_consenso
  comentario_resposta_consenso STRING, -- @map <- staging.stg_avaliacao_resposta_avaliacao.comentario_resposta_consenso
  id_nota_calibrada INT, -- @map <- staging.stg_avaliacao_resposta_avaliacao.id_nota_calibrada
  PRIMARY KEY (resposta_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT competences.RESPOSTA_LIVRE_AVALIACAO — grain (tenant_slug, id)
-- @origen: staging.stg_avaliacao_resposta_livre_avaliacao
CREATE TABLE IF NOT EXISTS edw.fact_resposta_livre_avaliacao (
  resposta_livre_avaliacao_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_avaliacao_resposta_livre_avaliacao.id
  id_formulario_avaliacao INT, -- @map <- staging.stg_avaliacao_resposta_livre_avaliacao.id_formulario_avaliacao
  id_funcao_pergunta_livre INT, -- @map <- staging.stg_avaliacao_resposta_livre_avaliacao.id_funcao_pergunta_livre
  resposta_livre STRING, -- @map <- staging.stg_avaliacao_resposta_livre_avaliacao.resposta_livre
  dt_resposta TIMESTAMP, -- @map <- staging.stg_avaliacao_resposta_livre_avaliacao.dt_resposta
  resposta_consolidado STRING, -- @map <- staging.stg_avaliacao_resposta_livre_avaliacao.resposta_consolidado
  id_opcao_funcao_pergunta_livre INT, -- @map <- staging.stg_avaliacao_resposta_livre_avaliacao.id_opcao_funcao_pergunta_livre
  PRIMARY KEY (resposta_livre_avaliacao_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.AcceptAgreementHistory — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_acceptagreementhistory
CREATE TABLE IF NOT EXISTS edw.fact_accept_agreement_history (
  accept_agreement_history_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_colaborador_acceptagreementhistory.id
  created_on TIMESTAMP, -- @map <- staging.stg_colaborador_acceptagreementhistory.created_on
  agreement_details STRING, -- @map <- staging.stg_colaborador_acceptagreementhistory.agreement_details
  accept_agreement_id INT, -- @map <- staging.stg_colaborador_acceptagreementhistory.accept_agreement_id
  accept_agreement_signature_id INT, -- @map <- staging.stg_colaborador_acceptagreementhistory.accept_agreement_signature_id
  accept_agreement_last_signature STRING, -- @map <- staging.stg_colaborador_acceptagreementhistory.accept_agreement_last_signature
  motive STRING, -- @map <- staging.stg_colaborador_acceptagreementhistory.motive
  PRIMARY KEY (accept_agreement_history_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.ActivityHistory — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_activityhistory
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.fact_activity_history (
  activity_history_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id BIGINT, -- @map <- staging.stg_colaborador_activityhistory.id
  title STRING, -- @map <- staging.stg_colaborador_activityhistory.title
  description STRING, -- @map <- staging.stg_colaborador_activityhistory.description
  notification_type INT, -- @map <- staging.stg_colaborador_activityhistory.notification_type
  employee_id INT, -- @map <- staging.stg_colaborador_activityhistory.employee_id
  module_id INT, -- @map <- staging.stg_colaborador_activityhistory.module_id
  read INT, -- @map <- staging.stg_colaborador_activityhistory.read
  creator_user_id BIGINT, -- @map <- staging.stg_colaborador_activityhistory.creator_user_id
  creation_time TIMESTAMP, -- @map <- staging.stg_colaborador_activityhistory.creation_time
  object_id INT, -- @map <- staging.stg_colaborador_activityhistory.object_id
  read_only INT, -- @map <- staging.stg_colaborador_activityhistory.read_only
  PRIMARY KEY (activity_history_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.AVALIADOR_FORUM — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_avaliador_forum
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: nine_box_key -> edw.dim_nine_box.nine_box_key
CREATE TABLE IF NOT EXISTS edw.fact_avaliador_forum (
  avaliador_forum_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  nine_box_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_avaliador_forum.id
  id_colaborador_avaliador INT, -- @map <- staging.stg_colaborador_avaliador_forum.id_colaborador_avaliador
  id_forum INT, -- @map <- staging.stg_colaborador_avaliador_forum.id_forum
  PRIMARY KEY (avaliador_forum_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.DiscretionaryScoreImport — grain (tenant_slug)
-- @origen: staging.stg_colaborador_discretionaryscoreimport
CREATE TABLE IF NOT EXISTS edw.fact_discretionary_score_import (
  discretionary_score_import_key BIGINT,
  tenant_slug STRING,
  import_log_id INT, -- @map <- staging.stg_colaborador_discretionaryscoreimport.import_log_id
  line INT, -- @map <- staging.stg_colaborador_discretionaryscoreimport.line
  calculation_period INT, -- @map <- staging.stg_colaborador_discretionaryscoreimport.calculation_period
  employee_id INT, -- @map <- staging.stg_colaborador_discretionaryscoreimport.employee_id
  user_name STRING, -- @map <- staging.stg_colaborador_discretionaryscoreimport.user_name
  score DOUBLE, -- @map <- staging.stg_colaborador_discretionaryscoreimport.score
  description STRING, -- @map <- staging.stg_colaborador_discretionaryscoreimport.description
  PRIMARY KEY (discretionary_score_import_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.Education — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_education
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.fact_education (
  education_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_education.id
  institution_name STRING, -- @map <- staging.stg_colaborador_education.institution_name
  degree STRING, -- @map <- staging.stg_colaborador_education.degree
  field_of_study STRING, -- @map <- staging.stg_colaborador_education.field_of_study
  start TIMESTAMP, -- @map <- staging.stg_colaborador_education.start
  end TIMESTAMP, -- @map <- staging.stg_colaborador_education.end
  employee_id INT, -- @map <- staging.stg_colaborador_education.employee_id
  logo STRING, -- @map <- staging.stg_colaborador_education.logo
  PRIMARY KEY (education_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.EmployeeAccessGroup — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_employeeaccessgroup
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.fact_employee_access_group (
  employee_access_group_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_employeeaccessgroup.id
  employee_id INT, -- @map <- staging.stg_colaborador_employeeaccessgroup.employee_id
  module_id INT, -- @map <- staging.stg_colaborador_employeeaccessgroup.module_id
  type INT, -- @map <- staging.stg_colaborador_employeeaccessgroup.type
  PRIMARY KEY (employee_access_group_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.EmployeeModifierValue — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_employeemodifiervalue
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: modifier_key -> edw.dim_modifier.modifier_key
CREATE TABLE IF NOT EXISTS edw.fact_employee_modifier_value (
  employee_modifier_value_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  modifier_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_employeemodifiervalue.id
  value DECIMAL(28,8), -- @map <- staging.stg_colaborador_employeemodifiervalue.value
  employee_id INT, -- @map <- staging.stg_colaborador_employeemodifiervalue.employee_id
  modifier_id INT, -- @map <- staging.stg_colaborador_employeemodifiervalue.modifier_id
  update_date TIMESTAMP, -- @map <- staging.stg_colaborador_employeemodifiervalue.update_date
  PRIMARY KEY (employee_modifier_value_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.EvaluationDiscretionary — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_evaluationdiscretionary
-- @fk: concept_discretionary_key -> edw.dim_concept_discretionary.concept_discretionary_key
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.fact_evaluation_discretionary (
  evaluation_discretionary_key BIGINT,
  tenant_slug STRING,
  concept_discretionary_key BIGINT,
  employee_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_evaluationdiscretionary.id
  concept_id INT, -- @map <- staging.stg_colaborador_evaluationdiscretionary.concept_id
  eligible_discretionary_id INT, -- @map <- staging.stg_colaborador_evaluationdiscretionary.eligible_discretionary_id
  evaluator_id INT, -- @map <- staging.stg_colaborador_evaluationdiscretionary.evaluator_id
  evaluated_date TIMESTAMP, -- @map <- staging.stg_colaborador_evaluationdiscretionary.evaluated_date
  grade DECIMAL(7,2), -- @map <- staging.stg_colaborador_evaluationdiscretionary.grade
  calibrated_grade DECIMAL(7,2), -- @map <- staging.stg_colaborador_evaluationdiscretionary.calibrated_grade
  status INT, -- @map <- staging.stg_colaborador_evaluationdiscretionary.status
  PRIMARY KEY (evaluation_discretionary_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.GoalAttachment — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_goalattachment
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: goal_key -> edw.dim_goal.goal_key
CREATE TABLE IF NOT EXISTS edw.fact_goal_attachment (
  goal_attachment_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  goal_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_goalattachment.id
  goal_id INT, -- @map <- staging.stg_colaborador_goalattachment.goal_id
  employee_id INT, -- @map <- staging.stg_colaborador_goalattachment.employee_id
  file_name STRING, -- @map <- staging.stg_colaborador_goalattachment.file_name
  upload_date TIMESTAMP, -- @map <- staging.stg_colaborador_goalattachment.upload_date
  content_type STRING, -- @map <- staging.stg_colaborador_goalattachment.content_type
  month INT, -- @map <- staging.stg_colaborador_goalattachment.month
  origem INT, -- @map <- staging.stg_colaborador_goalattachment.origem
  key STRING, -- @map <- staging.stg_colaborador_goalattachment.key
  content_length INT, -- @map <- staging.stg_colaborador_goalattachment.content_length
  PRIMARY KEY (goal_attachment_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.HISTORICO_CARGO — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_historico_cargo
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: job_key -> edw.dim_org_job.job_key
CREATE TABLE IF NOT EXISTS edw.fact_historico_cargo (
  historico_cargo_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  job_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_historico_cargo.id
  id_cargo INT, -- @map <- staging.stg_colaborador_historico_cargo.id_cargo
  dt_ini TIMESTAMP, -- @map <- staging.stg_colaborador_historico_cargo.dt_ini
  dt_fim TIMESTAMP, -- @map <- staging.stg_colaborador_historico_cargo.dt_fim
  salario DOUBLE, -- @map <- staging.stg_colaborador_historico_cargo.salario
  id_colaborador INT, -- @map <- staging.stg_colaborador_historico_cargo.id_colaborador
  PRIMARY KEY (historico_cargo_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.NINE_BOX_CALIBRADOS — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_nine_box_calibrados
CREATE TABLE IF NOT EXISTS edw.fact_nine_box_calibrados (
  nine_box_calibrados_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_colaborador_nine_box_calibrados.id
  id_nine_box INT, -- @map <- staging.stg_colaborador_nine_box_calibrados.id_nine_box
  id_colaborador INT, -- @map <- staging.stg_colaborador_nine_box_calibrados.id_colaborador
  calibration_markup INT, -- @map <- staging.stg_colaborador_nine_box_calibrados.calibration_markup
  PRIMARY KEY (nine_box_calibrados_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.PSW_COLABORADOR — grain (tenant_slug, id_colaborador)
-- @origen: staging.stg_colaborador_psw_colaborador
-- @fk: employee_key -> edw.dim_employee.employee_key
CREATE TABLE IF NOT EXISTS edw.fact_psw_colaborador (
  psw_colaborador_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  id_colaborador INT, -- @map <- staging.stg_colaborador_psw_colaborador.id_colaborador
  create_date TIMESTAMP, -- @map <- staging.stg_colaborador_psw_colaborador.create_date
  last_upd TIMESTAMP, -- @map <- staging.stg_colaborador_psw_colaborador.last_upd
  expired INT, -- @map <- staging.stg_colaborador_psw_colaborador.expired
  attempts INT, -- @map <- staging.stg_colaborador_psw_colaborador.attempts
  current_psw STRING, -- @map <- staging.stg_colaborador_psw_colaborador.current_psw
  private_current_psw BINARY, -- @map <- staging.stg_colaborador_psw_colaborador.private_current_psw
  PRIMARY KEY (psw_colaborador_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.ThemeShare — grain (tenant_slug, id)
-- @origen: staging.stg_colaborador_themeshare
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: theme_key -> edw.dim_theme.theme_key
CREATE TABLE IF NOT EXISTS edw.fact_theme_share (
  theme_share_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  theme_key BIGINT,
  id INT, -- @map <- staging.stg_colaborador_themeshare.id
  theme_id INT, -- @map <- staging.stg_colaborador_themeshare.theme_id
  employee_id INT, -- @map <- staging.stg_colaborador_themeshare.employee_id
  permission_type INT, -- @map <- staging.stg_colaborador_themeshare.permission_type
  PRIMARY KEY (theme_share_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.EXPRESSAO_CALCULO_META — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_expressao_calculo_meta
-- @fk: meta_goal_key -> edw.dim_goal.goal_key
-- @fk: meta_ref_goal_key -> edw.dim_goal.goal_key
CREATE TABLE IF NOT EXISTS edw.fact_expressao_calculo (
  expressao_calculo_key BIGINT,
  tenant_slug STRING,
  meta_goal_key BIGINT,
  meta_ref_goal_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_expressao_calculo_meta.id
  id_meta INT, -- @map <- staging.stg_metricas_expressao_calculo_meta.id_meta
  id_meta_ref INT, -- @map <- staging.stg_metricas_expressao_calculo_meta.id_meta_ref
  id_grupo_conta_ref INT, -- @map <- staging.stg_metricas_expressao_calculo_meta.id_grupo_conta_ref
  id_entidade_ref INT, -- @map <- staging.stg_metricas_expressao_calculo_meta.id_entidade_ref
  id_matriz INT, -- @map <- staging.stg_metricas_expressao_calculo_meta.id_matriz
  tipo_processo_ref INT, -- @map <- staging.stg_metricas_expressao_calculo_meta.tipo_processo_ref
  tipo_matriz_ref INT, -- @map <- staging.stg_metricas_expressao_calculo_meta.tipo_matriz_ref
  valor_ref DOUBLE, -- @map <- staging.stg_metricas_expressao_calculo_meta.valor_ref
  peso_meta_ref DECIMAL(28,8), -- @map <- staging.stg_metricas_expressao_calculo_meta.peso_meta_ref
  operador INT, -- @map <- staging.stg_metricas_expressao_calculo_meta.operador
  desc_expressao STRING, -- @map <- staging.stg_metricas_expressao_calculo_meta.desc_expressao
  ordem INT, -- @map <- staging.stg_metricas_expressao_calculo_meta.ordem
  id_eixo_x INT, -- @map <- staging.stg_metricas_expressao_calculo_meta.id_eixo_x
  id_eixo_y INT, -- @map <- staging.stg_metricas_expressao_calculo_meta.id_eixo_y
  id_eixo_z INT, -- @map <- staging.stg_metricas_expressao_calculo_meta.id_eixo_z
  PRIMARY KEY (expressao_calculo_key)
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
-- @note: FACT dbo.INFO_NOTA_META — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_info_nota_meta
-- @fk: goal_key -> edw.dim_goal.goal_key
CREATE TABLE IF NOT EXISTS edw.fact_info_nota_meta (
  info_nota_meta_key BIGINT,
  tenant_slug STRING,
  goal_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_info_nota_meta.id
  id_meta INT, -- @map <- staging.stg_metricas_info_nota_meta.id_meta
  tipo_valor INT, -- @map <- staging.stg_metricas_info_nota_meta.tipo_valor
  PRIMARY KEY (info_nota_meta_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.LabelGoal — grain (tenant_slug, id_label, id_goal)
-- @origen: staging.stg_metricas_labelgoal
-- @fk: goal_key -> edw.dim_goal.goal_key
CREATE TABLE IF NOT EXISTS edw.fact_label_goal (
  label_goal_key BIGINT,
  tenant_slug STRING,
  goal_key BIGINT,
  id_label INT, -- @map <- staging.stg_metricas_labelgoal.id_label
  id_goal INT, -- @map <- staging.stg_metricas_labelgoal.id_goal
  PRIMARY KEY (label_goal_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.NOTA_META — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_nota_meta
-- @fk: goal_key -> edw.dim_goal.goal_key
CREATE TABLE IF NOT EXISTS edw.fact_nota_meta (
  nota_meta_key BIGINT,
  tenant_slug STRING,
  goal_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_nota_meta.id
  id_meta INT, -- @map <- staging.stg_metricas_nota_meta.id_meta
  id_nota INT, -- @map <- staging.stg_metricas_nota_meta.id_nota
  perc_nota DOUBLE, -- @map <- staging.stg_metricas_nota_meta.perc_nota
  valor_nota DOUBLE, -- @map <- staging.stg_metricas_nota_meta.valor_nota
  PRIMARY KEY (nota_meta_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.ScoreValuesRV — grain (tenant_slug, id)
-- @origen: staging.stg_metricas_scorevaluesrv
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: area_key -> edw.dim_org_area.area_key
-- @fk: time_apuracao_key -> edw.dim_time_apuracao.time_apuracao_key
-- @fk: time_gestao_key -> edw.dim_time_gestao.time_gestao_key
CREATE TABLE IF NOT EXISTS edw.fact_score_values_rv (
  score_values_rv_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  area_key BIGINT,
  time_apuracao_key BIGINT,
  time_gestao_key BIGINT,
  id INT, -- @map <- staging.stg_metricas_scorevaluesrv.id
  individual DECIMAL(28,8), -- @map <- staging.stg_metricas_scorevaluesrv.individual
  area DECIMAL(28,8), -- @map <- staging.stg_metricas_scorevaluesrv.area
  superior DECIMAL(28,8), -- @map <- staging.stg_metricas_scorevaluesrv.superior
  filial DECIMAL(28,8), -- @map <- staging.stg_metricas_scorevaluesrv.filial
  presidencia DECIMAL(28,8), -- @map <- staging.stg_metricas_scorevaluesrv.presidencia
  avaliacao_competencia DECIMAL(28,8), -- @map <- staging.stg_metricas_scorevaluesrv.avaliacao_competencia
  discricionario DECIMAL(28,8), -- @map <- staging.stg_metricas_scorevaluesrv.discricionario
  calculation_period_id INT, -- @map <- staging.stg_metricas_scorevaluesrv.calculation_period_id
  employee_id INT, -- @map <- staging.stg_metricas_scorevaluesrv.employee_id
  management_cycle_id INT, -- @map <- staging.stg_metricas_scorevaluesrv.management_cycle_id
  dt_fim TIMESTAMP, -- @map <- staging.stg_metricas_scorevaluesrv.dt_fim
  employee_area_id INT, -- @map <- staging.stg_metricas_scorevaluesrv.employee_area_id
  avaliacao_discricionaria DECIMAL(28,8), -- @map <- staging.stg_metricas_scorevaluesrv.avaliacao_discricionaria
  PRIMARY KEY (score_values_rv_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.AreaHistory — grain (tenant_slug, id)
-- @origen: staging.stg_organizacao_areahistory
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: area_key -> edw.dim_org_area.area_key
CREATE TABLE IF NOT EXISTS edw.fact_area_history (
  area_history_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  area_key BIGINT,
  id INT, -- @map <- staging.stg_organizacao_areahistory.id
  start_date TIMESTAMP, -- @map <- staging.stg_organizacao_areahistory.start_date
  end_date TIMESTAMP, -- @map <- staging.stg_organizacao_areahistory.end_date
  area_id INT, -- @map <- staging.stg_organizacao_areahistory.area_id
  employee_id INT, -- @map <- staging.stg_organizacao_areahistory.employee_id
  score DECIMAL(28,8), -- @map <- staging.stg_organizacao_areahistory.score
  start_date_ref TIMESTAMP, -- @map <- staging.stg_organizacao_areahistory.start_date_ref
  PRIMARY KEY (area_history_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.HistorySection — grain (tenant_slug, id)
-- @origen: staging.stg_organizacao_historysection
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: area_key -> edw.dim_org_area.area_key
-- @fk: job_key -> edw.dim_org_job.job_key
-- @fk: time_apuracao_key -> edw.dim_time_apuracao.time_apuracao_key
CREATE TABLE IF NOT EXISTS edw.fact_history_section (
  history_section_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  area_key BIGINT,
  job_key BIGINT,
  time_apuracao_key BIGINT,
  id INT, -- @map <- staging.stg_organizacao_historysection.id
  start_date TIMESTAMP, -- @map <- staging.stg_organizacao_historysection.start_date
  end_date TIMESTAMP, -- @map <- staging.stg_organizacao_historysection.end_date
  area_history_id INT, -- @map <- staging.stg_organizacao_historysection.area_history_id
  job_position_history_id INT, -- @map <- staging.stg_organizacao_historysection.job_position_history_id
  calculation_period_id INT, -- @map <- staging.stg_organizacao_historysection.calculation_period_id
  employee_id INT, -- @map <- staging.stg_organizacao_historysection.employee_id
  area_id INT, -- @map <- staging.stg_organizacao_historysection.area_id
  job_position_id INT, -- @map <- staging.stg_organizacao_historysection.job_position_id
  area_history_start_at TIMESTAMP, -- @map <- staging.stg_organizacao_historysection.area_history_start_at
  area_history_end_at TIMESTAMP, -- @map <- staging.stg_organizacao_historysection.area_history_end_at
  area_history_score DECIMAL(28,8), -- @map <- staging.stg_organizacao_historysection.area_history_score
  area_history_start_at_ref TIMESTAMP, -- @map <- staging.stg_organizacao_historysection.area_history_start_at_ref
  job_position_history_start_at TIMESTAMP, -- @map <- staging.stg_organizacao_historysection.job_position_history_start_at
  job_position_history_end_at TIMESTAMP, -- @map <- staging.stg_organizacao_historysection.job_position_history_end_at
  job_position_history_salary DOUBLE, -- @map <- staging.stg_organizacao_historysection.job_position_history_salary
  PRIMARY KEY (history_section_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.JobPositionLevel — grain (tenant_slug, job_position_id, level_id)
-- @origen: staging.stg_organizacao_jobpositionlevel
-- @fk: nivel_key -> edw.dim_nivel.nivel_key
-- @fk: job_key -> edw.dim_org_job.job_key
CREATE TABLE IF NOT EXISTS edw.fact_job_position_level (
  job_position_level_key BIGINT,
  tenant_slug STRING,
  nivel_key BIGINT,
  job_key BIGINT,
  job_position_id INT, -- @map <- staging.stg_organizacao_jobpositionlevel.job_position_id
  level_id INT, -- @map <- staging.stg_organizacao_jobpositionlevel.level_id
  PRIMARY KEY (job_position_level_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.PERFIL_GRUPO_USUARIO — grain (tenant_slug, id)
-- @origen: staging.stg_organizacao_perfil_grupo_usuario
-- @fk: grupo_usuario_key -> edw.dim_grupo_usuario.grupo_usuario_key
CREATE TABLE IF NOT EXISTS edw.fact_perfil_grupo_usuario (
  perfil_grupo_usuario_key BIGINT,
  tenant_slug STRING,
  grupo_usuario_key BIGINT,
  id INT, -- @map <- staging.stg_organizacao_perfil_grupo_usuario.id
  id_grupo_usuario INT, -- @map <- staging.stg_organizacao_perfil_grupo_usuario.id_grupo_usuario
  id_funcionalidade STRING, -- @map <- staging.stg_organizacao_perfil_grupo_usuario.id_funcionalidade
  pagina INT, -- @map <- staging.stg_organizacao_perfil_grupo_usuario.pagina
  PRIMARY KEY (perfil_grupo_usuario_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.TERMO_ACEITE_ASSINATURA — grain (tenant_slug, id)
-- @origen: staging.stg_organizacao_termo_aceite_assinatura
-- @fk: employee_key -> edw.dim_employee.employee_key
-- @fk: area_key -> edw.dim_org_area.area_key
-- @fk: termo_aceite_key -> edw.dim_termo_aceite.termo_aceite_key
CREATE TABLE IF NOT EXISTS edw.fact_termo_aceite_assinatura (
  termo_aceite_assinatura_key BIGINT,
  tenant_slug STRING,
  employee_key BIGINT,
  area_key BIGINT,
  termo_aceite_key BIGINT,
  id INT, -- @map <- staging.stg_organizacao_termo_aceite_assinatura.id
  id_termo_aceite INT, -- @map <- staging.stg_organizacao_termo_aceite_assinatura.id_termo_aceite
  id_area_colaborador INT, -- @map <- staging.stg_organizacao_termo_aceite_assinatura.id_area_colaborador
  id_colaborador INT, -- @map <- staging.stg_organizacao_termo_aceite_assinatura.id_colaborador
  assinatura_colaborador INT, -- @map <- staging.stg_organizacao_termo_aceite_assinatura.assinatura_colaborador
  data_assinatura_colaborador TIMESTAMP, -- @map <- staging.stg_organizacao_termo_aceite_assinatura.data_assinatura_colaborador
  id_responsavel_area INT, -- @map <- staging.stg_organizacao_termo_aceite_assinatura.id_responsavel_area
  assinatura_responsavel_area INT, -- @map <- staging.stg_organizacao_termo_aceite_assinatura.assinatura_responsavel_area
  data_assinatura_responsavel_area TIMESTAMP, -- @map <- staging.stg_organizacao_termo_aceite_assinatura.data_assinatura_responsavel_area
  tipo_assinatura_colaborador INT, -- @map <- staging.stg_organizacao_termo_aceite_assinatura.tipo_assinatura_colaborador
  tipo_assinatura_responsavel_area INT, -- @map <- staging.stg_organizacao_termo_aceite_assinatura.tipo_assinatura_responsavel_area
  PRIMARY KEY (termo_aceite_assinatura_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.TriggerArea — grain (tenant_slug, id)
-- @origen: staging.stg_organizacao_triggerarea
-- @fk: area_key -> edw.dim_org_area.area_key
-- @fk: trigger_key -> edw.dim_trigger.trigger_key
CREATE TABLE IF NOT EXISTS edw.fact_trigger_area (
  trigger_area_key BIGINT,
  tenant_slug STRING,
  area_key BIGINT,
  trigger_key BIGINT,
  id INT, -- @map <- staging.stg_organizacao_triggerarea.id
  area_id INT, -- @map <- staging.stg_organizacao_triggerarea.area_id
  trigger_id INT, -- @map <- staging.stg_organizacao_triggerarea.trigger_id
  PRIMARY KEY (trigger_area_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT competences.IndividualDevelopmentAction — grain (tenant_slug, id)
-- @origen: staging.stg_pdi_individualdevelopmentaction
-- @fk: acao_sugerida_pdi_key -> edw.dim_acao_sugerida_pdi.acao_sugerida_pdi_key
-- @fk: categoria_pdi_acao_key -> edw.dim_categoria_pdi_acao.categoria_pdi_acao_key
-- @fk: competency_key -> edw.dim_competency.competency_key
-- @fk: eval_cycle_key -> edw.dim_eval_cycle.eval_cycle_key
-- @fk: fator_avaliacao_key -> edw.dim_fator_avaliacao.fator_avaliacao_key
CREATE TABLE IF NOT EXISTS edw.fact_individual_development_action (
  individual_development_action_key BIGINT,
  tenant_slug STRING,
  acao_sugerida_pdi_key BIGINT,
  categoria_pdi_acao_key BIGINT,
  competency_key BIGINT,
  eval_cycle_key BIGINT,
  fator_avaliacao_key BIGINT,
  id INT, -- @map <- staging.stg_pdi_individualdevelopmentaction.id
  origin INT, -- @map <- staging.stg_pdi_individualdevelopmentaction.origin
  evaluation_cycle_id INT, -- @map <- staging.stg_pdi_individualdevelopmentaction.evaluation_cycle_id
  competence_id INT, -- @map <- staging.stg_pdi_individualdevelopmentaction.competence_id
  evaluation_factor_id INT, -- @map <- staging.stg_pdi_individualdevelopmentaction.evaluation_factor_id
  action_suggested_id INT, -- @map <- staging.stg_pdi_individualdevelopmentaction.action_suggested_id
  category_action_suggested_id INT, -- @map <- staging.stg_pdi_individualdevelopmentaction.category_action_suggested_id
  PRIMARY KEY (individual_development_action_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.EligibleDiscretionary — grain (tenant_slug, id)
-- @origen: staging.stg_remuneracao_eligiblediscretionary
-- @fk: calibration_group_discretionary_key -> edw.dim_calibration_group_discretionary.calibration_group_discretionary_key
-- @fk: final_range_range_discretionary_key -> edw.dim_range_discretionary.range_discretionary_key
-- @fk: medium_range_range_discretionary_key -> edw.dim_range_discretionary.range_discretionary_key
CREATE TABLE IF NOT EXISTS edw.fact_eligible_discretionary (
  eligible_discretionary_key BIGINT,
  tenant_slug STRING,
  calibration_group_discretionary_key BIGINT,
  final_range_range_discretionary_key BIGINT,
  medium_range_range_discretionary_key BIGINT,
  id INT, -- @map <- staging.stg_remuneracao_eligiblediscretionary.id
  status INT, -- @map <- staging.stg_remuneracao_eligiblediscretionary.status
  rv_participant_id INT, -- @map <- staging.stg_remuneracao_eligiblediscretionary.rv_participant_id
  create_date TIMESTAMP, -- @map <- staging.stg_remuneracao_eligiblediscretionary.create_date
  calibration_date TIMESTAMP, -- @map <- staging.stg_remuneracao_eligiblediscretionary.calibration_date
  final_range_id INT, -- @map <- staging.stg_remuneracao_eligiblediscretionary.final_range_id
  medium_range_id INT, -- @map <- staging.stg_remuneracao_eligiblediscretionary.medium_range_id
  grupo_calibragem STRING, -- @map <- staging.stg_remuneracao_eligiblediscretionary.grupo_calibragem
  calibration_group_discretionary_id INT, -- @map <- staging.stg_remuneracao_eligiblediscretionary.calibration_group_discretionary_id
  PRIMARY KEY (eligible_discretionary_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.EmployeeAnalyticResult — grain (tenant_slug, id)
-- @origen: staging.stg_remuneracao_employeeanalyticresult
CREATE TABLE IF NOT EXISTS edw.fact_employee_analytic_result (
  employee_analytic_result_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_remuneracao_employeeanalyticresult.id
  score DECIMAL(28,8), -- @map <- staging.stg_remuneracao_employeeanalyticresult.score
  multiple DECIMAL(28,8), -- @map <- staging.stg_remuneracao_employeeanalyticresult.multiple
  salary DECIMAL(28,8), -- @map <- staging.stg_remuneracao_employeeanalyticresult.salary
  score_ref DECIMAL(28,8), -- @map <- staging.stg_remuneracao_employeeanalyticresult.score_ref
  multiple_ref DECIMAL(28,8), -- @map <- staging.stg_remuneracao_employeeanalyticresult.multiple_ref
  salary_ref DECIMAL(28,8), -- @map <- staging.stg_remuneracao_employeeanalyticresult.salary_ref
  participant_id INT, -- @map <- staging.stg_remuneracao_employeeanalyticresult.participant_id
  pool_redistribution DECIMAL(28,8), -- @map <- staging.stg_remuneracao_employeeanalyticresult.pool_redistribution
  history_section_id INT, -- @map <- staging.stg_remuneracao_employeeanalyticresult.history_section_id
  PRIMARY KEY (employee_analytic_result_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.ParticipantAggregatedExtract — grain (tenant_slug, id)
-- @origen: staging.stg_remuneracao_participantaggregatedextract
CREATE TABLE IF NOT EXISTS edw.fact_participant_aggregated_extract (
  participant_aggregated_extract_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_remuneracao_participantaggregatedextract.id
  dt_ref TIMESTAMP, -- @map <- staging.stg_remuneracao_participantaggregatedextract.dt_ref
  extract BINARY, -- @map <- staging.stg_remuneracao_participantaggregatedextract.extract
  participant_id INT, -- @map <- staging.stg_remuneracao_participantaggregatedextract.participant_id
  multiple DECIMAL(28,8), -- @map <- staging.stg_remuneracao_participantaggregatedextract.multiple
  compensation DECIMAL(28,8), -- @map <- staging.stg_remuneracao_participantaggregatedextract.compensation
  PRIMARY KEY (participant_aggregated_extract_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.ParticipantExtract — grain (tenant_slug, id)
-- @origen: staging.stg_remuneracao_participantextract
CREATE TABLE IF NOT EXISTS edw.fact_participant_extract (
  participant_extract_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_remuneracao_participantextract.id
  dt_ref TIMESTAMP, -- @map <- staging.stg_remuneracao_participantextract.dt_ref
  extract BINARY, -- @map <- staging.stg_remuneracao_participantextract.extract
  released INT, -- @map <- staging.stg_remuneracao_participantextract.released
  history_section_id INT, -- @map <- staging.stg_remuneracao_participantextract.history_section_id
  participant_id INT, -- @map <- staging.stg_remuneracao_participantextract.participant_id
  participant_aggregated_extract_id INT, -- @map <- staging.stg_remuneracao_participantextract.participant_aggregated_extract_id
  score DECIMAL(28,8), -- @map <- staging.stg_remuneracao_participantextract.score
  multiple DECIMAL(28,8), -- @map <- staging.stg_remuneracao_participantextract.multiple
  compensation DECIMAL(28,8), -- @map <- staging.stg_remuneracao_participantextract.compensation
  PRIMARY KEY (participant_extract_key)
) USING DELTA;

-- @layer: edw
-- @group: fatos
-- @note: FACT dbo.ParticipantExtractControl — grain (tenant_slug, id)
-- @origen: staging.stg_remuneracao_participantextractcontrol
CREATE TABLE IF NOT EXISTS edw.fact_participant_extract_control (
  participant_extract_control_key BIGINT,
  tenant_slug STRING,
  id INT, -- @map <- staging.stg_remuneracao_participantextractcontrol.id
  dt_ref TIMESTAMP, -- @map <- staging.stg_remuneracao_participantextractcontrol.dt_ref
  released INT, -- @map <- staging.stg_remuneracao_participantextractcontrol.released
  participant_id INT, -- @map <- staging.stg_remuneracao_participantextractcontrol.participant_id
  history_section_id INT, -- @map <- staging.stg_remuneracao_participantextractcontrol.history_section_id
  PRIMARY KEY (participant_extract_control_key)
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
-- @note: FACT dbo.SuccessionScoresDetails — grain (tenant_slug, id)
-- @origen: staging.stg_sucessao_successionscoresdetails
-- @fk: succession_cycle_settings_key -> edw.dim_succession_cycle_settings.succession_cycle_settings_key
CREATE TABLE IF NOT EXISTS edw.fact_succession_scores_details (
  succession_scores_details_key BIGINT,
  tenant_slug STRING,
  succession_cycle_settings_key BIGINT,
  id INT, -- @map <- staging.stg_sucessao_successionscoresdetails.id
  max_score DECIMAL(18,2), -- @map <- staging.stg_sucessao_successionscoresdetails.max_score
  min_score DECIMAL(18,2), -- @map <- staging.stg_sucessao_successionscoresdetails.min_score
  reference_score DECIMAL(18,2), -- @map <- staging.stg_sucessao_successionscoresdetails.reference_score
  dimension INT, -- @map <- staging.stg_sucessao_successionscoresdetails.dimension
  succession_cycle_settings_id INT, -- @map <- staging.stg_sucessao_successionscoresdetails.succession_cycle_settings_id
  PRIMARY KEY (succession_scores_details_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ANEXO_REUNIAO — stub sem dados piloto; origem reservada raw.dbo__ANEXO_REUNIAO via staging.stg_acao_anexo_reuniao
CREATE TABLE IF NOT EXISTS edw.defer_anexo_reuniao (
  anexo_reuniao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (anexo_reuniao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.DIARIO_DE_BORDO — stub sem dados piloto; origem reservada raw.dbo__DIARIO_DE_BORDO via staging.stg_acao_diario_de_bordo
CREATE TABLE IF NOT EXISTS edw.defer_diario_de_bordo (
  diario_de_bordo_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (diario_de_bordo_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.GESTOR_MARCADOR_ACAO — stub sem dados piloto; origem reservada raw.dbo__GESTOR_MARCADOR_ACAO via staging.stg_acao_gestor_marcador_acao
CREATE TABLE IF NOT EXISTS edw.defer_gestor_marcador_acao (
  gestor_marcador_acao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (gestor_marcador_acao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.KnowledgeManagement — stub sem dados piloto; origem reservada raw.dbo__KnowledgeManagement via staging.stg_acao_knowledgemanagement
CREATE TABLE IF NOT EXISTS edw.defer_knowledgemanagement (
  knowledgemanagement_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (knowledgemanagement_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.MARCADOR_ACAO — stub sem dados piloto; origem reservada raw.dbo__MARCADOR_ACAO via staging.stg_acao_marcador_acao
CREATE TABLE IF NOT EXISTS edw.defer_marcador_acao (
  marcador_acao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (marcador_acao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.MARCADOR_ACAO_ITEM — stub sem dados piloto; origem reservada raw.dbo__MARCADOR_ACAO_ITEM via staging.stg_acao_marcador_acao_item
CREATE TABLE IF NOT EXISTS edw.defer_marcador_acao_item (
  marcador_acao_item_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (marcador_acao_item_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.PARTICIPANTE_REUNIAO — stub sem dados piloto; origem reservada raw.dbo__PARTICIPANTE_REUNIAO via staging.stg_acao_participante_reuniao
CREATE TABLE IF NOT EXISTS edw.defer_participante_reuniao (
  participante_reuniao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (participante_reuniao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.QUICK_MEETING — stub sem dados piloto; origem reservada raw.dbo__QUICK_MEETING via staging.stg_acao_quick_meeting
CREATE TABLE IF NOT EXISTS edw.defer_quick_meeting (
  quick_meeting_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (quick_meeting_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.REFERENCIA_CONTRAMEDIDA — stub sem dados piloto; origem reservada raw.dbo__REFERENCIA_CONTRAMEDIDA via staging.stg_acao_referencia_contramedida
CREATE TABLE IF NOT EXISTS edw.defer_referencia_contramedida (
  referencia_contramedida_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (referencia_contramedida_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.REUNIAO — stub sem dados piloto; origem reservada raw.dbo__REUNIAO via staging.stg_acao_reuniao
CREATE TABLE IF NOT EXISTS edw.defer_reuniao (
  reuniao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (reuniao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.REUNIAO_PAUSE — stub sem dados piloto; origem reservada raw.dbo__REUNIAO_PAUSE via staging.stg_acao_reuniao_pause
CREATE TABLE IF NOT EXISTS edw.defer_reuniao_pause (
  reuniao_pause_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (reuniao_pause_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.TOPICO_REUNIAO — stub sem dados piloto; origem reservada raw.dbo__TOPICO_REUNIAO via staging.stg_acao_topico_reuniao
CREATE TABLE IF NOT EXISTS edw.defer_topico_reuniao (
  topico_reuniao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (topico_reuniao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.VOTACAO_CAUSA — stub sem dados piloto; origem reservada raw.dbo__VOTACAO_CAUSA via staging.stg_acao_votacao_causa
CREATE TABLE IF NOT EXISTS edw.defer_votacao_causa (
  votacao_causa_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (votacao_causa_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.AVALIACAO_CONTINUA — stub sem dados piloto; origem reservada raw.dbo__AVALIACAO_CONTINUA via staging.stg_avaliacao_avaliacao_continua
CREATE TABLE IF NOT EXISTS edw.defer_avaliacao_continua (
  avaliacao_continua_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (avaliacao_continua_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.CALC_RESULTADO_AVALIADOR_TIPO_COMPETENCIA — stub sem dados piloto; origem reservada raw.dbo__CALC_RESULTADO_AVALIADOR_TIPO_COMPETENCIA via staging.stg_avaliacao_calc_resultado_avaliador_tipo_competencia
CREATE TABLE IF NOT EXISTS edw.defer_calc_resultado_avaliador_tipo_competencia (
  calc_resultado_avaliador_tipo_competencia_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (calc_resultado_avaliador_tipo_competencia_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.CALC_RESULTADO_IMPACTO — stub sem dados piloto; origem reservada raw.dbo__CALC_RESULTADO_IMPACTO via staging.stg_avaliacao_calc_resultado_impacto
CREATE TABLE IF NOT EXISTS edw.defer_calc_resultado_impacto (
  calc_resultado_impacto_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (calc_resultado_impacto_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.CALC_RESULTADO_RISCO — stub sem dados piloto; origem reservada raw.dbo__CALC_RESULTADO_RISCO via staging.stg_avaliacao_calc_resultado_risco
CREATE TABLE IF NOT EXISTS edw.defer_calc_resultado_risco (
  calc_resultado_risco_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (calc_resultado_risco_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.CALC_RESULTADO_TIPO_AVALIADOR_TIPO_COMPETENCIA — stub sem dados piloto; origem reservada raw.dbo__CALC_RESULTADO_TIPO_AVALIADOR_TIPO_COMPETENCIA via staging.stg_avaliacao_calc_resultado_tipo_avaliador_tipo_competencia
CREATE TABLE IF NOT EXISTS edw.defer_calc_resultado_tipo_avaliador_tipo_competencia (
  calc_resultado_tipo_avaliador_tipo_competencia_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (calc_resultado_tipo_avaliador_tipo_competencia_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.CALIBRADOS_PERFORMANCE — stub sem dados piloto; origem reservada raw.dbo__CALIBRADOS_PERFORMANCE via staging.stg_avaliacao_calibrados_performance
CREATE TABLE IF NOT EXISTS edw.defer_calibrados_performance (
  calibrados_performance_key BIGINT,
  tenant_slug STRING,
  PRIMARY KEY (calibrados_performance_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.COMENTARIO_AVALIADO_FORUM_SUCESSAO — stub sem dados piloto; origem reservada raw.dbo__COMENTARIO_AVALIADO_FORUM_SUCESSAO via staging.stg_avaliacao_comentario_avaliado_forum_sucessao
CREATE TABLE IF NOT EXISTS edw.defer_comentario_avaliado_forum_sucessao (
  comentario_avaliado_forum_sucessao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (comentario_avaliado_forum_sucessao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.DeliberationOption — stub sem dados piloto; origem reservada raw.dbo__DeliberationOption via staging.stg_avaliacao_deliberationoption
CREATE TABLE IF NOT EXISTS edw.defer_deliberationoption (
  deliberationoption_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (deliberationoption_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.EffectivenessEvaluation — stub sem dados piloto; origem reservada raw.dbo__EffectivenessEvaluation via staging.stg_avaliacao_effectivenessevaluation
CREATE TABLE IF NOT EXISTS edw.defer_effectivenessevaluation (
  effectivenessevaluation_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (effectivenessevaluation_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.EvaluationCycleQuadrantPersonalization — stub sem dados piloto; origem reservada raw.dbo__EvaluationCycleQuadrantPersonalization via staging.stg_avaliacao_evaluationcyclequadrantpersonalization
CREATE TABLE IF NOT EXISTS edw.defer_evaluationcyclequadrantpersonalization (
  evaluationcyclequadrantpersonalization_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (evaluationcyclequadrantpersonalization_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.FORMULARIO_AVALIACAO_ABA — stub sem dados piloto; origem reservada raw.dbo__FORMULARIO_AVALIACAO_ABA via staging.stg_avaliacao_formulario_avaliacao_aba
CREATE TABLE IF NOT EXISTS edw.defer_formulario_avaliacao_aba (
  formulario_avaliacao_aba_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (formulario_avaliacao_aba_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.FORMULARIO_AVALIACAO_ABA_ITEM — stub sem dados piloto; origem reservada raw.dbo__FORMULARIO_AVALIACAO_ABA_ITEM via staging.stg_avaliacao_formulario_avaliacao_aba_item
CREATE TABLE IF NOT EXISTS edw.defer_formulario_avaliacao_aba_item (
  formulario_avaliacao_aba_item_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (formulario_avaliacao_aba_item_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.GRUPO_CARGO_AVALIACAO — stub sem dados piloto; origem reservada raw.dbo__GRUPO_CARGO_AVALIACAO via staging.stg_avaliacao_grupo_cargo_avaliacao
CREATE TABLE IF NOT EXISTS edw.defer_grupo_cargo_avaliacao (
  grupo_cargo_avaliacao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (grupo_cargo_avaliacao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.INSTANCIA_PARTICIPANTE_COMPETENCIA — stub sem dados piloto; origem reservada raw.dbo__INSTANCIA_PARTICIPANTE_COMPETENCIA via staging.stg_avaliacao_instancia_participante_competencia
CREATE TABLE IF NOT EXISTS edw.defer_instancia_participante_competencia (
  instancia_participante_competencia_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (instancia_participante_competencia_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ITEM_FEEDBACK — stub sem dados piloto; origem reservada raw.dbo__ITEM_FEEDBACK via staging.stg_avaliacao_item_feedback
CREATE TABLE IF NOT EXISTS edw.defer_item_feedback (
  item_feedback_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (item_feedback_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER competences.ItensSenderToReleaseAppraiseesQueue — stub sem dados piloto; origem reservada raw.competences__ItensSenderToReleaseAppraiseesQueue via staging.stg_avaliacao_itenssendertoreleaseappraiseesqueue
CREATE TABLE IF NOT EXISTS edw.defer_itenssendertoreleaseappraiseesqueue (
  itenssendertoreleaseappraiseesqueue_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (itenssendertoreleaseappraiseesqueue_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.JobEvaluationSuccession — stub sem dados piloto; origem reservada raw.dbo__JobEvaluationSuccession via staging.stg_avaliacao_jobevaluationsuccession
CREATE TABLE IF NOT EXISTS edw.defer_jobevaluationsuccession (
  jobevaluationsuccession_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (jobevaluationsuccession_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER competences.LOCALIDADE_INTERESSE_MUDANCA_AVALIADO — stub sem dados piloto; origem reservada raw.competences__LOCALIDADE_INTERESSE_MUDANCA_AVALIADO via staging.stg_avaliacao_localidade_interesse_mudanca_avaliado
CREATE TABLE IF NOT EXISTS edw.defer_localidade_interesse_mudanca_avaliado (
  localidade_interesse_mudanca_avaliado_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (localidade_interesse_mudanca_avaliado_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.OPCAO_PULSE_FEEDBACK_CONTINUO — stub sem dados piloto; origem reservada raw.dbo__OPCAO_PULSE_FEEDBACK_CONTINUO via staging.stg_avaliacao_opcao_pulse_feedback_continuo
CREATE TABLE IF NOT EXISTS edw.defer_opcao_pulse_feedback_continuo (
  opcao_pulse_feedback_continuo_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (opcao_pulse_feedback_continuo_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.PARTICIPANTE_PULSE_FEEDBACK_CONTINUO — stub sem dados piloto; origem reservada raw.dbo__PARTICIPANTE_PULSE_FEEDBACK_CONTINUO via staging.stg_avaliacao_participante_pulse_feedback_continuo
CREATE TABLE IF NOT EXISTS edw.defer_participante_pulse_feedback_continuo (
  participante_pulse_feedback_continuo_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (participante_pulse_feedback_continuo_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.PERIODO_AVALIACAO_PROJETO — stub sem dados piloto; origem reservada raw.dbo__PERIODO_AVALIACAO_PROJETO via staging.stg_avaliacao_periodo_avaliacao_projeto
CREATE TABLE IF NOT EXISTS edw.defer_periodo_avaliacao_projeto (
  periodo_avaliacao_projeto_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (periodo_avaliacao_projeto_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.PROJETO_AVALIACAO — stub sem dados piloto; origem reservada raw.dbo__PROJETO_AVALIACAO via staging.stg_avaliacao_projeto_avaliacao
CREATE TABLE IF NOT EXISTS edw.defer_projeto_avaliacao (
  projeto_avaliacao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (projeto_avaliacao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.PULSE_FEEDBACK_CONTINUO — stub sem dados piloto; origem reservada raw.dbo__PULSE_FEEDBACK_CONTINUO via staging.stg_avaliacao_pulse_feedback_continuo
CREATE TABLE IF NOT EXISTS edw.defer_pulse_feedback_continuo (
  pulse_feedback_continuo_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (pulse_feedback_continuo_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.Question — stub sem dados piloto; origem reservada raw.dbo__Question via staging.stg_avaliacao_question
CREATE TABLE IF NOT EXISTS edw.defer_question (
  question_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (question_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.QuestionsEffectivenessEvaluations — stub sem dados piloto; origem reservada raw.dbo__QuestionsEffectivenessEvaluations via staging.stg_avaliacao_questionseffectivenessevaluations
CREATE TABLE IF NOT EXISTS edw.defer_questionseffectivenessevaluations (
  questionseffectivenessevaluations_key BIGINT,
  tenant_slug STRING,
  effectiveness_evaluation_id BIGINT,
  question_id BIGINT,
  PRIMARY KEY (questionseffectivenessevaluations_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.QuestionsReactionEvaluations — stub sem dados piloto; origem reservada raw.dbo__QuestionsReactionEvaluations via staging.stg_avaliacao_questionsreactionevaluations
CREATE TABLE IF NOT EXISTS edw.defer_questionsreactionevaluations (
  questionsreactionevaluations_key BIGINT,
  tenant_slug STRING,
  reaction_evaluation_id BIGINT,
  question_id BIGINT,
  PRIMARY KEY (questionsreactionevaluations_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ReactionEvaluation — stub sem dados piloto; origem reservada raw.dbo__ReactionEvaluation via staging.stg_avaliacao_reactionevaluation
CREATE TABLE IF NOT EXISTS edw.defer_reactionevaluation (
  reactionevaluation_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (reactionevaluation_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.RESPOSTA_AVALIACAO_SUCESSAO — stub sem dados piloto; origem reservada raw.dbo__RESPOSTA_AVALIACAO_SUCESSAO via staging.stg_avaliacao_resposta_avaliacao_sucessao
CREATE TABLE IF NOT EXISTS edw.defer_resposta_avaliacao_sucessao (
  resposta_avaliacao_sucessao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (resposta_avaliacao_sucessao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.RESPOSTA_PULSE_FEEDBACK_CONTINUO — stub sem dados piloto; origem reservada raw.dbo__RESPOSTA_PULSE_FEEDBACK_CONTINUO via staging.stg_avaliacao_resposta_pulse_feedback_continuo
CREATE TABLE IF NOT EXISTS edw.defer_resposta_pulse_feedback_continuo (
  resposta_pulse_feedback_continuo_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (resposta_pulse_feedback_continuo_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.Absence — stub sem dados piloto; origem reservada raw.dbo__Absence via staging.stg_colaborador_absence
CREATE TABLE IF NOT EXISTS edw.defer_absence (
  absence_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (absence_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ChangeHistory — stub sem dados piloto; origem reservada raw.dbo__ChangeHistory via staging.stg_colaborador_changehistory
CREATE TABLE IF NOT EXISTS edw.defer_changehistory (
  changehistory_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (changehistory_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.COLABORADOR_DATA_EXTRACT — stub sem dados piloto; origem reservada raw.dbo__COLABORADOR_DATA_EXTRACT via staging.stg_colaborador_colaborador_data_extract
CREATE TABLE IF NOT EXISTS edw.defer_colaborador_data_extract (
  colaborador_data_extract_key BIGINT,
  tenant_slug STRING,
  PRIMARY KEY (colaborador_data_extract_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.Demand — stub sem dados piloto; origem reservada raw.dbo__Demand via staging.stg_colaborador_demand
CREATE TABLE IF NOT EXISTS edw.defer_demand (
  demand_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (demand_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.DemandsParticipants — stub sem dados piloto; origem reservada raw.dbo__DemandsParticipants via staging.stg_colaborador_demandsparticipants
CREATE TABLE IF NOT EXISTS edw.defer_demandsparticipants (
  demandsparticipants_key BIGINT,
  tenant_slug STRING,
  demand_id BIGINT,
  employee_id BIGINT,
  PRIMARY KEY (demandsparticipants_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ForumSyncLog — stub sem dados piloto; origem reservada raw.dbo__ForumSyncLog via staging.stg_colaborador_forumsynclog
CREATE TABLE IF NOT EXISTS edw.defer_forumsynclog (
  forumsynclog_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (forumsynclog_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.GoalAuditHistory — stub sem dados piloto; origem reservada raw.dbo__GoalAuditHistory via staging.stg_colaborador_goalaudithistory
CREATE TABLE IF NOT EXISTS edw.defer_goalaudithistory (
  goalaudithistory_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (goalaudithistory_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.GoalBookAttachment — stub sem dados piloto; origem reservada raw.dbo__GoalBookAttachment via staging.stg_colaborador_goalbookattachment
CREATE TABLE IF NOT EXISTS edw.defer_goalbookattachment (
  goalbookattachment_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (goalbookattachment_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.GroupOfEmployees — stub sem dados piloto; origem reservada raw.dbo__GroupOfEmployees via staging.stg_colaborador_groupofemployees
CREATE TABLE IF NOT EXISTS edw.defer_groupofemployees (
  groupofemployees_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (groupofemployees_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.GroupOfEmployeesParticipants — stub sem dados piloto; origem reservada raw.dbo__GroupOfEmployeesParticipants via staging.stg_colaborador_groupofemployeesparticipants
CREATE TABLE IF NOT EXISTS edw.defer_groupofemployeesparticipants (
  groupofemployeesparticipants_key BIGINT,
  tenant_slug STRING,
  group_of_employees_id BIGINT,
  employee_id BIGINT,
  PRIMARY KEY (groupofemployeesparticipants_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.INSTANCIA_CALIBRADOS — stub sem dados piloto; origem reservada raw.dbo__INSTANCIA_CALIBRADOS via staging.stg_colaborador_instancia_calibrados
CREATE TABLE IF NOT EXISTS edw.defer_instancia_calibrados (
  instancia_calibrados_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (instancia_calibrados_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.INSTANCIA_CALIBRADOS_PERFORMANCE — stub sem dados piloto; origem reservada raw.dbo__INSTANCIA_CALIBRADOS_PERFORMANCE via staging.stg_colaborador_instancia_calibrados_performance
CREATE TABLE IF NOT EXISTS edw.defer_instancia_calibrados_performance (
  instancia_calibrados_performance_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (instancia_calibrados_performance_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.JobEvaluationAnswerSuccession — stub sem dados piloto; origem reservada raw.dbo__JobEvaluationAnswerSuccession via staging.stg_colaborador_jobevaluationanswersuccession
CREATE TABLE IF NOT EXISTS edw.defer_jobevaluationanswersuccession (
  jobevaluationanswersuccession_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (jobevaluationanswersuccession_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.KPIStakeholder — stub sem dados piloto; origem reservada raw.dbo__KPIStakeholder via staging.stg_colaborador_kpistakeholder
CREATE TABLE IF NOT EXISTS edw.defer_kpistakeholder (
  kpistakeholder_key BIGINT,
  tenant_slug STRING,
  kpi_id BIGINT,
  stakeholder_id BIGINT,
  PRIMARY KEY (kpistakeholder_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.LabelEmployee — stub sem dados piloto; origem reservada raw.dbo__LabelEmployee via staging.stg_colaborador_labelemployee
CREATE TABLE IF NOT EXISTS edw.defer_labelemployee (
  labelemployee_key BIGINT,
  tenant_slug STRING,
  id_label BIGINT,
  id_employee BIGINT,
  PRIMARY KEY (labelemployee_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.META_DATA_EXTRACT — stub sem dados piloto; origem reservada raw.dbo__META_DATA_EXTRACT via staging.stg_colaborador_meta_data_extract
CREATE TABLE IF NOT EXISTS edw.defer_meta_data_extract (
  meta_data_extract_key BIGINT,
  tenant_slug STRING,
  PRIMARY KEY (meta_data_extract_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.Need — stub sem dados piloto; origem reservada raw.dbo__Need via staging.stg_colaborador_need
CREATE TABLE IF NOT EXISTS edw.defer_need (
  need_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (need_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.PERMISSAO_DASHBOARD — stub sem dados piloto; origem reservada raw.dbo__PERMISSAO_DASHBOARD via staging.stg_colaborador_permissao_dashboard
CREATE TABLE IF NOT EXISTS edw.defer_permissao_dashboard (
  permissao_dashboard_key BIGINT,
  tenant_slug STRING,
  PRIMARY KEY (permissao_dashboard_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.PermissaoFinanceira — stub sem dados piloto; origem reservada raw.dbo__PermissaoFinanceira via staging.stg_colaborador_permissaofinanceira
CREATE TABLE IF NOT EXISTS edw.defer_permissaofinanceira (
  permissaofinanceira_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (permissaofinanceira_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.Response — stub sem dados piloto; origem reservada raw.dbo__Response via staging.stg_colaborador_response
CREATE TABLE IF NOT EXISTS edw.defer_response (
  response_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (response_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.Stakeholder — stub sem dados piloto; origem reservada raw.dbo__Stakeholder via staging.stg_colaborador_stakeholder
CREATE TABLE IF NOT EXISTS edw.defer_stakeholder (
  stakeholder_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (stakeholder_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.StakeholdersCommittees — stub sem dados piloto; origem reservada raw.dbo__StakeholdersCommittees via staging.stg_colaborador_stakeholderscommittees
CREATE TABLE IF NOT EXISTS edw.defer_stakeholderscommittees (
  stakeholderscommittees_key BIGINT,
  tenant_slug STRING,
  stakeholder_id BIGINT,
  employee_id BIGINT,
  PRIMARY KEY (stakeholderscommittees_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.StakeholdersProject — stub sem dados piloto; origem reservada raw.dbo__StakeholdersProject via staging.stg_colaborador_stakeholdersproject
CREATE TABLE IF NOT EXISTS edw.defer_stakeholdersproject (
  stakeholdersproject_key BIGINT,
  tenant_slug STRING,
  strategy_goal_project_id BIGINT,
  employee_id BIGINT,
  PRIMARY KEY (stakeholdersproject_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.WelcomeSupportEmployee — stub sem dados piloto; origem reservada raw.dbo__WelcomeSupportEmployee via staging.stg_colaborador_welcomesupportemployee
CREATE TABLE IF NOT EXISTS edw.defer_welcomesupportemployee (
  welcomesupportemployee_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (welcomesupportemployee_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.AdvancePaymentConfig — stub sem dados piloto; origem reservada raw.dbo__AdvancePaymentConfig via staging.stg_metricas_advancepaymentconfig
CREATE TABLE IF NOT EXISTS edw.defer_advancepaymentconfig (
  advancepaymentconfig_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (advancepaymentconfig_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.AREA_BOOK — stub sem dados piloto; origem reservada raw.dbo__AREA_BOOK via staging.stg_metricas_area_book
CREATE TABLE IF NOT EXISTS edw.defer_area_book (
  area_book_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (area_book_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.AreasGroup — stub sem dados piloto; origem reservada raw.dbo__AreasGroup via staging.stg_metricas_areasgroup
CREATE TABLE IF NOT EXISTS edw.defer_areasgroup (
  areasgroup_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (areasgroup_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ArvoreMembrosQuebra — stub sem dados piloto; origem reservada raw.dbo__ArvoreMembrosQuebra via staging.stg_metricas_arvoremembrosquebra
CREATE TABLE IF NOT EXISTS edw.defer_arvoremembrosquebra (
  arvoremembrosquebra_key BIGINT,
  tenant_slug STRING,
  PRIMARY KEY (arvoremembrosquebra_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.CategoryAnalysis — stub sem dados piloto; origem reservada raw.dbo__CategoryAnalysis via staging.stg_metricas_categoryanalysis
CREATE TABLE IF NOT EXISTS edw.defer_categoryanalysis (
  categoryanalysis_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (categoryanalysis_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.COLABORADOR_SCORE — stub sem dados piloto; origem reservada raw.dbo__COLABORADOR_SCORE via staging.stg_metricas_colaborador_score
CREATE TABLE IF NOT EXISTS edw.defer_colaborador_score (
  colaborador_score_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (colaborador_score_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.CURVA_PONTUACAO — stub sem dados piloto; origem reservada raw.dbo__CURVA_PONTUACAO via staging.stg_metricas_curva_pontuacao
CREATE TABLE IF NOT EXISTS edw.defer_curva_pontuacao (
  curva_pontuacao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (curva_pontuacao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.Dimensao — stub sem dados piloto; origem reservada raw.dbo__Dimensao via staging.stg_metricas_dimensao
CREATE TABLE IF NOT EXISTS edw.defer_dimensao (
  dimensao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (dimensao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER okr.EmployeeKeyResult — stub sem dados piloto; origem reservada raw.okr__EmployeeKeyResult via staging.stg_metricas_employeekeyresult
CREATE TABLE IF NOT EXISTS edw.defer_employeekeyresult (
  employeekeyresult_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (employeekeyresult_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ExtractControl — stub sem dados piloto; origem reservada raw.dbo__ExtractControl via staging.stg_metricas_extractcontrol
CREATE TABLE IF NOT EXISTS edw.defer_extractcontrol (
  extractcontrol_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (extractcontrol_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.FAIXA_CLASSIFICACAO — stub sem dados piloto; origem reservada raw.dbo__FAIXA_CLASSIFICACAO via staging.stg_metricas_faixa_classificacao
CREATE TABLE IF NOT EXISTS edw.defer_faixa_classificacao (
  faixa_classificacao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (faixa_classificacao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.FAIXA_CLASSIFICACAO_PERFORMANCE — stub sem dados piloto; origem reservada raw.dbo__FAIXA_CLASSIFICACAO_PERFORMANCE via staging.stg_metricas_faixa_classificacao_performance
CREATE TABLE IF NOT EXISTS edw.defer_faixa_classificacao_performance (
  faixa_classificacao_performance_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (faixa_classificacao_performance_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.GoalObservation — stub sem dados piloto; origem reservada raw.dbo__GoalObservation via staging.stg_metricas_goalobservation
CREATE TABLE IF NOT EXISTS edw.defer_goalobservation (
  goalobservation_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (goalobservation_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.GRUPO_INDICADOR_ASSOCIADO — stub sem dados piloto; origem reservada raw.dbo__GRUPO_INDICADOR_ASSOCIADO via staging.stg_metricas_grupo_indicador_associado
CREATE TABLE IF NOT EXISTS edw.defer_grupo_indicador_associado (
  grupo_indicador_associado_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (grupo_indicador_associado_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.INDICADOR_TIPOMETA_BOOK — stub sem dados piloto; origem reservada raw.dbo__INDICADOR_TIPOMETA_BOOK via staging.stg_metricas_indicador_tipometa_book
CREATE TABLE IF NOT EXISTS edw.defer_indicador_tipometa_book (
  indicador_tipometa_book_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (indicador_tipometa_book_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.Initiative — stub sem dados piloto; origem reservada raw.dbo__Initiative via staging.stg_metricas_initiative
CREATE TABLE IF NOT EXISTS edw.defer_initiative (
  initiative_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (initiative_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ItemSwotAnalysis — stub sem dados piloto; origem reservada raw.dbo__ItemSwotAnalysis via staging.stg_metricas_itemswotanalysis
CREATE TABLE IF NOT EXISTS edw.defer_itemswotanalysis (
  itemswotanalysis_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (itemswotanalysis_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ItemSwotAnalysisRelationship — stub sem dados piloto; origem reservada raw.dbo__ItemSwotAnalysisRelationship via staging.stg_metricas_itemswotanalysisrelationship
CREATE TABLE IF NOT EXISTS edw.defer_itemswotanalysisrelationship (
  itemswotanalysisrelationship_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (itemswotanalysisrelationship_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ItemSwotAnalysisRelationshipItemSwotAnalysis — stub sem dados piloto; origem reservada raw.dbo__ItemSwotAnalysisRelationshipItemSwotAnalysis via staging.stg_metricas_itemswotanalysisrelationshipitemswotanalysis
CREATE TABLE IF NOT EXISTS edw.defer_itemswotanalysisrelationshipitemswotanalysis (
  itemswotanalysisrelationshipitemswotanalysis_key BIGINT,
  tenant_slug STRING,
  item_swot_analysis_relationship_id BIGINT,
  item_swot_analysis_id BIGINT,
  PRIMARY KEY (itemswotanalysisrelationshipitemswotanalysis_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER okr.KeyResult — stub sem dados piloto; origem reservada raw.okr__KeyResult via staging.stg_metricas_keyresult
CREATE TABLE IF NOT EXISTS edw.defer_keyresult (
  keyresult_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (keyresult_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER okr.KeyResultProgress — stub sem dados piloto; origem reservada raw.okr__KeyResultProgress via staging.stg_metricas_keyresultprogress
CREATE TABLE IF NOT EXISTS edw.defer_keyresultprogress (
  keyresultprogress_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (keyresultprogress_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER okr.KeyResultValue — stub sem dados piloto; origem reservada raw.okr__KeyResultValue via staging.stg_metricas_keyresultvalue
CREATE TABLE IF NOT EXISTS edw.defer_keyresultvalue (
  keyresultvalue_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (keyresultvalue_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.Matriz — stub sem dados piloto; origem reservada raw.dbo__Matriz via staging.stg_metricas_matriz
CREATE TABLE IF NOT EXISTS edw.defer_matriz (
  matriz_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (matriz_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.MembroDimensao — stub sem dados piloto; origem reservada raw.dbo__MembroDimensao via staging.stg_metricas_membrodimensao
CREATE TABLE IF NOT EXISTS edw.defer_membrodimensao (
  membrodimensao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (membrodimensao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.METABOOK — stub sem dados piloto; origem reservada raw.dbo__METABOOK via staging.stg_metricas_metabook
CREATE TABLE IF NOT EXISTS edw.defer_metabook (
  metabook_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (metabook_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.MonthlyGoal — stub sem dados piloto; origem reservada raw.dbo__MonthlyGoal via staging.stg_metricas_monthlygoal
CREATE TABLE IF NOT EXISTS edw.defer_monthlygoal (
  monthlygoal_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (monthlygoal_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.NivelMembros — stub sem dados piloto; origem reservada raw.dbo__NivelMembros via staging.stg_metricas_nivelmembros
CREATE TABLE IF NOT EXISTS edw.defer_nivelmembros (
  nivelmembros_key BIGINT,
  tenant_slug STRING,
  PRIMARY KEY (nivelmembros_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.NOTA_BOOK — stub sem dados piloto; origem reservada raw.dbo__NOTA_BOOK via staging.stg_metricas_nota_book
CREATE TABLE IF NOT EXISTS edw.defer_nota_book (
  nota_book_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (nota_book_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.NOTA_META_BOOK — stub sem dados piloto; origem reservada raw.dbo__NOTA_META_BOOK via staging.stg_metricas_nota_meta_book
CREATE TABLE IF NOT EXISTS edw.defer_nota_meta_book (
  nota_meta_book_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (nota_meta_book_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER okr.Objective — stub sem dados piloto; origem reservada raw.okr__Objective via staging.stg_metricas_objective
CREATE TABLE IF NOT EXISTS edw.defer_objective (
  objective_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (objective_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER okr.ObjectiveProgress — stub sem dados piloto; origem reservada raw.okr__ObjectiveProgress via staging.stg_metricas_objectiveprogress
CREATE TABLE IF NOT EXISTS edw.defer_objectiveprogress (
  objectiveprogress_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (objectiveprogress_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER okr.ObjectiveTree — stub sem dados piloto; origem reservada raw.okr__ObjectiveTree via staging.stg_metricas_objectivetree
CREATE TABLE IF NOT EXISTS edw.defer_objectivetree (
  objectivetree_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (objectivetree_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.Perspective — stub sem dados piloto; origem reservada raw.dbo__Perspective via staging.stg_metricas_perspective
CREATE TABLE IF NOT EXISTS edw.defer_perspective (
  perspective_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (perspective_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.StrategyAction — stub sem dados piloto; origem reservada raw.dbo__StrategyAction via staging.stg_metricas_strategyaction
CREATE TABLE IF NOT EXISTS edw.defer_strategyaction (
  strategyaction_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (strategyaction_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.StrategyAnalysis — stub sem dados piloto; origem reservada raw.dbo__StrategyAnalysis via staging.stg_metricas_strategyanalysis
CREATE TABLE IF NOT EXISTS edw.defer_strategyanalysis (
  strategyanalysis_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (strategyanalysis_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.StrategyAnalysisAttachment — stub sem dados piloto; origem reservada raw.dbo__StrategyAnalysisAttachment via staging.stg_metricas_strategyanalysisattachment
CREATE TABLE IF NOT EXISTS edw.defer_strategyanalysisattachment (
  strategyanalysisattachment_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (strategyanalysisattachment_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.StrategyCycle — stub sem dados piloto; origem reservada raw.dbo__StrategyCycle via staging.stg_metricas_strategycycle
CREATE TABLE IF NOT EXISTS edw.defer_strategycycle (
  strategycycle_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (strategycycle_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.StrategyGoal — stub sem dados piloto; origem reservada raw.dbo__StrategyGoal via staging.stg_metricas_strategygoal
CREATE TABLE IF NOT EXISTS edw.defer_strategygoal (
  strategygoal_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (strategygoal_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.StrategyGoalMetric — stub sem dados piloto; origem reservada raw.dbo__StrategyGoalMetric via staging.stg_metricas_strategygoalmetric
CREATE TABLE IF NOT EXISTS edw.defer_strategygoalmetric (
  strategygoalmetric_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (strategygoalmetric_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.StrategyGoalMetricValue — stub sem dados piloto; origem reservada raw.dbo__StrategyGoalMetricValue via staging.stg_metricas_strategygoalmetricvalue
CREATE TABLE IF NOT EXISTS edw.defer_strategygoalmetricvalue (
  strategygoalmetricvalue_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (strategygoalmetricvalue_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.StrategyGoalProject — stub sem dados piloto; origem reservada raw.dbo__StrategyGoalProject via staging.stg_metricas_strategygoalproject
CREATE TABLE IF NOT EXISTS edw.defer_strategygoalproject (
  strategygoalproject_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (strategygoalproject_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.StrategyGoalProjectValue — stub sem dados piloto; origem reservada raw.dbo__StrategyGoalProjectValue via staging.stg_metricas_strategygoalprojectvalue
CREATE TABLE IF NOT EXISTS edw.defer_strategygoalprojectvalue (
  strategygoalprojectvalue_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (strategygoalprojectvalue_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.SwotAnalysis — stub sem dados piloto; origem reservada raw.dbo__SwotAnalysis via staging.stg_metricas_swotanalysis
CREATE TABLE IF NOT EXISTS edw.defer_swotanalysis (
  swotanalysis_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (swotanalysis_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER okr.ToDoKR — stub sem dados piloto; origem reservada raw.okr__ToDoKR via staging.stg_metricas_todokr
CREATE TABLE IF NOT EXISTS edw.defer_todokr (
  todokr_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (todokr_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.VALOR_META_BOOK — stub sem dados piloto; origem reservada raw.dbo__VALOR_META_BOOK via staging.stg_metricas_valor_meta_book
CREATE TABLE IF NOT EXISTS edw.defer_valor_meta_book (
  valor_meta_book_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (valor_meta_book_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ValorMatriz — stub sem dados piloto; origem reservada raw.dbo__ValorMatriz via staging.stg_metricas_valormatriz
CREATE TABLE IF NOT EXISTS edw.defer_valormatriz (
  valormatriz_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (valormatriz_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.Visao — stub sem dados piloto; origem reservada raw.dbo__Visao via staging.stg_metricas_visao
CREATE TABLE IF NOT EXISTS edw.defer_visao (
  visao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (visao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER competences.AREA_INTERESSE_MUDANCA_AVALIADO — stub sem dados piloto; origem reservada raw.competences__AREA_INTERESSE_MUDANCA_AVALIADO via staging.stg_organizacao_area_interesse_mudanca_avaliado
CREATE TABLE IF NOT EXISTS edw.defer_area_interesse_mudanca_avaliado (
  area_interesse_mudanca_avaliado_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (area_interesse_mudanca_avaliado_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.AreasGroupItem — stub sem dados piloto; origem reservada raw.dbo__AreasGroupItem via staging.stg_organizacao_areasgroupitem
CREATE TABLE IF NOT EXISTS edw.defer_areasgroupitem (
  areasgroupitem_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (areasgroupitem_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.BOOK — stub sem dados piloto; origem reservada raw.dbo__BOOK via staging.stg_organizacao_book
CREATE TABLE IF NOT EXISTS edw.defer_book (
  book_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (book_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.DELIBERACAO_FORUM_AVALIADO — stub sem dados piloto; origem reservada raw.dbo__DELIBERACAO_FORUM_AVALIADO via staging.stg_organizacao_deliberacao_forum_avaliado
CREATE TABLE IF NOT EXISTS edw.defer_deliberacao_forum_avaliado (
  deliberacao_forum_avaliado_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (deliberacao_forum_avaliado_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.FUNCAO_AREA — stub sem dados piloto; origem reservada raw.dbo__FUNCAO_AREA via staging.stg_organizacao_funcao_area
CREATE TABLE IF NOT EXISTS edw.defer_funcao_area (
  funcao_area_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (funcao_area_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.GoalAudit — stub sem dados piloto; origem reservada raw.dbo__GoalAudit via staging.stg_organizacao_goalaudit
CREATE TABLE IF NOT EXISTS edw.defer_goalaudit (
  goalaudit_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (goalaudit_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.GoalWorkflowAreaEmployeeApprover — stub sem dados piloto; origem reservada raw.dbo__GoalWorkflowAreaEmployeeApprover via staging.stg_organizacao_goalworkflowareaemployeeapprover
CREATE TABLE IF NOT EXISTS edw.defer_goalworkflowareaemployeeapprover (
  goalworkflowareaemployeeapprover_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (goalworkflowareaemployeeapprover_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.JobPositionSuccession — stub sem dados piloto; origem reservada raw.dbo__JobPositionSuccession via staging.stg_organizacao_jobpositionsuccession
CREATE TABLE IF NOT EXISTS edw.defer_jobpositionsuccession (
  jobpositionsuccession_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (jobpositionsuccession_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ManagerSuccession — stub sem dados piloto; origem reservada raw.dbo__ManagerSuccession via staging.stg_organizacao_managersuccession
CREATE TABLE IF NOT EXISTS edw.defer_managersuccession (
  managersuccession_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (managersuccession_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.OrganizationIdentity — stub sem dados piloto; origem reservada raw.dbo__OrganizationIdentity via staging.stg_organizacao_organizationidentity
CREATE TABLE IF NOT EXISTS edw.defer_organizationidentity (
  organizationidentity_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (organizationidentity_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.HISTORICO_PDI — stub sem dados piloto; origem reservada raw.dbo__HISTORICO_PDI via staging.stg_pdi_historico_pdi
CREATE TABLE IF NOT EXISTS edw.defer_historico_pdi (
  historico_pdi_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (historico_pdi_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.LabelsTagTrainings — stub sem dados piloto; origem reservada raw.dbo__LabelsTagTrainings via staging.stg_pdi_labelstagtrainings
CREATE TABLE IF NOT EXISTS edw.defer_labelstagtrainings (
  labelstagtrainings_key BIGINT,
  tenant_slug STRING,
  training_id BIGINT,
  label_id BIGINT,
  PRIMARY KEY (labelstagtrainings_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.NecessaryResourcesOfTraining — stub sem dados piloto; origem reservada raw.dbo__NecessaryResourcesOfTraining via staging.stg_pdi_necessaryresourcesoftraining
CREATE TABLE IF NOT EXISTS edw.defer_necessaryresourcesoftraining (
  necessaryresourcesoftraining_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (necessaryresourcesoftraining_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.QualificationCenterConfig — stub sem dados piloto; origem reservada raw.dbo__QualificationCenterConfig via staging.stg_pdi_qualificationcenterconfig
CREATE TABLE IF NOT EXISTS edw.defer_qualificationcenterconfig (
  qualificationcenterconfig_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (qualificationcenterconfig_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.QualificationManager — stub sem dados piloto; origem reservada raw.dbo__QualificationManager via staging.stg_pdi_qualificationmanager
CREATE TABLE IF NOT EXISTS edw.defer_qualificationmanager (
  qualificationmanager_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (qualificationmanager_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.QualificationManagersSubordinates — stub sem dados piloto; origem reservada raw.dbo__QualificationManagersSubordinates via staging.stg_pdi_qualificationmanagerssubordinates
CREATE TABLE IF NOT EXISTS edw.defer_qualificationmanagerssubordinates (
  qualificationmanagerssubordinates_key BIGINT,
  tenant_slug STRING,
  qualification_manager_id BIGINT,
  employee_id BIGINT,
  PRIMARY KEY (qualificationmanagerssubordinates_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.Training — stub sem dados piloto; origem reservada raw.dbo__Training via staging.stg_pdi_training
CREATE TABLE IF NOT EXISTS edw.defer_training (
  training_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (training_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.TrainingAttachment — stub sem dados piloto; origem reservada raw.dbo__TrainingAttachment via staging.stg_pdi_trainingattachment
CREATE TABLE IF NOT EXISTS edw.defer_trainingattachment (
  trainingattachment_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (trainingattachment_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.TrainingClass — stub sem dados piloto; origem reservada raw.dbo__TrainingClass via staging.stg_pdi_trainingclass
CREATE TABLE IF NOT EXISTS edw.defer_trainingclass (
  trainingclass_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (trainingclass_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.TrainingClassDemands — stub sem dados piloto; origem reservada raw.dbo__TrainingClassDemands via staging.stg_pdi_trainingclassdemands
CREATE TABLE IF NOT EXISTS edw.defer_trainingclassdemands (
  trainingclassdemands_key BIGINT,
  tenant_slug STRING,
  demand_id BIGINT,
  training_class_id BIGINT,
  PRIMARY KEY (trainingclassdemands_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.TrainingClassParticipants — stub sem dados piloto; origem reservada raw.dbo__TrainingClassParticipants via staging.stg_pdi_trainingclassparticipants
CREATE TABLE IF NOT EXISTS edw.defer_trainingclassparticipants (
  trainingclassparticipants_key BIGINT,
  tenant_slug STRING,
  training_class_id BIGINT,
  employee_id BIGINT,
  PRIMARY KEY (trainingclassparticipants_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.TrainingClassParticipantsConfirmed — stub sem dados piloto; origem reservada raw.dbo__TrainingClassParticipantsConfirmed via staging.stg_pdi_trainingclassparticipantsconfirmed
CREATE TABLE IF NOT EXISTS edw.defer_trainingclassparticipantsconfirmed (
  trainingclassparticipantsconfirmed_key BIGINT,
  tenant_slug STRING,
  training_class_id BIGINT,
  employee_id BIGINT,
  PRIMARY KEY (trainingclassparticipantsconfirmed_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.TrainingClassTimeWeekly — stub sem dados piloto; origem reservada raw.dbo__TrainingClassTimeWeekly via staging.stg_pdi_trainingclasstimeweekly
CREATE TABLE IF NOT EXISTS edw.defer_trainingclasstimeweekly (
  trainingclasstimeweekly_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (trainingclasstimeweekly_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.TrainingDraft — stub sem dados piloto; origem reservada raw.dbo__TrainingDraft via staging.stg_pdi_trainingdraft
CREATE TABLE IF NOT EXISTS edw.defer_trainingdraft (
  trainingdraft_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (trainingdraft_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.TrainingPackage — stub sem dados piloto; origem reservada raw.dbo__TrainingPackage via staging.stg_pdi_trainingpackage
CREATE TABLE IF NOT EXISTS edw.defer_trainingpackage (
  trainingpackage_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (trainingpackage_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.TrainingPackagesTrainings — stub sem dados piloto; origem reservada raw.dbo__TrainingPackagesTrainings via staging.stg_pdi_trainingpackagestrainings
CREATE TABLE IF NOT EXISTS edw.defer_trainingpackagestrainings (
  trainingpackagestrainings_key BIGINT,
  tenant_slug STRING,
  training_package_id BIGINT,
  training_id BIGINT,
  PRIMARY KEY (trainingpackagestrainings_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.COTACAO_MOEDA — stub sem dados piloto; origem reservada raw.dbo__COTACAO_MOEDA via staging.stg_referencia_cotacao_moeda
CREATE TABLE IF NOT EXISTS edw.defer_cotacao_moeda (
  cotacao_moeda_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (cotacao_moeda_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.GRUPO_INDICADOR — stub sem dados piloto; origem reservada raw.dbo__GRUPO_INDICADOR via staging.stg_referencia_grupo_indicador
CREATE TABLE IF NOT EXISTS edw.defer_grupo_indicador (
  grupo_indicador_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (grupo_indicador_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.INDICADOR_BOOK — stub sem dados piloto; origem reservada raw.dbo__INDICADOR_BOOK via staging.stg_referencia_indicador_book
CREATE TABLE IF NOT EXISTS edw.defer_indicador_book (
  indicador_book_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (indicador_book_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.COTACAO_MOEDA_ITEM — stub sem dados piloto; origem reservada raw.dbo__COTACAO_MOEDA_ITEM via staging.stg_remuneracao_cotacao_moeda_item
CREATE TABLE IF NOT EXISTS edw.defer_cotacao_moeda_item (
  cotacao_moeda_item_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (cotacao_moeda_item_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ExtractEmployeeOptions — stub sem dados piloto; origem reservada raw.dbo__ExtractEmployeeOptions via staging.stg_remuneracao_extractemployeeoptions
CREATE TABLE IF NOT EXISTS edw.defer_extractemployeeoptions (
  extractemployeeoptions_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (extractemployeeoptions_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ParticipantAdvancePayment — stub sem dados piloto; origem reservada raw.dbo__ParticipantAdvancePayment via staging.stg_remuneracao_participantadvancepayment
CREATE TABLE IF NOT EXISTS edw.defer_participantadvancepayment (
  participantadvancepayment_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (participantadvancepayment_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ParticipantAdvancePaymentDiscount — stub sem dados piloto; origem reservada raw.dbo__ParticipantAdvancePaymentDiscount via staging.stg_remuneracao_participantadvancepaymentdiscount
CREATE TABLE IF NOT EXISTS edw.defer_participantadvancepaymentdiscount (
  participantadvancepaymentdiscount_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (participantadvancepaymentdiscount_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ParticipantAggregatedAdvancePayment — stub sem dados piloto; origem reservada raw.dbo__ParticipantAggregatedAdvancePayment via staging.stg_remuneracao_participantaggregatedadvancepayment
CREATE TABLE IF NOT EXISTS edw.defer_participantaggregatedadvancepayment (
  participantaggregatedadvancepayment_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (participantaggregatedadvancepayment_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ClassificationImpactOfLoss — stub sem dados piloto; origem reservada raw.dbo__ClassificationImpactOfLoss via staging.stg_sucessao_classificationimpactofloss
CREATE TABLE IF NOT EXISTS edw.defer_classificationimpactofloss (
  classificationimpactofloss_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (classificationimpactofloss_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ClassificationRiskOfLoss — stub sem dados piloto; origem reservada raw.dbo__ClassificationRiskOfLoss via staging.stg_sucessao_classificationriskofloss
CREATE TABLE IF NOT EXISTS edw.defer_classificationriskofloss (
  classificationriskofloss_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (classificationriskofloss_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.FORMULARIO_AVALIACAO_SUCESSAO — stub sem dados piloto; origem reservada raw.dbo__FORMULARIO_AVALIACAO_SUCESSAO via staging.stg_sucessao_formulario_avaliacao_sucessao
CREATE TABLE IF NOT EXISTS edw.defer_formulario_avaliacao_sucessao (
  formulario_avaliacao_sucessao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (formulario_avaliacao_sucessao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.FUNCAO_FORUM_SUCESSAO — stub sem dados piloto; origem reservada raw.dbo__FUNCAO_FORUM_SUCESSAO via staging.stg_sucessao_funcao_forum_sucessao
CREATE TABLE IF NOT EXISTS edw.defer_funcao_forum_sucessao (
  funcao_forum_sucessao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (funcao_forum_sucessao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.FUNCAO_IMPACTO_SUCESSAO — stub sem dados piloto; origem reservada raw.dbo__FUNCAO_IMPACTO_SUCESSAO via staging.stg_sucessao_funcao_impacto_sucessao
CREATE TABLE IF NOT EXISTS edw.defer_funcao_impacto_sucessao (
  funcao_impacto_sucessao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (funcao_impacto_sucessao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.FUNCAO_POTENCIAL_SUCESSAO — stub sem dados piloto; origem reservada raw.dbo__FUNCAO_POTENCIAL_SUCESSAO via staging.stg_sucessao_funcao_potencial_sucessao
CREATE TABLE IF NOT EXISTS edw.defer_funcao_potencial_sucessao (
  funcao_potencial_sucessao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (funcao_potencial_sucessao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.FUNCAO_RISCO_SUCESSAO — stub sem dados piloto; origem reservada raw.dbo__FUNCAO_RISCO_SUCESSAO via staging.stg_sucessao_funcao_risco_sucessao
CREATE TABLE IF NOT EXISTS edw.defer_funcao_risco_sucessao (
  funcao_risco_sucessao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (funcao_risco_sucessao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.FUNCAO_SUCESSAO — stub sem dados piloto; origem reservada raw.dbo__FUNCAO_SUCESSAO via staging.stg_sucessao_funcao_sucessao
CREATE TABLE IF NOT EXISTS edw.defer_funcao_sucessao (
  funcao_sucessao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (funcao_sucessao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.IMPACTO — stub sem dados piloto; origem reservada raw.dbo__IMPACTO via staging.stg_sucessao_impacto
CREATE TABLE IF NOT EXISTS edw.defer_impacto (
  impacto_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (impacto_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.POTENCIAL — stub sem dados piloto; origem reservada raw.dbo__POTENCIAL via staging.stg_sucessao_potencial
CREATE TABLE IF NOT EXISTS edw.defer_potencial (
  potencial_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (potencial_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.RISCO — stub sem dados piloto; origem reservada raw.dbo__RISCO via staging.stg_sucessao_risco
CREATE TABLE IF NOT EXISTS edw.defer_risco (
  risco_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (risco_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ScoreCurveImpactSuccession — stub sem dados piloto; origem reservada raw.dbo__ScoreCurveImpactSuccession via staging.stg_sucessao_scorecurveimpactsuccession
CREATE TABLE IF NOT EXISTS edw.defer_scorecurveimpactsuccession (
  scorecurveimpactsuccession_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (scorecurveimpactsuccession_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ScoreCurveRiskSuccession — stub sem dados piloto; origem reservada raw.dbo__ScoreCurveRiskSuccession via staging.stg_sucessao_scorecurverisksuccession
CREATE TABLE IF NOT EXISTS edw.defer_scorecurverisksuccession (
  scorecurverisksuccession_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (scorecurverisksuccession_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ScoreCurveSuccession — stub sem dados piloto; origem reservada raw.dbo__ScoreCurveSuccession via staging.stg_sucessao_scorecurvesuccession
CREATE TABLE IF NOT EXISTS edw.defer_scorecurvesuccession (
  scorecurvesuccession_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (scorecurvesuccession_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.SuccessionJobPositionReadiness — stub sem dados piloto; origem reservada raw.dbo__SuccessionJobPositionReadiness via staging.stg_sucessao_successionjobpositionreadiness
CREATE TABLE IF NOT EXISTS edw.defer_successionjobpositionreadiness (
  successionjobpositionreadiness_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (successionjobpositionreadiness_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.SuccessionNomination — stub sem dados piloto; origem reservada raw.dbo__SuccessionNomination via staging.stg_sucessao_successionnomination
CREATE TABLE IF NOT EXISTS edw.defer_successionnomination (
  successionnomination_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (successionnomination_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ACAO_BOOK — stub sem dados piloto; origem reservada raw.dbo__ACAO_BOOK via staging.stg_erp_acao_book
CREATE TABLE IF NOT EXISTS edw.defer_acao_book (
  acao_book_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (acao_book_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ActionBaseAttachment — stub sem dados piloto; origem reservada raw.dbo__ActionBaseAttachment via staging.stg_erp_actionbaseattachment
CREATE TABLE IF NOT EXISTS edw.defer_actionbaseattachment (
  actionbaseattachment_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (actionbaseattachment_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ActionCategoryCompetence — stub sem dados piloto; origem reservada raw.dbo__ActionCategoryCompetence via staging.stg_erp_actioncategorycompetence
CREATE TABLE IF NOT EXISTS edw.defer_actioncategorycompetence (
  actioncategorycompetence_key BIGINT,
  tenant_slug STRING,
  action_category_id BIGINT,
  competence_id BIGINT,
  PRIMARY KEY (actioncategorycompetence_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ActionEffectiveness — stub sem dados piloto; origem reservada raw.dbo__ActionEffectiveness via staging.stg_erp_actioneffectiveness
CREATE TABLE IF NOT EXISTS edw.defer_actioneffectiveness (
  actioneffectiveness_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (actioneffectiveness_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ActionVote — stub sem dados piloto; origem reservada raw.dbo__ActionVote via staging.stg_erp_actionvote
CREATE TABLE IF NOT EXISTS edw.defer_actionvote (
  actionvote_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (actionvote_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ANEXO_AVALIACAO — stub sem dados piloto; origem reservada raw.dbo__ANEXO_AVALIACAO via staging.stg_erp_anexo_avaliacao
CREATE TABLE IF NOT EXISTS edw.defer_anexo_avaliacao (
  anexo_avaliacao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (anexo_avaliacao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ANEXO_QUICK_MEETING — stub sem dados piloto; origem reservada raw.dbo__ANEXO_QUICK_MEETING via staging.stg_erp_anexo_quick_meeting
CREATE TABLE IF NOT EXISTS edw.defer_anexo_quick_meeting (
  anexo_quick_meeting_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (anexo_quick_meeting_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.AreaScoreRV — stub sem dados piloto; origem reservada raw.dbo__AreaScoreRV via staging.stg_erp_areascorerv
CREATE TABLE IF NOT EXISTS edw.defer_areascorerv (
  areascorerv_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (areascorerv_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.AreasGroupScoreAreasMemoryRV — stub sem dados piloto; origem reservada raw.dbo__AreasGroupScoreAreasMemoryRV via staging.stg_erp_areasgroupscoreareasmemoryrv
CREATE TABLE IF NOT EXISTS edw.defer_areasgroupscoreareasmemoryrv (
  areasgroupscoreareasmemoryrv_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (areasgroupscoreareasmemoryrv_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.AreasGroupScoreRV — stub sem dados piloto; origem reservada raw.dbo__AreasGroupScoreRV via staging.stg_erp_areasgroupscorerv
CREATE TABLE IF NOT EXISTS edw.defer_areasgroupscorerv (
  areasgroupscorerv_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (areasgroupscorerv_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.BKP_ACAO — stub sem dados piloto; origem reservada raw.dbo__BKP_ACAO via staging.stg_erp_bkp_acao
CREATE TABLE IF NOT EXISTS edw.defer_bkp_acao (
  bkp_acao_key BIGINT,
  tenant_slug STRING,
  PRIMARY KEY (bkp_acao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.BKP_ACAO2 — stub sem dados piloto; origem reservada raw.dbo__BKP_ACAO2 via staging.stg_erp_bkp_acao2
CREATE TABLE IF NOT EXISTS edw.defer_bkp_acao2 (
  bkp_acao2_key BIGINT,
  tenant_slug STRING,
  PRIMARY KEY (bkp_acao2_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.Breakdown — stub sem dados piloto; origem reservada raw.dbo__Breakdown via staging.stg_erp_breakdown
CREATE TABLE IF NOT EXISTS edw.defer_breakdown (
  breakdown_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (breakdown_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.BreakdownValue — stub sem dados piloto; origem reservada raw.dbo__BreakdownValue via staging.stg_erp_breakdownvalue
CREATE TABLE IF NOT EXISTS edw.defer_breakdownvalue (
  breakdownvalue_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (breakdownvalue_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.BreakdownValueOption — stub sem dados piloto; origem reservada raw.dbo__BreakdownValueOption via staging.stg_erp_breakdownvalueoption
CREATE TABLE IF NOT EXISTS edw.defer_breakdownvalueoption (
  breakdownvalueoption_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (breakdownvalueoption_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.BrfGoalSyncLog — stub sem dados piloto; origem reservada raw.dbo__BrfGoalSyncLog via staging.stg_erp_brfgoalsynclog
CREATE TABLE IF NOT EXISTS edw.defer_brfgoalsynclog (
  brfgoalsynclog_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (brfgoalsynclog_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.CALC_RESULTADO_POTENCIAL — stub sem dados piloto; origem reservada raw.dbo__CALC_RESULTADO_POTENCIAL via staging.stg_erp_calc_resultado_potencial
CREATE TABLE IF NOT EXISTS edw.defer_calc_resultado_potencial (
  calc_resultado_potencial_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (calc_resultado_potencial_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.CALC_RESULTADO_PROJETO — stub sem dados piloto; origem reservada raw.dbo__CALC_RESULTADO_PROJETO via staging.stg_erp_calc_resultado_projeto
CREATE TABLE IF NOT EXISTS edw.defer_calc_resultado_projeto (
  calc_resultado_projeto_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (calc_resultado_projeto_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.CALCULO_MANUAL_PERFORMANCE — stub sem dados piloto; origem reservada raw.dbo__CALCULO_MANUAL_PERFORMANCE via staging.stg_erp_calculo_manual_performance
CREATE TABLE IF NOT EXISTS edw.defer_calculo_manual_performance (
  calculo_manual_performance_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (calculo_manual_performance_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.CALENDARIO_EVENTO — stub sem dados piloto; origem reservada raw.dbo__CALENDARIO_EVENTO via staging.stg_erp_calendario_evento
CREATE TABLE IF NOT EXISTS edw.defer_calendario_evento (
  calendario_evento_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (calendario_evento_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.CATCH_BALL_BOOK — stub sem dados piloto; origem reservada raw.dbo__CATCH_BALL_BOOK via staging.stg_erp_catch_ball_book
CREATE TABLE IF NOT EXISTS edw.defer_catch_ball_book (
  catch_ball_book_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (catch_ball_book_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.CAUSA_BOOK — stub sem dados piloto; origem reservada raw.dbo__CAUSA_BOOK via staging.stg_erp_causa_book
CREATE TABLE IF NOT EXISTS edw.defer_causa_book (
  causa_book_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (causa_book_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.COMENTARIO — stub sem dados piloto; origem reservada raw.dbo__COMENTARIO via staging.stg_erp_comentario
CREATE TABLE IF NOT EXISTS edw.defer_comentario (
  comentario_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (comentario_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.COMPORTAMENTO — stub sem dados piloto; origem reservada raw.dbo__COMPORTAMENTO via staging.stg_erp_comportamento
CREATE TABLE IF NOT EXISTS edw.defer_comportamento (
  comportamento_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (comportamento_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.Country — stub sem dados piloto; origem reservada raw.dbo__Country via staging.stg_erp_country
CREATE TABLE IF NOT EXISTS edw.defer_country (
  country_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (country_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.DIRETRIZ_BOOK — stub sem dados piloto; origem reservada raw.dbo__DIRETRIZ_BOOK via staging.stg_erp_diretriz_book
CREATE TABLE IF NOT EXISTS edw.defer_diretriz_book (
  diretriz_book_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (diretriz_book_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.EMAIL_ENVIADO — stub sem dados piloto; origem reservada raw.dbo__EMAIL_ENVIADO via staging.stg_erp_email_enviado
CREATE TABLE IF NOT EXISTS edw.defer_email_enviado (
  email_enviado_key BIGINT,
  tenant_slug STRING,
  PRIMARY KEY (email_enviado_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.EmployeeGuest — stub sem dados piloto; origem reservada raw.dbo__EmployeeGuest via staging.stg_erp_employeeguest
CREATE TABLE IF NOT EXISTS edw.defer_employeeguest (
  employeeguest_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (employeeguest_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.EmployeeModifierMonthlyGoal — stub sem dados piloto; origem reservada raw.dbo__EmployeeModifierMonthlyGoal via staging.stg_erp_employeemodifiermonthlygoal
CREATE TABLE IF NOT EXISTS edw.defer_employeemodifiermonthlygoal (
  employeemodifiermonthlygoal_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (employeemodifiermonthlygoal_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.EmployeeModifierMonthlyValue — stub sem dados piloto; origem reservada raw.dbo__EmployeeModifierMonthlyValue via staging.stg_erp_employeemodifiermonthlyvalue
CREATE TABLE IF NOT EXISTS edw.defer_employeemodifiermonthlyvalue (
  employeemodifiermonthlyvalue_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (employeemodifiermonthlyvalue_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ExtractMigration — stub sem dados piloto; origem reservada raw.dbo__ExtractMigration via staging.stg_erp_extractmigration
CREATE TABLE IF NOT EXISTS edw.defer_extractmigration (
  extractmigration_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (extractmigration_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.FilePermission — stub sem dados piloto; origem reservada raw.dbo__FilePermission via staging.stg_erp_filepermission
CREATE TABLE IF NOT EXISTS edw.defer_filepermission (
  filepermission_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (filepermission_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.FORMULARIO — stub sem dados piloto; origem reservada raw.dbo__FORMULARIO via staging.stg_erp_formulario
CREATE TABLE IF NOT EXISTS edw.defer_formulario (
  formulario_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (formulario_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.FUNCAO_CARGO — stub sem dados piloto; origem reservada raw.dbo__FUNCAO_CARGO via staging.stg_erp_funcao_cargo
CREATE TABLE IF NOT EXISTS edw.defer_funcao_cargo (
  funcao_cargo_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (funcao_cargo_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.Goal — stub sem dados piloto; origem reservada raw.dbo__Goal via staging.stg_erp_goal
CREATE TABLE IF NOT EXISTS edw.defer_goal (
  goal_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (goal_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.GoalCache — stub sem dados piloto; origem reservada raw.dbo__GoalCache via staging.stg_erp_goalcache
CREATE TABLE IF NOT EXISTS edw.defer_goalcache (
  goalcache_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (goalcache_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.GoalCacheQueue — stub sem dados piloto; origem reservada raw.dbo__GoalCacheQueue via staging.stg_erp_goalcachequeue
CREATE TABLE IF NOT EXISTS edw.defer_goalcachequeue (
  goalcachequeue_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (goalcachequeue_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.GoalResponsible — stub sem dados piloto; origem reservada raw.dbo__GoalResponsible via staging.stg_erp_goalresponsible
CREATE TABLE IF NOT EXISTS edw.defer_goalresponsible (
  goalresponsible_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (goalresponsible_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.GoalValue — stub sem dados piloto; origem reservada raw.dbo__GoalValue via staging.stg_erp_goalvalue
CREATE TABLE IF NOT EXISTS edw.defer_goalvalue (
  goalvalue_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (goalvalue_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.GroupJobAccessGroup — stub sem dados piloto; origem reservada raw.dbo__GroupJobAccessGroup via staging.stg_erp_groupjobaccessgroup
CREATE TABLE IF NOT EXISTS edw.defer_groupjobaccessgroup (
  groupjobaccessgroup_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (groupjobaccessgroup_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.GRUPO_INDICADOR_ASSOCIADO_BOOK — stub sem dados piloto; origem reservada raw.dbo__GRUPO_INDICADOR_ASSOCIADO_BOOK via staging.stg_erp_grupo_indicador_associado_book
CREATE TABLE IF NOT EXISTS edw.defer_grupo_indicador_associado_book (
  grupo_indicador_associado_book_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (grupo_indicador_associado_book_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.GRUPO_INDICADOR_BOOK — stub sem dados piloto; origem reservada raw.dbo__GRUPO_INDICADOR_BOOK via staging.stg_erp_grupo_indicador_book
CREATE TABLE IF NOT EXISTS edw.defer_grupo_indicador_book (
  grupo_indicador_book_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (grupo_indicador_book_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.HISTORICO_COLABORADOR_CARGO — stub sem dados piloto; origem reservada raw.dbo__HISTORICO_COLABORADOR_CARGO via staging.stg_erp_historico_colaborador_cargo
CREATE TABLE IF NOT EXISTS edw.defer_historico_colaborador_cargo (
  historico_colaborador_cargo_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (historico_colaborador_cargo_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER import.ImportItem — stub sem dados piloto; origem reservada raw.import__ImportItem via staging.stg_erp_importitem
CREATE TABLE IF NOT EXISTS edw.defer_importitem (
  importitem_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (importitem_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ImpValorMatriz — stub sem dados piloto; origem reservada raw.dbo__ImpValorMatriz via staging.stg_erp_impvalormatriz
CREATE TABLE IF NOT EXISTS edw.defer_impvalormatriz (
  impvalormatriz_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (impvalormatriz_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.IPRestriction — stub sem dados piloto; origem reservada raw.dbo__IPRestriction via staging.stg_erp_iprestriction
CREATE TABLE IF NOT EXISTS edw.defer_iprestriction (
  iprestriction_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (iprestriction_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.KPI — stub sem dados piloto; origem reservada raw.dbo__KPI via staging.stg_erp_kpi
CREATE TABLE IF NOT EXISTS edw.defer_kpi (
  kpi_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (kpi_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.KPIBreakdown — stub sem dados piloto; origem reservada raw.dbo__KPIBreakdown via staging.stg_erp_kpibreakdown
CREATE TABLE IF NOT EXISTS edw.defer_kpibreakdown (
  kpibreakdown_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (kpibreakdown_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.KPIGrouping — stub sem dados piloto; origem reservada raw.dbo__KPIGrouping via staging.stg_erp_kpigrouping
CREATE TABLE IF NOT EXISTS edw.defer_kpigrouping (
  kpigrouping_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (kpigrouping_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.KPIStakeholderBook — stub sem dados piloto; origem reservada raw.dbo__KPIStakeholderBook via staging.stg_erp_kpistakeholderbook
CREATE TABLE IF NOT EXISTS edw.defer_kpistakeholderbook (
  kpistakeholderbook_key BIGINT,
  tenant_slug STRING,
  kpi_id BIGINT,
  stakeholder_id BIGINT,
  PRIMARY KEY (kpistakeholderbook_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.LISTA_PLANO_TIPO_AVALIADOR — stub sem dados piloto; origem reservada raw.dbo__LISTA_PLANO_TIPO_AVALIADOR via staging.stg_erp_lista_plano_tipo_avaliador
CREATE TABLE IF NOT EXISTS edw.defer_lista_plano_tipo_avaliador (
  lista_plano_tipo_avaliador_key BIGINT,
  tenant_slug STRING,
  PRIMARY KEY (lista_plano_tipo_avaliador_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ManagementCycle — stub sem dados piloto; origem reservada raw.dbo__ManagementCycle via staging.stg_erp_managementcycle
CREATE TABLE IF NOT EXISTS edw.defer_managementcycle (
  managementcycle_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (managementcycle_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.META_RELACIONADA — stub sem dados piloto; origem reservada raw.dbo__META_RELACIONADA via staging.stg_erp_meta_relacionada
CREATE TABLE IF NOT EXISTS edw.defer_meta_relacionada (
  meta_relacionada_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (meta_relacionada_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.MULTIPLO_NOTA — stub sem dados piloto; origem reservada raw.dbo__MULTIPLO_NOTA via staging.stg_erp_multiplo_nota
CREATE TABLE IF NOT EXISTS edw.defer_multiplo_nota (
  multiplo_nota_key BIGINT,
  tenant_slug STRING,
  PRIMARY KEY (multiplo_nota_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.ParticipantAggregatedAdvancePaymentDiscount — stub sem dados piloto; origem reservada raw.dbo__ParticipantAggregatedAdvancePaymentDiscount via staging.stg_erp_participantaggregatedadvancepaymentdiscount
CREATE TABLE IF NOT EXISTS edw.defer_participantaggregatedadvancepaymentdiscount (
  participantaggregatedadvancepaymentdiscount_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (participantaggregatedadvancepaymentdiscount_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.PDF_EXPLICATIVO_AVALIACAO — stub sem dados piloto; origem reservada raw.dbo__PDF_EXPLICATIVO_AVALIACAO via staging.stg_erp_pdf_explicativo_avaliacao
CREATE TABLE IF NOT EXISTS edw.defer_pdf_explicativo_avaliacao (
  pdf_explicativo_avaliacao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (pdf_explicativo_avaliacao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.PLANO_PESO_AVALIADOR — stub sem dados piloto; origem reservada raw.dbo__PLANO_PESO_AVALIADOR via staging.stg_erp_plano_peso_avaliador
CREATE TABLE IF NOT EXISTS edw.defer_plano_peso_avaliador (
  plano_peso_avaliador_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (plano_peso_avaliador_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.PRE_TRABALHO_AVALIADO_SUCESSAO — stub sem dados piloto; origem reservada raw.dbo__PRE_TRABALHO_AVALIADO_SUCESSAO via staging.stg_erp_pre_trabalho_avaliado_sucessao
CREATE TABLE IF NOT EXISTS edw.defer_pre_trabalho_avaliado_sucessao (
  pre_trabalho_avaliado_sucessao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (pre_trabalho_avaliado_sucessao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.RECURRING_JOB_LOG — stub sem dados piloto; origem reservada raw.dbo__RECURRING_JOB_LOG via staging.stg_erp_recurring_job_log
CREATE TABLE IF NOT EXISTS edw.defer_recurring_job_log (
  recurring_job_log_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (recurring_job_log_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.REFERENCIA_CAUSA — stub sem dados piloto; origem reservada raw.dbo__REFERENCIA_CAUSA via staging.stg_erp_referencia_causa
CREATE TABLE IF NOT EXISTS edw.defer_referencia_causa (
  referencia_causa_key BIGINT,
  tenant_slug STRING,
  id_causa_destino BIGINT,
  PRIMARY KEY (referencia_causa_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.RESPOSTA_COMENTARIO — stub sem dados piloto; origem reservada raw.dbo__RESPOSTA_COMENTARIO via staging.stg_erp_resposta_comentario
CREATE TABLE IF NOT EXISTS edw.defer_resposta_comentario (
  resposta_comentario_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (resposta_comentario_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.RESPOSTA_COMPORTAMENTO — stub sem dados piloto; origem reservada raw.dbo__RESPOSTA_COMPORTAMENTO via staging.stg_erp_resposta_comportamento
CREATE TABLE IF NOT EXISTS edw.defer_resposta_comportamento (
  resposta_comportamento_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (resposta_comportamento_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.SECAO — stub sem dados piloto; origem reservada raw.dbo__SECAO via staging.stg_erp_secao
CREATE TABLE IF NOT EXISTS edw.defer_secao (
  secao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (secao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.TEMPLATE_USUARIO — stub sem dados piloto; origem reservada raw.dbo__TEMPLATE_USUARIO via staging.stg_erp_template_usuario
CREATE TABLE IF NOT EXISTS edw.defer_template_usuario (
  template_usuario_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (template_usuario_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.TemporaryBulkInsert — stub sem dados piloto; origem reservada raw.dbo__TemporaryBulkInsert via staging.stg_erp_temporarybulkinsert
CREATE TABLE IF NOT EXISTS edw.defer_temporarybulkinsert (
  temporarybulkinsert_key BIGINT,
  tenant_slug STRING,
  PRIMARY KEY (temporarybulkinsert_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.TERMO_CONSENTIMENTO — stub sem dados piloto; origem reservada raw.dbo__TERMO_CONSENTIMENTO via staging.stg_erp_termo_consentimento
CREATE TABLE IF NOT EXISTS edw.defer_termo_consentimento (
  termo_consentimento_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (termo_consentimento_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.TrainingClassTimeDaily — stub sem dados piloto; origem reservada raw.dbo__TrainingClassTimeDaily via staging.stg_erp_trainingclasstimedaily
CREATE TABLE IF NOT EXISTS edw.defer_trainingclasstimedaily (
  trainingclasstimedaily_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (trainingclasstimedaily_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.VALOR_SECAO — stub sem dados piloto; origem reservada raw.dbo__VALOR_SECAO via staging.stg_erp_valor_secao
CREATE TABLE IF NOT EXISTS edw.defer_valor_secao (
  valor_secao_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (valor_secao_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.VW_AREA_QUEUE — stub sem dados piloto; origem reservada raw.dbo__VW_AREA_QUEUE via staging.stg_erp_vw_area_queue
CREATE TABLE IF NOT EXISTS edw.defer_vw_area_queue (
  vw_area_queue_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (vw_area_queue_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.VW_COLABORADOR_INATIVADO_QUEUE — stub sem dados piloto; origem reservada raw.dbo__VW_COLABORADOR_INATIVADO_QUEUE via staging.stg_erp_vw_colaborador_inativado_queue
CREATE TABLE IF NOT EXISTS edw.defer_vw_colaborador_inativado_queue (
  vw_colaborador_inativado_queue_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (vw_colaborador_inativado_queue_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.VW_COLABORADOR_QUEUE — stub sem dados piloto; origem reservada raw.dbo__VW_COLABORADOR_QUEUE via staging.stg_erp_vw_colaborador_queue
CREATE TABLE IF NOT EXISTS edw.defer_vw_colaborador_queue (
  vw_colaborador_queue_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (vw_colaborador_queue_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.vw_goal — stub sem dados piloto; origem reservada raw.dbo__vw_goal via staging.stg_erp_vw_goal
CREATE TABLE IF NOT EXISTS edw.defer_vw_goal (
  vw_goal_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (vw_goal_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.VW_GOAL_RESPONSIBLE — stub sem dados piloto; origem reservada raw.dbo__VW_GOAL_RESPONSIBLE via staging.stg_erp_vw_goal_responsible
CREATE TABLE IF NOT EXISTS edw.defer_vw_goal_responsible (
  vw_goal_responsible_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (vw_goal_responsible_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.VW_GOAL_WEIGHT — stub sem dados piloto; origem reservada raw.dbo__VW_GOAL_WEIGHT via staging.stg_erp_vw_goal_weight
CREATE TABLE IF NOT EXISTS edw.defer_vw_goal_weight (
  vw_goal_weight_key BIGINT,
  tenant_slug STRING,
  core_goal_id BIGINT,
  PRIMARY KEY (vw_goal_weight_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.VW_KPI — stub sem dados piloto; origem reservada raw.dbo__VW_KPI via staging.stg_erp_vw_kpi
CREATE TABLE IF NOT EXISTS edw.defer_vw_kpi (
  vw_kpi_key BIGINT,
  tenant_slug STRING,
  id BIGINT,
  PRIMARY KEY (vw_kpi_key)
) USING DELTA;

-- @layer: edw
-- @group: defer
-- @note: DEFER dbo.VW_MANAGEMENT_CYCLE — stub sem dados piloto; origem reservada raw.dbo__VW_MANAGEMENT_CYCLE via staging.stg_erp_vw_management_cycle
CREATE TABLE IF NOT EXISTS edw.defer_vw_management_cycle (
  vw_management_cycle_key BIGINT,
  tenant_slug STRING,
  core_management_cycle_id BIGINT,
  description BIGINT,
  PRIMARY KEY (vw_management_cycle_key)
) USING DELTA;

-- =============================================================================
-- MART — consumo (apenas EDW como origem)
-- =============================================================================

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

-- @layer: raw
-- @group: pipeline
-- @note: Quarentena de drift de schema — todo objeto/coluna/dado de tenant que não casa com o contrato de 616 tabelas é logado aqui para avaliação futura (nunca descartado em silêncio)
CREATE TABLE IF NOT EXISTS pipeline.schema_drift_log (
  tenant_slug STRING,
  object_type STRING,
  object_name STRING,
  reason STRING,
  payload STRING,
  detected_at TIMESTAMP,
  PRIMARY KEY (tenant_slug, object_type, object_name, detected_at)
) USING DELTA;
