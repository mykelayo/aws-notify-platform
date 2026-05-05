# S3 bucket for static website
resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name
  tags   = var.tags
}

# Public access block (allow public read for website)
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy for public read access
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

# Website hosting configuration
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id
  index_document {
    suffix = "index.html"
  }
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "publish" {
  name        = "${var.name_prefix}-publish-api"
  description = "API to publish messages to SNS"
  tags        = var.tags
}

# API Gateway resource (root /)
resource "aws_api_gateway_resource" "publish" {
  rest_api_id = aws_api_gateway_rest_api.publish.id
  parent_id   = aws_api_gateway_rest_api.publish.root_resource_id
  path_part   = "publish"
}

# API Gateway method (POST)
resource "aws_api_gateway_method" "publish_post" {
  rest_api_id   = aws_api_gateway_rest_api.publish.id
  resource_id   = aws_api_gateway_resource.publish.id
  http_method   = "POST"
  authorization = "NONE"
}

# Lambda execution (publisher) – separate from processor Lambda
resource "aws_lambda_function" "publisher" {
  filename         = var.publisher_zip_path
  source_code_hash = filebase64sha256(var.publisher_zip_path)
  function_name    = "${var.name_prefix}-publisher"
  role             = aws_iam_role.publisher_execution.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.13"
  timeout          = 10
  memory_size      = 128

  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }

  tags = var.tags
}

# IAM role for publisher Lambda
resource "aws_iam_role" "publisher_execution" {
  name = "${var.name_prefix}-publisher-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach basic logs policy
resource "aws_iam_role_policy_attachment" "publisher_logs" {
  role       = aws_iam_role.publisher_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# IAM policy for publisher to publish to SNS
resource "aws_iam_role_policy" "publisher_sns" {
  name = "publish-to-sns"
  role = aws_iam_role.publisher_execution.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sns:Publish"
      Resource = var.sns_topic_arn
    }]
  })
}

# API Gateway integration (Lambda proxy)
resource "aws_api_gateway_integration" "publish_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.publish.id
  resource_id             = aws_api_gateway_resource.publish.id
  http_method             = aws_api_gateway_method.publish_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.publisher.invoke_arn
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "publisher_api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.publisher.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.publish.execution_arn}/*/*/*"
}

# Deploy API Gateway to a stage
resource "aws_api_gateway_deployment" "publish" {
  depends_on = [aws_api_gateway_integration.publish_lambda]
  rest_api_id = aws_api_gateway_rest_api.publish.id
  stage_name  = var.api_stage_name
}

# Output the API URL
output "api_url" {
  value = "${aws_api_gateway_deployment.publish.invoke_url}/publish"
}
output "website_url" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}