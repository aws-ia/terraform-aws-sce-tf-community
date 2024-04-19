# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

module "label" {
  source = "git::https://github.com/aws-ia/terraform-aws-label.git?ref=9595b11" # v0.0.5

  account   = data.aws_caller_identity.current.account_id
  env       = var.stage
  id_order  = var.label_id_order
  name      = local.solution_name
  namespace = local.region_abbreviation
}