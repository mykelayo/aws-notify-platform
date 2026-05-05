# Security group for Aurora (allows inbound from Lambda security group)
resource "aws_security_group" "aurora" {
  name        = "${var.name_prefix}-aurora-sg"
  description = "Allow inbound from Lambda to Aurora"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow PostgreSQL from Lambda security group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.lambda_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# DB Subnet group (requires at least 2 AZs)
resource "aws_db_subnet_group" "aurora" {
  name        = "${var.name_prefix}-aurora-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "Subnet group for Aurora Serverless"

  tags = var.tags
}

# Aurora Serverless v2 cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "${var.name_prefix}-aurora-cluster"
  engine             = "aurora-postgresql"
  engine_version     = var.aurora_engine_version
  database_name      = var.database_name
  master_username    = var.master_username
  master_password    = var.master_password
  db_subnet_group_name = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [aws_security_group.aurora.id]

  # Enable Data API for HTTP access (simpler for Lambda)
  enable_http_endpoint = var.enable_data_api

  # Serverless v2 scaling configuration
  serverlessv2_scaling_configuration {
    min_capacity = var.min_acus
    max_capacity = var.max_acus
  }

  # Deletion protection for dev (safety)
  deletion_protection = var.deletion_protection

  # Skip final snapshot for dev (clean teardown)
  skip_final_snapshot = true

  # Backup retention (1 day to reduce cost)
  backup_retention_period = 1

  tags = var.tags
}

# Aurora Serverless v2 instance (at least one)
resource "aws_rds_cluster_instance" "aurora_instance" {
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version
  publicly_accessible = false

  tags = var.tags
}