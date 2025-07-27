#!/bin/bash

# Sudo helper functions using askpass with keychain storage

KEYCHAIN_SERVICE="dotfiles-sudo"
KEYCHAIN_ACCOUNT="$(whoami)"
ASKPASS_SCRIPT="$(dirname "${BASH_SOURCE[0]}")/sudo-askpass.sh"

# Initialize sudo with askpass
init_sudo_askpass() {
    local message="${1:-This operation requires administrator privileges.}"
    
    # Make askpass script executable
    chmod +x "$ASKPASS_SCRIPT"
    
    # Set environment for sudo askpass
    export SUDO_ASKPASS="$ASKPASS_SCRIPT"
    
    print_info "$message"
    print_info "Please enter your password when prompted..."
    
    # Test sudo access and store password in keychain
    if sudo -A true 2>/dev/null; then
        print_success "Administrator credentials cached in keychain"
        return 0
    else
        print_error "Failed to cache administrator credentials"
        return 1
    fi
}

# Clean up keychain entry
cleanup_sudo_askpass() {
    print_info "Cleaning up cached credentials..."
    security delete-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" 2>/dev/null || true
    unset SUDO_ASKPASS
}

# Run command with sudo using askpass
sudo_askpass() {
    if [[ -n "${SUDO_ASKPASS:-}" ]]; then
        sudo -A "$@"
    else
        print_error "Sudo askpass not initialized. Call init_sudo_askpass first."
        return 1
    fi
}

# Check if sudo credentials are available
check_sudo_askpass() {
    if [[ -n "${SUDO_ASKPASS:-}" ]] && security find-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}