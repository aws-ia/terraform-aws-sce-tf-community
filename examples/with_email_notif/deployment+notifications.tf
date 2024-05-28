# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# Out of the box deployment with e-mail notifications
module "sce_tf" {
  source = "../.."

  sns_topic_email_addresses = ["myname@example.com"]
}