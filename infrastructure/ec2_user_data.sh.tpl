#!/bin/bash
# Bootstraps the app server: installs Docker, clones the repo, builds the
# image from this project's own Dockerfile, and runs it pointed at RDS.
# Templated by Terraform (templatefile()) - variables come from ec2.tf.
set -euxo pipefail

dnf update -y
dnf install -y docker git
systemctl enable --now docker
usermod -aG docker ec2-user

git clone --branch "${app_repo_branch}" "${app_repo_url}" /opt/app
cd /opt/app

docker build -t grocery-app .

docker run -d \
  --name grocery-app \
  --restart unless-stopped \
  -p 5000:5000 \
  -e POSTGRES_URI="${postgres_uri}" \
  -e JWT_SECRET_KEY="${jwt_secret_key}" \
  -e USE_S3_STORAGE="true" \
  -e S3_BUCKET_NAME="${s3_bucket_name}" \
  -e S3_REGION="${aws_region}" \
  grocery-app
