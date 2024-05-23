# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

output "sce_parameter_parser_role_arn" {
  description = "Parameter parser Lambda function IAM role ARN. You need to allow this role to assume the portfolio launch role"
  value       = module.core.sce_parameter_parser_role_arn
}

# TODO: make this clear what this role is about
output "terraform_execution_role" {
  description = "CodeBuild IAM role ARN. You need to allow this role to assume the portfolio launch role"
  value       = aws_iam_role.sce_codebuild_runner.arn
}