#!/bin/bash
set -euo pipefail

# ----------------------------
# Simple Bicep deployment script
# ----------------------------

# Usage: ./deploy.sh <environment>
# Example: ./deploy.sh dev

ENV=${1}  # default to dev if not provided

# Map environment to parameter file
PARAM_FILE="${ENV}.bicepparam"

if [[ ! -f "$PARAM_FILE" ]]; then
  echo "Parameter file $PARAM_FILE not found!"
  exit 1
fi

# Choose a location (used only for subscription-level deployment)
LOCATION="polandcentral"

# Deploy the Bicep file at subscription scope
echo "Deploying Bicep to subscription using environment: $ENV"
az deployment sub create \
    --name "bicep-deployment-$ENV-$(date +%Y%m%d%H%M%S)" \
    --location $LOCATION \
    --template-file main.bicep \
    --parameters "$PARAM_FILE"

echo "Deployment completed successfully!"
