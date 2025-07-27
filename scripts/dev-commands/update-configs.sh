#!/bin/bash

# Update dotfiles configuration
# Pulls latest changes and re-runs setup

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/common.sh"

# Configuration
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Debug path resolution
if [[ ! -f "$ROOT_DIR/config/config.env" ]]; then
    echo "ERROR: Cannot find config.env at $ROOT_DIR/config/config.env"
    echo "SCRIPT_DIR: $SCRIPT_DIR"
    echo "ROOT_DIR: $ROOT_DIR"
    exit 1
fi

source "$ROOT_DIR/config/config.env"

update_configs_command() {
    local skip_apps=false
    local dry_run=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-apps)
                skip_apps=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            -h|--help)
                echo "Usage: update-configs [OPTIONS]"
                echo
                echo "Update dotfiles configuration from repository"
                echo
                echo "OPTIONS:"
                echo "  --skip-apps     Skip application installation/updates"
                echo "  --dry-run       Show what would be done without making changes"
                echo "  -h, --help      Show this help message"
                echo
                echo "EXAMPLES:"
                echo "  update-configs                # Full update"
                echo "  update-configs --skip-apps    # Update configs only"
                echo "  update-configs --dry-run      # Preview changes"
                return 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Run 'update-configs --help' for usage information"
                return 1
                ;;
        esac
    done
    
    print_header "Updating Dotfiles Configuration"
    
    # Ensure INSTALL_DIR is set
    if [[ -z "${INSTALL_DIR:-}" ]]; then
        print_error "INSTALL_DIR not set. Cannot locate dotfiles repository."
        print_info "Try running from the dotfiles directory or check config.env"
        return 1
    fi
    
    # Check if we're in a git repository
    if [[ ! -d "$INSTALL_DIR/.git" ]]; then
        print_error "Dotfiles directory is not a git repository: $INSTALL_DIR"
        print_info "Try running the full install script instead"
        return 1
    fi
    
    # Change to dotfiles directory
    cd "$INSTALL_DIR"
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        print_warning "You have uncommitted changes in your dotfiles repository"
        print_info "Current changes:"
        git status --porcelain
        echo
        read -p "Continue with update? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Update cancelled"
            return 0
        fi
    fi
    
    # Fetch and pull latest changes
    print_info "Fetching latest changes from repository..."
    
    if [[ "$dry_run" == true ]]; then
        print_info "DRY RUN: Would fetch and pull latest changes"
        git fetch --dry-run origin 2>/dev/null || true
        local current_branch=$(git branch --show-current)
        local behind_count=$(git rev-list --count HEAD..origin/"$current_branch" 2>/dev/null || echo "0")
        if [[ "$behind_count" -gt 0 ]]; then
            print_info "DRY RUN: Would pull $behind_count commit(s) from origin/$current_branch"
        else
            print_info "DRY RUN: Already up to date"
        fi
    else
        git fetch origin
        
        local current_branch=$(git branch --show-current)
        local behind_count=$(git rev-list --count HEAD..origin/"$current_branch" 2>/dev/null || echo "0")
        
        if [[ "$behind_count" -gt 0 ]]; then
            print_info "Pulling $behind_count new commit(s)..."
            git pull origin "$current_branch"
            print_success "Repository updated"
        else
            print_success "Already up to date"
        fi
    fi
    
    # Build setup command arguments
    local setup_args=()
    if [[ "$skip_apps" == true ]]; then
        setup_args+=("--skip-apps")
    fi
    if [[ "$dry_run" == true ]]; then
        setup_args+=("--dry-run")
    fi
    
    # Re-run setup
    print_info "Re-running setup with updated configuration..."
    
    if [[ -f "$INSTALL_DIR/scripts/setup.sh" ]]; then
        bash "$INSTALL_DIR/scripts/setup.sh" "${setup_args[@]}"
    else
        print_error "Setup script not found at $INSTALL_DIR/scripts/setup.sh"
        return 1
    fi
    
    print_header "Configuration Update Complete"
    print_success "Dotfiles configuration has been updated successfully!"
    
    if [[ "$dry_run" == false ]]; then
        print_info "Restart your terminal for shell changes to take effect"
        print_info "Log file: ~/config.log"
    fi
}