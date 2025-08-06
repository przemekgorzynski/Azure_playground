#!/bin/bash

# Required ARM environment variables
REQUIRED_VARS=(
  "ARM_CLIENT_ID"
  "ARM_CLIENT_SECRET"
  "ARM_SUBSCRIPTION_ID"
  "ARM_TENANT_ID"
  "BACKEND_ARM_SUBSCRIPTION"
  "BACKEND_RG_NAME"
  "BACKEND_SA_NAME"
  "BACKEND_CONTAINER_NAME"
)

MISSING_VARS=()

# Check each required variable
for var in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!var}" ]]; then
    MISSING_VARS+=("$var")
  fi
done

# If any are missing, print an error and exit
if [ ${#MISSING_VARS[@]} -ne 0 ]; then
  echo "❌ Missing required environment variables:"
  for var in "${MISSING_VARS[@]}"; do
    echo "  - $var"
  done
  echo -e "\n💡 Please run:\n\n  source .env\n"
  exit 1
fi

# Proceed with terraform init
echo "✅ All required ARM_* environment variables are set."

# Run terraform init with backend config
terraform init \
  -backend-config="subscription_id=$BACKEND_ARM_SUBSCRIPTION" \
  -backend-config="resource_group_name=$BACKEND_RG_NAME" \
  -backend-config="storage_account_name=$BACKEND_SA_NAME" \
  -backend-config="container_name=$BACKEND_CONTAINER_NAME" \
  -backend-config="key=terraform.tfstate"