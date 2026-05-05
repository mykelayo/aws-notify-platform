terraform {
  backend "s3" {
    bucket         = "aws-notify-platform-tfstate-global"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}