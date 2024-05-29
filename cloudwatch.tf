# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

#########################################
# CodeBuild
#########################################
resource "aws_cloudwatch_log_group" "sce_codebuild_runner" {
  name              = "${local.cloudwatch.codebuild_log_group_prefix}/${local.codebuild.sce_runner.name}"
  kms_key_id        = aws_kms_alias.tfc.target_key_arn
  retention_in_days = var.cloudwatch_log_group_retention
  tags              = var.tags
}


#########################################
# Lambda Functions
#########################################

resource "aws_cloudwatch_log_group" "sce_lambda_provisioning_handler" {
  name              = "${local.cloudwatch.lambda_log_group_prefix}/${local.lambda.sce_lambda_provisioning_handler.function_name}"
  kms_key_id        = aws_kms_alias.tfc.target_key_arn
  retention_in_days = var.cloudwatch_log_group_retention
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "sce_lambda_get_state_file_outputs" {
  name              = "${local.cloudwatch.lambda_log_group_prefix}/${local.lambda.sce_get_state_file_outputs.function_name}"
  kms_key_id        = aws_kms_alias.tfc.target_key_arn
  retention_in_days = var.cloudwatch_log_group_retention
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "sce_lambda_notify_provision_update_result" {
  name              = "${local.cloudwatch.lambda_log_group_prefix}/${local.lambda.sce_notify_provision_update_result.function_name}"
  kms_key_id        = aws_kms_alias.tfc.target_key_arn
  retention_in_days = var.cloudwatch_log_group_retention
  tags              = var.tags
}

#########################################
# Step Functions
#########################################

resource "aws_cloudwatch_log_group" "sce_sfn_manage_provisioned_product" {
  name              = "${local.cloudwatch.sfn_log_group_prefix}/${local.sfn.sce_manage_provisioned_product.name}"
  kms_key_id        = aws_kms_alias.tfc.target_key_arn
  retention_in_days = var.cloudwatch_log_group_retention
  tags              = var.tags
}