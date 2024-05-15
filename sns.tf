# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_sns_topic" "sns_codebuild_result_notify_topic" {
  name              = local.sns.sns_codebuild_result_notify_topic.name
  kms_master_key_id = aws_kms_alias.tfc.target_key_arn
  tags              = var.tags
}

resource "aws_sns_topic_policy" "sns_codebuild_result_notify_topic" {
  arn = aws_sns_topic.sns_codebuild_result_notify_topic.arn

  policy = templatefile("${path.module}/iam/resource-policies/sns/codebuild-result-notify-topic.json.tftpl", {
    aws_sns_topic_sns_codebuild_result_notify_topic_arn = aws_sns_topic.sns_codebuild_result_notify_topic.arn
    data_aws_caller_identity_current_account_id         = data.aws_caller_identity.current.account_id
  })
}

resource "aws_sns_topic_subscription" "sns_codebuild_result_notify_topic" {
  count = length(var.sns_topic_email_addresses)

  topic_arn = aws_sns_topic.sns_codebuild_result_notify_topic.arn
  protocol  = "email"
  endpoint  = var.sns_topic_email_addresses[count.index]
}
