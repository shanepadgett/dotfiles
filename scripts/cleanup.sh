#!/bin/bash

# Cleanup script to remove symlinks and restore backups
# Usage: ./scripts/cleanup.sh [--force]

set -euo pipefail

# Source centralized logging system
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/logger.sh"

BACKUP_DIR="$HOME/.config-backup"
# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
# shellcheck disable=SC1091
source "$ROOT_DIR/config/config.env"

remove_symlink "$CONFIG_SHELL_DIR/zshrc" "$HOME/.zshrc"
remove_symlink "$CONFIG_SHELL_DIR/bashrc" "$HOME/.bashrc"
remove_symlink "$CONFIG_TOOLS_DIR/vscode" "$HOME/.config/Code/User"
remove_symlink "$CONFIG_TOOLS_DIR/zed" "$HOME/.config/zed"
remove_symlink "$CONFIG_TOOLS_DIR/ghostty" "$HOME/.config/ghostty"

# Restore backups
restore_backup "$BACKUP_DIR-*/.zshrc" "$HOME"
restore_backup "$BACKUP_DIR-*/.bashrc" "$HOME"
restore_backup "$BACKUP_DIR-*/Code" "$HOME/.config"
restore_backup "$BACKUP_DIR-*/zed" "$HOME/.config"
restore_backup "$BACKUP_DIR-*/ghostty" "$HOME/.config"

log_success "Cleanup completed!"
