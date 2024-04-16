# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_lambda_invocation" "trigger_codebuild_job" {
  function_name = aws_lambda_function.codebuild_trigger.function_name

  input = <<JSON
{
  "codebuild_project_name": "${aws_codebuild_project.this.name}"
}
JSON

  depends_on = [time_sleep.trigger_codebuild_job]
}

resource "time_sleep" "trigger_codebuild_job" {
  depends_on = [aws_iam_role_policy.codebuild_trigger_policy, aws_iam_role_policy_attachment.codebuild_trigger_vpc_access]

  create_duration = "10s"
}