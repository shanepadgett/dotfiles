#!/bin/zsh

# Combined shell script validation: linting + formatting
# Usage: ./dev/validate-shell.sh [--fix] [files...]

set -euo pipefail

# Check if running in dev container environment
if ! ([ -f /.dockerenv ] || [ -n "$REMOTE_CONTAINERS" ] || [ -n "$CODESPACES" ] || [ -n "$DEVCONTAINER" ]); then
  echo "❌ This script requires the dev container environment"
  echo "Please open this project in a dev container and try again."
  echo "The dev container includes shellcheck, shfmt and other required tools."
  exit 1
fi

# Source centralized logging system
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/logger.sh"

print_header "Shell Script Validation (Lint + Format)"

# Pass all arguments to both scripts
ARGS=("$@")

echo
print_info "Step 1: Running shellcheck linting..."
if ! "$SCRIPT_DIR/lint-shell.sh" "${ARGS[@]}"; then
  print_error "Linting failed. Please fix the issues above before proceeding."
  print_info "Run with --fix to see detailed fix suggestions:"
  print_info "  ./scripts/validate-shell.sh --fix"
  exit 1
fi

echo
print_info "Step 2: Running shfmt formatting..."
if ! "$SCRIPT_DIR/format-shell.sh" "${ARGS[@]}"; then
  print_error "Formatting failed."
  exit 1
fi

echo
print_info "Step 3: Re-running shellcheck to verify fixes..."
if ! "$SCRIPT_DIR/lint-shell.sh" "${ARGS[@]}"; then
  print_error "Some issues remain after formatting. Please review manually."
  exit 1
fi

echo
print_success "🎉 All shell scripts pass validation!"
print_info "✅ Linting: All files pass shellcheck"
print_info "✅ Formatting: All files are properly formatted"
