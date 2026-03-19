#!/bin/bash
set -e

# ── Colors ─────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ── Helpers ────────────────────────────────────────────────
info()    { echo -e "${BLUE}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ── Load env vars ──────────────────────────────────────────
if [ ! -f .env ]; then
  error ".env file not found"
fi
source .env
success "Loaded .env"

# ── Check required env vars ────────────────────────────────
[ -z "$ARM_CLIENT_ID" ]             && error "ARM_CLIENT_ID is not set in .env"
[ -z "$ARM_CLIENT_SECRET" ]         && error "ARM_CLIENT_SECRET is not set in .env"
[ -z "$ARM_TENANT_ID" ]             && error "ARM_TENANT_ID is not set in .env"
[ -z "$TF_TOKEN_app_terraform_io" ] && error "TF_TOKEN_app_terraform_io is not set in .env"
success "Environment variables validated"

# ── Args ───────────────────────────────────────────────────
COMMAND=${1:-plan}
VAR_FILE=${2:-lz.tfvars}

# ── Check tfvars file exists (not needed for init) ─────────
if [ "$COMMAND" != "init" ] && [ ! -f "$VAR_FILE" ]; then
  error "Var file '$VAR_FILE' not found"
fi

# ── Check terraform is installed ───────────────────────────
if ! command -v terraform &> /dev/null; then
  error "Terraform is not installed or not in PATH"
fi

echo ""
info "Command  : $COMMAND"
info "Var file : $VAR_FILE"
info "Tenant   : $ARM_TENANT_ID"
info "Client   : $ARM_CLIENT_ID"
echo ""

# ── Run ────────────────────────────────────────────────────
case $COMMAND in
  init)
    info "Initialising Terraform (--upgrade)..."
    terraform init -upgrade
    success "Init complete"
    ;;
  plan)
    info "Running Terraform plan..."
    terraform plan -var-file $VAR_FILE
    success "Plan complete"
    ;;
  apply)
    warn "This will make changes to your infrastructure!"
    info "Running Terraform apply..."
    terraform apply -var-file $VAR_FILE
    success "Apply complete"
    ;;
  destroy)
    warn "This will DESTROY your infrastructure!"
    info "Running Terraform destroy..."
    terraform destroy -var-file $VAR_FILE
    success "Destroy complete"
    ;;
  *)
    error "Unknown command '$COMMAND'. Usage: $0 {init|plan|apply|destroy} [tfvars_file]"
    ;;
esac