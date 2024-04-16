# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_lambda_function" "codebuild_trigger" {
  #checkov:skip=CKV_AWS_115:Concurrent execution limit not required
  #checkov:skip=CKV_AWS_272:Code signing not required
  #checkov:skip=CKV_AWS_116:DLQ not required
  #checkov:skip=CKV_AWS_50:X-Ray tracing not required

  architectures    = ["arm64"]
  filename         = data.archive_file.codebuild_trigger.output_path
  function_name    = substr("${var.common_name}-codebuild-trigger", 0, 63)
  description      = "${var.common_name} - CodeBuild Trigger"
  role             = aws_iam_role.codebuild_trigger_lambda_role.arn
  handler          = "codebuild_trigger.lambda_handler"
  source_code_hash = data.archive_file.codebuild_trigger.output_base64sha256
  memory_size      = local.lambda.codebuild_trigger.memory_size
  runtime          = "python${local.python_version}"
  tags             = var.tags
  timeout          = local.lambda.codebuild_trigger.timeout

  dynamic "vpc_config" {
    for_each = var.vpc_deployment ? [1] : []
    content {
      subnet_ids         = var.vpc_deployment ? var.vpc_private_subnet_ids : []
      security_group_ids = var.vpc_deployment ? var.vpc_security_group_ids : []
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda_codebuild_trigger]
}