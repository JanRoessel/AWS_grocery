resource "aws_s3_bucket" "avatars" {
  bucket = var.s3_bucket_name

  tags = { Name = "${var.app_name}-avatars" }
}

# Woche 7: versioning + lifecycle management to keep storage costs in check.
resource "aws_s3_bucket_versioning" "avatars" {
  bucket = aws_s3_bucket.avatars.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "avatars" {
  bucket = aws_s3_bucket.avatars.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# No public access - the app fetches/serves avatars through the backend
# using the IAM instance role below, not via public bucket URLs.
resource "aws_s3_bucket_public_access_block" "avatars" {
  bucket = aws_s3_bucket.avatars.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
