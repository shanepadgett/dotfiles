#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Source configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
source "$ROOT_DIR/config/config.env"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y-%m-%d-%H%M%S)"
LOG_FILE="$HOME/config.log"

# Functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# Logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Create backup directory
create_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        print_info "Creating backup directory: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        log "Created backup directory: $BACKUP_DIR"
        print_success "Backup directory created"
    else
        print_info "Backup directory already exists: $BACKUP_DIR"
    fi
}

# Backup existing file/directory
backup_existing() {
    local target="$1"
    local backup_name="$(basename "$target")"

    if [[ -e "$target" || -L "$target" ]]; then
        # If it's already a symlink pointing to our config, skip backup
        if [[ -L "$target" ]]; then
            local link_target="$(readlink "$target")"
            if [[ "$link_target" == "$CONFIG_SHELL_DIR"* ]]; then
                print_info "Skipping backup of $target (already linked to config)"
                return 0
            fi
        fi

        print_info "Backing up existing $target"
        cp -r "$target" "$BACKUP_DIR/$backup_name"
        log "Backed up $target to $BACKUP_DIR/$backup_name"
        return 0
    fi

    return 0
}

# Create symlink with conflict detection
create_symlink() {
    local source="$1"
    local target="$2"
    local display_name="${3:-$target}"

    # Check if source exists
    if [[ ! -e "$source" ]]; then
        print_warning "Source file not found: $source"
        log "WARNING: Source file not found: $source"
        return 1
    fi

    # Check if target already exists
    if [[ -e "$target" || -L "$target" ]]; then
        # If it's a broken symlink, remove it
        if [[ -L "$target" && ! -e "$target" ]]; then
            print_info "Removing broken symlink: $target"
            rm "$target"
            log "Removed broken symlink: $target"
        else
            # Backup existing file/directory
            backup_existing "$target"
            rm -rf "$target"
        fi
    fi

    # Create parent directory if needed
    local parent_dir="$(dirname "$target")"
    if [[ ! -d "$parent_dir" ]]; then
        mkdir -p "$parent_dir"
        log "Created directory: $parent_dir"
    fi

    # Create symlink
    ln -s "$source" "$target"
    print_success "Linked $display_name"
    log "Created symlink: $target -> $source"
}

# Setup shell configurations
setup_shell_configs() {
    print_header "Setting up shell configurations"

    # .zshrc
    if [[ -f "$CONFIG_SHELL_DIR/zshrc" ]]; then
        create_symlink "$CONFIG_SHELL_DIR/zshrc" "$HOME/.zshrc" ".zshrc"
    fi

    # .bashrc
    if [[ -f "$CONFIG_SHELL_DIR/bashrc" ]]; then
        create_symlink "$CONFIG_SHELL_DIR/bashrc" "$HOME/.bashrc" ".bashrc"
    fi

    # .aliases
    if [[ -f "$CONFIG_SHELL_DIR/aliases" ]]; then
        create_symlink "$CONFIG_SHELL_DIR/aliases" "$HOME/.aliases" ".aliases"
    fi

    # .exports directory
    if [[ -d "$CONFIG_SHELL_DIR/exports" ]]; then
        create_symlink "$CONFIG_SHELL_DIR/exports" "$HOME/.exports" ".exports"
    fi
}

# Setup zoxide configuration
setup_zoxide() {
    print_header "Setting up zoxide configuration"

    if [[ -d "$INSTALL_DIR/config/tools/zoxide" ]]; then
        create_symlink "$INSTALL_DIR/config/tools/zoxide" "$HOME/.config/zoxide" "zoxide config"
    fi
}

# Setup VS Code configuration
setup_vscode() {
    print_header "Setting up VS Code configuration"

    # VS Code settings location varies by platform
    local vscode_dir="$HOME/Library/Application Support/Code/User"

    if [[ -d "$INSTALL_DIR/config/tools/vscode" ]]; then
        # Settings
        if [[ -f "$INSTALL_DIR/config/tools/vscode/settings.json" ]]; then
            create_symlink "$INSTALL_DIR/config/tools/vscode/settings.json" "$vscode_dir/settings.json" "VS Code settings"
        fi

        # Keybindings
        if [[ -f "$INSTALL_DIR/config/tools/vscode/keybindings.json" ]]; then
            create_symlink "$INSTALL_DIR/config/tools/vscode/keybindings.json" "$vscode_dir/keybindings.json" "VS Code keybindings"
        fi

        # Snippets
        if [[ -d "$INSTALL_DIR/config/tools/vscode/snippets" ]]; then
            create_symlink "$INSTALL_DIR/config/tools/vscode/snippets" "$vscode_dir/snippets" "VS Code snippets"
        fi
    fi
}

# Setup Zed configuration
setup_zed() {
    print_header "Setting up Zed configuration"

    # Zed config location
    local zed_dir="$HOME/.config/zed"

    if [[ -d "$INSTALL_DIR/config/tools/zed" ]]; then
        create_symlink "$INSTALL_DIR/config/tools/zed" "$zed_dir" "Zed config"
    fi
}

# Setup Ghostty configuration
setup_ghostty() {
    print_header "Setting up Ghostty configuration"

    # Ghostty config location
    local ghostty_dir="$HOME/.config/ghostty"

    if [[ -d "$INSTALL_DIR/config/tools/ghostty" ]]; then
        create_symlink "$INSTALL_DIR/config/tools/ghostty" "$ghostty_dir" "Ghostty config"
    elif [[ -f "$INSTALL_DIR/config/tools/ghostty.conf" ]]; then
        # Some users might have a single config file
        create_symlink "$INSTALL_DIR/config/tools/ghostty.conf" "$HOME/.config/ghostty/config" "Ghostty config"
    fi
}

# Setup Claude Code configuration
setup_claude_code() {
    print_header "Setting up Claude Code configuration"

    # Claude Code config location (may vary)
    local claude_dir="$HOME/.config/claude-code"

    if [[ -d "$INSTALL_DIR/config/tools/claude-code" ]]; then
        create_symlink "$INSTALL_DIR/config/tools/claude-code" "$claude_dir" "Claude Code config"
    fi
}

# Setup OpenCode configuration
setup_opencode() {
    print_header "Setting up OpenCode configuration"

    # OpenCode config location (may vary)
    local opencode_dir="$HOME/.config/opencode"

    if [[ -d "$INSTALL_DIR/config/tools/opencode" ]]; then
        create_symlink "$INSTALL_DIR/config/tools/opencode" "$opencode_dir" "OpenCode config"
    fi
}

# Setup development utilities
setup_dev_utils() {
    print_header "Setting up development utilities"

    # Create ~/.local/bin if it doesn't exist
    mkdir -p "$HOME/.local/bin"

    # Create symlinks for development utilities
    local dev_utils_script="$ROOT_DIR/scripts/dev-utils.sh"
    
    if [[ -f "$dev_utils_script" ]]; then
        # Make the script executable
        chmod +x "$dev_utils_script"
        
        # Create individual symlinks for each command
        create_symlink "$dev_utils_script" "$HOME/.local/bin/git-init" "git-init command"
        create_symlink "$dev_utils_script" "$HOME/.local/bin/pr" "pr command"
        create_symlink "$dev_utils_script" "$HOME/.local/bin/dev" "dev command"
        create_symlink "$dev_utils_script" "$HOME/.local/bin/update-configs" "update-configs command"
        create_symlink "$dev_utils_script" "$HOME/.local/bin/reset-configs" "reset-configs command"
        
        print_success "Development utilities installed"
        print_info "Available commands: git-init, pr, dev, update-configs, reset-configs"
        print_info "Commands are organized in modular files under scripts/dev-commands/"
    else
        print_warning "Development utilities script not found: $dev_utils_script"
    fi
}

# Clean up broken symlinks
cleanup_broken_symlinks() {
    print_header "Cleaning up broken symlinks"

    local found_broken=0

    # Check common locations for broken symlinks
    local locations=(
        "$HOME/.zshrc"
        "$HOME/.bashrc"
        "$HOME/.config/zoxide"
        "$HOME/.config/zed"
        "$HOME/.config/ghostty"
        "$HOME/.config/claude-code"
        "$HOME/.config/opencode"
        "$HOME/Library/Application Support/Code/User/settings.json"
        "$HOME/Library/Application Support/Code/User/keybindings.json"
        "$HOME/Library/Application Support/Code/User/snippets"
    )

    for location in "${locations[@]}"; do
        if [[ -L "$location" && ! -e "$location" ]]; then
            print_info "Removing broken symlink: $location"
            rm "$location"
            log "Removed broken symlink: $location"
            ((found_broken++))
        fi
    done

    if [[ $found_broken -eq 0 ]]; then
        print_success "No broken symlinks found"
    else
        print_success "Removed $found_broken broken symlink(s)"
    fi
}

# Main execution
main() {
    print_header "Shell Configuration Setup"

    log "Starting shell configuration setup"

    # Check if shell directory exists
    if [[ ! -d "$CONFIG_SHELL_DIR" ]]; then
        print_error "Shell directory not found: $CONFIG_SHELL_DIR"
        log "ERROR: Shell directory not found: $CONFIG_SHELL_DIR"
        exit 1
    fi

    # Create backup directory
    create_backup_dir

    # Clean up any broken symlinks first
    cleanup_broken_symlinks

    # Setup configurations
    setup_shell_configs
    setup_zoxide
    setup_vscode
    setup_zed
    setup_ghostty
    setup_claude_code
    setup_opencode
    setup_dev_utils

    # Final summary
    echo
    print_header "Shell Configuration Setup Complete"
    print_success "All shell configurations have been linked successfully!"
    print_info "Backups saved to: $BACKUP_DIR"
    print_info "Restart your terminal for shell changes to take effect"

    log "Shell configuration setup completed successfully"
}

# Run main function
main "$@"
