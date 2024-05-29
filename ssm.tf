# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_ssm_parameter" "ssh_key" {
  count = var.create_ssh_key_ssm_parameter ? 1 : 0

  name   = var.ssh_key_ssm_parameter_path
  key_id = aws_kms_alias.tfc.target_key_arn
  type   = "SecureString"
  value  = "REPLACE_ME"

  tags = var.tags

  lifecycle {
    ignore_changes = [value]
  }
}