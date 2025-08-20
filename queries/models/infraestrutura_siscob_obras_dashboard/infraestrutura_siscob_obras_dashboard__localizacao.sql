{{ config(alias='localizacao', schema='infraestrutura_siscob_obras_dashboard') }}
SELECT
  l.id_obra,
  l.id_bairro,
  l.bairro,
  l.id_regiao_planejamento,
  l.endereco,
  l.latitude,
  l.longitude,
  l.bairro_regiao_planejamento AS ap_bairro,
  l.latitude_regiao_planejamento AS latitude_ap,
  l.longitude_regiao_planejamento AS longitude_ap,
FROM
  `rj-smi.infraestrutura_siscob_obras.localizacao` AS l
INNER JOIN `rj-smi.infraestrutura_siscob_obras.obra` AS o
  ON l.id_obra = o.id_obra
WHERE (
  situacao IN("EXECUTANDO","SUSPENSA") AND
  EXTRACT(YEAR FROM(o.data_termino_atual)) >= 2021
  ) OR
  EXTRACT(YEAR FROM(o.data_inicio)) >= 2021