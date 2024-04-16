# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_codebuild_project" "sce_runner" {

  name           = local.codebuild.sce_runner.name
  build_timeout  = local.codebuild.sce_runner.build_timeout
  description    = local.codebuild.sce_runner.description
  encryption_key = aws_kms_alias.tfc.target_key_arn
  service_role   = aws_iam_role.sce_codebuild_runner.arn
  tags           = var.tags

  artifacts {
    type = local.codebuild.sce_runner.artifacts_type
  }

  environment {
    compute_type                = local.codebuild.sce_runner.compute_type
    image                       = local.codebuild.sce_runner.image
    type                        = local.codebuild.sce_runner.type
    image_pull_credentials_type = local.codebuild.sce_runner.image_pull_credentials_type
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.sce_codebuild_runner.name
    }

    s3_logs {
      status   = local.codebuild.sce_runner.s3_logs_status
      location = "${aws_s3_bucket.sce_logging.id}/${local.codebuild.sce_runner.name}"
    }
  }

  source {
    type = local.codebuild.sce_runner.source_type
    buildspec = templatefile("${path.module}/buildspecs/sce_runner.yml.tftpl", {
      aws_s3_bucket_sce_terraform_state_id = aws_s3_bucket.sce_terraform_state.id
      ssh_key_ssm_parameter_path           = var.ssh_key_ssm_parameter_path
      terraform_runner_version             = local.python.terraform_runner_version
      terraform_version                    = local.terraform.version
    })
  }

  dynamic "vpc_config" {
    for_each = local.vpc_deployment ? [1] : [0]
    content {
      vpc_id             = local.vpc_deployment ? var.vpc_id : ""
      subnets            = local.vpc_deployment ? var.vpc_private_subnet_ids : []
      security_group_ids = local.vpc_deployment ? var.vpc_security_group_ids : []
    }
  }

  depends_on = [aws_cloudwatch_log_group.sce_codebuild_runner]
}