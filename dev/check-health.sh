#!/bin/zsh

# Health check script to verify installation state
# Usage: ./dev/check-health.sh

set -euo pipefail

# Check if running in dev container environment
if ! ([ -f /.dockerenv ] || [ -n "$REMOTE_CONTAINERS" ] || [ -n "$CODESPACES" ] || [ -n "$DEVCONTAINER" ]); then
  echo "❌ This script requires the dev container environment"
  echo "Please open this project in a dev container and try again."
  echo "The dev container includes required tools for health checking."
  exit 1
fi

# Source centralized logging system
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/logger.sh"

log_header "Mac Setup Health Check"
echo

# Check Homebrew
if command -v brew &>/dev/null; then
  log_success "Homebrew is installed"
  log_info "Version: $(brew --version | head -1)"
else
  log_error "Homebrew is not installed"
fi

# Check Brewfile packages
echo
log_step "Checking Brewfile packages"
if [ -f "Brewfile" ]; then
  if brew bundle check --file=Brewfile 2>/dev/null; then
    log_success "All Brewfile packages are installed"
  else
    log_warning "Some Brewfile packages are missing"
  fi
else
  log_warning "Brewfile not found"
fi

# Check symlinks
echo
log_step "Checking symlinks"

check_symlink() {
  local source="$1"
  local target="$2"
  local description="$3"

  if [ -L "$target" ]; then
    if [ "$(readlink "$target")" = "$source" ]; then
      log_success "$description"
    else
      log_warning "$description (points to wrong location)"
    fi
  elif [ -e "$target" ]; then
    log_warning "$description (exists but not a symlink)"
  else
    log_error "$description (missing)"
  fi
}

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
# shellcheck disable=SC1091
source "$ROOT_DIR/config/config.env"

check_symlink "$CONFIG_SHELL_DIR/zshrc" "$HOME/.zshrc" "Zsh configuration"
check_symlink "$CONFIG_SHELL_DIR/bashrc" "$HOME/.bashrc" "Bash configuration"
check_symlink "$CONFIG_TOOLS_DIR/vscode" "$HOME/.config/Code/User" "VS Code settings"
check_symlink "$CONFIG_TOOLS_DIR/zed" "$HOME/.config/zed" "Zed settings"
check_symlink "$CONFIG_TOOLS_DIR/ghostty" "$HOME/.config/ghostty" "Ghostty configuration"
check_symlink "$CONFIG_TOOLS_DIR/direnv" "$HOME/.config/direnv" "direnv configuration"

# Check applications
echo
log_step "Checking applications"

apps=(
  "Raycast:/Applications/Raycast.app"
  "Ghostty:/Applications/Ghostty.app"
  "Zed:/Applications/Zed.app"
  "VS Code:/Applications/Visual Studio Code.app"
  "Discord:/Applications/Discord.app"
  "Brave:/Applications/Brave Browser.app"
  "Rectangle:/Applications/Rectangle.app"
  "Obsidian:/Applications/Obsidian.app"
  "1Password:/Applications/1Password.app"
)

for app in "${apps[@]}"; do
  IFS=':' read -r name path <<<"$app"
  if [ -d "$path" ]; then
    log_success "$name"
  else
    log_error "$name"
  fi
done

# Check CLI tools
echo
log_step "Checking CLI tools"

tools=(
  "zsh:zsh --version"
  "zoxide:zoxide --version"
  "gh:gh --version"
  "bruno:bruno --version"
)

for tool in "${tools[@]}"; do
  IFS=':' read -r name _ <<<"$tool"
  if command -v "$name" &>/dev/null; then
    log_success "$name"
  else
    log_error "$name"
  fi
done

# Check log file
echo
log_step "Checking log file"
if [ -f "$HOME/config.log" ]; then
  log_success "Log file exists"
  log_info "Last update: $(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$HOME/config.log")"
else
  log_warning "Log file not found"
fi

echo
log_header "Health check complete"
