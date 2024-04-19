# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

module "core" {
  source = "git@github.com:aws-ia/terraform-aws-sce-core.git?ref=main" # tflint-ignore: terraform_module_pinned_source

  cloudwatch_log_group_retention = var.cloudwatch_log_group_retention

  label_id_order = var.label_id_order

  lambda_sce_parameter_parser_architectures = ["arm64"]
  lambda_sce_parameter_parser_handler       = "bootstrap"
  lambda_sce_parameter_parser_runtime       = "provided.al2023"
  lambda_sce_parameter_parser_s3_bucket     = aws_s3_bucket.sce_terraform_state.id
  lambda_sce_parameter_parser_s3_key        = "build/terraform-parameter-parser.zip"

  stage = var.stage

  vpc_id                 = var.vpc_id
  vpc_private_subnet_ids = var.vpc_private_subnet_ids
  vpc_security_group_ids = var.vpc_security_group_ids

  tags = var.tags

  depends_on = [module.build]
}
