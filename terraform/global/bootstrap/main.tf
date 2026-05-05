terraform {
  required_version = "~> 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.43.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 bucket for remote state
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name
  force_destroy = false

  tags = {
    Name        = "aws-notify-platform-tfstate"
    Environment = "bootstrap"
    Project     = "aws-notify-platform"
  }
}

# Versioning enabled
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state_public_access" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "aws-notify-platform-tfstate-lock"
    Environment = "bootstrap"
    Project     = "aws-notify-platform"
  }
}

