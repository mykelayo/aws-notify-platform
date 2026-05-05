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

module "vpc" {
  source = "../../modules/vpc"

  name_prefix           = var.name_prefix
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  tags                  = var.tags
}

module "messaging" {
  source = "../../modules/messaging"

  name_prefix        = var.name_prefix
  max_receive_count  = 3
  create_dlq_alarm   = true
  alarm_actions      = []  # TODO: add SNS topic ARN for email (Phase 4)
  ok_actions         = []
  tags               = var.tags
}