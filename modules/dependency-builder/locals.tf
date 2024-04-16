# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  archive_path   = "${path.module}/build-artifacts/"
  golang_version = "1.21"
  lambda = {
    codebuild_trigger = {
      function_name = substr("${var.common_name}-codebuild-trigger", 0, 63)
      memory_size   = 1024
      timeout       = 900
    }
  }
  python_version = "3.12"
}