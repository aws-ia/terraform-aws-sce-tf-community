# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

############################################################################################################
# sce_terraform_community_layer
############################################################################################################

data "archive_file" "sce_terraform_community_layer" {
  type        = "zip"
  source_dir  = "${path.module}/src/python/sce-terraform-community-layer"
  output_path = "${local.archive_path}/sce-terraform-community-layer.zip"
}


############################################################################################################
# sce_provisioning_handler
############################################################################################################

data "archive_file" "sce_provisioning_handler" {
  type        = "zip"
  source_dir  = "${path.module}/src/python/provisioning-operations-handler"
  output_path = "${local.archive_path}/sce-provisioning-operations-handler.zip"
}

############################################################################################################
# sce_get_state_file_outputs
############################################################################################################

data "archive_file" "sce_get_state_file_outputs" {
  type        = "zip"
  source_dir  = "${path.module}/src/python/get-state-file-outputs"
  output_path = "${local.archive_path}/sce-get-state-file-outputs.zip"
}

############################################################################################################
# sce_notify_provision_update_result
############################################################################################################

data "archive_file" "sce_notify_provision_update_result" {
  type        = "zip"
  source_dir  = "${path.module}/src/python/notify-provision-update-result"
  output_path = "${local.archive_path}/sce-notify-provision-update-result.zip"
}

############################################################################################################
# terraform_parameter_parser
############################################################################################################
data "archive_file" "terraform_parameter_parser" {
  type        = "zip"
  source_dir  = "${path.module}/src/golang/terraform-parameter-parser"
  output_path = "${local.archive_path}/terraform-parameter-parser.zip"
}

resource "aws_s3_object" "terraform_parameter_parser" {
  key        = "${local.archive_path}/terraform-parameter-parser.zip"
  bucket     = aws_s3_bucket.sce_terraform_state.id
  source     = data.archive_file.terraform_parameter_parser.output_path
  kms_key_id = aws_kms_alias.tfc.target_key_arn
}

############################################################################################################
# terraform_runner
############################################################################################################

data "archive_file" "terraform_runner" {
  type        = "zip"
  source_dir  = "${path.module}/src/python/terraform-runner"
  output_path = "${local.archive_path}/terraform-runner.zip"
}

resource "aws_s3_object" "terraform_runner" {
  key        = "${local.archive_path}/terraform-runner.zip"
  bucket     = aws_s3_bucket.sce_terraform_state.id
  source     = data.archive_file.terraform_runner.output_path
  kms_key_id = aws_kms_alias.tfc.target_key_arn
}