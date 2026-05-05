output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.notifications.arn
}

output "sqs_queue_arn" {
  description = "ARN of the main SQS queue"
  value       = aws_sqs_queue.main.arn
}

output "sqs_queue_url" {
  description = "URL of the main SQS queue"
  value       = aws_sqs_queue.main.id
}

output "dlq_arn" {
  description = "ARN of the DLQ"
  value       = aws_sqs_queue.dlq.arn
}

output "dlq_url" {
  description = "URL of the DLQ"
  value       = aws_sqs_queue.dlq.id
}

output "dlq_name" {
  description = "Name of the DLQ"
  value       = aws_sqs_queue.dlq.name
}