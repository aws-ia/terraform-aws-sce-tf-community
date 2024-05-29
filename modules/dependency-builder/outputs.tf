# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

output "lambda_layer_build_status" {
  value = jsondecode(data.aws_lambda_invocation.trigger_codebuild_job.result)["Status"]
}
