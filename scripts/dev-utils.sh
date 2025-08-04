#!/bin/zsh

# Development utilities dispatcher
# Routes commands to appropriate specialized scripts

set -euo pipefail

# No longer need script directory calculation since we use absolute paths

# Source configuration for INSTALL_DIR
# Always use the standard dotfiles location
# shellcheck disable=SC1091
source "$HOME/.dotfiles/config/config.env"

# Source common utilities from the actual installation directory
# Use INSTALL_DIR from config.env to locate common.sh correctly
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/dev-commands/common.sh"

# Store the original script name for later use (since $0 changes in functions)
SCRIPT_NAME="$0"

# Get the command name from how the script was called
get_command_name() {
  # Use the stored script name to avoid issues with $0 changing in functions
  if [[ -n ${SCRIPT_NAME:-} ]]; then
    local cmd_name
    cmd_name=$(basename "$SCRIPT_NAME")
    echo "$cmd_name"
  else
    local cmd_name
    cmd_name=$(basename "$0")
    echo "$cmd_name"
  fi
}

# Main function to route commands based on script name
main() {
  local command_name
  command_name=$(get_command_name)

  case "$command_name" in
    "pr")
      # shellcheck disable=SC1091
      source "$INSTALL_DIR/scripts/dev-commands/pr.sh"
      pr_command "$@"
      ;;
    "dev")
      # shellcheck disable=SC1091
      source "$INSTALL_DIR/scripts/dev-commands/dev.sh"
      dev_command "$@"
      ;;
    "update-configs")
      # shellcheck disable=SC1091
      source "$INSTALL_DIR/scripts/dev-commands/update-configs.sh"
      update_configs_command "$@"
      ;;
    "reset-configs")
      # shellcheck disable=SC1091
      source "$INSTALL_DIR/scripts/dev-commands/reset-configs.sh"
      reset_configs_command "$@"
      ;;
    "teardown")
      # shellcheck disable=SC1091
      source "$INSTALL_DIR/scripts/dev-commands/teardown.sh"
      teardown_command "$@"
      ;;
    "dev-utils.sh")
      # If called directly, show help
      print_header "Development Utilities"
      echo "This script provides multiple commands:"
      echo "  git-init <name> [desc]    Initialize new git project with first commit (shell function)"
      echo "  pr [title]                Create pull request using gh CLI"
      echo "  dev [action] [project]    Manage development environments"
      echo "  delete-repo [name|.] [opt] Delete repository locally and on GitHub (shell function)"
      echo "  update-configs [opts]     Update dotfiles from repository"
      echo "  reset-configs [opts]      Reset dotfiles to repository state"
      echo "  teardown [opts]           Remove dotfiles and applications"
      echo
      echo "Commands are organized in modular files:"
      echo "  config/shell/functions/git-init.sh (shell function)"
      echo "  scripts/dev-commands/pr.sh"
      echo "  scripts/dev-commands/dev.sh"
      echo "  scripts/dev-commands/common.sh (shared utilities)"
      echo
      echo "Create symlinks to use these commands:"
      echo "  ln -sf ${INSTALL_DIR:-\$INSTALL_DIR}/scripts/dev-utils.sh ~/.local/bin/pr"
      echo "  ln -sf ${INSTALL_DIR:-\$INSTALL_DIR}/scripts/dev-utils.sh ~/.local/bin/dev"
      echo "  ln -sf ${INSTALL_DIR:-\$INSTALL_DIR}/scripts/dev-utils.sh ~/.local/bin/update-configs"
      echo "  ln -sf ${INSTALL_DIR:-\$INSTALL_DIR}/scripts/dev-utils.sh ~/.local/bin/reset-configs"
      echo "  ln -sf ${INSTALL_DIR:-\$INSTALL_DIR}/scripts/dev-utils.sh ~/.local/bin/teardown"
      ;;
    *)
      print_error "Unknown command: $command_name"
      return 1
      ;;
  esac
}

# Only run main if script is executed directly (not sourced)
# Check if script is being executed (not sourced)
# Handle both direct execution and symlinked execution
if [[ $0 == *dev-utils.sh ]] || [[ $0 == */pr ]] || [[ $0 == */dev ]] || [[ $0 == */update-configs ]] || [[ $0 == */reset-configs ]] || [[ $0 == */teardown ]]; then
  main "$@"
fi
