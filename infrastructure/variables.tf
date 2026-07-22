variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-central-1"
}

variable "app_name" {
  description = "Short name used to tag/name all resources"
  type        = string
  default     = "grocery"
}

variable "instance_type" {
  description = "EC2 instance type for the app server"
  type        = string
  default     = "t3.micro" # Free Tier eligible
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair, for SSH access"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH into the EC2 instance (lock this down to your own IP/32 in production)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_repo_url" {
  description = "Git URL the EC2 instance clones and builds the app from"
  type        = string
  default     = "https://github.com/JanRoessel/AWS_grocery.git"
}

variable "app_repo_branch" {
  description = "Branch to check out on the EC2 instance"
  type        = string
  default     = "version2"
}

variable "db_engine_version" {
  description = "PostgreSQL engine version for RDS"
  type        = string
  default     = "16.4"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro" # Free Tier eligible
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "grocery"
}

variable "db_username" {
  description = "Master username for RDS"
  type        = string
  default     = "grocery_admin"
}

variable "db_password" {
  description = "Master password for RDS. Provide via terraform.tfvars (gitignored) or TF_VAR_db_password env var - never commit this."
  type        = string
  sensitive   = true
}

variable "jwt_secret_key" {
  description = "Flask JWT secret key used by the app. Provide via terraform.tfvars or TF_VAR_jwt_secret_key."
  type        = string
  sensitive   = true
}

variable "s3_bucket_name" {
  description = "Globally-unique S3 bucket name for user avatar storage"
  type        = string
}

variable "alarm_email" {
  description = "E-Mail address for CloudWatch alarm notifications (optional - leer lassen wenn keine E-Mail gewünscht)"
  type        = string
  default     = ""
}
