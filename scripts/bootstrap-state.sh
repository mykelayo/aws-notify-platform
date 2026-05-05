#!/bin/bash
set -e

echo "Bootstrapping Terraform state backend (S3 + DynamoDB) with AWS Provider 6.x..."

cd terraform/global/bootstrap

if [ ! -f terraform.tfvars ]; then
  cp terraform.tfvars.example terraform.tfvars
  echo "Created terraform.tfvars."
  exit 1
fi

terraform init
terraform plan
terraform apply -auto-approve

echo "Bootstrap complete."
echo "S3 bucket and DynamoDB table are ready for remote state."