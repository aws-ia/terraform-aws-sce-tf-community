# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

############################################################################################################
# codebuild_trigger
############################################################################################################

data "archive_file" "codebuild_trigger" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/codebuild-trigger"
  output_path = "${local.archive_path}/codebuild-trigger.zip"
}