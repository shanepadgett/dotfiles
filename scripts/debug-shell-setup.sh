#!/bin/bash

# Debug script to test shell configurations one by one

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/lib/logger.sh"

# Test function
test_app() {
    print_info "Testing if Block Goose AI agent UI opens..."
    print_info "Please try to open the app now and press Enter when done"
    read -r
}

# Confirmation
confirm() {
    local msg="$1"
    print_info "$msg [y/n]: "
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

print_header "Shell Configuration Debug Mode"

# Initial test
print_info "First, let's test if the app works right now"
test_app

# Test 1: Just the basic shell config without exports
if confirm "Test 1: Link only .zshrc (without exports)?"; then
    print_info "Temporarily moving exports directory..."
    if [[ -d "$HOME/.exports" ]]; then
        mv "$HOME/.exports" "$HOME/.exports.backup"
    fi
    test_app
    
    if confirm "Restore exports?"; then
        if [[ -d "$HOME/.exports.backup" ]]; then
            mv "$HOME/.exports.backup" "$HOME/.exports"
        fi
    fi
fi

# Test 2: Remove PATH modifications
if confirm "Test 2: Remove PATH modifications?"; then
    print_info "Temporarily removing path.sh..."
    if [[ -f "$HOME/.exports/path.sh" ]]; then
        mv "$HOME/.exports/path.sh" "$HOME/.exports/path.sh.backup"
    fi
    test_app
    
    if confirm "Restore path.sh?"; then
        if [[ -f "$HOME/.exports/path.sh.backup" ]]; then
            mv "$HOME/.exports/path.sh.backup" "$HOME/.exports/path.sh"
        fi
    fi
fi

# Test 3: Remove NODE_ENV
if confirm "Test 3: Remove NODE_ENV export?"; then
    print_info "Creating temporary development.sh without NODE_ENV..."
    if [[ -f "$HOME/.exports/development.sh" ]]; then
        cp "$HOME/.exports/development.sh" "$HOME/.exports/development.sh.backup"
        grep -v "NODE_ENV" "$HOME/.exports/development.sh.backup" > "$HOME/.exports/development.sh" || true
    fi
    test_app
    
    if confirm "Restore development.sh?"; then
        if [[ -f "$HOME/.exports/development.sh.backup" ]]; then
            mv "$HOME/.exports/development.sh.backup" "$HOME/.exports/development.sh"
        fi
    fi
fi

print_success "Debug session complete!"
print_info "Based on which test made the app work, we can identify the problem."