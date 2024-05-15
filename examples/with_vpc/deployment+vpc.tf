# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# Deploys the solution in a user-provided VPC

module "sce_tf" {
  source = "../.."

  vpc_id                 = "vpc-xxxxxx"
  vpc_private_subnet_ids = ["subnet-xxxxxx", "subnet-yyyyyy"]
  vpc_security_group_ids = ["sg-xxxxxx"]
}