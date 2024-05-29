# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

module "build" {
  source = "./modules/dependency-builder"

  common_name                    = module.label.id
  golang_version                 = local.golang.version
  kms_key_arn                    = aws_kms_alias.tfc.target_key_arn
  python_version                 = local.python.version
  s3_logging_bucket_name         = aws_s3_bucket.sce_logging.id
  s3_terraform_state_bucket_name = aws_s3_bucket.sce_terraform_state.id
  tags                           = var.tags
  terraform_runner_version       = local.python.terraform_runner_version
  vpc_deployment                 = local.vpc_deployment
  vpc_id                         = var.vpc_id
  vpc_private_subnet_ids         = var.vpc_private_subnet_ids
  vpc_security_group_ids         = var.vpc_security_group_ids
}