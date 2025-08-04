#!/bin/bash

set -euo pipefail

# Source configuration and logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
# shellcheck disable=SC1091
source "$ROOT_DIR/config/config.env"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/logger.sh"

BACKUP_DIR="$HOME/.config-backup-$(date +%Y-%m-%d-%H%M%S)"
LOG_FILE="$HOME/config.log"

# Enhanced logging with file output
log() {
  log_to_file "$LOG_FILE" "$1"
}

# Create backup directory
create_backup_dir() {
  if [[ ! -d $BACKUP_DIR ]]; then
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
  local backup_name
  backup_name="$(basename "$target")"

  if [[ -e $target || -L $target ]]; then
    # If it's already a symlink pointing to our config, skip backup
    if [[ -L $target ]]; then
      local link_target
      link_target="$(readlink "$target")"
      if [[ $link_target == "$CONFIG_SHELL_DIR"* ]]; then
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

# Calculate relative path from target to source
# This ensures symlinks work across different environments (host/container)
get_relative_path() {
  local source="$1"
  local target="$2"

  # Get absolute paths
  local source_abs
  source_abs="$(cd "$(dirname "$source")" && pwd)/$(basename "$source")"
  local target_dir
  target_dir="$(dirname "$target")"

  # Calculate relative path using Python for reliability
  python3 -c "
import os
import sys
source = sys.argv[1]
target_dir = sys.argv[2]
rel_path = os.path.relpath(source, target_dir)
print(rel_path)
" "$source_abs" "$target_dir" 2>/dev/null || echo "$source"
}

# Create symlink with conflict detection
create_symlink() {
  local source="$1"
  local target="$2"
  local display_name="${3:-$target}"

  # Check if source exists
  if [[ ! -e $source ]]; then
    print_warning "Source file not found: $source"
    log "WARNING: Source file not found: $source"
    return 1
  fi

  # Check if target already exists
  if [[ -e $target || -L $target ]]; then
    # If it's a broken symlink, remove it
    if [[ -L $target && ! -e $target ]]; then
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
  local parent_dir
  parent_dir="$(dirname "$target")"
  if [[ ! -d $parent_dir ]]; then
    mkdir -p "$parent_dir"
    log "Created directory: $parent_dir"
  fi

  # Calculate relative path for the symlink
  local relative_source
  relative_source=$(get_relative_path "$source" "$target")

  # Create symlink with relative path
  ln -s "$relative_source" "$target"
  print_success "Linked $display_name"
  log "Created symlink: $target -> $relative_source (relative)"
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

  # .functions directory
  if [[ -d "$CONFIG_SHELL_DIR/functions" ]]; then
    create_symlink "$CONFIG_SHELL_DIR/functions" "$HOME/.functions" ".functions"
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

# Setup Ripgrep configuration
setup_ripgrep() {
  print_header "Setting up Ripgrep configuration"

  if [[ -f "$INSTALL_DIR/config/tools/ripgreprc" ]]; then
    create_symlink "$INSTALL_DIR/config/tools/ripgreprc" "$HOME/.ripgreprc" "Ripgrep config"
  fi
}

# Setup Git configuration
setup_git() {
  print_header "Setting up Git configuration"

  # Symlink the main gitconfig
  if [[ -f "$INSTALL_DIR/config/tools/gitconfig" ]]; then
    create_symlink "$INSTALL_DIR/config/tools/gitconfig" "$HOME/.gitconfig" "Git config"
  fi

  # Create local config with 1Password data
  if command -v op &>/dev/null && op vault list >/dev/null 2>&1; then
    if git_name=$(op read "op://Personal/Git Config/name" 2>/dev/null) &&
      git_email=$(op read "op://Personal/Git Config/email" 2>/dev/null); then

      cat >"$HOME/.gitconfig.local" <<EOF
[user]
    name = $git_name
    email = $git_email
EOF
      print_success "Git credentials configured from 1Password"
      print_info "Name: $git_name"
      print_info "Email: $git_email"
    else
      print_warning "Git config not found in 1Password"
      print_info "Please add 'Git Config' item to 1Password with 'name' and 'email' fields"
      print_info "Or manually create ~/.gitconfig.local with your git user settings"
    fi
  else
    print_warning "1Password CLI not available or not authenticated"
    print_info "Please manually create ~/.gitconfig.local with your git user settings"
    print_info "Example content:"
    print_info "[user]"
    print_info "    name = Your Name"
    print_info "    email = your.email@example.com"
  fi
}

# Setup Claude settings
setup_claude() {
  print_header "Setting up Claude settings"

  # Claude settings location
  local claude_dir="$HOME/.claude"

  # Create .claude directory if it doesn't exist
  if [[ ! -d $claude_dir ]]; then
    mkdir -p "$claude_dir"
    log "Created directory: $claude_dir"
  fi

  if [[ -f "$INSTALL_DIR/config/tools/claude/settings.json" ]]; then
    create_symlink "$INSTALL_DIR/config/tools/claude/settings.json" "$claude_dir/settings.json" "Claude settings"
  fi

  if [[ -f "$INSTALL_DIR/config/tools/claude/mcp.json" ]]; then
    create_symlink "$INSTALL_DIR/config/tools/claude/mcp.json" "$claude_dir/mcp.json" "Claude MCP config"
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

  if [[ -f $dev_utils_script ]]; then
    # Make the script executable
    chmod +x "$dev_utils_script"

    # Create individual symlinks for each command
    create_symlink "$dev_utils_script" "$HOME/.local/bin/git-init" "git-init command"
    create_symlink "$dev_utils_script" "$HOME/.local/bin/pr" "pr command"
    create_symlink "$dev_utils_script" "$HOME/.local/bin/dev" "dev command"
    create_symlink "$dev_utils_script" "$HOME/.local/bin/update-configs" "update-configs command"
    create_symlink "$dev_utils_script" "$HOME/.local/bin/reset-configs" "reset-configs command"
    create_symlink "$dev_utils_script" "$HOME/.local/bin/teardown" "teardown command"

    print_success "Development utilities installed"
    print_info "Available commands: git-init, pr, dev, update-configs, reset-configs, teardown"
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
    "$HOME/.aliases"
    "$HOME/.exports"
    "$HOME/.functions"
    "$HOME/.config/zoxide"
    "$HOME/.config/zed"
    "$HOME/.config/ghostty"
    "$HOME/.claude/settings.json"
    "$HOME/.config/claude-code"
    "$HOME/.config/opencode"
    "$HOME/Library/Application Support/Code/User/settings.json"
    "$HOME/Library/Application Support/Code/User/keybindings.json"
    "$HOME/Library/Application Support/Code/User/snippets"
  )

  for location in "${locations[@]}"; do
    if [[ -L $location && ! -e $location ]]; then
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
  if [[ ! -d $CONFIG_SHELL_DIR ]]; then
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
  setup_git
  setup_zoxide
  setup_ripgrep
  setup_vscode
  setup_zed
  setup_ghostty
  setup_claude
  setup_claude_code
  setup_opencode
  setup_dev_utils

  # Final summary
  print_header "Shell Configuration Setup Complete"
  print_success "All shell configurations have been linked successfully!"
  print_info "Backups saved to: $BACKUP_DIR"
  print_info "Restart your terminal for shell changes to take effect"

  log "Shell configuration setup completed successfully"
}

# Run main function
main "$@"
