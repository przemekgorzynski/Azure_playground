#!/bin/bash

# Load environment variables from .env file
source .env

# Run terraform init with backend config
terraform init \
  -backend-config="subscription_id=$BACKEND_ARM_SUBSCRIPTION" \
  -backend-config="resource_group_name=$BACKEND_RG_NAME" \
  -backend-config="storage_account_name=$BACKEND_SA_NAME" \
  -backend-config="container_name=$BACKEND_CONTAINER_NAME" \
  -backend-config="key=terraform.tfstate"