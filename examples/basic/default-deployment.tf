# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# Out of the box deployment (no VPC, notifications, etc.)
module "sce_tf" {
  source = "git::ssh://git@ssh.gitlab.aws.dev/albsilv/terraform-aws-sce-tf-community.git?ref=develop"
}