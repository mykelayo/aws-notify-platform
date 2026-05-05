variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "aws-notify"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones (2)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "max_receive_count" {
  description = "Number of times a message can be received before going to DLQ"
  type        = number
  default     = 3
}

variable "lambda_zip_path" {
  description = "Path to the Lambda deployment zip file"
  type        = string
  default     = "../../../src/processor/lambda.zip"
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

variable "db_username" {
  description = "Aurora master username"
  type        = string
  sensitive   = true
  default     = "notifyadmin"
}

variable "db_password" {
  description = "Aurora master password (at least 8 chars, letters+numbers)"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "notifications"
}

variable "alert_email" {
  description = "Email to receive CloudWatch alarms"
  type        = string
}

variable "min_acus" {
  description = "Minimum Aurora Capacity Units (0.5 is minimum)"
  type        = number
  default     = 0.5
}

variable "max_acus" {
  description = "Maximum Aurora Capacity Units"
  type        = number
  default     = 2
}

variable "enable_data_api" {
  description = "Enable Data API for Aurora (allows HTTP SQL queries)"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false  # For dev, disable to allow teardown
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    Project   = "aws-notify-platform"
    ManagedBy = "Terraform"
    Environment = "dev"
  }
}