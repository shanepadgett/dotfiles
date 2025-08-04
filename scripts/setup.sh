#!/bin/zsh

set -euo pipefail

# Source centralized logging system
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/logger.sh"

# Script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$HOME/config.log"

# Options
DRY_RUN=false
SKIP_SHELL=false
SKIP_APPS=false

# Legacy compatibility functions are now provided by logger.sh

# Logging
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >>"$LOG_FILE"
}

# Parse command line options
parse_options() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --skip-shell)
        SKIP_SHELL=true
        shift
        ;;
      --skip-apps)
        SKIP_APPS=true
        shift
        ;;
      -h | --help)
        echo "Usage: $0 [OPTIONS]"
        echo "Options:"
        echo "  --dry-run        Show what would be done without making changes"
        echo "  --skip-shell     Skip shell configuration setup"
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
  {
    echo "==========================================="
    echo "Mac Setup Installation - $(date)"
    echo "==========================================="
  } >>"$LOG_FILE"
  log "Starting installation with options: DRY_RUN=$DRY_RUN, SKIP_SHELL=$SKIP_SHELL, SKIP_APPS=$SKIP_APPS"
}

# Install Homebrew packages
install_homebrew_packages() {
  print_header "Installing Homebrew Packages"

  if [[ $SKIP_APPS == true ]]; then
    print_info "Skipping application installation (--skip-apps flag)"
    log "Skipped Homebrew installation due to --skip-apps flag"
    return 0
  fi

  if [[ $DRY_RUN == true ]]; then
    print_info "DRY RUN: Would install packages from Brewfile"
    brew bundle check --file="$ROOT_DIR/Brewfile" --verbose
    return 0
  fi

  # Ensure sudo credentials are available for Homebrew operations
  if check_sudo_askpass 2>/dev/null; then
    print_info "Using cached credentials for Homebrew installation..."
  else
    print_info "Refreshing sudo credentials before Homebrew installation..."
    sudo -v
  fi

  print_info "Installing packages from Brewfile..."
  cd "$ROOT_DIR"

  # Run brew bundle and capture output
  local brew_output
  local brew_exit_code

  brew_output=$(brew bundle install --file="$ROOT_DIR/Brewfile" 2>&1)
  brew_exit_code=$?

  # Log the full output
  echo "$brew_output" >>"$LOG_FILE"

  if [[ $brew_exit_code -eq 0 ]]; then
    print_success "Homebrew packages installed successfully"
    log "Homebrew bundle install completed successfully"
  else
    print_warning "Some Homebrew packages had issues during installation"
    log "WARNING: Homebrew bundle install exit code: $brew_exit_code"

    # Show specific failures if any
    if echo "$brew_output" | grep -q "Error\|Failed"; then
      print_info "Failed packages:"
      echo "$brew_output" | grep -E "Error|Failed" | head -5
    fi

    print_info "Check $LOG_FILE for full details"
    # Continue execution even if some packages fail
  fi
}

# Setup 1Password for CLI integration
setup_1password() {
  print_header "Setting up 1Password Integration"

  if [[ $DRY_RUN == true ]]; then
    print_info "DRY RUN: Would setup 1Password integration"
    return 0
  fi

  # Check if 1Password was installed
  if ! brew list --cask 1password &>/dev/null; then
    print_warning "1Password not found - skipping integration setup"
    return 0
  fi

  # Launch 1Password for initial setup
  print_info "Launching 1Password for initial setup..."
  print_warning "Please sign in to 1Password and complete setup before continuing"
  open -a "1Password 7 - Password Manager" || open -a "1Password" 2>/dev/null || true

  # Wait for user confirmation
  echo
  print_info "Press ENTER after you've signed in to 1Password..."
  read -r </dev/tty
  echo

  # Guide user to enable CLI integration
  print_info "Setting up 1Password CLI integration..."
  print_warning "Please enable 'Integrate with 1Password CLI' in 1Password app:"
  print_info "1. Open 1Password app"
  print_info "2. Go to Settings > Developer"
  print_info "3. Check 'Integrate with 1Password CLI'"
  print_info "4. Enable Touch ID if desired"
  echo
  print_info "Press ENTER after enabling CLI integration..."
  read -r </dev/tty
  echo

  # Test authentication
  print_info "Testing 1Password CLI authentication..."
  if command -v op &>/dev/null && op vault list >/dev/null 2>&1; then
    print_success "✅ 1Password CLI authentication successful"
    log "1Password CLI authentication successful"
  else
    print_warning "⚠️  1Password CLI authentication test failed"
    print_info "This is okay - git configuration will be set up later during shell setup"
    log "WARNING: 1Password CLI authentication test failed"
  fi
}

# Install AI coding tools
install_ai_tools() {
  print_header "Installing AI Coding Tools"

  if [[ $SKIP_APPS == true ]]; then
    print_info "Skipping AI tools installation (--skip-apps flag)"
    log "Skipped AI tools installation due to --skip-apps flag"
    return 0
  fi

  if [[ $DRY_RUN == true ]]; then
    print_info "DRY RUN: Would install AI coding tools"
    print_info "  - Claude Code via curl"
    print_info "  - OpenCode via curl"
    return 0
  fi

  # Run the AI tools installation script
  if [[ -f "$SCRIPT_DIR/install-ai-tools.sh" ]]; then
    print_info "Running AI tools installation script..."
    chmod +x "$SCRIPT_DIR/install-ai-tools.sh"
    if "$SCRIPT_DIR/install-ai-tools.sh"; then
      print_success "AI tools installation completed"
      log "AI tools installation completed successfully"
    else
      print_warning "Some AI tools failed to install"
      log "WARNING: AI tools installation had failures"
    fi
  else
    print_warning "AI tools installation script not found"
    log "WARNING: install-ai-tools.sh not found at $SCRIPT_DIR/install-ai-tools.sh"
  fi
}

# Create development directories
create_development_directories() {
  print_header "Creating Development Directories"

  if [[ $DRY_RUN == true ]]; then
    print_info "DRY RUN: Would create development directories"
    print_info "  - ~/Development"
    print_info "  - ~/Development/personal"
    print_info "  - ~/Development/open-source"
    print_info "  - ~/Development/experiments"
    print_info "  - ~/Development/work"
    return 0
  fi

  local dev_dirs=(
    "$HOME/Development"
    "$HOME/Development/personal"
    "$HOME/Development/open-source"
    "$HOME/Development/experiments"
    "$HOME/Development/work"
  )

  for dir in "${dev_dirs[@]}"; do
    if [[ ! -d $dir ]]; then
      print_info "Creating directory: $dir"
      mkdir -p "$dir"
      log "Created directory: $dir"
    else
      print_info "Directory already exists: $dir"
      log "Directory already exists: $dir"
    fi
  done

  print_success "Development directories created"
}

# Setup shell configurations
setup_shell() {
  print_header "Setting Up Shell Configurations"

  if [[ $SKIP_SHELL == true ]]; then
    print_info "Skipping shell setup (--skip-shell flag)"
    log "Skipped shell setup due to --skip-shell flag"
    return 0
  fi

  if [[ $DRY_RUN == true ]]; then
    print_info "DRY RUN: Would setup shell configurations"
    return 0
  fi

  # Check if shell setup script exists
  if [[ -f "$SCRIPT_DIR/setup-shell.sh" ]]; then
    print_info "Running shell setup..."
    chmod +x "$SCRIPT_DIR/setup-shell.sh"
    if "$SCRIPT_DIR/setup-shell.sh"; then
      print_success "Shell setup completed"
      log "Shell setup completed successfully"
    else
      print_error "Shell setup failed"
      log "ERROR: Shell setup failed"
      return 1
    fi
  else
    print_warning "Shell setup script not found"
    print_info "Run './scripts/setup-shell.sh' when it's created"
    log "WARNING: setup-shell.sh not found at $SCRIPT_DIR/setup-shell.sh"
  fi
}

# Configure macOS system defaults
configure_macos_defaults() {
  print_header "Configuring macOS System Defaults"

  if [[ $DRY_RUN == true ]]; then
    print_info "DRY RUN: Would configure macOS defaults"
    print_info "  - Dock autohide and application setup"
    print_info "  - Trackpad navigation settings"
    print_info "  - Finder preferences"
    return 0
  fi

  # Check if macOS defaults script exists
  if [[ -f "$SCRIPT_DIR/configure-macos-defaults.sh" ]]; then
    print_info "Running macOS defaults configuration..."
    chmod +x "$SCRIPT_DIR/configure-macos-defaults.sh"
    if "$SCRIPT_DIR/configure-macos-defaults.sh"; then
      print_success "macOS defaults configured"
      log "macOS defaults configuration completed successfully"
    else
      print_warning "macOS defaults configuration had issues"
      log "WARNING: macOS defaults configuration failed"
    fi
  else
    print_warning "macOS defaults script not found"
    log "WARNING: configure-macos-defaults.sh not found at $SCRIPT_DIR/configure-macos-defaults.sh"
  fi
}

# Main installation
main() {
  print_header "Mac Setup Installation"

  # Parse options
  parse_options "$@"

  # Initialize log
  init_log

  # Initialize or refresh sudo credentials using askpass
  if [[ -f "$SCRIPT_DIR/lib/sudo-helper.sh" ]]; then
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/lib/sudo-helper.sh"
    if ! check_sudo_askpass; then
      init_sudo_askpass "System configuration requires administrator privileges."
    else
      print_info "Using cached administrator credentials from keychain"
    fi

    # Clean up credentials on exit
    trap "cleanup_sudo_askpass; trap - EXIT" EXIT
  else
    # Fallback to traditional sudo refresh
    print_info "Refreshing sudo credentials for system configuration..."
    sudo -v
  fi

  # Check if we're in the right directory
  if [[ ! -f "$ROOT_DIR/Brewfile" ]]; then
    print_error "Brewfile not found. Are you running this from the correct directory?"
    log "ERROR: Brewfile not found at $ROOT_DIR/Brewfile"
    exit 1
  fi

  # Install Homebrew packages with retry
  local retry_count=0
  local max_retries=3

  while [ $retry_count -lt $max_retries ]; do
    if install_homebrew_packages; then
      break
    else
      retry_count=$((retry_count + 1))
      if [ $retry_count -lt $max_retries ]; then
        print_warning "Retrying Homebrew installation (attempt $retry_count/$max_retries)..."
        sleep 5
      else
        print_error "Homebrew installation failed after $max_retries attempts"
      fi
    fi
  done

  # Setup 1Password integration
  setup_1password

  # Create development directories
  create_development_directories

  # Setup shell configurations
  setup_shell

  # Install AI tools (after shell setup so they can inject into shell configs)
  install_ai_tools

  # Configure macOS defaults
  configure_macos_defaults

  # Final summary
  echo
  print_header "Installation Summary"

  if [[ $DRY_RUN == true ]]; then
    print_info "DRY RUN completed - no changes were made"
  else
    print_success "Mac setup installation completed!"
    print_info "Check the log for details: $LOG_FILE"

    if [[ $SKIP_APPS == false ]]; then
      print_info "Applications installed via Homebrew"
    fi

    if [[ $SKIP_SHELL == false ]]; then
      if [[ -f "$SCRIPT_DIR/setup-shell.sh" ]]; then
        print_info "Shell configurations setup"
      else
        print_warning "Shell setup pending (script not found)"
      fi
    fi
  fi

  log "Installation completed"
}

# Run main function
main "$@"
