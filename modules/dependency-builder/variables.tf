# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

#########################################
# Solution-Level Variables
#########################################

variable "common_name" {
  description = "Common name to be used for resources deployed by this module"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN for the KMS Key being used for this solution"
  type        = string
}

variable "s3_logging_bucket_name" {
  description = "The name of the S3 bucket used to store logs for the solution"
  type        = string
}

variable "s3_terraform_state_bucket_name" {
  description = "The name of the S3 bucket used to store state for the solution"
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to resources deployed by this solution."
  type        = map(any)
  default     = null
}
#########################################
# Build Variables
#########################################

variable "golang_version" {
  description = "The version of Golang to leverage in Codebuild"
  type        = string
}

variable "python_version" {
  description = "The version of Python to leverage in Codebuild"
  type        = string
}
variable "terraform_runner_version" {
  description = "The version of the Terraform Runner being built"
  type        = string
}

#########################################
# Cloudwatch Variables
#########################################

variable "cloudwatch_log_group_retention" {
  description = "Amount of days to keep CloudWatch Log Groups for Lambda functions. 0 = Never Expire"
  type        = string
  default     = "0"
  validation {
    condition     = contains(["1", "3", "5", "7", "14", "30", "60", "90", "120", "150", "180", "365", "400", "545", "731", "1827", "3653", "0"], var.cloudwatch_log_group_retention)
    error_message = "Valid values for var: cloudwatch_log_group_retention are (1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0)."
  }
}

#########################################
# VPC Variables
#########################################

variable "vpc_deployment" {
  type        = bool
  description = "A boolean flag that devermines whether this solution will be deployed inside a VPC"
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to use if leveraging an existing VPC for the solution. Otherwise, a VPC will be created as part of deployment."
  default     = null
}

variable "vpc_private_subnet_ids" {
  type        = list(string)
  description = "Required if `vpc_id` is specified. List of private subnets to use in the provided vpc_id"
  default     = null
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Required if `vpc_id` is specified. List of security groups to use in the provided vpc_id"
  default     = null
}
