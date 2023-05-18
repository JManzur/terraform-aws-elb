# Get the Account ID of the AWS Elastic Load Balancing Service Account.
data "aws_elb_service_account" "main" {}
# Get the AWS Account ID
data "aws_caller_identity" "current" {}
# Get the AWS Region
data "aws_region" "current" {}

locals {
  lb_log_bucket_name = lower("${var.name_prefix}-${var.environment}-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}-alb-logs-${var.name_suffix}")
}

# Create the Bucket
resource "aws_s3_bucket" "elb_logs" {
  count = var.access_logs_bucket.create_new_bucket ? 1 : 0

  bucket        = local.lb_log_bucket_name
  force_destroy = true

  tags = { Name = local.lb_log_bucket_name }

  lifecycle {
    ignore_changes = [bucket, tags]
  }
}

# Enble Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "elb_logs" {
  count = var.access_logs_bucket.create_new_bucket ? 1 : 0

  bucket = try(aws_s3_bucket.elb_logs[0].bucket, null)

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Create a lifecycle retention policy
resource "aws_s3_bucket_lifecycle_configuration" "elb_logs" {
  count = var.access_logs_bucket.create_new_bucket ? 1 : 0

  bucket = try(aws_s3_bucket.elb_logs[0].bucket, null)

  rule {
    id = "elb_logs"

    expiration {
      days = var.alb_log_retention_days
    }

    status = "Enabled"
  }
}

# AccessControlListNotSupported in the Dev Account
# resource "aws_s3_bucket_acl" "elb_logs" {
#   count = var.access_logs_bucket.create_new_bucket ? 1 : 0

#   bucket = try(aws_s3_bucket.elb_logs[0].id, null)
#   acl    = "private"
# }

# Define the S3 bucket policy
data "aws_iam_policy_document" "elb_logs" {
  statement {
    sid    = "AllowELBRootAccount"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.lb_log_bucket_name}/*"]
  }

  statement {
    sid    = "AWSLogDeliveryWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.lb_log_bucket_name}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid    = "AWSLogDeliveryAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${local.lb_log_bucket_name}"]
  }
}


# Allow  the AWS Elastic Load Balancing Service to put objects in the bucket
resource "aws_s3_bucket_policy" "elb_logs" {
  count = var.access_logs_bucket.create_new_bucket ? 1 : 0

  bucket = try(aws_s3_bucket.elb_logs[0].id, null)
  policy = data.aws_iam_policy_document.elb_logs.json
}

# Block all public access to bucket and objects
resource "aws_s3_bucket_public_access_block" "elb_logs" {
  count = var.access_logs_bucket.create_new_bucket ? 1 : 0

  bucket = try(aws_s3_bucket.elb_logs[0].id, null)

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable Versioning on Bucket
resource "aws_s3_bucket_versioning" "elb_logs" {
  count = var.access_logs_bucket.create_new_bucket ? 1 : 0

  bucket = try(aws_s3_bucket.elb_logs[0].id, null)
  versioning_configuration {
    status = "Enabled"
  }
}