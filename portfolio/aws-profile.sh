#!/usr/bin/env bash

AWS_PROFILE_NAME="Aryan"

export AWS_PROFILE="$AWS_PROFILE_NAME"

# Check profile exists in credentials or config file
CREDENTIALS_FILE="$HOME/.aws/credentials"
CONFIG_FILE="$HOME/.aws/config"

PROFILE_IN_CREDENTIALS=$(grep -c "^\[${AWS_PROFILE}\]" "$CREDENTIALS_FILE" 2>/dev/null || echo 0)
PROFILE_IN_CONFIG=$(grep -c "^\[profile ${AWS_PROFILE}\]" "$CONFIG_FILE" 2>/dev/null || echo 0)

if [ "$PROFILE_IN_CREDENTIALS" -eq 0 ] && [ "$PROFILE_IN_CONFIG" -eq 0 ]; then
  echo "Error: AWS profile '$AWS_PROFILE' not found."
  echo "  Run: aws configure --profile $AWS_PROFILE"
  exit 1
fi

# Check credentials are populated (non-SSO profiles)
ACCESS_KEY=$(aws configure get aws_access_key_id --profile "$AWS_PROFILE" 2>/dev/null)
if [ -z "$ACCESS_KEY" ]; then
  echo "Error: No credentials found for profile '$AWS_PROFILE'."
  echo "  Run: aws configure --profile $AWS_PROFILE"
  exit 1
fi

echo "AWS profile set: $AWS_PROFILE"
