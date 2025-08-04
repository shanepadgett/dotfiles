#!/bin/bash

# Git project initialization command
# Creates a new project with git repo, README, .gitignore, and initial commit

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

# Check if git user configuration is set
check_git_user_config() {
  local git_name
  local git_email
  git_name=$(git config user.name 2>/dev/null)
  git_email=$(git config user.email 2>/dev/null)

  if [ -z "$git_name" ] || [ -z "$git_email" ]; then
    print_error "Git user configuration is not set"
    print_info "Please configure your git user name and email:"
    print_info '  git config --global user.name "Your Name"'
    print_info '  git config --global user.email "your.email@example.com"'
    return 1
  fi
  return 0
}

# Check if GitHub CLI is authenticated
check_github_auth() {
  if ! check_github_cli; then
    return 1
  fi

  if ! gh auth status &>/dev/null; then
    print_error "GitHub CLI is not authenticated"
    print_info "Please authenticate with GitHub:"
    print_info "  gh auth login"
    return 1
  fi

  print_success "GitHub CLI is authenticated"
  return 0
}

# Create project directory and navigate to it
setup_project_directory() {
  local project_name="$1"

  if [[ ! -d $project_name ]]; then
    print_info "Creating project directory: $project_name"
    mkdir -p "$project_name"
  fi

  cd "$project_name"
}

# Initialize git repository
initialize_git_repo() {
  if [[ ! -d ".git" ]]; then
    print_info "Initializing git repository..."
    git init
    print_success "Git repository initialized"
  else
    print_warning "Git repository already exists"
  fi
}

# Create README.md file
create_readme() {
  local project_name="$1"
  local description="$2"

  if [[ ! -f "README.md" ]]; then
    print_info "Creating README.md..."
    local template_path="$SCRIPT_DIR/../../templates/README.md"

    if [[ -f $template_path ]]; then
      cp "$template_path" "README.md"
      # Replace placeholders in the template
      sed -i '' "s/PROJECT_NAME/$project_name/g" "README.md"
      sed -i '' "s/PROJECT_DESCRIPTION/${description:-A new project}/g" "README.md"
      print_success "README.md created from template"
    else
      print_error "README template not found at $template_path"
      print_error "Template may have been moved or deleted"
      return 1
    fi
  fi
}

# Create .gitignore file
create_gitignore() {
  if [[ ! -f ".gitignore" ]]; then
    print_info "Creating .gitignore..."
    local template_path="$SCRIPT_DIR/../../templates/gitignore"

    if [[ -f $template_path ]]; then
      cp "$template_path" ".gitignore"
      print_success ".gitignore created from template"
    else
      print_error "Gitignore template not found at $template_path"
      print_error "Template may have been moved or deleted"
      return 1
    fi
  fi
}

# Create initial commit
create_initial_commit() {
  # Check if git user configuration is set before committing
  if ! check_git_user_config; then
    return 1
  fi

  print_info "Staging files for initial commit..."
  git add .

  print_info "Creating initial commit..."
  git commit -m "Initial commit

- Add README.md with project structure
- Add comprehensive .gitignore
- Set up basic project foundation"

  print_success "Initial commit created"
}

# Interactive prompt for repository details
prompt_for_repo_details() {
  # shellcheck disable=SC2178
  local -n details_ref=$1

  # Project name
  while true; do
    echo
    read -r -p "Repository name: " 'details_ref[name]'
    if [[ -n ${details_ref[name]} ]]; then
      # Validate repository name (basic GitHub rules)
      if [[ ${details_ref[name]} =~ ^[a-zA-Z0-9._-]+$ ]]; then
        break
      else
        print_error "Repository name can only contain alphanumeric characters, dots, dashes, and underscores"
      fi
    else
      print_error "Repository name is required"
    fi
  done

  # Description
  echo
  read -r -p "Description (optional): " 'details_ref[description]'

  # Visibility
  echo
  print_info "Repository visibility:"
  echo "  1) Public (anyone can see)"
  echo "  2) Private (only you and collaborators)"
  echo "  3) Internal (organization members only)"
  while true; do
    read -r -p "Choose visibility [1-3]: " visibility_choice
    case $visibility_choice in
      1)
        details_ref['visibility']="public"
        break
        ;;
      2)
        details_ref['visibility']="private"
        break
        ;;
      3)
        details_ref['visibility']="internal"
        break
        ;;
      *) print_error "Please choose 1, 2, or 3" ;;
    esac
  done

  # Template options
  echo
  print_info "Template options:"
  echo "  1) Create from existing template repository"
  echo "  2) Create standard repository"
  echo "  3) Create repository to be used as template"
  while true; do
    read -r -p "Choose template option [1-3]: " template_choice
    case $template_choice in
      1)
        details_ref['template_mode']="from"
        read -r -p "Template repository (owner/repo): " 'details_ref[template_repo]'
        break
        ;;
      2)
        details_ref['template_mode']="none"
        break
        ;;
      3)
        details_ref['template_mode']="as"
        break
        ;;
      *) print_error "Please choose 1, 2, or 3" ;;
    esac
  done

  # Directory location
  echo
  print_info "Project location:"
  echo "  1) Create in current directory"
  echo "  2) Create in new subdirectory ./${details_ref[name]}"
  while true; do
    read -r -p "Choose location [1-2]: " location_choice
    case $location_choice in
      1)
        details_ref['location']="current"
        break
        ;;
      2)
        details_ref['location']="subdirectory"
        break
        ;;
      *) print_error "Please choose 1 or 2" ;;
    esac
  done

  # GitHub features
  echo
  print_info "GitHub repository features:"
  read -r -p "Add README.md? [Y/n]: " add_readme
  details_ref['add_readme']=$([ "${add_readme,,}" != "n" ] && echo "true" || echo "false")

  read -r -p "Add .gitignore? [Y/n]: " add_gitignore
  details_ref['add_gitignore']=$([ "${add_gitignore,,}" != "n" ] && echo "true" || echo "false")

  if [[ ${details_ref[add_gitignore]} == "true" ]]; then
    read -r -p "Gitignore template (e.g., Node, Python, Go) [blank for general]: " 'details_ref[gitignore_template]'
  fi
}

# Create GitHub repository using GitHub CLI
create_github_repo() {
  # shellcheck disable=SC2178
  local -n repo_details=$1

  print_info "Creating GitHub repository: ${repo_details[name]}"

  # Build gh repo create command
  local gh_command="gh repo create ${repo_details[name]}"

  # Add visibility flag
  gh_command+=" --${repo_details[visibility]}"

  # Add description if provided
  if [[ -n ${repo_details[description]} ]]; then
    gh_command+=" --description \"${repo_details[description]}\""
  fi

  # Handle template creation (FROM template)
  if [[ ${repo_details[template_mode]} == "from" && -n ${repo_details[template_repo]} ]]; then
    gh_command+=" --template ${repo_details[template_repo]}"
  fi

  # Add GitHub-managed files only if not using a template
  if [[ ${repo_details[template_mode]} != "from" ]]; then
    if [[ ${repo_details[add_readme]} == "true" ]]; then
      gh_command+=" --add-readme"
    fi

    if [[ ${repo_details[add_gitignore]} == "true" ]]; then
      if [[ -n ${repo_details[gitignore_template]} ]]; then
        gh_command+=" --gitignore ${repo_details[gitignore_template]}"
      else
        gh_command+=" --gitignore"
      fi
    fi
  fi

  # Clone the repository locally
  gh_command+=" --clone"

  # Execute the command
  print_info "Running: $gh_command"
  if eval "$gh_command"; then
    print_success "GitHub repository created successfully"
    return 0
  else
    print_error "Failed to create GitHub repository"
    return 1
  fi
}

# Setup remote origin (if not already done by --clone)
setup_remote_origin() {
  local repo_name="$1"

  # Check if origin already exists
  if git remote get-url origin &>/dev/null; then
    print_success "Remote origin already configured"
    return 0
  fi

  # Get the authenticated user's GitHub username
  local github_user
  github_user=$(gh api user --jq '.login' 2>/dev/null || true)

  if [[ -n $github_user ]]; then
    local repo_url="https://github.com/${github_user}/${repo_name}.git"
    print_info "Adding remote origin: $repo_url"
    git remote add origin "$repo_url"
    print_success "Remote origin configured"
  else
    print_warning "Could not determine GitHub username. Remote origin not configured."
    return 1
  fi
}

# Handle template repository setup
handle_template_setup() {
  # shellcheck disable=SC2178
  local -n repo_details=$1

  if [[ ${repo_details[template_mode]} == "as" ]]; then
    print_info "Repository will be marked as template..."
    print_warning "GitHub CLI doesn't support marking repositories as templates during creation"
    print_info "You'll need to manually enable this in GitHub settings after creation"

    # Store template instructions for later display
    repo_details['needs_template_setup']="true"
  fi
}

# Display next steps
show_next_steps() {
  # shellcheck disable=SC2178
  local -n repo_details=$1

  print_info "Project initialized in: $(pwd)"
  print_info "GitHub repository: https://github.com/$(gh api user --jq '.login' 2>/dev/null)/${repo_details[name]}"

  echo
  print_info "Next steps:"

  # Show template setup instructions if needed
  if [[ ${repo_details[needs_template_setup]} == "true" ]]; then
    echo "  1. Mark repository as template:"
    echo "     - Visit: https://github.com/$(gh api user --jq '.login' 2>/dev/null)/${repo_details[name]}/settings"
    echo "     - Check 'Template repository' option"
    echo "  2. Make changes and commit: git add . && git commit -m 'Update'"
    echo "  3. Push changes: git push"
    echo "  4. Create pull requests: pr"
  else
    echo "  1. Make changes and commit: git add . && git commit -m 'Your changes'"
    echo "  2. Push changes: git push"
    echo "  3. Create pull requests: pr"
  fi

  echo
  print_success "Repository setup complete!"
}

# Initialize a new git project with GitHub integration
git_init_command() {
  # Check prerequisites
  if ! check_git_user_config || ! check_github_auth; then
    return 1
  fi

  print_header "GitHub Repository Creation Wizard"

  # Declare associative array for repository details
  declare -A repo_details

  # Get repository details from user
  prompt_for_repo_details repo_details

  echo
  print_header "Creating Repository: ${repo_details[name]}"

  # Handle directory setup based on user preference
  if [[ ${repo_details[location]} == "subdirectory" ]]; then
    setup_project_directory "${repo_details[name]}"
  fi

  # Handle template setup notifications
  handle_template_setup repo_details

  # Create GitHub repository (this will clone it locally)
  if ! create_github_repo repo_details; then
    print_error "Failed to create GitHub repository"
    return 1
  fi

  # Navigate to the cloned directory
  cd "${repo_details[name]}" || {
    print_error "Failed to navigate to cloned repository"
    return 1
  }

  # If not using a template and GitHub didn't create files, create them locally
  if [[ ${repo_details[template_mode]} != "from" ]]; then
    if [[ ${repo_details[add_readme]} == "false" ]]; then
      create_readme "${repo_details[name]}" "${repo_details[description]}"
    fi

    if [[ ${repo_details[add_gitignore]} == "false" ]]; then
      create_gitignore
    fi

    # Create initial commit if we added local files
    if [[ ${repo_details[add_readme]} == "false" || ${repo_details[add_gitignore]} == "false" ]]; then
      create_initial_commit
    fi
  fi

  # Show next steps and completion
  show_next_steps repo_details
}

# Main execution
main() {
  git_init_command "$@"
}

# Only run main if script is executed directly (not sourced)
if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  main "$@"
fi
