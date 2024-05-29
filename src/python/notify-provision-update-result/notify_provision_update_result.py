# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

import logging

from sce_terraform_community.core.configuration import Configuration
from sce_terraform_community.core.exception import log_exception
from sce_terraform_community.core.service_catalog_facade import ServiceCatalogFacade
from sce_terraform_community.notify.errors import get_failure_reason, workflow_has_error
from sce_terraform_community.notify.outputs import (
    convert_state_file_outputs_to_service_catalog_outputs,
)

# Globals
log = logging.getLogger()
log.setLevel(logging.INFO)
app_config = None
service_catalog_facade = None

# Input keys
WORKFLOW_TOKEN_KEY = "token"
SCE_OPERATION = "operation"
RECORD_ID_KEY = "recordId"
TRACER_TAG_KEY = "tracerTag"
TRACER_TAG_KEY_KEY = "key"
TRACER_TAG_VALUE_KEY = "value"


def __notify_succeeded(event):
    service_catalog_facade.notify_provision_succeeded(
        workflow_token=event[WORKFLOW_TOKEN_KEY],
        record_id=event[RECORD_ID_KEY],
        tracer_tag_key=event[TRACER_TAG_KEY][TRACER_TAG_KEY_KEY],
        tracer_tag_value=event[TRACER_TAG_KEY][TRACER_TAG_VALUE_KEY],
        outputs=convert_state_file_outputs_to_service_catalog_outputs(event),
    )


def __notify_failed(event):
    service_catalog_facade.notify_provision_failed(
        workflow_token=event[WORKFLOW_TOKEN_KEY],
        record_id=event[RECORD_ID_KEY],
        failure_reason=get_failure_reason(event),
        tracer_tag_key=event[TRACER_TAG_KEY][TRACER_TAG_KEY_KEY],
        tracer_tag_value=event[TRACER_TAG_KEY][TRACER_TAG_VALUE_KEY],
        outputs=convert_state_file_outputs_to_service_catalog_outputs(event),
    )


def __notify_update_succeeded(event):
    service_catalog_facade.notify_update_succeeded(
        workflow_token=event[WORKFLOW_TOKEN_KEY],
        record_id=event[RECORD_ID_KEY],
        outputs=convert_state_file_outputs_to_service_catalog_outputs(event),
    )


def __notify_update_failed(event):
    service_catalog_facade.notify_update_failed(
        workflow_token=event[WORKFLOW_TOKEN_KEY],
        record_id=event[RECORD_ID_KEY],
        failure_reason=get_failure_reason(event),
        outputs=convert_state_file_outputs_to_service_catalog_outputs(event),
    )


def notify(event, context):
    log.info(f"Handling event {event}")

    global app_config
    global service_catalog_facade

    try:
        if not app_config:
            app_config = Configuration()
        if not service_catalog_facade:
            service_catalog_facade = ServiceCatalogFacade(app_config)

        if event[SCE_OPERATION] == "PROVISION_PRODUCT":
            if workflow_has_error(event):
                __notify_failed(event)
            else:
                __notify_succeeded(event)
        elif event[SCE_OPERATION] == "UPDATE_PROVISIONED_PRODUCT":
            if workflow_has_error(event):
                __notify_update_failed(event)
            else:
                __notify_update_succeeded(event)

    except Exception as exception:
        log_exception(exception)
        raise exception
