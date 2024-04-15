{{ config(alias='medicao', schema='infraestrutura_siscob_obras_dashboard') }}
SELECT
  m.id_obra,
  m.id_medicao,
  m.id_etapa,
  m.tipo_medicao,
  m.data_inicio,
  m.data_fim,
  m.valor_final,
FROM
  `rj-smi.infraestrutura_siscob_obras.medicao` AS m
  INNER JOIN `rj-smi.infraestrutura_siscob_obras.obra` AS o ON m.id_obra = o.id_obra
WHERE (
  situacao IN("EXECUTANDO","SUSPENSA") AND 
  EXTRACT(YEAR FROM(o.data_termino_atual)) >= 2021
  ) OR
  EXTRACT(YEAR FROM(o.data_inicio)) >= 2021