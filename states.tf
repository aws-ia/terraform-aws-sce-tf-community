# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_sfn_state_machine" "sce_manage_provisioned_product" {
  name = local.sfn.sce_manage_provisioned_product.name

  definition = templatefile("${path.module}/states/manage_provisioned_product.asl.tftpl", {
    data_aws_partition_current_partition                       = data.aws_partition.current.partition
    data_aws_region_current_name                               = data.aws_region.current.name
    data_aws_caller_identity_current_account_id                = data.aws_caller_identity.current.account_id
    aws_codebuild_project_sce_runner_name                      = aws_codebuild_project.sce_runner.name
    aws_lambda_function_sce_get_state_file_outputs_arn         = aws_lambda_function.sce_get_state_file_outputs.arn
    aws_lambda_function_sce_notify_provision_update_result_arn = aws_lambda_function.sce_notify_provision_update_result.arn
    aws_sns_topic_codebuild_result_notify_arn                  = aws_sns_topic.sns_codebuild_result_notify_topic.arn
  })

  role_arn = aws_iam_role.sce_sfn_manage_provisioned_product.arn

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.sce_sfn_manage_provisioned_product.arn}:*"
    include_execution_data = true
    level                  = var.sfn_log_level
  }
  tracing_configuration {
    enabled = var.x_ray_tracing_enabled
  }

  tags = var.tags
}
