# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_iam_role" "codebuild" {
  name = var.common_name
  assume_role_policy = templatefile("${path.module}/iam/trust-policies/trust.json.tftpl", {
    service_principals = "\"codebuild.amazonaws.com\""
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "codebuild" {
  role = aws_iam_role.codebuild.name
  policy = templatefile("${path.module}/iam/role-policies/codebuild.tftpl", {
    data_aws_caller_identity_current_account_id = data.aws_caller_identity.current.account_id
    data_aws_partition_current_partition        = data.aws_partition.current.partition
    data_aws_region_current_name                = data.aws_region.current.name
    kms_key_arn                                 = var.kms_key_arn
    s3_terraform_state_bucket_name              = var.s3_terraform_state_bucket_name
    s3_logging_bucket_name                      = var.s3_logging_bucket_name
  })
}

resource "aws_iam_role" "codebuild_trigger_lambda_role" {
  name = "codebuild_trigger_role"
  assume_role_policy = templatefile("${path.module}/iam/trust-policies/trust.json.tftpl", {
    service_principals = "\"lambda.amazonaws.com\""
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "codebuild_trigger_policy" {
  role = aws_iam_role.codebuild_trigger_lambda_role.name
  policy = templatefile("${path.module}/iam/role-policies/codebuild-trigger.tftpl", {
    aws_codebuild_project_this_name                     = aws_codebuild_project.this.name
    aws_lambda_function_codebuild_trigger_function_name = local.lambda.codebuild_trigger.function_name
    data_aws_partition_current_partition                = data.aws_partition.current.partition
    data_aws_region_current_name                        = data.aws_region.current.name
    data_aws_caller_identity_current_account_id         = data.aws_caller_identity.current.account_id
    kms_key_arn                                         = var.kms_key_arn
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_trigger_vpc_access" {
  role       = aws_iam_role.codebuild_trigger_lambda_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}