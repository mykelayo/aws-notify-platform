variable "name_prefix"     { default = "aws-notify" }
variable "bucket_name"     { description = "Globally unique S3 bucket name" }
variable "sns_topic_arn"   { description = "SNS topic ARN for publishing" }
variable "publisher_zip_path" { default = "../../../src/publisher/lambda.zip" }
variable "api_stage_name"  { default = "prod" }
variable "tags"            { type = map(string) ; default = {} }