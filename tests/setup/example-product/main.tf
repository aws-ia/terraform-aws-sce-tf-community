# Adopted from https://github.com/hashicorp/aws-service-catalog-engine-for-tfc/tree/main/example-product

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

data "aws_caller_identity" "current" {}

resource "random_string" "random" {
  length  = 16
  special = false
  lower   = true
  upper   = false
}

# # # #
# THE PORTFOLIO
resource "aws_servicecatalog_portfolio" "portfolio" {
  name          = "Example Portfolio"
  description   = "Example Portfolio created via AWS Service Catalog Engine"
  provider_name = "AWS Examples"
}

locals {
  unique_portfolio_ids = { for index, portfolio_id in [aws_servicecatalog_portfolio.portfolio.id] : index => portfolio_id }
}

# # # #
# THE PROVISIONING ARTIFACT (TERRAFORM CONFIGURATION FILES)

resource "aws_s3_bucket" "artifact_bucket" {
  #checkov:skip=CKV2_AWS_6: skip block public access for the test
  #checkov:skip=CKV_AWS_144: skip replication for the test
  #checkov:skip=CKV_AWS_145: skip encryption for the test
  #checkov:skip=CKV_AWS_21: skip versioning for the test
  #checkov:skip=CKV_AWS_18: skip logging for the test
  #checkov:skip=CKV2_AWS_61: skip lifecycle for the test
  bucket        = "service-catalog-example-product-${random_string.random.result}"
  force_destroy = true
}

resource "aws_s3_object" "artifact" {
  bucket = aws_s3_bucket.artifact_bucket.id
  key    = "product.tar.gz"
  source = "${path.module}/product.tar.gz"
  etag   = filemd5("${path.module}/product.tar.gz")
}

# # # #
# THE PRODUCT IN SERVICE CATALOG

resource "aws_servicecatalog_product" "example" {
  name  = "service-catalog-example-product-${random_string.random.result}"
  owner = var.service_catalog_product_owner
  type  = "EXTERNAL"

  provisioning_artifact_parameters {
    name                        = "v1"
    disable_template_validation = true
    template_url                = "https://s3.amazonaws.com/${aws_s3_object.artifact.bucket}/${aws_s3_object.artifact.key}"
    type                        = "EXTERNAL"
  }
}

locals {
  _product_name_convert_snake_case_to_class_case = join("", [for word in split("_", aws_servicecatalog_product.example.name) : title(word)])
  _product_name_convert_kebab_case_to_class_case = join("", [for word in split("-", local._product_name_convert_snake_case_to_class_case) : title(word)])
  class_case_product_name                        = local._product_name_convert_kebab_case_to_class_case
}

resource "aws_servicecatalog_tag_option_resource_association" "example_product_managed_by" {
  resource_id   = aws_servicecatalog_product.example.id
  tag_option_id = aws_servicecatalog_tag_option.product_managed_by.id
}

resource "aws_servicecatalog_tag_option" "product_managed_by" {
  key   = "ManagedBy"
  value = "sce-tf-community"
}

resource "aws_servicecatalog_tag_option_resource_association" "example_product_name" {
  resource_id   = aws_servicecatalog_product.example.id
  tag_option_id = aws_servicecatalog_tag_option.product_name.id
}

resource "aws_servicecatalog_tag_option" "product_name" {
  key   = "ServiceCatalogProduct"
  value = aws_servicecatalog_product.example.name
}

resource "aws_servicecatalog_product_portfolio_association" "example" {
  for_each     = local.unique_portfolio_ids
  portfolio_id = each.value
  product_id   = aws_servicecatalog_product.example.id
}

# # # #
# THE PRODUCT'S LAUNCH CONSTRAINT AND IAM ROLE

resource "aws_servicecatalog_constraint" "example" {
  # Need to wait a bit after the role is created as Service Catalog will immediately try to assume the role to test it.
  depends_on = [time_sleep.wait_for_launch_constraint_role_to_be_assumable]

  for_each     = local.unique_portfolio_ids
  description  = "Launch constraint for the ${aws_servicecatalog_product.example.name} product."
  portfolio_id = each.value
  product_id   = aws_servicecatalog_product.example.id
  type         = "LAUNCH"

  parameters = jsonencode({
    "RoleArn" : aws_iam_role.example_product_launch_role.arn
  })
}

resource "aws_iam_role" "example_product_launch_role" {
  name = "${local.class_case_product_name}LaunchRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Allow Service Catalog to assume the role
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowServiceCatalogToAssume"
        Principal = {
          Service = "servicecatalog.amazonaws.com"
        }
      },
      {
        # Allow the CodeBuild and ParameterParser Lambda functions to assume the role so that they can download the provisioning artifact from S3
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = [
              "${var.parameter_parser_role_arn}*",
              "${var.terraform_execution_role_arn}*"
            ]
          }
        }
      }
    ]
  })
}

resource "time_sleep" "wait_for_launch_constraint_role_to_be_assumable" {
  depends_on      = [aws_iam_role.example_product_launch_role, aws_iam_role_policy.example_product_launch_constraint_policy]
  create_duration = "15s"
}

resource "aws_iam_role_policy" "example_product_launch_constraint_policy" {
  name   = "example_product_launch_constraint_policy"
  role   = aws_iam_role.example_product_launch_role.id
  policy = data.aws_iam_policy_document.example_product_launch_constraint_policy.json
}

data "aws_iam_policy_document" "example_product_launch_constraint_policy" {
  #checkov:skip=CKV_AWS_356: select action require (*)
  #checkov:skip=CKV_AWS_111
  version = "2012-10-17"

  statement {
    sid = "S3AccessToProvisioningObjects"

    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/servicecatalog:provisioning"
      values   = ["true"]
    }
  }

  statement {
    sid = "AllowCreationOfBucketsToDistributeProvisioningArtifact"

    effect = "Allow"

    actions = [
      "s3:CreateBucket*",
      "s3:DeleteBucket*",
      "s3:Get*",
      "s3:List*",
      "s3:PutBucketTagging"
    ]

    resources = ["arn:aws:s3:::*"]
  }

  statement {
    sid = "ResourceGroups"

    effect = "Allow"

    actions = [
      "resource-groups:CreateGroup",
      "resource-groups:ListGroupResources",
      "resource-groups:DeleteGroup",
      "resource-groups:Tag"
    ]

    resources = ["*"]
  }

  statement {
    sid = "Tagging"

    effect = "Allow"

    actions = [
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues",
      "tag:TagResources",
      "tag:UntagResources"
    ]

    resources = ["*"]
  }
}

# # # #
# SHARE PORTFOLIO TO PIPELINE FOR TEST

resource "aws_servicecatalog_principal_portfolio_association" "abp_role" {
  for_each     = local.unique_portfolio_ids
  portfolio_id = each.value 
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ABPIntegrationRole"
}

resource "aws_servicecatalog_principal_portfolio_association" "abp_user" {
  for_each     = local.unique_portfolio_ids
  portfolio_id = each.value 
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/abp"
}