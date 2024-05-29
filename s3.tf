# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

############################################################################################################
# sce_terraform_state
############################################################################################################

#tfsec:ignore:aws-s3-enable-bucket-logging : false alarm, bucket logging is enabled as separate resource
resource "aws_s3_bucket" "sce_terraform_state" {
  #checkov:skip=CKV2_AWS_61:Lifecycle policies not implemented due to nature of contents

  bucket        = local.s3.sce_terraform_state.bucket
  force_destroy = var.s3_force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_policy" "sce_terraform_state" {
  bucket = aws_s3_bucket.sce_terraform_state.id
  policy = templatefile("${path.module}/iam/resource-policies/s3/sce-terraform-state.json.tftpl", {
    aws_s3_bucket_sce_terraform_state_arn = aws_s3_bucket.sce_terraform_state.arn
  })
}

resource "aws_s3_bucket_versioning" "sce_terraform_state" {

  bucket = aws_s3_bucket.sce_terraform_state.id
  versioning_configuration {
    status = local.s3.sce_terraform_state.versioning_configuration_status
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sce_terraform_state" {

  bucket = aws_s3_bucket.sce_terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_alias.tfc.target_key_arn
      sse_algorithm     = local.s3.sce_terraform_state.sse_algorithm #tfsec:ignore:aws-s3-encryption-customer-key : false-alarm
    }
  }
}

resource "aws_s3_bucket_public_access_block" "sce_terraform_state" {

  bucket = aws_s3_bucket.sce_terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "sce_terraform_state" {
  bucket        = aws_s3_bucket.sce_terraform_state.id
  target_bucket = aws_s3_bucket.sce_logging.id
  target_prefix = "${aws_s3_bucket.sce_terraform_state.id}/"
}

############################################################################################################
# sce_logging
############################################################################################################

resource "aws_s3_bucket" "sce_logging" {
  bucket        = local.s3.sce_logging.bucket
  force_destroy = var.s3_force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_policy" "sce_logging" {
  bucket = aws_s3_bucket.sce_logging.id
  policy = templatefile("${path.module}/iam/resource-policies/s3/sce-logging.json.tftpl", {
    aws_s3_bucket_sce_logging_arn = aws_s3_bucket.sce_logging.arn
  })
}

resource "aws_s3_bucket_versioning" "sce_logging" {

  bucket = aws_s3_bucket.sce_logging.id
  versioning_configuration {
    status = local.s3.sce_logging.versioning_configuration_status
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sce_logging" {

  bucket = aws_s3_bucket.sce_logging.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_alias.tfc.target_key_arn
      sse_algorithm     = local.s3.sce_logging.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_public_access_block" "sce_logging" {

  bucket = aws_s3_bucket.sce_logging.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "sce_logging" {
  bucket        = aws_s3_bucket.sce_logging.id
  target_bucket = aws_s3_bucket.sce_access_logs.id
  target_prefix = "${aws_s3_bucket.sce_logging.id}/"
}

resource "aws_s3_bucket_lifecycle_configuration" "sce_logging" {
  bucket = aws_s3_bucket.sce_logging.id
  rule {
    status = "Enabled"
    filter {
      prefix = "/"
    }
    id = "sce_logging_lifecycle_configuration_rule"

    noncurrent_version_expiration {
      noncurrent_days = var.s3_logs_expiration_days
    }
  }

  rule {
    status = "Enabled"
    filter {}
    id = "abort_incomplete_multipart_uploads"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

############################################################################################################
# sce_access_logs
############################################################################################################

#tfsec:ignore:aws-s3-enable-bucket-logging : skip logging on access log bucket
resource "aws_s3_bucket" "sce_access_logs" {
  bucket        = local.s3.sce_access_logs.bucket
  force_destroy = var.s3_force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_policy" "sce_access_logs" {
  bucket = aws_s3_bucket.sce_access_logs.id
  policy = templatefile("${path.module}/iam/resource-policies/s3/sce-access-logs.json.tftpl", {
    aws_s3_bucket_sce_access_logs_arn           = aws_s3_bucket.sce_access_logs.arn
    data_aws_caller_identity_current_account_id = data.aws_caller_identity.current.account_id
  })
}

resource "aws_s3_bucket_versioning" "sce_access_logs" {
  bucket = aws_s3_bucket.sce_access_logs.id
  versioning_configuration {
    status = local.s3.sce_access_logs.versioning_configuration_status
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sce_access_logs" {
  bucket = aws_s3_bucket.sce_access_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = local.s3.sce_access_logs.sse_algorithm #tfsec:ignore:aws-s3-encryption-customer-key : SSE-KMS not supported for access log
    }
  }
}

resource "aws_s3_bucket_public_access_block" "sce_logging_bucket" {
  bucket                  = aws_s3_bucket.sce_access_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "sce_access_logs" {
  bucket = aws_s3_bucket.sce_access_logs.id
  rule {
    status = "Enabled"
    filter {
      prefix = "/"
    }
    id = "sce_access_logs_lifecycle_configuration_rule"

    noncurrent_version_expiration {
      noncurrent_days = var.s3_access_logging_expiration_days
    }
  }

  rule {
    status = "Enabled"
    filter {}
    id = "abort_incomplete_multipart_uploads"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}