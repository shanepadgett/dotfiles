#!/bin/bash

# Update Brewfile based on currently installed packages
# Usage: ./scripts/update-brewfile.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BREWFILE="$PROJECT_DIR/Brewfile"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Updating Brewfile with current system state...${NC}"

# Create backup
if [ -f "$BREWFILE" ]; then
    cp "$BREWFILE" "$BREWFILE.backup.$(date +%Y%m%d-%H%M%S)"
    echo -e "${YELLOW}Backup created: $BREWFILE.backup.$(date +%Y%m%d-%H%M%S)${NC}"
fi

# Generate new Brewfile
cd "$PROJECT_DIR"
brew bundle dump --file="$BREWFILE" --force

echo -e "${GREEN}Brewfile updated successfully!${NC}"
echo -e "${YELLOW}Review the changes and commit if they look correct.${NC}"