#!/bin/bash

# Cleanup script to remove symlinks and restore backups
# Usage: ./scripts/cleanup.sh [--force]

set -euo pipefail

FORCE=false
if [[ "${1:-}" == "--force" ]]; then
    FORCE=true
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BACKUP_DIR="$HOME/.config-backup"
DOTFILES_DIR="$HOME/.dotfiles/dotfiles"

if [[ "$FORCE" != true ]]; then
    echo -e "${YELLOW}This will remove all symlinks and restore backups.${NC}"
    echo -e "${YELLOW}Are you sure? (y/N):${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Cleanup cancelled.${NC}"
        exit 0
    fi
fi

echo -e "${GREEN}Starting cleanup...${NC}"

# Remove symlinks
remove_symlink() {
    local source="$1"
    local target="$2"

    if [ -L "$target" ]; then
        rm "$target"
        echo -e "${GREEN}Removed symlink: $target${NC}"
    elif [ -e "$target" ]; then
        echo -e "${YELLOW}Warning: $target exists but is not a symlink${NC}"
    fi
}

# Restore backups
restore_backup() {
    local backup_pattern="$1"
    local target_dir="$2"

    local latest_backup=$(ls -t $backup_pattern 2>/dev/null | head -1)
    if [ -n "$latest_backup" ]; then
        cp -r "$latest_backup"/* "$target_dir"/
        echo -e "${GREEN}Restored backup: $latest_backup -> $target_dir${NC}"
    fi
}

# Remove common symlinks
remove_symlink "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
remove_symlink "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"
remove_symlink "$DOTFILES_DIR/vscode" "$HOME/.config/Code/User"
remove_symlink "$DOTFILES_DIR/zed" "$HOME/.config/zed"
remove_symlink "$DOTFILES_DIR/ghostty" "$HOME/.config/ghostty"

# Restore backups
restore_backup "$BACKUP_DIR-*/.zshrc" "$HOME"
restore_backup "$BACKUP_DIR-*/.bashrc" "$HOME"
restore_backup "$BACKUP_DIR-*/Code" "$HOME/.config"
restore_backup "$BACKUP_DIR-*/zed" "$HOME/.config"
restore_backup "$BACKUP_DIR-*/ghostty" "$HOME/.config"

echo -e "${GREEN}Cleanup completed!${NC}"
