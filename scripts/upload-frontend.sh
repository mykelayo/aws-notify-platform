#!/bin/bash
set -e
BUCKET_NAME=$1  # passed from Terraform output
aws s3 sync frontend/ "s3://$BUCKET_NAME/" --acl public-read