# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

############################################################################################################
# Generate customer-managed versions of AWSLambdaBasicExecutionRole, AWSLambdaVPCAccessExecutionRole
############################################################################################################
resource "aws_iam_policy" "aws_lambda_basic_execution" {
  name        = substr("${module.label.id}-aws-lambda-basic-execution", 0, 127)
  path        = "/"
  description = "Customer managed version of AWSLambdaBasicExecutionRole"

  policy = data.aws_iam_policy.AWSLambdaBasicExecutionRole.policy
  tags   = var.tags
}

resource "aws_iam_policy" "aws_lambda_vpc_access_execution" {
  name        = substr("${module.label.id}-aws-lambda-vpc-access-execution", 0, 127)
  path        = "/"
  description = "Customer managed version of AWSLambdaVPCAccessExecutionRole"

  policy = data.aws_iam_policy.AWSLambdaVPCAccessExecutionRole.policy
  tags   = var.tags
}

resource "aws_iam_policy" "aws_lambda_xray_write_only_access" {
  name        = substr("${module.label.id}-aws-lambda-xray-write-only-access", 0, 127)
  path        = "/"
  description = "Customer managed version of AWSXrayWriteOnlyAccess"

  policy = data.aws_iam_policy.AWSXrayWriteOnlyAccess.policy
  tags   = var.tags
}

###################################################################
# CodeBuild
###################################################################

# sce_runner

resource "aws_iam_role" "sce_codebuild_runner" {
  name = substr("${module.label.id}-codebuild-runner", 0, 63)
  assume_role_policy = templatefile("${path.module}/iam/trust-policies/trust.json.tftpl", {
    service_principals = "\"codebuild.amazonaws.com\""
  })
}

resource "aws_iam_role_policy" "sce_codebuild_runner" {
  name = substr("${module.label.id}-codebuild-runner", 0, 63)
  role = aws_iam_role.sce_codebuild_runner.name

  policy = templatefile("${path.module}/iam/role-policies/codebuild/sce-runner.json.tftpl", {
    aws_kms_alias_sce_target_key_arn            = aws_kms_alias.tfc.target_key_arn
    aws_s3_bucket_sce_logging_arn               = aws_s3_bucket.sce_logging.arn
    aws_s3_bucket_sce_terraform_state_arn       = aws_s3_bucket.sce_terraform_state.arn
    data_aws_partition_current_partition        = data.aws_partition.current.partition
    data_aws_region_current_name                = data.aws_region.current.name
    data_aws_caller_identity_current_account_id = data.aws_caller_identity.current.account_id
    ssm_parameter_name                          = substr(var.ssh_key_ssm_parameter_path, 1, -1)
  })
}

###################################################################
# Lambda
###################################################################

# sce_lambda_provisioning_handler

resource "aws_iam_role" "sce_lambda_provisioning_handler" {
  name = substr("${module.label.id}-lambda-provisioning-handler", 0, 63)

  assume_role_policy = templatefile("${path.module}/iam/trust-policies/trust.json.tftpl", {
    service_principals = "\"lambda.amazonaws.com\""
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "sce_lambda_provisioning_handler" {
  name = substr("${module.label.id}-lambda-provisioning-handler", 0, 127)
  role = aws_iam_role.sce_lambda_provisioning_handler.id

  policy = templatefile("${path.module}/iam/role-policies/lambda/sce_provisioning_handler.json.tftpl", {
    aws_kms_alias_sce_target_key_arn                         = module.core.kms_key_arn
    aws_sqs_queue_sce_provision_queue_arn                    = module.core.sqs_provision_queue_arn
    aws_sqs_queue_sce_termination_queue_arn                  = module.core.sqs_termination_queue_arn
    aws_sqs_queue_sce_update_queue_arn                       = module.core.sqs_update_queue_arn
    aws_sfn_state_machine_sce_manage_provisioned_product_arn = aws_sfn_state_machine.sce_manage_provisioned_product.arn
  })
}

resource "aws_iam_role_policy_attachment" "sce_lambda_provisioning_handler" {
  count = length(local.lambda.lambda_managed_policies)

  role       = aws_iam_role.sce_lambda_provisioning_handler.name
  policy_arn = local.lambda.lambda_managed_policies[count.index]
}


# sce_lambda_get_state_file_outputs

resource "aws_iam_role" "sce_lambda_get_state_file_outputs" {
  name = substr("${module.label.id}-lambda-get-state-file-outputs", 0, 63)

  assume_role_policy = templatefile("${path.module}/iam/trust-policies/trust.json.tftpl", {
    service_principals = "\"lambda.amazonaws.com\""
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "sce_lambda_get_state_file_outputs" {
  name = substr("${module.label.id}-lambda-get-state-file-outputs", 0, 127)
  role = aws_iam_role.sce_lambda_get_state_file_outputs.id

  policy = templatefile("${path.module}/iam/role-policies/lambda/sce_get_state_file_outputs.json.tftpl", {
    aws_kms_alias_sce_target_key_arn            = aws_kms_alias.tfc.target_key_arn
    aws_s3_bucket_sce_terraform_state_arn       = aws_s3_bucket.sce_terraform_state.arn
    data_aws_partition_current_partition        = data.aws_partition.current.partition
    data_aws_region_current_name                = data.aws_region.current.name
    data_aws_caller_identity_current_account_id = data.aws_caller_identity.current.account_id

  })
}

resource "aws_iam_role_policy_attachment" "sce_lambda_get_state_file_outputs" {
  count = length(local.lambda.lambda_managed_policies)

  role       = aws_iam_role.sce_lambda_get_state_file_outputs.name
  policy_arn = local.lambda.lambda_managed_policies[count.index]
}

# sce_lambda_notify_provision_update_result

resource "aws_iam_role" "sce_lambda_notify_provision_update_result" {
  name = substr("${module.label.id}-lambda-notify-provision-update-result", 0, 63)

  assume_role_policy = templatefile("${path.module}/iam/trust-policies/trust.json.tftpl", {
    service_principals = "\"lambda.amazonaws.com\""
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "sce_lambda_notify_provision_update_result" {
  name = substr("${module.label.id}-lambda-notify-provision-update-result", 0, 127)
  role = aws_iam_role.sce_lambda_notify_provision_update_result.id

  policy = templatefile("${path.module}/iam/role-policies/lambda/sce_notify_provision_update_result.json.tftpl", {
    data_aws_partition_current_partition        = data.aws_partition.current.partition
    data_aws_region_current_name                = data.aws_region.current.name
    data_aws_caller_identity_current_account_id = data.aws_caller_identity.current.account_id

  })
}

resource "aws_iam_role_policy_attachment" "sce_lambda_notify_provision_update_result" {
  count = length(local.lambda.lambda_managed_policies)

  role       = aws_iam_role.sce_lambda_notify_provision_update_result.name
  policy_arn = local.lambda.lambda_managed_policies[count.index]
}

###################################################################
# Step Functions
###################################################################

# sce_sfn_manage_provisioned_product

resource "aws_iam_role" "sce_sfn_manage_provisioned_product" {
  name = substr("${module.label.id}-sfn-manage-provisioned-product", 0, 63)

  assume_role_policy = templatefile("${path.module}/iam/trust-policies/trust.json.tftpl", {
    service_principals = "\"states.amazonaws.com\""
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "sce_sfn_manage_provisioned_product" {
  name = substr("${module.label.id}-sfn-manage-provisioned-product", 0, 127)
  role = aws_iam_role.sce_sfn_manage_provisioned_product.id

  policy = templatefile("${path.module}/iam/role-policies/states/sce_manage_provisioned_product.json.tftpl", {
    aws_kms_alias_sce_target_key_arn                           = aws_kms_alias.tfc.target_key_arn
    aws_lambda_function_sce_get_state_file_outputs_arn         = aws_lambda_function.sce_get_state_file_outputs.arn
    aws_lambda_function_sce_notify_provision_update_result_arn = aws_lambda_function.sce_notify_provision_update_result.arn
    aws_sns_topic_codebuild_result_notify_arn                  = aws_sns_topic.sns_codebuild_result_notify_topic.arn
    data_aws_region_current_name                               = data.aws_region.current.name
    data_aws_partition_current_partition                       = data.aws_partition.current.partition
    data_aws_caller_identity_current_account_id                = data.aws_caller_identity.current.account_id
    aws_codebuild_project_sce_runner_arn                       = aws_codebuild_project.sce_runner.arn
  })
}