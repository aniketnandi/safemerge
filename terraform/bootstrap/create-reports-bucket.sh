#!/usr/bin/env bash
# Creates the private S3 bucket for scan reports, using the AWS CLI.
# Terraform cannot create buckets in Learner Lab (the object lock read is blocked),
# so the bucket is created here and its settings are managed in terraform/modules/reports.
# Safe to run more than once.
set -euo pipefail

REGION="us-east-1"
OWNER="${1:?Usage: ./create-reports-bucket.sh <owner> <env>}"
ENV="${2:?Usage: ./create-reports-bucket.sh <owner> <env>}"
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
BUCKET="sm-${ENV}-reports-${ACCOUNT}"

if aws s3api head-bucket --bucket "$BUCKET" >/dev/null 2>&1; then
  echo "Bucket $BUCKET already exists"
else
  aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" >/dev/null
  echo "Created $BUCKET"
fi

aws s3api put-bucket-tagging --bucket "$BUCKET" \
  --tagging "TagSet=[{Key=project,Value=safemerge},{Key=env,Value=${ENV}},{Key=owner,Value=${OWNER}}]"

echo "Reports bucket ready: $BUCKET"
