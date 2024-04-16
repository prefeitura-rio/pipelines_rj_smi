# -*- coding: utf-8 -*-
"""
DBT-related flows.
"""

from copy import deepcopy

from prefect.run_configs import KubernetesRun
from prefect.storage import GCS

from prefeitura_rio.pipelines_templates.run_dbt_model.flows import (
    templates__run_dbt_model__flow,
)
from prefeitura_rio.pipelines_utils.state_handlers import (
    handler_initialize_sentry,
    handler_inject_bd_credentials,
)

from pipelines.constants import constants

template_dbt_flow = deepcopy(templates__run_dbt_model__flow)
template_dbt_flow.state_handlers = [
    handler_inject_bd_credentials,
    handler_initialize_sentry,
]
template_dbt_flow.storage = GCS(constants.GCS_FLOWS_BUCKET.value)
template_dbt_flow.run_config = KubernetesRun(image=constants.DOCKER_IMAGE.value)