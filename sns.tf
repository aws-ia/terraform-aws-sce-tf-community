# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_sns_topic" "sns_codebuild_result_notify_topic" {
  name              = local.sns.sns_codebuild_result_notify_topic.name
  kms_master_key_id = aws_kms_alias.tfc.target_key_arn
  tags              = var.tags
}

resource "aws_sns_topic_subscription" "sns_codebuild_result_notify_topic" {
  count = length(var.sns_topic_email_addresses)

  topic_arn = aws_sns_topic.sns_codebuild_result_notify_topic.arn
  protocol  = "email"
  endpoint  = var.sns_topic_email_addresses[count.index]
}
