variable "name_prefix" {
  description = "Prefix for resources"
  type        = string
  default     = "aws-notify"
}

variable "alert_email" {
  description = "Email address to receive alerts"
  type        = string
}

variable "enable_dlq_alarm" {
  description = "Create CloudWatch alarm for DLQ non-empty"
  type        = bool
  default     = true
}

variable "dlq_queue_name" {
  description = "Name of the DLQ queue (for dimensions)"
  type        = string
}

variable "enable_lambda_alarm" {
  description = "Create CloudWatch alarm for Lambda errors"
  type        = bool
  default     = true
}

variable "lambda_function_name" {
  description = "Name of the Lambda function to monitor"
  type        = string
}

variable "lambda_error_threshold" {
  description = "Number of Lambda errors per minute to trigger alarm"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}