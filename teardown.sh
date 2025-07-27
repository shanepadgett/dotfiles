#!/bin/bash

# Development Environment Teardown Script
# Reverses the setup process by uninstalling packages, removing symlinks, and cleaning up

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR"
BACKUP_DIR_PATTERN="$HOME/.config-backup-20*"
DRY_RUN=false

# Logging
LOG_FILE="$HOME/teardown.log"

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Teardown development environment setup

OPTIONS:
    -h, --help      Show this help message
    -d, --dry-run   Show what would be done without executing
    -y, --yes       Skip confirmation prompts

EXAMPLES:
    $0              # Interactive teardown with confirmations
    $0 --dry-run    # Preview what would be removed
    $0 --yes        # Skip all confirmations
EOF
}

confirm() {
    if [[ "$SKIP_CONFIRM" == "true" ]]; then
        return 0
    fi

    echo -e "${YELLOW}$1${NC}"
    read -p "Continue? [y/N]: " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

run_cmd() {
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would execute: $*"
    else
        eval "$*"
    fi
}

# Check if Homebrew is installed
brew_installed() {
    command -v brew >/dev/null 2>&1
}

# Uninstall Homebrew packages
uninstall_brew_packages() {
    log "Uninstalling Homebrew packages..."

    if ! brew_installed; then
        warn "Homebrew not found, skipping package uninstallation"
        return
    fi

    local brewfile="$REPO_DIR/Brewfile"
    if [[ -f "$brewfile" ]]; then
        info "Using Brewfile to uninstall packages..."
        run_cmd "brew bundle --file='$brewfile' --force cleanup"
    else
        warn "Brewfile not found, manually removing common packages..."

        # Get list of installed packages
        local packages=$(brew list --formula 2>/dev/null || true)
        local casks=$(brew list --cask 2>/dev/null || true)

        if [[ -n "$packages" ]]; then
            info "Uninstalling brew packages: $packages"
            run_cmd "brew uninstall --force $packages"
        fi

        if [[ -n "$casks" ]]; then
            info "Uninstalling casks: $casks"
            run_cmd "brew uninstall --cask --force $casks"
        fi
    fi
}

# Remove AI coding tools
remove_ai_tools() {
    log "Removing AI coding tools..."

    if [[ -f "$REPO_DIR/scripts/install-ai-tools.sh" ]]; then
        info "Using AI tools uninstall script..."
            run_cmd "$REPO_DIR/scripts/install-ai-tools.sh uninstall"    else
        warn "AI tools install script not found, skipping AI tools removal"
    fi
}

# Remove symlinks
remove_symlinks() {
    log "Removing symlinks from home directory..."

    local shell_configs=(
        ".zshrc"
        ".bashrc"
        ".bash_profile"
        ".zprofile"
        ".gitconfig"
        ".gitignore_global"
        ".vimrc"
        ".tmux.conf"
        ".config/nvim"
        ".config/git"
        ".config/zsh"
        ".config/bash"
    )

    for config in "${shell_configs[@]}"; do
        local target="$HOME/$config"
        if [[ -L "$target" ]]; then
            info "Removing symlink: $target"
            run_cmd "rm '$target'"
        elif [[ -f "$target" || -d "$target" ]]; then
            warn "Regular file/directory exists at $target (not a symlink)"
        fi
    done
}

# Restore original configurations
restore_backups() {
    log "Restoring original configurations..."

    local backup_dirs=($BACKUP_DIR_PATTERN)
    if [[ ${#backup_dirs[@]} -eq 0 ]]; then
        warn "No backup directories found"
        return
    fi

    # Use the most recent backup
    local latest_backup=$(ls -dt $BACKUP_DIR_PATTERN 2>/dev/null | head -n1)
    if [[ -n "$latest_backup" && -d "$latest_backup" ]]; then
        info "Restoring from backup: $latest_backup"

        # Restore shell configs
        if [[ -d "$latest_backup" ]]; then
            info "Restoring backed up configuration files..."
            run_cmd "cp -r '$latest_backup'/.* '$HOME'/ 2>/dev/null || true"
        fi
    else
        warn "No valid backup directory found"
    fi
}

# Clean up directories and logs
cleanup_directories() {
    log "Cleaning up development directories..."

    local dirs_to_clean=(
        "$HOME/dev"
        "$HOME/.config-backup-*"
        "$HOME/config.log"
        "$HOME/teardown.log"
        "$HOME/.orbstack"
    )

    for dir in "${dirs_to_clean[@]}"; do
        if [[ -e "$dir" ]]; then
            info "Removing $dir"
            run_cmd "rm -rf '$dir'"
        fi
    done
}

# Main teardown process
main() {
    log "Starting development environment teardown..."

    if [[ "$DRY_RUN" == "true" ]]; then
        info "Running in DRY RUN mode - no changes will be made"
    fi

    if ! confirm "This will remove all development tools and configurations. Are you sure?"; then
        log "Teardown cancelled by user"
        exit 0
    fi

    # Execute teardown steps
    uninstall_brew_packages
    remove_ai_tools
    remove_symlinks

    if confirm "Restore original configurations from backup?"; then
        restore_backups
    fi

    if confirm "Clean up development directories and logs?"; then
        cleanup_directories
    fi

    log "Teardown completed successfully!"
    info "You may need to restart your shell or terminal for changes to take effect"
}

# Parse command line arguments
SKIP_CONFIRM=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -y|--yes)
            SKIP_CONFIRM=true
            shift
            ;;
        *)
            error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Run main function
main
