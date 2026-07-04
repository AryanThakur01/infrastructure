#!/usr/bin/env bash
set -e

source "$(dirname "$0")/check-aws-context.sh"

ENV="$1"
COMMAND="$2"

SUPPORTED_ENVS=("staging" "prod") # created in setup.sh
if [[ ! " ${SUPPORTED_ENVS[@]} " =~ " ${ENV} " ]]; then
  echo "Unsupported environment: $ENV"
  echo "Supported environments are: ${SUPPORTED_ENVS[*]}"
  exit 1
fi

if [ "$COMMAND" == "tfworkspace" ]; then
  # Command for planning Terraform changes
  terraform workspace select "$ENV"
  exit 0
elif [ "$COMMAND" == "tfplan" ]; then
  # Command for planning Terraform changes
  terraform workspace select "$ENV"
  terraform plan -var-file="environments/terraform/$ENV.tfvars"
  exit 0

elif [ "$COMMAND" == "tfapply" ]; then
  # Command for applying Terraform changes
  terraform workspace select "$ENV"
  terraform apply -var-file="environments/terraform/$ENV.tfvars"
  exit 0

elif [ "$COMMAND" == "tfsensitivekeys" ]; then
  # Command for retrieving sensitive keys from Terraform outputs
  terraform workspace select "$ENV"
  echo "GITHUB_AWS_SECRET_ACCESS_KEY=$(terraform output -raw GITHUB_AWS_SECRET_ACCESS_KEY)"
  echo "REDIS_PASSWORD=$(terraform output REDIS_PASSWORD)"
  exit 0
fi
