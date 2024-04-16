# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# Out of the box deployment with e-mail notifications
module "sce_tf" {
  source = "git::ssh://git@ssh.gitlab.aws.dev/albsilv/terraform-aws-sce-tf-community.git?ref=develop"

  sns_topic_email_addresses = ["albsilv@amazon.com"]
}