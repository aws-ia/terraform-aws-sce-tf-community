# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_kms_key" "tfc" {
  description         = local.kms.tfc.description
  enable_key_rotation = local.kms.tfc.enable_key_rotation
  policy = templatefile("${path.module}/iam/resource-policies/kms/tfc.json.tftpl", {
    data_aws_caller_identity_current_account_id = data.aws_caller_identity.current.account_id
    data_aws_region_current_name                = data.aws_region.current.name
    data_aws_partition_current_id               = data.aws_partition.current.id
  })
  tags = var.tags
}

resource "aws_kms_alias" "tfc" {
  name          = local.kms.tfc.alias
  target_key_id = aws_kms_key.tfc.key_id
}