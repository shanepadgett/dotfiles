#!/bin/bash

# Development Environment Teardown Script
# Reverses the setup process by uninstalling packages, removing symlinks, and cleaning up

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/common.sh"

# Configuration
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
if [[ -f "$ROOT_DIR/config/config.env" ]]; then
    source "$ROOT_DIR/config/config.env"
fi

# Set REPO_DIR to INSTALL_DIR for consistency
REPO_DIR="${INSTALL_DIR:-$ROOT_DIR}"
BACKUP_DIR_PATTERN="$HOME/.config-backup-20*"
DRY_RUN=false
SKIP_CONFIRM=false

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
Usage: teardown [OPTIONS]

Teardown development environment setup

OPTIONS:
    -h, --help      Show this help message
    -d, --dry-run   Show what would be done without executing
    -y, --yes       Skip confirmation prompts

EXAMPLES:
    teardown              # Interactive teardown with confirmations
    teardown --dry-run    # Preview what would be removed
    teardown --yes        # Skip all confirmations
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
        info "Parsing Brewfile to find packages to uninstall..."
        
        # Extract package names from Brewfile
        local brew_packages=$(grep '^brew ' "$brewfile" | sed 's/brew "\([^"]*\)".*/\1/' | tr '\n' ' ')
        local cask_packages=$(grep '^cask ' "$brewfile" | sed 's/cask "\([^"]*\)".*/\1/' | tr '\n' ' ')
        
        # Uninstall casks first (they often depend on formulas)
        if [[ -n "$cask_packages" ]]; then
            info "Uninstalling casks: $cask_packages"
            for cask in $cask_packages; do
                if brew list --cask "$cask" &>/dev/null; then
                    run_cmd "brew uninstall --cask --force '$cask'"
                else
                    info "Cask $cask not installed, skipping"
                fi
            done
        fi
        
        # Then uninstall formulas
        if [[ -n "$brew_packages" ]]; then
            info "Uninstalling brew packages: $brew_packages"
            for package in $brew_packages; do
                if brew list --formula "$package" &>/dev/null; then
                    run_cmd "brew uninstall --force '$package'"
                else
                    info "Package $package not installed, skipping"
                fi
            done
        fi
        
        # Clean up any remaining dependencies
        info "Cleaning up unused dependencies..."
        run_cmd "brew autoremove"
        
    else
        warn "Brewfile not found at $brewfile"
        info "Attempting to uninstall all user-installed packages..."

        # Get list of all installed packages (fallback)
        local packages=$(brew list --formula 2>/dev/null || true)
        local casks=$(brew list --cask 2>/dev/null || true)

        if [[ -n "$casks" ]]; then
            info "Uninstalling all casks: $casks"
            run_cmd "brew uninstall --cask --force $casks"
        fi

        if [[ -n "$packages" ]]; then
            info "Uninstalling all brew packages: $packages"
            run_cmd "brew uninstall --force $packages"
        fi
    fi
}

# Remove AI coding tools
remove_ai_tools() {
    log "Removing AI coding tools..."

    if [[ -f "$REPO_DIR/scripts/install-ai-tools.sh" ]]; then
        info "Using AI tools uninstall script..."
        run_cmd "$REPO_DIR/scripts/install-ai-tools.sh uninstall"
    else
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
        ".config/zoxide"
        ".config/zed"
        ".config/ghostty"
        ".config/claude-code"
        ".config/opencode"
        ".local/bin/git-init"
        ".local/bin/pr"
        ".local/bin/dev"
        ".local/bin/update-configs"
        ".local/bin/reset-configs"
        ".local/bin/teardown"
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

# Remove the dotfiles repository (final step)
remove_repository() {
    log "Removing dotfiles repository..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would remove repository: $REPO_DIR"
        return 0
    fi
    
    # Copy this script to temp location and re-exec to finish removal
    local temp_script="/tmp/teardown-final-$$.sh"
    cat > "$temp_script" << 'EOF'
#!/bin/bash
REPO_DIR="$1"
echo "Removing dotfiles repository: $REPO_DIR"
rm -rf "$REPO_DIR"
echo "✓ Dotfiles repository removed"
echo "Teardown complete!"
rm -f "$0"  # Remove this temp script
EOF
    
    chmod +x "$temp_script"
    info "Executing final repository removal..."
    exec bash "$temp_script" "$REPO_DIR"
}

# Check if running in a terminal that will be uninstalled
check_terminal_warning() {
    # Check if running in Ghostty - BLOCK execution
    if [[ "${TERM_PROGRAM:-}" == "ghostty" ]]; then
        error "Cannot run teardown from Ghostty terminal!"
        error "Teardown will uninstall Ghostty, terminating this session mid-process."
        echo
        info "Please run teardown from Terminal.app or iTerm2:"
        info "1. Open Terminal.app (Applications > Utilities > Terminal)"
        info "2. Run: teardown"
        echo
        log "Teardown blocked - running from Ghostty"
        exit 1
    fi
    
    # Check if running in VS Code integrated terminal - BLOCK execution
    if [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then
        error "Cannot run teardown from VS Code integrated terminal!"
        error "Teardown will uninstall VS Code, terminating this session mid-process."
        echo
        info "Please run teardown from Terminal.app:"
        info "1. Open Terminal.app (Applications > Utilities > Terminal)"
        info "2. Run: teardown"
        echo
        log "Teardown blocked - running from VS Code"
        exit 1
    fi
    
    # Check if running in Zed integrated terminal - BLOCK execution
    if [[ "${TERM_PROGRAM:-}" == "zed" ]]; then
        error "Cannot run teardown from Zed integrated terminal!"
        error "Teardown will uninstall Zed, terminating this session mid-process."
        echo
        info "Please run teardown from Terminal.app:"
        info "1. Open Terminal.app (Applications > Utilities > Terminal)"
        info "2. Run: teardown"
        echo
        log "Teardown blocked - running from Zed"
        exit 1
    fi
}

# Main teardown process
teardown_main() {
    log "Starting development environment teardown..."

    if [[ "$DRY_RUN" == "true" ]]; then
        info "Running in DRY RUN mode - no changes will be made"
    fi

    # Check for terminal conflicts
    check_terminal_warning

    if ! confirm "This will remove all development tools and configurations. Are you sure?"; then
        log "Teardown cancelled by user"
        exit 0
    fi

    # Prompt for sudo access upfront (unless dry run)
    if [[ "$DRY_RUN" != "true" ]]; then
        prompt_sudo "This teardown may require administrator privileges for some operations."
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

    # Final step: offer to remove the dotfiles repository
    if confirm "Remove the dotfiles repository itself? (This will delete $REPO_DIR)"; then
        remove_repository
    fi

    log "Teardown completed successfully!"
    info "You may need to restart your shell or terminal for changes to take effect"
}

teardown_command() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                return 0
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
                return 1
                ;;
        esac
    done

    # Ensure INSTALL_DIR is set
    if [[ -z "${INSTALL_DIR:-}" ]]; then
        print_error "INSTALL_DIR not set. Cannot locate dotfiles repository."
        print_info "Try running from the dotfiles directory or check config.env"
        return 1
    fi

    # Run main teardown
    teardown_main
}