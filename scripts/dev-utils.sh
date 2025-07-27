#!/bin/bash

# Development utilities dispatcher
# Routes commands to appropriate specialized scripts

set -euo pipefail

# Get the directory of this script (resolve symlinks)
SCRIPT_DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
COMMANDS_DIR="$SCRIPT_DIR/dev-commands"

# Source common utilities
source "$COMMANDS_DIR/common.sh"

# Get the command name from how the script was called
get_command_name() {
    basename "$0"
}

# Main function to route commands based on script name
main() {
    local command_name=$(get_command_name)
    
    case "$command_name" in
        "git-init")
            source "$COMMANDS_DIR/git-init.sh"
            git_init_command "$@"
            ;;
        "pr")
            source "$COMMANDS_DIR/pr.sh"
            pr_command "$@"
            ;;
        "dev")
            source "$COMMANDS_DIR/dev.sh"
            dev_command "$@"
            ;;
        "dev-utils.sh")
            # If called directly, show help
            print_header "Development Utilities"
            echo "This script provides multiple commands:"
            echo "  git-init <name> [desc]    Initialize new git project with first commit"
            echo "  pr [title]                Create pull request using gh CLI"
            echo "  dev [action] [project]    Manage development environments"
            echo
            echo "Commands are organized in modular files:"
            echo "  scripts/dev-commands/git-init.sh"
            echo "  scripts/dev-commands/pr.sh"
            echo "  scripts/dev-commands/dev.sh"
            echo "  scripts/dev-commands/common.sh (shared utilities)"
            echo
            echo "Create symlinks to use these commands:"
            echo "  ln -sf ~/.dotfiles/scripts/dev-utils.sh ~/.local/bin/git-init"
            echo "  ln -sf ~/.dotfiles/scripts/dev-utils.sh ~/.local/bin/pr"
            echo "  ln -sf ~/.dotfiles/scripts/dev-utils.sh ~/.local/bin/dev"
            ;;
        *)
            print_error "Unknown command: $command_name"
            return 1
            ;;
    esac
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi