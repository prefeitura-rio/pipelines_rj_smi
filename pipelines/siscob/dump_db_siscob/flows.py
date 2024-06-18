# -*- coding: utf-8 -*-
"""
Database dumping flows for segovi project (SISCOB).
"""

from copy import deepcopy

from prefect.run_configs import KubernetesRun
from prefect.storage import GCS
from prefeitura_rio.pipelines_templates.dump_db.flows import flow as dump_sql_flow
from prefeitura_rio.pipelines_utils.prefect import set_default_parameters
from prefeitura_rio.pipelines_utils.state_handlers import (
    handler_initialize_sentry,
    handler_inject_bd_credentials,
)

from pipelines.constants import constants
from pipelines.siscob.dump_db_siscob.schedules import siscob_update_schedule

dump_siscob_flow = deepcopy(dump_sql_flow)
dump_siscob_flow.name = "SMI: SISCOB - Ingerir tabelas de banco SQL"
dump_siscob_flow.state_handlers = [handler_inject_bd_credentials, handler_initialize_sentry]
dump_siscob_flow.storage = GCS(constants.GCS_FLOWS_BUCKET.value)
dump_siscob_flow.run_config = KubernetesRun(
    image=constants.DOCKER_IMAGE.value,
    labels=[
        constants.RJ_SMI_AGENT_LABEL.value,
    ],
)

siscob_default_parameters = {
    "db_database": "SISCOB200",
    "db_host": "10.70.1.34",
    "db_port": "1433",
    "db_type": "sql_server",
    "infisical_secret_path": "/db_siscob",
    "dataset_id": "infraestrutura_siscob_obras",
}
dump_siscob_flow = set_default_parameters(
    dump_siscob_flow, default_parameters=siscob_default_parameters
)

dump_siscob_flow.schedule = siscob_update_schedule
