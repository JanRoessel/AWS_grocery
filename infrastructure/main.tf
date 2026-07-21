terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Local state by default (fine for a solo bootcamp project). To collaborate
  # or version state remotely, uncomment and point at an S3 bucket you own:
  # backend "s3" {
  #   bucket = "my-terraform-state-bucket"
  #   key    = "aws-grocery/terraform.tfstate"
  #   region = "eu-central-1"
  # }
}

provider "aws" {
  region = var.aws_region
}

# Reuse the account's default VPC/subnets, matching what Woche 2 already set
# up manually ("Nutzung der von AWS bereitgestellten Standard-VPC und
# Subnetze") - no custom networking needed for this project's scope.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
