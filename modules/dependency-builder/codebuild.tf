# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_codebuild_project" "this" {
  name           = substr("${var.common_name}-dependency-builder", 0, 254)
  description    = "Codebuild project to build dependencies for ${var.common_name}"
  build_timeout  = "10"
  service_role   = aws_iam_role.codebuild.arn
  encryption_key = var.kms_key_arn
  tags           = var.tags

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "aws/codebuild/amazonlinux2-aarch64-standard:3.0"
    type                        = "ARM_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild.name
      stream_name = "${var.common_name}-dependency-builder-logs"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${var.s3_logging_bucket_name}/${var.common_name}-dependency-builder-logs"
    }
  }

  source {
    type = "NO_SOURCE"
    buildspec = templatefile("${path.module}/buildspecs/dependency-builder.yml", {

      golang_version                 = var.golang_version
      python_version                 = var.python_version
      s3_terraform_state_bucket_name = var.s3_terraform_state_bucket_name
      terraform_runner_version       = var.terraform_runner_version

    })
  }

  dynamic "vpc_config" {
    for_each = var.vpc_deployment ? [1] : []
    content {
      vpc_id             = var.vpc_deployment ? var.vpc_id : ""
      subnets            = var.vpc_deployment ? var.vpc_private_subnet_ids : []
      security_group_ids = var.vpc_deployment ? var.vpc_security_group_ids : []
    }
  }
}

