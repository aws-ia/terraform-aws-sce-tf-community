# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# Out of the box deployment (no VPC, notifications, etc.)
module "sce_tf" {
  source = "../.."
  
  s3_force_destroy = var.s3_force_destroy
}

variable "s3_force_destroy" {
  description = "Set to true if you want to force delete S3 bucket created by this module (including contents of the bucket)"
  type        = bool
  default     = false
}