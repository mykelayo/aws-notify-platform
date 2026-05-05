environment {
  variables = merge(var.environment_variables, {
    AURORA_CLUSTER_ARN = var.aurora_cluster_arn
    AURORA_SECRET_ARN  = var.aurora_secret_arn
    DATABASE_NAME      = var.database_name
  })
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_execution" {
  name = "${var.name_prefix}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# IAM policy for CloudWatch Logs (basic Lambda logging)
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# VPC access policy (if Lambda runs in private subnets)
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count = var.enable_vpc ? 1 : 0

  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Placeholder policy for future Aurora access (grant minimal RDS data API or direct DB)
resource "aws_iam_role_policy" "aurora_access" {
  count = var.enable_aurora ? 1 : 0

  name = "${var.name_prefix}-lambda-aurora-access"
  role = aws_iam_role.lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-data:ExecuteStatement",
          "rds-data:BatchExecuteStatement"
        ]
        Resource = var.aurora_cluster_arn
      }
    ]
  })
}

# Lambda function (processor)
resource "aws_lambda_function" "message_processor" {
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  function_name    = "${var.name_prefix}-message-processor"
  role             = aws_iam_role.lambda_execution.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.13"
  timeout          = var.lambda_timeout_seconds
  memory_size      = var.lambda_memory_mb

  environment {
    variables = var.environment_variables
  }

  # VPC configuration (if Lambda needs to access private resources like Aurora)
  dynamic "vpc_config" {
    for_each = var.enable_vpc ? [1] : []
    content {
      subnet_ids         = var.private_subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  tags = var.tags
}

# SQS event source mapping (triggers Lambda from main SQS queue)
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.message_processor.arn
  enabled          = true

  # SQS already handles retries via redrive policy; Lambda default retry is 0 when using event source
  # Setting batch size to 1 for simplicity
  batch_size = var.sqs_batch_size
}

# IAM policy for Data API (execute SQL statements)
resource "aws_iam_role_policy" "data_api" {
  count = var.enable_aurora ? 1 : 0

  name = "${var.name_prefix}-lambda-data-api"
  role = aws_iam_role.lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-data:ExecuteStatement",
          "rds-data:BatchExecuteStatement"
        ]
        Resource = var.aurora_cluster_arn
      }
    ]
  })
}


