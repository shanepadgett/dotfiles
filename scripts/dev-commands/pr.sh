#!/bin/zsh

# Pull request creation command
# Creates GitHub pull requests using the gh CLI

set -euo pipefail

# Source configuration for installation paths
# shellcheck disable=SC1091
source "$HOME/.dotfiles/config/config.env"

# Source common utilities from the actual installation directory
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/dev-commands/common.sh"

# Create a pull request using gh CLI
pr_command() {
  local title="${1:-}"
  local draft="${2:-false}"

  print_header "Creating Pull Request"

  # Check prerequisites
  check_github_cli || return 1
  check_git_repo || return 1
  check_git_commits || return 1

  # Get current branch
  local current_branch
  current_branch=$(git branch --show-current)
  if [[ $current_branch == "main" || $current_branch == "master" ]]; then
    print_warning "You're on the main branch. Consider creating a feature branch first."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      print_info "Cancelled"
      return 0
    fi
  fi

  # Auto-generate title if not provided
  if [[ -z $title ]]; then
    local last_commit
    last_commit=$(git log -1 --pretty=format:"%s")
    title="$last_commit"
    print_info "Using last commit message as title: $title"
  fi

  # Create PR
  local pr_args=("--title" "$title")

  if [[ $draft == "true" ]]; then
    pr_args+=("--draft")
    print_info "Creating draft pull request..."
  else
    print_info "Creating pull request..."
  fi

  # Add body with commit messages since main/master
  local base_branch="main"
  if git show-ref --verify --quiet refs/heads/master; then
    base_branch="master"
  fi

  local body
  body="## Changes

$(git log --oneline ${base_branch}..HEAD | sed 's/^/- /')

## Test Plan

- [ ] Manual testing completed
- [ ] All tests pass
- [ ] Code review completed"

  pr_args+=("--body" "$body")

  if gh pr create "${pr_args[@]}"; then
    print_success "Pull request created successfully"
    gh pr view --web
  else
    print_error "Failed to create pull request"
    return 1
  fi
}

# Main execution
main() {
  pr_command "$@"
}

# Only run main if script is executed directly (not sourced)
if [[ $0 == *pr.sh ]]; then
  main "$@"
fi
