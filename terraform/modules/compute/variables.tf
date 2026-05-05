variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "aws-notify"
}

variable "lambda_zip_path" {
  description = "Path to the Lambda deployment zip file"
  type        = string
  default     = "../../../src/processor/lambda.zip"  # Built by Makefile
}

variable "lambda_timeout_seconds" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_mb" {
  description = "Lambda memory in MB (512 is sweet spot)"
  type        = number
  default     = 512
}

variable "environment_variables" {
  description = "Environment variables for Lambda"
  type        = map(string)
  default     = {}
}

variable "enable_vpc" {
  description = "Attach Lambda to VPC (private subnets)"
  type        = bool
  default     = true
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs (required if enable_vpc = true)"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs for Lambda (required if enable_vpc = true)"
  type        = list(string)
  default     = []
}

variable "enable_aurora" {
  description = "Grant Aurora Data API permissions (if using Aurora Serverless v2 Data API)"
  type        = bool
  default     = false
}

variable "aurora_cluster_arn" {
  description = "ARN of Aurora cluster for Data API permissions"
  type        = string
  default     = ""
}

variable "sqs_queue_arn" {
  description = "ARN of the main SQS queue to trigger Lambda"
  type        = string
}

variable "sqs_batch_size" {
  description = "Maximum number of messages to process in one Lambda invocation"
  type        = number
  default     = 1
}

variable "aurora_secret_arn" {
  description = "Secrets Manager ARN for DB credentials"
  type        = string
  default     = ""
}

variable "database_name" {
  description = "Database name for Data API"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}