# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "service_catalog_product_owner" {
  type        = string
  description = "Name of the owner of the AWS Service Catalog Product"
  default     = "Service Catalog Admin"
}

variable "parameter_parser_role_arn" {
  type        = string
  description = "ARN of the IAM Role that the Terraform Parameter Parser Lambda Function uses to parse parameters"
}

variable "terraform_execution_role_arn" {
  type        = string
  description = "ARN of the IAM Role used in CodeBuild to perform Terraform workflow"
}