
{{ config(alias='programa_fonte', schema='infraestrutura_siscob_obras_dashboard') }}
SELECT
DISTINCT
  pf.id_obra,
  pf.id_programa_trabalho,
  pf.programa_trabalho,
  pf.id_fonte_recurso,
  pf.fonte_recurso,
  pf.id_natureza_despesa,
  pf.natureza_despesa,
FROM
  `rj-smi.infraestrutura_siscob_obras.programa_fonte` AS pf
  INNER JOIN `rj-smi.infraestrutura_siscob_obras.obra` AS o ON pf.id_obra = o.id_obra
WHERE (
  situacao IN("EXECUTANDO","SUSPENSA") AND
  EXTRACT(YEAR FROM(o.data_termino_atual)) >= 2021
  ) OR
  EXTRACT(YEAR FROM(o.data_inicio)) >= 2021