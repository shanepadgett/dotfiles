#!/bin/bash

set -euo pipefail

# Default installation directory (can be overridden by config.env later)
INSTALL_DIR="$HOME/.dotfiles"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/shanepadgett/dotfiles.git"

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
    echo -e "${BLUE}ℹ $1${NC}"
}

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
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════╗"
    echo "║       Mac Setup Installer v1.0        ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${NC}"

    print_info "Starting Mac setup process..."

    # Run checks and installation
    check_macos
    install_homebrew
    install_git
    setup_repository
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
