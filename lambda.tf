# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

############################################################################################################
# sce_terraform_community_layer
############################################################################################################
resource "aws_lambda_layer_version" "sce_terraform_community_layer" {
  filename         = data.archive_file.sce_terraform_community_layer.output_path
  layer_name       = local.lambda_layer.sce_terraform_community_layer.layer_name
  source_code_hash = data.archive_file.sce_terraform_community_layer.output_base64sha256
}

############################################################################################################
# sce_provisioning_handler
############################################################################################################

resource "aws_lambda_function" "sce_provisioning_handler" {
  # tflint-ignore: aws_lambda_function_invalid_runtime
  #checkov:skip=CKV_AWS_115:Concurrent execution limit not required
  #checkov:skip=CKV_AWS_272:Code signing not required
  #checkov:skip=CKV_AWS_116:DLQ is not required

  architectures    = local.lambda.sce_lambda_provisioning_handler.architectures
  description      = local.lambda.sce_lambda_provisioning_handler.description
  filename         = data.archive_file.sce_provisioning_handler.output_path
  function_name    = local.lambda.sce_lambda_provisioning_handler.function_name
  handler          = local.lambda.sce_lambda_provisioning_handler.handler
  kms_key_arn      = aws_kms_alias.tfc.target_key_arn
  layers           = [aws_lambda_layer_version.sce_terraform_community_layer.arn]
  memory_size      = local.lambda.sce_lambda_provisioning_handler.memory_size
  role             = aws_iam_role.sce_lambda_provisioning_handler.arn
  runtime          = local.lambda.sce_lambda_provisioning_handler.runtime
  source_code_hash = data.archive_file.sce_provisioning_handler.output_base64sha256
  tags             = var.tags
  timeout          = local.lambda.sce_lambda_provisioning_handler.timeout

  environment {
    variables = {
      STATE_MACHINE_ARN = aws_sfn_state_machine.sce_manage_provisioned_product.arn
    }
  }

  tracing_config {
    mode = local.lambda.sce_lambda_provisioning_handler.tracing_config_mode
  }

  dynamic "vpc_config" {
    for_each = local.vpc_deployment ? [1] : [0]
    content {
      subnet_ids         = local.vpc_deployment ? var.vpc_private_subnet_ids : []
      security_group_ids = local.vpc_deployment ? var.vpc_security_group_ids : []
    }
  }

  depends_on = [aws_cloudwatch_log_group.sce_lambda_provisioning_handler]
}

resource "aws_lambda_event_source_mapping" "sce_provision_queue" {
  event_source_arn = module.core.sqs_provision_queue_arn
  function_name    = aws_lambda_function.sce_provisioning_handler.arn
}

resource "aws_lambda_event_source_mapping" "sce_update_queue" {
  event_source_arn = module.core.sqs_update_queue_arn
  function_name    = aws_lambda_function.sce_provisioning_handler.arn
}

resource "aws_lambda_event_source_mapping" "sce_terminate_queue" {
  event_source_arn = module.core.sqs_termination_queue_arn
  function_name    = aws_lambda_function.sce_provisioning_handler.arn
}

############################################################################################################
# sce_get_state_file_outputs
############################################################################################################

resource "aws_lambda_function" "sce_get_state_file_outputs" {
  #checkov:skip=CKV_AWS_115:Concurrent execution limit not required
  #checkov:skip=CKV_AWS_272:Code signing not required
  #checkov:skip=CKV_AWS_116:DLQ is not required

  architectures    = local.lambda.sce_get_state_file_outputs.architectures
  description      = local.lambda.sce_get_state_file_outputs.description
  filename         = data.archive_file.sce_get_state_file_outputs.output_path
  function_name    = local.lambda.sce_get_state_file_outputs.function_name
  handler          = local.lambda.sce_get_state_file_outputs.handler
  kms_key_arn      = aws_kms_alias.tfc.target_key_arn
  layers           = [aws_lambda_layer_version.sce_terraform_community_layer.arn]
  memory_size      = local.lambda.sce_get_state_file_outputs.memory_size
  role             = aws_iam_role.sce_lambda_get_state_file_outputs.arn
  runtime          = local.lambda.sce_get_state_file_outputs.runtime
  source_code_hash = data.archive_file.sce_get_state_file_outputs.output_base64sha256
  tags             = var.tags
  timeout          = local.lambda.sce_get_state_file_outputs.timeout

  environment {
    variables = {
      STATE_BUCKET_NAME = aws_s3_bucket.sce_terraform_state.id
    }
  }

  tracing_config {
    mode = local.lambda.sce_get_state_file_outputs.tracing_config_mode
  }

  dynamic "vpc_config" {
    for_each = local.vpc_deployment ? [1] : [0]
    content {
      subnet_ids         = local.vpc_deployment ? var.vpc_private_subnet_ids : []
      security_group_ids = local.vpc_deployment ? var.vpc_security_group_ids : []
    }
  }

  depends_on = [aws_cloudwatch_log_group.sce_lambda_get_state_file_outputs]
}

############################################################################################################
# sce_notify_provision_update_result
############################################################################################################

resource "aws_lambda_function" "sce_notify_provision_update_result" {
  #checkov:skip=CKV_AWS_115:Concurrent execution limit not required
  #checkov:skip=CKV_AWS_272:Code signing not required
  #checkov:skip=CKV_AWS_116:DLQ is not required

  architectures    = local.lambda.sce_notify_provision_update_result.architectures
  description      = local.lambda.sce_notify_provision_update_result.description
  filename         = data.archive_file.sce_notify_provision_update_result.output_path
  function_name    = local.lambda.sce_notify_provision_update_result.function_name
  handler          = local.lambda.sce_notify_provision_update_result.handler
  layers           = [aws_lambda_layer_version.sce_terraform_community_layer.arn]
  memory_size      = local.lambda.sce_notify_provision_update_result.memory_size
  role             = aws_iam_role.sce_lambda_notify_provision_update_result.arn
  runtime          = local.lambda.sce_notify_provision_update_result.runtime
  source_code_hash = data.archive_file.sce_notify_provision_update_result.output_base64sha256
  tags             = var.tags
  timeout          = local.lambda.sce_notify_provision_update_result.timeout

  tracing_config {
    mode = local.lambda.sce_notify_provision_update_result.tracing_config_mode
  }


  dynamic "vpc_config" {
    for_each = local.vpc_deployment ? [1] : [0]
    content {
      subnet_ids         = local.vpc_deployment ? var.vpc_private_subnet_ids : []
      security_group_ids = local.vpc_deployment ? var.vpc_security_group_ids : []
    }
  }

  depends_on = [aws_cloudwatch_log_group.sce_lambda_notify_provision_update_result]
}