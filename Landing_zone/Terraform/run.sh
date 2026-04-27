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

# ── Check terraform is installed ───────────────────────────
if ! command -v terraform &> /dev/null; then
  error "Terraform is not installed or not in PATH"
fi

# ── Build -var-file flags from all *.tfvars in order ───────
VAR_ARGS=""
for f in vars/common.tfvars vars/hub.tfvars vars/spoke1.tfvars vars/spoke2.tfvars; do
  [ "$COMMAND" != "init" ] && [ ! -f "$f" ] && error "Var file '$f' not found"
  VAR_ARGS="$VAR_ARGS -var-file $f"
done

echo ""
info "Command  : $COMMAND"
info "Var files: vars/common vars/hub vars/spoke1 vars/spoke2"
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
    terraform plan $VAR_ARGS
    success "Plan complete"
    ;;
  apply)
    warn "This will make changes to your infrastructure!"
    info "Running Terraform apply..."
    terraform apply $VAR_ARGS
    success "Apply complete"
    ;;
  destroy)
    warn "This will DESTROY your infrastructure!"
    info "Running Terraform destroy..."
    terraform destroy $VAR_ARGS
    success "Destroy complete"
    ;;
  *)
    error "Unknown command '$COMMAND'. Usage: $0 {init|plan|apply|destroy}"
    ;;
esac