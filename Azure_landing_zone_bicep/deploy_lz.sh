#!/bin/bash
set -euo pipefail

# ----------------------------
# Simple Bicep deployment script
# ----------------------------
# Usage: ./deploy.sh [--dry-run]
# Example: ./deploy.sh
#          ./deploy.sh --dry-run

LOCATION="polandcentral"
DRY_RUN=false

# Parse arguments
for arg in "$@"; do
  case $arg in
    --dry-run)
      DRY_RUN=true
      ;;
    *)
      echo "Unknown argument: $arg"
      exit 1
      ;;
  esac
done

if [ "$DRY_RUN" = true ]; then
  echo "Running in DRY-RUN mode (what-if)"
  az deployment sub what-if \
    --name "bicep-deployment-$(date +%Y%m%d%H%M%S)" \
    --location $LOCATION \
    --template-file landing_zone.bicep \
    --parameters landing_zone.bicepparam
else
  echo "Deploying Bicep to subscription"
  az deployment sub create \
    --name "bicep-deployment-$(date +%Y%m%d%H%M%S)" \
    --location $LOCATION \
    --template-file landing_zone.bicep \
    --parameters landing_zone.bicepparam
fi