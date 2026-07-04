#!/usr/bin/env bash

source "$(dirname "$0")/aws-profile.sh"
source "$(dirname "$0")/environments/scripts/.env"

EXPECTED_REGION="ap-south-1"
if [ -z "$EXPECTED_AWS_ACCOUNT_ID" ]; then
  echo "Error: EXPECTED_AWS_ACCOUNT_ID env var is not set"
  exit 1
fi

CURRENT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
if [ "$CURRENT_ACCOUNT" != "$EXPECTED_AWS_ACCOUNT_ID" ]; then
  echo "Error: Wrong AWS account."
  echo "  Expected: $EXPECTED_AWS_ACCOUNT_ID"
  echo "  Current:  $CURRENT_ACCOUNT"
  exit 1
fi

CURRENT_REGION=$(aws configure get region 2>/dev/null || echo "${AWS_DEFAULT_REGION:-unset}")
if [ "$CURRENT_REGION" != "$EXPECTED_REGION" ]; then
  echo "Error: Wrong AWS region."
  echo "  Expected: $EXPECTED_REGION"
  echo "  Current:  $CURRENT_REGION"
  exit 1
fi

echo "AWS context verified: account=$CURRENT_ACCOUNT, region=$CURRENT_REGION"
