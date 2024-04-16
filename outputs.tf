# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

output "sce_parameter_parser_role_arn" {
  value = module.core.sce_parameter_parser_role_arn
}

output "terraform_execution_role" {
  value = aws_iam_role.sce_codebuild_runner.arn
}