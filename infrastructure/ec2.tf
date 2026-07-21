locals {
  user_data = templatefile("${path.module}/ec2_user_data.sh.tpl", {
    app_repo_url    = var.app_repo_url
    app_repo_branch = var.app_repo_branch
    postgres_uri    = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.postgres.endpoint}/${var.db_name}"
    jwt_secret_key  = var.jwt_secret_key
    s3_bucket_name  = aws_s3_bucket.avatars.bucket
    aws_region      = var.aws_region
  })
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.key_pair_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_app_profile.name

  # RDS must exist first so its endpoint can be baked into user_data.
  depends_on = [aws_db_instance.postgres]

  user_data                   = local.user_data
  user_data_replace_on_change = true

  tags = { Name = "${var.app_name}-app-server" }
}
