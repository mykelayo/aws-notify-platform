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

# Security group for Lambda (if not already defined)
# We'll use the default VPC security group for now.
# But better to create a dedicated Lambda security group.

module "database" {
  source = "../../modules/database"

  name_prefix            = var.name_prefix
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  lambda_security_group_ids = [module.vpc.default_security_group_id]
  master_username        = var.db_username
  master_password        = var.db_password
  database_name          = var.db_name
  min_acus               = var.min_acus
  max_acus               = var.max_acus
  enable_data_api        = var.enable_data_api
  deletion_protection    = var.deletion_protection

  tags = var.tags
}

module "observability" {
  source = "../../modules/observability"

  name_prefix           = var.name_prefix
  alert_email           = var.alert_email
  dlq_queue_name        = module.messaging.dlq_name
  lambda_function_name  = module.compute.lambda_function_name

  tags = var.tags
}