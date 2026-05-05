variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "aws-notify"
}

variable "vpc_id" {
  description = "VPC ID where Aurora will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs (at least 2 AZs)"
  type        = list(string)
}

variable "lambda_security_group_ids" {
  description = "List of security group IDs for Lambda (to allow inbound)"
  type        = list(string)
  default     = []
}

variable "aurora_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16.3"
}

variable "database_name" {
  description = "Initial database name"
  type        = string
  default     = "notifications"
}

variable "master_username" {
  description = "Master username (will be stored in secrets manager ideally)"
  type        = string
  sensitive   = true
  default     = "dbadmin"
}

variable "master_password" {
  description = "Master password (sensitive)"
  type        = string
  sensitive   = true
  default     = null
}

variable "enable_data_api" {
  description = "Enable Data API for Aurora (allows HTTP SQL queries)"
  type        = bool
  default     = true
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

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false  
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}