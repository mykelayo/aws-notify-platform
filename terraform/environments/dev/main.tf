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

# Module calls will go here (VPC, messaging, etc.)