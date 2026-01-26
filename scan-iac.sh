#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Config
# -----------------------------
SCAN_DIR="${1:-.}"

# Docker images
CHECKOV_IMAGE="bridgecrew/checkov:latest"
CHECKOV_CONFIG_FILE="${CHECKOV_CONFIG_FILE:-.checkov-skip.yml}"
TRIVY_IMAGE="aquasec/trivy:latest"
YAMLLINT_IMAGE="cytopia/yamllint:latest"

# Colors
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
NC="\033[0m"

echo -e "${GREEN}=== IaC Local Scan: ${SCAN_DIR} ===${NC}"

# -----------------------------
# Functions
# -----------------------------

# -----------------------------
# Terraform
# -----------------------------
terraform_fmt() {
    echo -e "\n${GREEN}Checking Terraform formatting...${NC}"
    if terraform fmt -check -recursive "$SCAN_DIR"; then
        echo -e "${GREEN}terraform fmt OK${NC}"
    else
        echo -e "${YELLOW}terraform fmt found issues${NC}"
    fi
}

terraform_validate() {
    echo -e "\n${GREEN}Validating Terraform configuration...${NC}"
    (cd "$SCAN_DIR" && terraform init -backend=false >/dev/null 2>&1 && terraform validate) \
        && echo -e "${GREEN}terraform validate OK${NC}" \
        || echo -e "${YELLOW}terraform validate found issues${NC}"
}

checkov_scan() {
    echo -e "\n${GREEN}Running Checkov Terraform scan...${NC}"

    docker run --rm \
      -e CHECKOV_ENABLE_SECRET_SCAN=false \
      -v "$(realpath "$SCAN_DIR")":/tf \
      "$CHECKOV_IMAGE" \
      -d /tf -f terraform \
      --quiet \
      --compact 2>/dev/null || \
      echo -e "${YELLOW}Checkov found issues${NC}"
}


# -----------------------------
# Bicep
# -----------------------------
bicep_syntax() {
    echo -e "${GREEN}Checking Bicep syntax in folder: $SCAN_DIR${NC}"
    for f in $(find "$SCAN_DIR" -name "*.bicep"); do
        echo -e "\n${GREEN}Checking $f...${NC}"
        if bicep build "$f" --stdout >/dev/null 2>&1; then
            echo -e "${GREEN}$f OK${NC}"
        else
            echo -e "${YELLOW}$f has syntax issues${NC}"
        fi
    done
}

# -----------------------------
# Helm
# -----------------------------
helm_lint() {
    echo -e "${GREEN}Linting Helm charts in folder: $SCAN_DIR${NC}"
    for chart in "$SCAN_DIR"/*; do
        if [ -d "$chart" ]; then
            echo -e "\n${GREEN}Linting chart: $(basename "$chart")${NC}"
            helm lint "$chart" || echo -e "${YELLOW}Lint found issues in $(basename "$chart")${NC}"
        fi
    done
}

helm_yaml_checks() {
    echo -e "\n${GREEN}Running YAML checks on Helm charts via Docker...${NC}"
    for chart in "$SCAN_DIR"/*; do
        if [ -d "$chart" ]; then
            echo -e "\n${GREEN}Checking chart: $(basename "$chart")${NC}"

            # Render Helm chart to temp file
            RENDERED=$(mktemp)
            helm template "$chart" > "$RENDERED"

            # yamllint via Docker
            docker run --rm --platform linux/amd64 -v "$(dirname "$RENDERED")":/data "$YAMLLINT_IMAGE" /data/$(basename "$RENDERED") || \
                echo -e "${YELLOW}yamllint found issues in $(basename "$chart")${NC}"

            rm "$RENDERED"
        fi
    done
}

# -----------------------------
# Main logic
# -----------------------------
if [ ! -d "$SCAN_DIR" ]; then
    echo -e "${YELLOW}Provided path is not a directory: $SCAN_DIR${NC}"
    exit 1
fi

BASE_LOWER=$(basename "$SCAN_DIR" | tr '[:upper:]' '[:lower:]')

case "$BASE_LOWER" in
    terraform)
        terraform_fmt
        terraform_validate
        checkov_scan
        ;;
    bicep)
        bicep_syntax
        ;;
    helm)
        helm_lint
        helm_yaml_checks
        ;;
    *)
        echo -e "${YELLOW}Unknown folder type: $BASE_LOWER. No scans executed.${NC}"
        ;;
esac

echo -e "\n${GREEN}=== Scan complete ===${NC}"
