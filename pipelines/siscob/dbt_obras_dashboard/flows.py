# -*- coding: utf-8 -*-
"""
DBT-related flows
"""

from copy import deepcopy

from prefect.run_configs import KubernetesRun
from prefect.storage import GCS
from prefeitura_rio.pipelines_templates.run_dbt_model.flows import (
    templates__run_dbt_model__flow,
)
from prefeitura_rio.pipelines_utils.prefect import set_default_parameters
from prefeitura_rio.pipelines_utils.state_handlers import (
    handler_initialize_sentry,
    handler_inject_bd_credentials,
)

from pipelines.constants import constants
from pipelines.siscob.dbt_obras_dashboard.schedules import (
    smi_dashboard_obras_monthly_update_schedule,
)

run_dbt_smi_dashboard_obras_flow = deepcopy(templates__run_dbt_model__flow)
run_dbt_smi_dashboard_obras_flow.name = "SMI: Dashboard de Obras - Materializar tabelas"
run_dbt_smi_dashboard_obras_flow.state_handlers = [
    handler_inject_bd_credentials,
    handler_initialize_sentry,
]
run_dbt_smi_dashboard_obras_flow.storage = GCS(constants.GCS_FLOWS_BUCKET.value)
run_dbt_smi_dashboard_obras_flow.run_config = KubernetesRun(image=constants.DOCKER_IMAGE.value)

smi_dashboard_obras_default_parameters = {
    "dataset_id": "infraestrutura_siscob_obras_dashboard",
    "upstream": True,
    "dbt_alias": True,
}
run_dbt_smi_dashboard_obras_flow = set_default_parameters(
    run_dbt_smi_dashboard_obras_flow,
    default_parameters=smi_dashboard_obras_default_parameters,
)

run_dbt_smi_dashboard_obras_flow.schedule = smi_dashboard_obras_monthly_update_schedule
