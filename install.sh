#!/bin/bash

set -euo pipefail

# Default installation directory (can be overridden by config.env later)
INSTALL_DIR="$HOME/.dotfiles"

# Source centralized logging system
source_logger() {
    local logger_file="$INSTALL_DIR/scripts/lib/logger.sh"
    if [[ -f "$logger_file" ]]; then
        source "$logger_file"
    else
        # Fallback colors if logger not available yet
        if [[ -z "${LOG_RED:-}" ]]; then
            LOG_RED='\033[1;91m'
            LOG_GREEN='\033[1;92m'
            LOG_YELLOW='\033[1;93m'
            LOG_BLUE='\033[1;94m'
            LOG_CYAN='\033[1;96m'
            LOG_BOLD='\033[1m'
            LOG_RESET='\033[0m'
        fi

        log_info() { echo -e "${LOG_CYAN}[INFO]${LOG_RESET} $1"; }
        log_success() { echo -e "${LOG_GREEN}[SUCCESS]${LOG_RESET} $1"; }
        log_error() { echo -e "${LOG_RED}[ERROR]${LOG_RESET} $1"; }
        log_warning() { echo -e "${LOG_YELLOW}[WARNING]${LOG_RESET} $1"; }
        log_header() { echo -e "${LOG_BLUE}[SECTION]${LOG_RESET} ${LOG_BOLD}$1${LOG_RESET}"; }

        # Legacy compatibility
        print_success() { log_success "$1"; }
        print_error() { log_error "$1"; }
        print_warning() { log_warning "$1"; }
        print_info() { log_info "$1"; }
        print_header() { log_header "$1"; }
    fi
}

# Configuration
REPO_URL="https://github.com/shanepadgett/dotfiles.git"

# Source common utilities if available (after repository setup)
source_common_utils() {
    local common_file="$INSTALL_DIR/scripts/dev-commands/common.sh"
    if [[ -f "$common_file" ]]; then
        source "$common_file"
    fi
}

# Initialize logging (will use fallback until repository is cloned)
source_logger

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only."
        exit 1
    fi
    print_success "Running on macOS"
}

# Install Homebrew if not present
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_header "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH based on Mac architecture
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            # Apple Silicon Mac
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            # Intel Mac
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        print_success "Homebrew installed"
    else
        print_success "Homebrew already installed"
    fi
}

# Install Git if not present
install_git() {
    if ! command -v git &> /dev/null; then
        print_header "Installing Git"
        brew install git
        print_success "Git installed"
    else
        print_success "Git already installed"
    fi
}



# Clone or update repository
setup_repository() {
    print_header "Setting up repository"

    if [[ -d "$INSTALL_DIR" ]]; then
        print_info "Repository already exists, updating..."
        cd "$INSTALL_DIR"

        # Get current branch and update accordingly
        local current_branch=$(git branch --show-current 2>/dev/null || echo "main")
        if git pull origin "$current_branch" 2>/dev/null; then
            print_success "Repository updated from origin/$current_branch"
        else
            print_warning "Failed to pull from origin/$current_branch, trying git pull"
            if git pull; then
                print_success "Repository updated"
            else
                print_warning "Git pull failed, continuing with existing repository"
            fi
        fi
    else
        print_info "Cloning repository..."
        git clone "$REPO_URL" "$INSTALL_DIR"
        print_success "Repository cloned"

        # Now source the proper logger
        source_logger
    fi
}

# Run main setup script
run_setup() {
    print_header "Running setup"

    cd "$INSTALL_DIR"

    # Source configuration to potentially override INSTALL_DIR and set other vars
    if [[ -f "config/config.env" ]]; then
        source "config/config.env"
    fi

    if [[ -f "scripts/setup.sh" ]]; then
        bash "scripts/setup.sh" "$@"
    else
        print_error "Setup script not found at scripts/setup.sh"
        exit 1
    fi
}

# Main execution
main() {
    echo -e "${LOG_BLUE}"
    echo "╔═══════════════════════════════════════╗"
    echo "║       Mac Setup Installer v1.0        ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${LOG_RESET}"

    print_info "Starting Mac setup process..."

    # Run checks and installation
    check_macos

    # Initialize sudo with keychain-based askpass
    if [[ -f "$INSTALL_DIR/scripts/lib/sudo-helper.sh" ]]; then
        source "$INSTALL_DIR/scripts/lib/sudo-helper.sh"
        init_sudo_askpass "This installation may require administrator privileges for Homebrew and system configuration."

        # Clean up credentials on exit
        trap "cleanup_sudo_askpass" EXIT
    else
        # Fallback to traditional sudo if helper not available yet
        print_info "This installation may require administrator privileges for Homebrew and system configuration."
        print_info "Please enter your password to cache sudo credentials..."
        sudo -v
    fi

    install_homebrew
    install_git
    setup_repository

    # Source common utilities now that repository is available
    source_common_utils

    run_setup "$@"

    print_header "Setup Complete!"
    print_success "Your Mac has been configured successfully."
    print_info "Please restart your terminal for all changes to take effect."
    print_info "Log file: ~/config.log"
}

# Error handling
trap 'print_error "An error occurred. Check ~/config.log for details."' ERR

# Create log file
mkdir -p "$(dirname "$INSTALL_DIR")"
exec > >(tee -a "$HOME/config.log")
exec 2>&1

echo "=== Mac Setup Installation Log - $(date) ===" >> "$HOME/config.log"

# Run main function with all arguments
main "$@"
