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
  max_receive_count  = var.max_receive_count
  create_dlq_alarm   = true
  alarm_actions      = []  # TODO: add SNS topic ARN for email
  ok_actions         = []
  tags               = var.tags
}

module "compute" {
  source = "../../modules/compute"

  name_prefix           = var.name_prefix
  lambda_zip_path       = var.lambda_zip_path
  lambda_timeout_seconds = var.lambda_timeout_seconds
  lambda_memory_mb      = var.lambda_memory_mb

  enable_vpc        = true
  private_subnet_ids = module.vpc.private_subnet_ids
  # For now, no security group for Lambda (will create one later for Aurora)
  security_group_ids = [module.vpc.default_security_group_id]
  
  sqs_queue_arn      = module.messaging.sqs_queue_arn
  sqs_batch_size     = 1

  tags = var.tags
}