data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

// 1. Create an S3 bucket for storing Terraform state files
resource "aws_s3_bucket" "portfolio" {
  bucket = format("${var.project_name}-${var.env}-%s-%s-an", data.aws_caller_identity.current.account_id, data.aws_region.current.region)
  tags = {
    Environment = var.env
  }
}

// 2. Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// 3. Create a bucket policy to allow access to the S3 bucket
data "aws_iam_policy_document" "portfolio_oac" {
  statement {
    sid       = "AllowS3CloudfrontAccess"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.portfolio.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.portfolio.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id
  policy = data.aws_iam_policy_document.portfolio_oac.json
}

// 4. Versioning and lifecycle configuration for the S3 bucket
resource "aws_s3_bucket_versioning" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id

  rule {
    id     = "ExpireOldVersions"
    status = "Enabled"

    // Expire noncurrent versions after 4 days - This will help to reduce storage costs for the S3 bucket by automatically deleting old versions of objects that are no longer needed after a certain period of time.
    noncurrent_version_expiration {
      noncurrent_days = 4
    }

    // Abort incomplete multipart uploads after 1 day - This will help to reduce storage costs for the S3 bucket by automatically aborting multipart uploads that are not completed within a certain period of time.
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    // Expire delete markers after 1 day - This will help to reduce storage costs for the S3 bucket by automatically deleting delete markers that are no longer needed after a certain period of time.
    expiration {
      expired_object_delete_marker = true
    }
  }
}

// 5. Server-side encryption configuration for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

// 6. Owner and ACL configuration for the S3 bucket
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.portfolio.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
