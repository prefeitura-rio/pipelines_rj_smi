# -*- coding: utf-8 -*-
# flake8: noqa

"""
Schedules for the database dump pipeline.
"""

from datetime import datetime, timedelta

import pytz
from prefect.schedules import Schedule
from prefeitura_rio.pipelines_utils.io import untuple_clocks as untuple
from prefeitura_rio.pipelines_utils.prefect import generate_dump_db_schedules

from pipelines.constants import constants

#####################################
#
# SISCOB Schedules
#
#####################################

siscob_queries = {
    "obra": {
        "materialize_after_dump": True,
        "materialization_mode": "prod",
        "dump_mode": "overwrite",
        "execute_query": """
            SELECT
                DISTINCT
                    CD_OBRA,
                    DS_TITULO,
                    ORGAO_CONTRATANTE,
                    ORGAO_EXECUTOR,
                    NR_PROCESSO,
                    OBJETO,
                    NM_FAVORECIDO,
                    CNPJ,
                    NR_LICITACAO,
                    MODALIDADE,
                    DT_ASS_CONTRATO,
                    DT_INICIO_OBRA,
                    DT_TERMINO_PREVISTO,
                    DT_TERMINO_ATUAL,
                    NR_CONTRATO,
                    AA_EXERCICIO,
                    SITUACAO,
                    VL_ORCADO_C_BDI,
                    VL_CONTRATADO,
                    VL_VIGENTE,
                    PC_MEDIDO,
                    PRAZO_INICIAL
            FROM dbo.fuSEGOVI_Dados_da_Obra()
            """,
    },
    "medicao": {
        "materialize_after_dump": True,
        "materialization_mode": "prod",
        "dump_mode": "overwrite",
        "execute_query": """
            SELECT
                DISTINCT
                    CD_OBRA,
                    NR_MEDICAO,
                    CD_ETAPA,
                    TP_MEDICAO_D,
                    DT_INI_MEDICAO,
                    DT_FIM_MEDICAO,
                    VL_FINAL
            FROM dbo.fuSEGOVI_Medicoes()
            """,
    },
    "termo_aditivo": {
        "materialize_after_dump": True,
        "materialization_mode": "prod",
        "dump_mode": "overwrite",
        "execute_query": """
            SELECT
                DISTINCT
                    CD_OBRA,
                    NR_DO_TERMO,
                    TP_ACERTO,
                    DT_DO,
                    DT_AUTORIZACAO,
                    VL_ACERTO
            FROM dbo.fuSEGOVI_Termos_Aditivos()
            """,
    },
    "cronograma_financeiro": {
        "materialize_after_dump": True,
        "materialization_mode": "prod",
        "dump_mode": "overwrite",
        "execute_query": """
            SELECT
                DISTINCT
                    CD_OBRA,
                    ETAPA,
                    DT_INICIO_ETAPA,
                    DT_FIM_ETAPA,
                    PC_PERCENTUAL,
                    VL_ESTIMADO
            FROM dbo.fuSEGOVI_Cronograma_Financeiro()
            """,
    },
    "localizacao": {
        "materialize_after_dump": True,
        "materialization_mode": "prod",
        "dump_mode": "overwrite",
        "execute_query": """
            SELECT
                DISTINCT
                    CD_OBRA,
                    ENDERECO,
                    NM_BAIRRO,
                    NM_RA,
                    NM_AP
            FROM dbo.fuSEGOVI_Localizacoes_obra()
            """,
    },
    "cronograma_alteracao": {
        "materialize_after_dump": True,
        "materialization_mode": "prod",
        "dump_mode": "overwrite",
        "execute_query": """
            SELECT
                DISTINCT
                    CD_OBRA,
                    NR_PROCESSO,
                    TP_ALTERACAO,
                    DT_PUBL_DO,
                    CD_ETAPA,
                    NR_PRAZO,
                    DT_VALIDADE,
                    DS_OBSERVACAO
            FROM dbo.fuSEGOVI_Alteração_de_Cronograma()
            """,
    },
    "programa_fonte": {
        "materialize_after_dump": True,
        "materialization_mode": "prod",
        "dump_mode": "overwrite",
        "execute_query": """
            SELECT
                DISTINCT
                    CD_OBRA,
                    CD_PRG_TRAB,
                    PROGRAMA_TRABALHO,
                    CD_FONTE_RECURSO,
                    FONTE_RECURSO,
                    CD_NATUREZA_DSP,
                    NATUREZA_DESPESA
            FROM dbo.fuSEGOVI_Programa_Fonte()
            """,
    },
    "obras_suspensas": {
        "materialize_after_dump": True,
        "materialization_mode": "prod",
        "dump_mode": "overwrite",
        "execute_query": """
            SELECT
                DISTINCT
                    CD_OBRA,
                    REPLACE(REPLACE(DS_TITULO_OBJETO, CHAR(13), ''), CHAR(10), '') AS DS_TITULO_OBJETO,
                    DT_SUSPENSAO,
                    REPLACE(REPLACE(DS_MOTIVO, CHAR(13), ''), CHAR(10), '') AS DS_MOTIVO,
                    REPLACE(REPLACE(DS_PREVISAO, CHAR(13), ''), CHAR(10), '') AS DS_PREVISAO,
                    REPLACE(REPLACE(DS_JUSTIFICATIVA, CHAR(13), ''), CHAR(10), '') AS DS_JUSTIFICATIVA,
                    NM_RESPONSAVEL
            FROM dbo.fuSEGOVI_Obras_Suspensas()
            """,
    },
    "itens_medicao": {
        "materialize_after_dump": True,
        "materialization_mode": "prod",
        "dump_mode": "overwrite",
        "execute_query": """
            SELECT
                DISTINCT
                    CD_OBRA,
                    REPLACE(REPLACE(DS_TITULO_OBJETO, CHAR(13), ''), CHAR(10), '') AS DS_TITULO_OBJETO,
                    DS_ESTADO,
                    NR_MEDICAO,
                    DT_INI_MEDICAO,
                    DT_FIM_MEDICAO,
                    CD_ETAPA,
                    NM_SISTEMA,
                    NM_SUB_SISTEMA,
                    NM_PLANILHA,
                    NR_ITEM,
                    CD_CHAVE_EXTERNA,
                    REPLACE(REPLACE(DS_ITEM_SERVICO, CHAR(13), ''), CHAR(10), '') AS DS_ITEM_SERVICO,
                    TX_UNIDADE_MEDIDA,
                    VL_ITEM_SERVICO,
                    QT_MEDIDA,
                    QT_ACUMULADA,
                    VL_MEDIDO
            FROM dbo.fuSEGOVI_Itens_Medicao()
            """,
    },
    "orcamento_licitado": {
        "materialize_after_dump": True,
        "materialization_mode": "prod",
        "dump_mode": "overwrite",
        "execute_query": """
            SELECT
                DISTINCT
                    CD_OBRA,
                    REPLACE(REPLACE(DS_TITULO_OBJETO, CHAR(13), ''), CHAR(10), '') AS DS_TITULO_OBJETO,
                    NM_SISTEMA,
                    NM_SUB_SISTEMA,
                    NM_PLANILHA,
                    NR_ITEM,
                    CD_CHAVE_EXTERNA,
                    REPLACE(REPLACE(DS_ITEM_SERVICO, CHAR(13), ''), CHAR(10), '') AS DS_ITEM_SERVICO,
                    TX_UNIDADE_MEDIDA,
                    QT_CONTRATADO,
                    VL_UNITARIO,
                    VL_TOTAL
            FROM dbo.fuSEGOVI_Orcamento_Licitado()
            """,
    },
}

siscob_clocks = generate_dump_db_schedules(
    interval=timedelta(minutes=15),
    start_date=datetime(2024, 1, 1, 2, 0, tzinfo=pytz.timezone("America/Sao_Paulo")),
    labels=[
        constants.RJ_SMI_AGENT_LABEL.value,
    ],
    db_database="SISCOB200",
    db_host="10.70.1.34",
    db_port="1433",
    db_type="sql_server",
    dataset_id="infraestrutura_siscob_obras",
    infisical_secret_path="/db_siscob",
    table_parameters=siscob_queries,
)

siscob_update_schedule = Schedule(clocks=untuple(siscob_clocks))
