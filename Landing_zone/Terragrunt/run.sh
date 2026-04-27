#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ── Load env vars ──────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../Terraform/.env"

if [ ! -f "$ENV_FILE" ]; then
  error ".env file not found at $ENV_FILE"
fi
source "$ENV_FILE"
success "Loaded .env"

[ -z "$ARM_CLIENT_ID" ]               && error "ARM_CLIENT_ID is not set"
[ -z "$ARM_CLIENT_SECRET" ]           && error "ARM_CLIENT_SECRET is not set"
[ -z "$ARM_TENANT_ID" ]               && error "ARM_TENANT_ID is not set"
[ -z "$TF_TOKEN_app_terraform_io" ]   && error "TF_TOKEN_app_terraform_io is not set"
[ -z "$ARM_MGMT_SUBSCRIPTION_ID" ]    && error "ARM_MGMT_SUBSCRIPTION_ID is not set"
[ -z "$ARM_SPOKE1_SUBSCRIPTION_ID" ]  && error "ARM_SPOKE1_SUBSCRIPTION_ID is not set"
[ -z "$ARM_SPOKE2_SUBSCRIPTION_ID" ]  && error "ARM_SPOKE2_SUBSCRIPTION_ID is not set"
success "Environment variables validated"

command -v terragrunt &> /dev/null || error "terragrunt is not installed or not in PATH"
command -v terraform  &> /dev/null || error "terraform is not installed or not in PATH"

# ── Args ───────────────────────────────────────────────────
# Usage: ./run.sh <command> [target]
#   command : init | plan | apply | destroy  (default: plan)
#   target  : hub | spoke1 | spoke2 | all   (default: all)
COMMAND=${1:-plan}
TARGET=${2:-all}

VALID_TARGETS=("hub" "spoke1" "spoke2" "all")
[[ " ${VALID_TARGETS[*]} " =~ " $TARGET " ]] || error "Unknown target '$TARGET'. Use: hub | spoke1 | all"

echo ""
info "Command      : $COMMAND"
info "Target       : $TARGET"
info "Tenant       : $ARM_TENANT_ID"
info "Client       : $ARM_CLIENT_ID"
echo ""

run_single() {
  local dir="$SCRIPT_DIR/$1"
  [ -d "$dir" ] || error "Directory not found: $dir"
  info "[$1] Running $COMMAND..."
  terragrunt "$COMMAND" --working-dir "$dir"
}

run_all() {
  terragrunt run --all "$COMMAND" --working-dir "$SCRIPT_DIR" --log-level warn
}

case $COMMAND in
  init)
    case $TARGET in
      all) run_all ;;
      *)   run_single "$TARGET" ;;
    esac
    success "Init complete"
    ;;
  plan)
    case $TARGET in
      all) run_all ;;
      *)   run_single "$TARGET" ;;
    esac
    success "Plan complete"
    ;;
  apply)
    warn "This will make changes to infrastructure in: $TARGET"
    case $TARGET in
      all) run_all ;;
      *)   run_single "$TARGET" ;;
    esac
    success "Apply complete"
    ;;
  destroy)
    warn "This will DESTROY infrastructure in: $TARGET"
    read -p "Are you sure? (yes/no): " confirm
    [ "$confirm" = "yes" ] || error "Destroy cancelled"
    case $TARGET in
      all) run_all ;;
      *)   run_single "$TARGET" ;;
    esac
    success "Destroy complete"
    ;;
  *)
    error "Unknown command '$COMMAND'. Usage: $0 {init|plan|apply|destroy} [hub|spoke1|all]"
    ;;
esac
