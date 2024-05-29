# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/${substr("${var.common_name}-dependency-builder", 0, 254)}"
  kms_key_id        = var.kms_key_arn
  retention_in_days = var.cloudwatch_log_group_retention
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "lambda_codebuild_trigger" {
  name              = "/aws/lambda/${local.lambda.codebuild_trigger.function_name}"
  kms_key_id        = var.kms_key_arn
  retention_in_days = var.cloudwatch_log_group_retention
  tags              = var.tags
}
