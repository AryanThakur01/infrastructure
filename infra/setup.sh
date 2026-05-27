#!/usr/bin/env bash
set -e

source "$(dirname "$0")/check-aws-context.sh"

# Constants
S3_TERRAFORM_BUCKET_REGION="ap-south-1"
S3_TERRAFORM_BUCKET_NAME="terraform-state-${CURRENT_ACCOUNT}"
SERVER_SIDE_ENCRYPTION_CONFIGURATION='{
  "Rules": [{
    "ApplyServerSideEncryptionByDefault": {
      "SSEAlgorithm": "AES256"
    }
  }]
}'
DYNAMODB_TABLE_NAME="terraform-state-locks"
ENVIRONMENTS=("staging" "production")

# AWS S3 Setup
if aws s3api head-bucket --bucket "$S3_TERRAFORM_BUCKET_NAME" 2>/dev/null; then
  echo "S3 bucket '$S3_TERRAFORM_BUCKET_NAME' already exists. Skipping creation."
else
  aws s3api create-bucket \
    --bucket "$S3_TERRAFORM_BUCKET_NAME" \
    --region $S3_TERRAFORM_BUCKET_REGION \
    --create-bucket-configuration LocationConstraint=$S3_TERRAFORM_BUCKET_REGION
  aws s3api put-bucket-versioning \
    --bucket "$S3_TERRAFORM_BUCKET_NAME" \
    --versioning-configuration Status=Enabled
  aws s3api put-bucket-encryption \
    --bucket "$S3_TERRAFORM_BUCKET_NAME" \
    --server-side-encryption-configuration "$SERVER_SIDE_ENCRYPTION_CONFIGURATION"
fi

# AWS DynamoDB Setup
if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE_NAME" --region $S3_TERRAFORM_BUCKET_REGION 2>/dev/null; then
  echo "DynamoDB table '$DYNAMODB_TABLE_NAME' already exists. Skipping creation."
else
  aws dynamodb create-table \
    --table-name $DYNAMODB_TABLE_NAME \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region $S3_TERRAFORM_BUCKET_REGION
fi


# Terraform Environments Setup
for ENV in "${ENVIRONMENTS[@]}"; do
  if ! terraform workspace list | grep -q "$ENV"; then
    terraform workspace new "$ENV"
  else
    echo "Workspace '$ENV' already exists. Skipping creation."
  fi
done

terraform workspace list
