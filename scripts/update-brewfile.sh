#!/bin/bash

# Update Brewfile based on currently installed packages
# Usage: ./scripts/update-brewfile.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BREWFILE="$PROJECT_DIR/Brewfile"

# Source centralized logging system
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/logger.sh"

log_info "Updating Brewfile with current system state..."

# Create backup
if [ -f "$BREWFILE" ]; then
  cp "$BREWFILE" "$BREWFILE.backup.$(date +%Y%m%d-%H%M%S)"
  log_warning "Backup created: $BREWFILE.backup.$(date +%Y%m%d-%H%M%S)"
fi

# Generate new Brewfile
cd "$PROJECT_DIR"
brew bundle dump --file="$BREWFILE" --force

log_success "Brewfile updated successfully!"
log_warning "Review the changes and commit if they look correct."
