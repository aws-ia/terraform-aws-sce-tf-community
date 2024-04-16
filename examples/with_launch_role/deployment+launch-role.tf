# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# Default deployment + administrative launch role for a service catalog product.
data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

module "sce_tf" {
  source = "git::ssh://git@ssh.gitlab.aws.dev/albsilv/terraform-aws-sce-tf-community.git?ref=develop"
}

resource "aws_iam_role" "sce_launch_role" {
  name = "sce-launch-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "servicecatalog.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {
                "AWS": [
                    "arn:${data.aws_partition.current.id}:iam::${data.aws_caller_identity.current.account_id}:root"
                ]
            },
            "Condition": {
                "StringLike": {
                    "aws:PrincipalArn": [
                        "${module.sce_tf.terraform_execution_role}",
                        "${module.sce_tf.sce_parameter_parser_role_arn}"
                    ]
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "sce_launch_role" {
  name = "sce-launch-role"
  role = aws_iam_role.sce_launch_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}