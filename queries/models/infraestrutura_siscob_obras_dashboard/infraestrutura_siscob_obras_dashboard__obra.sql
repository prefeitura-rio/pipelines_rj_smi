{{ config(alias='obra', schema='infraestrutura_siscob_obras_dashboard') }}
WITH
  obra AS (
    SELECT
      id_obra,
      id_processo,
      id_licitacao,
      id_contrato,
      titulo,
      -- concatenar favorecido e cnpj CONCAT(favorecido, " - ", cnpj) AS favorecido_cnpj,
      CONCAT(favorecido, " - ", cnpj) AS favorecido_cnpj,
      -- corriginddo tipo de obra
      CASE
        WHEN objeto = "OBRA" THEN "Obra"
        WHEN objeto = "SERVICO" THEN "Serviço"
        WHEN objeto = "CONTINUO" THEN "Continuo"
      ELSE objeto
      END AS objeto,

      -- correspondencas de situacao
      CASE
        WHEN situacao = "CONCL_FINANC" THEN "Concluída"
        WHEN situacao = "DEVOLV_GARANTIA" THEN "Concluída"
        WHEN situacao = "EXECUTANDO" THEN "Executando"
        WHEN situacao = "PROC_AC_DEF" THEN "Concluída"
        WHEN situacao = "REPACTUADO" THEN "Repactuada"
        WHEN situacao = "CONTRATO_RESCINDIDO" THEN "Rescindida"
        WHEN situacao = "CANCELADO" THEN "Cancelada"
        WHEN situacao = "PROC_AC_PROV" THEN "Em processo de aceitação"
        WHEN situacao = "SUSPENSA" THEN "Suspensa"
      END AS situacao,

      -- corrigindo modalidade
      CASE
        WHEN modalidade = "DISPENSA" THEN "Dispensa"
        WHEN modalidade = "TOMADA_PRECO" THEN "Tomada de preços"
        WHEN modalidade = "CONCORRENCIA" THEN "Concorrência"
        WHEN modalidade = "CONVITE" THEN "Convite"
        WHEN modalidade = "INEXIGIBILIDADE" THEN "Inexigibilidade"
        WHEN modalidade = "PREGAO_ELETRONICO" THEN "Pregão eletrônico"
      ELSE modalidade
      END AS modalidade,
      ano_inicio_contrato,
      data_assinatura_contrato,
      data_inicio,
      data_termino_previsto,
      data_termino_atual,
      valor_orcado,
      valor_contratado,
      valor_vigente,
      percentual_medido,
      prazo_inicial,
      orgao_contratante,
      -- ######################################################
      -- extrair texto antes de - na coluna orgao_contratante #
      -- ######################################################
      SPLIT(orgao_contratante, " - ")[OFFSET(0)] AS orgao_contratante_sigla_completa,
      orgao_executor,
      -- ######################################################
      -- extrair texto antes de - na coluna orgao_executor #
      -- ######################################################
      SPLIT(orgao_executor, " - ")[OFFSET(0)] AS orgao_executor_sigla_completa,
    FROM `rj-smi.infraestrutura_siscob_obras.obra`
    WHERE (
  situacao IN("EXECUTANDO","SUSPENSA") AND
  EXTRACT(YEAR FROM(data_termino_atual)) >= 2021
  ) OR
  EXTRACT(YEAR FROM(data_inicio)) >= 2021),

  obras_completa AS (
    SELECT
      t.*,
      SPLIT(orgao_contratante_sigla_completa, "/")[OFFSET(0)] AS nome_orgao_contratante,
      SPLIT(orgao_executor_sigla_completa, "/")[OFFSET(0)] AS nome_orgao_executor
    FROM obra t
  ),

  obras_final AS (
    SELECT
      * EXCEPT(
          nome_orgao_contratante,
          nome_orgao_executor
        ),
      -- #####################################################################
      -- extrair texto antes de / na coluna orgao_contratante_sigla_completa #
      -- #####################################################################
      CASE
        WHEN nome_orgao_contratante = "AC" THEN "Secretaria Especial de Ação Comunitária - SEAC-RIO"
        WHEN nome_orgao_contratante = "CVL" THEN "Secretaria Municipal da Casa Civil - CASA CIVIL"
        WHEN nome_orgao_contratante = "F" THEN "Secretaria Municipal de Fazenda - SMF"
        WHEN nome_orgao_contratante = "FPJ" THEN "Fundação Parques e Jardins - FPJ"
        WHEN nome_orgao_contratante = "Geo-Rio" THEN "Fundação Instituto de Geotécnica do Município do Rio de Janeiro - GEO-RIO"
        WHEN nome_orgao_contratante = "GEO-RIO" THEN "Fundação Instituto de Geotécnica do Município do Rio de Janeiro - GEO-RIO"
        WHEN nome_orgao_contratante = "H" THEN "Secretaria Municipal de Habitação - SMH"
        WHEN nome_orgao_contratante = "I" THEN "Secretaria Municipal de Infraestrutura - SMI"
        WHEN nome_orgao_contratante = "IH" THEN "Secretaria Municipal de Infraestrutura e Habitação - SMIH"
        WHEN nome_orgao_contratante = "IHC" THEN "Secretaria Municipal de Infraestrutura, Habitação e Conservação - SMIHC"
        WHEN nome_orgao_contratante = "MULTIRIO" THEN "Empresa Municipal de MultiMeios - MULTIRIO"
        WHEN nome_orgao_contratante = "O" THEN "Secretaria Municipal de Obras - SMO"
        WHEN nome_orgao_contratante = "PREVI-RIO" THEN "Instituto de Previdência e Assistência do Município do Rio de Janeiro - PREVI-RIO"
        WHEN nome_orgao_contratante = "QV" THEN "Secretaria Municipal do Envelhecimento Saudável e Qualidade de Vida - SEMESQV"
        WHEN nome_orgao_contratante = "RIO-AGUAS" THEN "Fundação Instituto das Águas do Município do Rio de Janeiro - RIO-ÁGUAS"
        WHEN nome_orgao_contratante = "RIO-ÁGUAS" THEN "Fundação Instituto das Águas do Município do Rio de Janeiro - RIO-ÁGUAS"
        WHEN nome_orgao_contratante = "RIOLUZ" THEN "Companhia Municipal de Energia e Iluminação - RIOLUZ"
        WHEN nome_orgao_contratante = "RIO-URBE" THEN "Empresa Municipal de Urbanização - RIO-URBE"
        WHEN nome_orgao_contratante = "S" THEN "Secretaria Municipal de Saúde - SMS"
        WHEN nome_orgao_contratante = "SC" THEN "Secretaria Municipal de Conservação - SECONSERVA"
        WHEN nome_orgao_contratante = "SCMA" THEN "Secretaria Municipal de Conservação e Meio Ambiente - SECONSERMA"
        WHEN nome_orgao_contratante = "SEAC-RIO" THEN "Secretaria Especial de Ação Comunitária - SEAC-RIO"
        WHEN nome_orgao_contratante = "SECONSERMA" THEN "Secretaria Municipal de Conservação e Meio Ambiente - SECONSERMA"
        WHEN nome_orgao_contratante = "SECONSERVA" THEN "Secretaria Municipal de Conservação - SECONSERVA"
        WHEN nome_orgao_contratante = "SEMESQV" THEN "Secretaria Municipal do Envelhecimento Saudável e Qualidade de Vida - SEMESQV"
        WHEN nome_orgao_contratante = "SMA" THEN "Secretaria Municipal de Administração - SMA"
        WHEN nome_orgao_contratante = "SMAR" THEN "Secretaria Municipal de Saneamento e Recursos Hídricos - SMAR"
        WHEN nome_orgao_contratante = "SMC" THEN "Secretaria Municipal de Cultura - SMC"
        WHEN nome_orgao_contratante = "SME" THEN "Secretaria Municipal de Educação - SME"
        WHEN nome_orgao_contratante = "SMF" THEN "Secretaria Municipal de Fazenda - SMF"
        WHEN nome_orgao_contratante = "SMFP" THEN "Secretaria Municipal de Fazenda e Planejamento - SMFP"
        WHEN nome_orgao_contratante = "SMH" THEN "Secretaria Municipal de Habitação - SMH"
        WHEN nome_orgao_contratante = "SMHC" THEN "Secretaria Municipal de Habitação e Cidadania - SMHC"
        WHEN nome_orgao_contratante = "SMI" THEN "Secretaria Municipal de Infraestrutura - SMI"
        WHEN nome_orgao_contratante = "SMIH" THEN "Secretaria Municipal de Infraestrutura e Habitação - SMIH"
        WHEN nome_orgao_contratante = "SMIHC" THEN "Secretaria Municipal de Infraestrutura, Habitação e Conservação - SMIHC"
        WHEN nome_orgao_contratante = "SMO" THEN "Secretaria Municipal de Obras - SMO"
        WHEN nome_orgao_contratante = "SMS" THEN "Secretaria Municipal de Saúde - SMS"
        WHEN nome_orgao_contratante = "SMUIH" THEN "Secretaria Municipal de Urbanismo, Infraestrutura e Habitação - SMUIH"
        WHEN nome_orgao_contratante = "UIH" THEN "Secretaria Municipal de Urbanismo, Infraestrutura e Habitação - SMUIH"
      ELSE orgao_contratante
      END AS nome_orgao_contratante,

      CASE
        WHEN nome_orgao_executor = "AC" THEN "Secretaria Especial de Ação Comunitária - SEAC-RIO"
        WHEN nome_orgao_executor = "CVL" THEN "Secretaria Municipal da Casa Civil - CASA CIVIL"
        WHEN nome_orgao_executor = "F" THEN "Secretaria Municipal de Fazenda - SMF"
        WHEN nome_orgao_executor = "FPJ" THEN "Fundação Parques e Jardins - FPJ"
        WHEN nome_orgao_executor = "Geo-Rio" THEN "Fundação Instituto de Geotécnica do Município do Rio de Janeiro - GEO-RIO"
        WHEN nome_orgao_executor = "GEO-RIO" THEN "Fundação Instituto de Geotécnica do Município do Rio de Janeiro - GEO-RIO"
        WHEN nome_orgao_executor = "H" THEN "Secretaria Municipal de Habitação - SMH"
        WHEN nome_orgao_executor = "I" THEN "Secretaria Municipal de Infraestrutura - SMI"
        WHEN nome_orgao_executor = "IH" THEN "Secretaria Municipal de Infraestrutura e Habitação - SMIH"
        WHEN nome_orgao_executor = "IHC" THEN "Secretaria Municipal de Infraestrutura, Habitação e Conservação - SMIHC"
        WHEN nome_orgao_executor = "MULTIRIO"  THEN "Empresa Municipal de MultiMeios - MULTIRIO"
        WHEN nome_orgao_executor = "O" THEN "Secretaria Municipal de Obras - SMO"
        WHEN nome_orgao_executor = "PREVI-RIO" THEN "Instituto de Previdência e Assistência do Município do Rio de Janeiro - PREVI-RIO"
        WHEN nome_orgao_executor = "QV" THEN "Secretaria Municipal do Envelhecimento Saudável e Qualidade de Vida - SEMESQV"
        WHEN nome_orgao_executor = "RIO-AGUAS" THEN "Fundação Instituto das Águas do Município do Rio de Janeiro - RIO-ÁGUAS"
        WHEN nome_orgao_executor = "RIO-ÁGUAS" THEN "Fundação Instituto das Águas do Município do Rio de Janeiro - RIO-ÁGUAS"
        WHEN nome_orgao_executor = "RIOLUZ" THEN "Companhia Municipal de Energia e Iluminação - RIOLUZ"
        WHEN nome_orgao_executor = "RIO-URBE" THEN "Empresa Municipal de Urbanização - RIO-URBE"
        WHEN nome_orgao_executor = "S" THEN "Secretaria Municipal de Saúde - SMS"
        WHEN nome_orgao_executor = "SC" THEN "Secretaria Municipal de Conservação - SECONSERVA"
        WHEN nome_orgao_executor = "SCMA" THEN "Secretaria Municipal de Conservação e Meio Ambiente - SECONSERMA"
        WHEN nome_orgao_executor = "SEAC-RIO" THEN "Secretaria Especial de Ação Comunitária - SEAC-RIO"
        WHEN nome_orgao_executor = "SECONSERMA" THEN "Secretaria Municipal de Conservação e Meio Ambiente - SECONSERMA"
        WHEN nome_orgao_executor = "SECONSERVA" THEN "Secretaria Municipal de Conservação - SECONSERVA"
        WHEN nome_orgao_executor = "SEMESQV" THEN "Secretaria Municipal do Envelhecimento Saudável e Qualidade de Vida - SEMESQV"
        WHEN nome_orgao_executor = "SMA" THEN "Secretaria Municipal de Administração - SMA"
        WHEN nome_orgao_executor = "SMAR" THEN "Secretaria Municipal de Saneamento e Recursos Hídricos - SMAR"
        WHEN nome_orgao_executor = "SMC" THEN "Secretaria Municipal de Cultura - SMC"
        WHEN nome_orgao_executor = "SME" THEN "Secretaria Municipal de Educação - SME"
        WHEN nome_orgao_executor = "SMF" THEN "Secretaria Municipal de Fazenda - SMF"
        WHEN nome_orgao_executor = "SMFP" THEN "Secretaria Municipal de Fazenda e Planejamento - SMFP"
        WHEN nome_orgao_executor = "SMH" THEN "Secretaria Municipal de Habitação - SMH"
        WHEN nome_orgao_executor = "SMHC" THEN "Secretaria Municipal de Habitação e Cidadania - SMHC"
        WHEN nome_orgao_executor = "SMI" THEN "Secretaria Municipal de Infraestrutura - SMI"
        WHEN nome_orgao_executor = "SMIH" THEN "Secretaria Municipal de Infraestrutura e Habitação - SMIH"
        WHEN nome_orgao_executor = "SMIHC" THEN "Secretaria Municipal de Infraestrutura, Habitação e Conservação - SMIHC"
        WHEN nome_orgao_executor = "SMO" THEN "Secretaria Municipal de Obras - SMO"
        WHEN nome_orgao_executor = "SMS" THEN "Secretaria Municipal de Saúde - SMS"
        WHEN nome_orgao_executor = "SMUIH" THEN "Secretaria Municipal de Urbanismo, Infraestrutura e Habitação - SMUIH"
        WHEN nome_orgao_executor = "UIH" THEN "Secretaria Municipal de Urbanismo, Infraestrutura e Habitação - SMUIH"
      ELSE orgao_executor
      END AS nome_orgao_executor
    FROM obras_completa t
  ),

  fonte AS (
    SELECT
      DISTINCT
        id_obra,
        fonte_recurso
    FROM `rj-smi.infraestrutura_siscob_obras.programa_fonte`
  ),

  obra_fonte AS (
    SELECT
      o.id_obra,
      COUNT(f.fonte_recurso) AS qtd_fonte_recurso,
      ARRAY_TO_STRING(ARRAY_AGG (f.fonte_recurso),', ') fontes_recurso
    FROM `rj-smi.infraestrutura_siscob_obras.obra` o
    LEFT JOIN fonte f
      ON f.id_obra = o.id_obra
    GROUP BY o.id_obra
    ORDER BY 2 DESC
  )

SELECT
  o.*,
  f.qtd_fonte_recurso,
  f.fontes_recurso
FROM obras_final o
LEFT JOIN obra_fonte f
  ON f.id_obra = o.id_obra
ORDER BY f.qtd_fonte_recurso DESC