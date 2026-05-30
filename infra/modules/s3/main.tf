# 1. Create an S3 bucket
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
  force_destroy = var.force_destroy
}

# 2. Configure bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  depends_on = [aws_s3_bucket.this]
}

# 3. Configure public access block settings
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access

  depends_on = [aws_s3_bucket.this, aws_s3_bucket_ownership_controls.this]
}

# 4. Configure versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# 5. Configure server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.encryption_algorithm
      kms_master_key_id = var.encryption_algorithm == "aws:kms" ? var.kms_master_key_id : null
    }
    bucket_key_enabled = true
  }
}

# 6. Configure static website hosting
resource "aws_s3_bucket_website_configuration" "this" {
  count  = var.enable_website ? 1 : 0
  bucket = aws_s3_bucket.this.id

  lifecycle {
    # Without this, a misconfigured caller gets a silently broken setup with no error message.
    precondition {
      condition     = !var.block_public_access
      error_message = "Website hosting requires block_public_access = false. A private bucket cannot serve website traffic directly."
    }
  }

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}

# 7. Attach bucket policy if provided
resource "aws_s3_bucket_policy" "this" {
  count  = var.bucket_policy != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = var.bucket_policy

  depends_on = [aws_s3_bucket_public_access_block.this]
}

# 8. Configure lifecycle rules to expire noncurrent versions if versioning is enabled
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = var.enable_lifecycle_rule ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiry_days
    }

    expiration {
      expired_object_delete_marker = true
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}
