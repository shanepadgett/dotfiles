#!/bin/zsh

# Reset dotfiles configuration to repository state
# Discards local changes and resets to HEAD

set -euo pipefail

# Source configuration for installation paths
# shellcheck disable=SC1091
source "$HOME/.dotfiles/config/config.env"

# Source common utilities from the actual installation directory
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/dev-commands/common.sh"

# Configuration
ROOT_DIR="$INSTALL_DIR"

# Debug path resolution
if [[ ! -f "$ROOT_DIR/config/config.env" ]]; then
  echo "ERROR: Cannot find config.env at $ROOT_DIR/config/config.env"
  echo "SCRIPT_DIR: $SCRIPT_DIR"
  echo "ROOT_DIR: $ROOT_DIR"
  exit 1
fi

# shellcheck disable=SC1091
source "$ROOT_DIR/config/config.env"

reset_configs_command() {
  local force=false
  local dry_run=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --force)
        force=true
        shift
        ;;
      --dry-run)
        dry_run=true
        shift
        ;;
      -h | --help)
        echo "Usage: reset-configs [OPTIONS]"
        echo
        echo "Reset dotfiles configuration to repository state"
        echo "Discards all local changes and resets to HEAD"
        echo
        echo "OPTIONS:"
        echo "  --force         Skip confirmation prompts"
        echo "  --dry-run       Show what would be reset without making changes"
        echo "  -h, --help      Show this help message"
        echo
        echo "EXAMPLES:"
        echo "  reset-configs                # Interactive reset with confirmation"
        echo "  reset-configs --force        # Reset without confirmation"
        echo "  reset-configs --dry-run      # Preview what would be reset"
        echo
        echo "WARNING: This will permanently discard all uncommitted changes!"
        return 0
        ;;
      *)
        print_error "Unknown option: $1"
        echo "Run 'reset-configs --help' for usage information"
        return 1
        ;;
    esac
  done

  print_header "Resetting Dotfiles Configuration"

  # Ensure INSTALL_DIR is set
  if [[ -z ${INSTALL_DIR:-} ]]; then
    print_error "INSTALL_DIR not set. Cannot locate dotfiles repository."
    print_info "Try running from the dotfiles directory or check config.env"
    return 1
  fi

  # Check if we're in a git repository
  if [[ ! -d "$INSTALL_DIR/.git" ]]; then
    print_error "Dotfiles directory is not a git repository: $INSTALL_DIR"
    print_info "Cannot reset a non-git directory"
    return 1
  fi

  # Change to dotfiles directory
  cd "$INSTALL_DIR"

  # Check if there are any changes to reset
  if git diff-index --quiet HEAD -- 2>/dev/null && [[ -z "$(git ls-files --others --exclude-standard)" ]]; then
    print_success "Repository is already clean - no changes to reset"
    return 0
  fi

  # Show what would be reset
  print_info "Current repository status:"
  git status --porcelain
  echo

  if [[ $dry_run == true ]]; then
    print_info "DRY RUN: Would reset the following:"
    print_info "  - Discard all modified files"
    print_info "  - Remove all untracked files"
    print_info "  - Reset to HEAD commit"
    return 0
  fi

  # Confirmation unless --force
  if [[ $force != true ]]; then
    print_warning "This will permanently discard ALL uncommitted changes!"
    print_warning "Modified files will be reset to their repository state"
    print_warning "Untracked files will be deleted"
    echo
    read -p "Are you sure you want to continue? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      print_info "Reset cancelled"
      return 0
    fi
  fi

  # Perform the reset
  print_info "Resetting repository to HEAD..."

  # Reset all tracked files to HEAD
  if git reset --hard HEAD; then
    print_success "Reset tracked files to HEAD"
  else
    print_error "Failed to reset tracked files"
    return 1
  fi

  # Remove untracked files and directories
  if git clean -fd; then
    print_success "Removed untracked files and directories"
  else
    print_warning "Some untracked files could not be removed"
  fi

  # Final status check
  if git diff-index --quiet HEAD -- 2>/dev/null && [[ -z "$(git ls-files --others --exclude-standard)" ]]; then
    print_header "Reset Complete"
    print_success "Repository has been reset to a clean state!"
    print_info "All local changes have been discarded"
  else
    print_warning "Repository may not be completely clean"
    print_info "Current status:"
    git status --short
  fi
}
