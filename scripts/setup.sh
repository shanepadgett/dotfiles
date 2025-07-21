#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$HOME/.mac-setup.log"

# Options
DRY_RUN=false
SKIP_DOTFILES=false
SKIP_APPS=false

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

# Parse command line options
parse_options() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --skip-dotfiles)
                SKIP_DOTFILES=true
                shift
                ;;
            --skip-apps)
                SKIP_APPS=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --dry-run        Show what would be done without making changes"
                echo "  --skip-dotfiles  Skip dotfiles setup"
                echo "  --skip-apps      Skip application installation"
                echo "  -h, --help       Show this help message"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                echo "Run '$0 --help' for usage information"
                exit 1
                ;;
        esac
    done
}

# Create log file with header
init_log() {
    echo "===========================================" >> "$LOG_FILE"
    echo "Mac Setup Installation - $(date)" >> "$LOG_FILE"
    echo "===========================================" >> "$LOG_FILE"
    log "Starting installation with options: DRY_RUN=$DRY_RUN, SKIP_DOTFILES=$SKIP_DOTFILES, SKIP_APPS=$SKIP_APPS"
}

# Install Homebrew packages
install_homebrew_packages() {
    print_header "Installing Homebrew Packages"
    
    if [[ "$SKIP_APPS" == true ]]; then
        print_info "Skipping application installation (--skip-apps flag)"
        log "Skipped Homebrew installation due to --skip-apps flag"
        return 0
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "DRY RUN: Would install packages from Brewfile"
        brew bundle check --file="$ROOT_DIR/Brewfile" --verbose
        return 0
    fi
    
    print_info "Installing packages from Brewfile..."
    cd "$ROOT_DIR"
    
    if brew bundle install --file="$ROOT_DIR/Brewfile"; then
        print_success "Homebrew packages installed successfully"
        log "Homebrew bundle install completed successfully"
    else
        print_error "Some Homebrew packages failed to install"
        log "ERROR: Homebrew bundle install had failures"
        print_warning "Check the log above for details"
        # Continue execution even if some packages fail
    fi
}

# Install AI coding tools
install_ai_tools() {
    print_header "Installing AI Coding Tools"
    
    if [[ "$SKIP_APPS" == true ]]; then
        print_info "Skipping AI tools installation (--skip-apps flag)"
        log "Skipped AI tools installation due to --skip-apps flag"
        return 0
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "DRY RUN: Would install AI coding tools"
        print_info "  - Claude Code via curl"
        print_info "  - OpenCode via curl"
        return 0
    fi
    
    # Run the AI tools installation script
    if [[ -x "$SCRIPT_DIR/install-ai-tools.sh" ]]; then
        print_info "Running AI tools installation script..."
        if "$SCRIPT_DIR/install-ai-tools.sh"; then
            print_success "AI tools installation completed"
            log "AI tools installation completed successfully"
        else
            print_warning "Some AI tools failed to install"
            log "WARNING: AI tools installation had failures"
        fi
    else
        print_warning "AI tools installation script not found or not executable"
        log "WARNING: install-ai-tools.sh not found at $SCRIPT_DIR/install-ai-tools.sh"
    fi
}

# Setup dotfiles
setup_dotfiles() {
    print_header "Setting Up Dotfiles"
    
    if [[ "$SKIP_DOTFILES" == true ]]; then
        print_info "Skipping dotfiles setup (--skip-dotfiles flag)"
        log "Skipped dotfiles setup due to --skip-dotfiles flag"
        return 0
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "DRY RUN: Would setup dotfiles"
        return 0
    fi
    
    # Check if dotfiles setup script exists
    if [[ -x "$SCRIPT_DIR/setup-dotfiles.sh" ]]; then
        print_info "Running dotfiles setup..."
        if "$SCRIPT_DIR/setup-dotfiles.sh"; then
            print_success "Dotfiles setup completed"
            log "Dotfiles setup completed successfully"
        else
            print_error "Dotfiles setup failed"
            log "ERROR: Dotfiles setup failed"
            return 1
        fi
    else
        print_warning "Dotfiles setup script not found yet"
        print_info "Run './scripts/setup-dotfiles.sh' when it's created"
        log "WARNING: setup-dotfiles.sh not found at $SCRIPT_DIR/setup-dotfiles.sh"
    fi
}

# Main installation
main() {
    print_header "Mac Setup Installation"
    
    # Parse options
    parse_options "$@"
    
    # Initialize log
    init_log
    
    # Check if we're in the right directory
    if [[ ! -f "$ROOT_DIR/Brewfile" ]]; then
        print_error "Brewfile not found. Are you running this from the correct directory?"
        log "ERROR: Brewfile not found at $ROOT_DIR/Brewfile"
        exit 1
    fi
    
    # Install Homebrew packages
    install_homebrew_packages
    
    # Install AI tools
    install_ai_tools
    
    # Setup dotfiles
    setup_dotfiles
    
    # Final summary
    echo
    print_header "Installation Summary"
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "DRY RUN completed - no changes were made"
    else
        print_success "Mac setup installation completed!"
        print_info "Check the log for details: $LOG_FILE"
        
        if [[ "$SKIP_APPS" == false ]]; then
            print_info "Applications installed via Homebrew"
        fi
        
        if [[ "$SKIP_DOTFILES" == false ]]; then
            if [[ -x "$SCRIPT_DIR/setup-dotfiles.sh" ]]; then
                print_info "Dotfiles configured"
            else
                print_warning "Dotfiles setup pending (script not found)"
            fi
        fi
    fi
    
    log "Installation completed"
}

# Run main function
main "$@"