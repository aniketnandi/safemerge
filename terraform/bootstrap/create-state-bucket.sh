#!/usr/bin/env bash
# Creates the S3 bucket for Terraform state, using the AWS CLI.
# Terraform's aws_s3_bucket resource fails in Learner Lab because it reads
# the object lock setting, which Learner Lab blocks. The CLI does not.
# Safe to run more than once.
set -euo pipefail

REGION="us-east-1"
OWNER="${1:?Usage: ./create-state-bucket.sh <owner> <env>}"
ENV="${2:?Usage: ./create-state-bucket.sh <owner> <env>}"
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
BUCKET="sm-tfstate-${ACCOUNT}"

if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
  echo "Bucket $BUCKET already exists"
else
  aws s3api create-bucket --bucket "$BUCKET" --region "$REGION"
  echo "Created $BUCKET"
fi

# Keep old versions of the state file, so a bad change can be undone
aws s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

# Encrypt the state at rest
aws s3api put-bucket-encryption --bucket "$BUCKET" \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

# State can contain secrets, so block all public access
aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

aws s3api put-bucket-tagging --bucket "$BUCKET" \
  --tagging "TagSet=[{Key=project,Value=safemerge},{Key=env,Value=${ENV}},{Key=owner,Value=${OWNER}}]"

echo "State bucket ready: $BUCKET"
