output "lambda_function_arn" {
  description = "ARN of the message processor Lambda"
  value       = aws_lambda_function.message_processor.arn
}

output "lambda_function_name" {
  description = "Name of the message processor Lambda"
  value       = aws_lambda_function.message_processor.function_name
}

output "lambda_role_arn" {
  description = "IAM role ARN used by Lambda"
  value       = aws_iam_role.lambda_execution.arn
}

variable "aurora_cluster_arn" {
  description = "ARN of Aurora cluster for Data API permissions"
  type        = string
  default     = ""
}