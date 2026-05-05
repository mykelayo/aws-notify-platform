# AWS Notify Platform

Event-driven notification platform using SNS → SQS → Lambda → Aurora Serverless.

## Architecture

[Setup Mermaid diagram or description]

## Key Decisions

See [docs/decisions.md](docs/decisions.md)

## Prerequisites

- AWS CLI configured
- Terraform >= 1.15
- Python 3.13
- GitHub account (for CI/CD)

## Quick Start

1. Clone repo
2. Run `scripts/bootstrap-state.sh` (creates S3 bucket and DynamoDB for remote state)
3. Create `terraform/environments/dev/terraform.tfvars` with: