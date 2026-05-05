# SNS Topic - main notification ingress
resource "aws_sns_topic" "notifications" {
  name = "${var.name_prefix}-notifications"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-sns-topic"
  })
}

# SQS Queue - main queue (subscribed to SNS)
resource "aws_sqs_queue" "main" {
  name = "${var.name_prefix}-queue"

  # Visibility timeout = 6x Lambda timeout (180s for 30s Lambda)
  visibility_timeout_seconds = 180

  # Message retention (maximum 14 days)
  message_retention_seconds = 345600  # 4 days (balance between cost and recovery)

  # Redrive policy: after maxReceiveCount, send to DLQ
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  # Encryption (SSE-SQS - free, uses AWS managed key)
  sqs_managed_sse_enabled = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-main-queue"
  })
}

# Dead Letter Queue (DLQ)
resource "aws_sqs_queue" "dlq" {
  name = "${var.name_prefix}-dlq"

  # Maximum retention for manual inspection (14 days)
  message_retention_seconds = 1209600  # 14 days

  # No redrive policy on DLQ (final destination)
  sqs_managed_sse_enabled = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-dlq"
  })
}

# SQS Queue Policy - allow SNS to send messages
resource "aws_sqs_queue_policy" "main" {
  queue_url = aws_sqs_queue.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "sns.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.main.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.notifications.arn
          }
        }
      }
    ]
  })
}

# SNS Topic Subscription - SNS sends to SQS
resource "aws_sns_topic_subscription" "sqs" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.main.arn

  # Raw message delivery (send entire JSON, not wrapped)
  raw_message_delivery = true
}

# CloudWatch alarm for DLQ non-empty
resource "aws_cloudwatch_metric_alarm" "dlq_non_empty" {
  count = var.create_dlq_alarm ? 1 : 0

  alarm_name          = "${var.name_prefix}-dlq-non-empty"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300  # 5 minutes
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "DLQ has messages - check for processing failures"
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.dlq.name
  }

  alarm_actions = var.alarm_actions  # e.g., SNS topic for email
  ok_actions    = var.ok_actions

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-dlq-alarm"
  })
}