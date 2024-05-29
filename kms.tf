# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

#tfsec:ignore:aws-kms-auto-rotate-keys : KMS Key rotation is optional, if dictated by customer policies
resource "aws_kms_key" "tfc" {
  #checkov:skip=CKV_AWS_7:KMS Key rotation is optional, if dictated by customer policies

  description = local.kms.tfc.description
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