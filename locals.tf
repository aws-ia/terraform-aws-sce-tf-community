# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  archive_path = "./build/src"

  cloudwatch = {
    codebuild_log_group_prefix = "/aws/codebuild"
    lambda_log_group_prefix    = "/aws/lambda"
    sfn_log_group_prefix       = "/aws/states"
  }
  codebuild = {
    sce_runner = {
      artifacts_type              = "NO_ARTIFACTS"
      build_timeout               = 480
      compute_type                = "BUILD_GENERAL1_LARGE"
      description                 = "Service Catalog Engine for Terraform Community Runner"
      image                       = "aws/codebuild/amazonlinux2-aarch64-standard:3.0"
      image_pull_credentials_type = "CODEBUILD"
      name                        = substr("${module.label.id}-runner", 0, 254)
      s3_logs_status              = "ENABLED"
      source_type                 = "NO_SOURCE"
      type                        = "ARM_CONTAINER"
      role_name_prefix            = "TerraformExecutionRole"
    }
  }

  golang = {
    version = "1.21"
  }

  kms = {
    tfc = {
      alias       = "alias/tfc"
      description = "KMS key for Service Catalog Engine TFC"
    }
  }
  lambda = {
    lambda_managed_policies = local.vpc_deployment ? [aws_iam_policy.aws_lambda_basic_execution.arn, aws_iam_policy.aws_lambda_vpc_access_execution.arn, aws_iam_policy.aws_lambda_xray_write_only_access.arn] : [aws_iam_policy.aws_lambda_basic_execution.arn, aws_iam_policy.aws_lambda_xray_write_only_access.arn]
    sce_lambda_provisioning_handler = {
      architectures       = ["arm64"]
      description         = "Handles TF Provisioning Operations - Invoked by SQS"
      function_name       = substr("${module.label.id}-provisioning-handler", 0, 63)
      handler             = "provisioning_operations_handler.handle_sqs_records"
      memory_size         = 256
      runtime             = "python3.12"
      timeout             = "30"
      tracing_config_mode = "Active"
    }
    sce_get_state_file_outputs = {
      architectures       = ["arm64"]
      description         = "Handles state file parsing which is stored in S3  - Invoked by SfN"
      function_name       = substr("${module.label.id}-get-state-file-outputs", 0, 63)
      handler             = "get_state_file_outputs.parse"
      memory_size         = 256
      runtime             = "python3.12"
      timeout             = "30"
      tracing_config_mode = "Active"
    }
    sce_notify_provision_update_result = {
      architectures       = ["arm64"]
      description         = "Handles the notification to Service Catalog - Invoked by SfN"
      function_name       = substr("${module.label.id}-notify-provision-update-result", 0, 63)
      handler             = "notify_provision_update_result.notify"
      memory_size         = 256
      runtime             = "python3.12"
      timeout             = "30"
      tracing_config_mode = "Active"
    }
  }

  lambda_layer = {
    sce_terraform_community_layer = {
      layer_name = substr("${module.label.id}-lambda-layer", 0, 63)
    }
  }

  python = {
    terraform_runner_version = "0.1"
    version                  = "3.12"
  }

  region              = data.aws_region.current.name
  region_abbreviation = format("%s%s%s", substr(split("-", local.region)[0], 0, 1), substr(split("-", local.region)[1], 0, 1), substr(split("-", local.region)[2], 0, 1))

  s3 = {
    sce_terraform_state = {
      bucket                          = substr("${module.label.id}-${data.aws_caller_identity.current.account_id}-tf-state", 0, 62)
      sse_algorithm                   = "aws:kms"
      versioning_configuration_status = "Enabled"
    }
    sce_logging = {
      bucket                          = substr("${module.label.id}-${data.aws_caller_identity.current.account_id}-logging", 0, 62)
      sse_algorithm                   = "aws:kms"
      versioning_configuration_status = "Enabled"
    }
    sce_access_logs = {
      bucket                          = substr("${module.label.id}-${data.aws_caller_identity.current.account_id}-access-logs", 0, 62)
      sse_algorithm                   = "AES256"
      versioning_configuration_status = "Enabled"
    }
  }

  sfn = {
    sce_manage_provisioned_product = {
      name = substr("${module.label.id}-manage-provisioned-product", 0, 63)
    }
  }

  sns = {
    sns_codebuild_result_notify_topic = {
      name = substr("${module.label.id}-sns-codebuild-result-notify-topic", 0, 63)
    }
  }
  solution_name = "aws-sce-tf-community"

  terraform = {
    version = "1.5.7"
  }

  vpc_deployment = var.vpc_id != null ? true : false
}
