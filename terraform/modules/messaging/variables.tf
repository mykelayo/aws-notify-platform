variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "aws-notify"
}

variable "max_receive_count" {
  description = "Number of times a message can be received before going to DLQ"
  type        = number
  default     = 3
}

variable "create_dlq_alarm" {
  description = "Create CloudWatch alarm for DLQ non-empty"
  type        = bool
  default     = true
}

variable "alarm_actions" {
  description = "List of ARNs (SNS topics) to notify when DLQ has messages"
  type        = list(string)
  default     = []  # Provide an SNS topic ARN for email alerts
}

variable "ok_actions" {
  description = "List of ARNs to notify when DLQ clears"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default = {
    Project   = "aws-notify-platform"
    ManagedBy = "Terraform"
  }
}