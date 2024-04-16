# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

#########################################
# Solution-Level Variables
#########################################

variable "create_ssh_key_ssm_parameter" {
  description = "Boolean flag indicating whether an SSM parameter will be created for an SSH key. If created, it will be defaulted to a value of REPLACE_ME and will need to be updated outside of this module."
  type        = bool
  default     = false
}

variable "label_id_order" {
  description = "ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique"
  type        = list(string)
  default     = ["name", "namespace", "stage"]
}

variable "ssh_key_ssm_parameter_path" {
  description = "The SSM parameter path containing a private SSH key for cloning modules from private Git repositories."
  type        = string
  default     = "/sce/tf/ssh-key"
}

variable "stage" {
  description = "Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'."
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags to apply to resources deployed by this solution."
  type        = map(any)
  default     = null
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
# S3 Variables
#########################################

variable "s3_access_logging_expiration_days" {
  description = "The amount of days to retain logs in the S3 logs bucket"
  type        = string
  default     = "365"
}

#########################################
# SFN Variables
#########################################

variable "sfn_log_level" {
  description = "Defines which category of execution history events are logged. Valid values: ALL, ERROR, FATAL, OFF"
  type        = string
  default     = "ALL"
  validation {
    condition     = contains(["ALL", "ERROR", "FATAL", "OFF"], var.sfn_log_level)
    error_message = "Valid values for var: sfn_log_level are (true, false)."
  }
}

#########################################
# SNS Variable
#########################################

variable "sns_topic_email_addresses" {
  description = "The email address to notify about the AWS CodeBuild success or failure"
  type        = list(string)
  default     = []
}

#########################################
# VPC Variables
#########################################

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

#########################################
# X-Ray Variables
#########################################

variable "x_ray_tracing_enabled" {
  description = "When set to true, AWS X-Ray tracing is enabled."
  type        = bool
  default     = true
  validation {
    condition     = contains([true, false], var.x_ray_tracing_enabled)
    error_message = "Valid values for var: x_ray_tracing_enabled are (true, false)."
  }
}

