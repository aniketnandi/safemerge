# The bucket itself is created by terraform/bootstrap/create-reports-bucket.sh.
# Terraform looks it up here and manages all of its settings.
data "aws_s3_bucket" "reports" {
  bucket = "${var.prefix}-reports-${var.account_id}"
}

# Reports are never public. Users get 15-minute pre-signed URLs instead.
resource "aws_s3_bucket_public_access_block" "reports" {
  bucket                  = data.aws_s3_bucket.reports.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versioning, so a report cannot be silently overwritten
resource "aws_s3_bucket_versioning" "reports" {
  bucket = data.aws_s3_bucket.reports.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypted at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "reports" {
  bucket = data.aws_s3_bucket.reports.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Retention: cheaper storage after 30 days, deleted after 180 days
resource "aws_s3_bucket_lifecycle_configuration" "reports" {
  bucket = data.aws_s3_bucket.reports.id

  rule {
    id     = "report-retention"
    status = "Enabled"
    filter {}

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 180
    }

    # Old versions (from overwrites) are removed after 30 days
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  depends_on = [aws_s3_bucket_versioning.reports]
}
