SELECT 
    DISTINCT
        SAFE_CAST(REGEXP_REPLACE(cd_obra, r'\.0$', '') AS STRING) id_obra,
        SAFE_CAST(etapa AS STRING) id_etapa,
        SAFE_CAST(
            SAFE.PARSE_DATE ('%Y-%m-%d', dt_inicio_etapa) AS DATE
        ) AS data_inicio,
        SAFE_CAST(
            SAFE.PARSE_DATE ('%Y-%m-%d', dt_fim_etapa) AS DATE
        ) AS data_fim,
        SAFE_CAST(vl_estimado AS FLOAT64) valor_estimado,
        SAFE_CAST(pc_percentual AS FLOAT64) percentual_estimado
FROM `rj-smi.infraestrutura_siscob_obras_staging.cronograma_financeiro`