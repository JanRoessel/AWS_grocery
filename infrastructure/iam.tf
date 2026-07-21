# IAM Instance Role for EC2 - least privilege: only S3 read/write on this
# project's own bucket, nothing else. Avoids hard-coded AWS credentials on
# the instance (see backend/app/services/user_service.py, which falls back
# to the instance role automatically when no static keys are set).
resource "aws_iam_role" "ec2_app_role" {
  name = "${var.app_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = { Name = "${var.app_name}-ec2-role" }
}

resource "aws_iam_role_policy" "s3_avatars_access" {
  name = "${var.app_name}-s3-avatars-access"
  role = aws_iam_role.ec2_app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.avatars.arn,
        "${aws_s3_bucket.avatars.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_app_profile" {
  name = "${var.app_name}-ec2-profile"
  role = aws_iam_role.ec2_app_role.name
}
