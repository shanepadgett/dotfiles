#!/bin/bash

# Git project initialization command
# Creates a new project with git repo, README, .gitignore, and initial commit

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

# Check if git user configuration is set
check_git_user_config() {
    local git_name=$(git config user.name 2>/dev/null)
    local git_email=$(git config user.email 2>/dev/null)

    if [ -z "$git_name" ] || [ -z "$git_email" ]; then
        print_error "Git user configuration is not set"
        print_info "Please configure your git user name and email:"
        print_info "  git config --global user.name \"Your Name\""
        print_info "  git config --global user.email \"your.email@example.com\""
        return 1
    fi
    return 0
}

# Create project directory and navigate to it
setup_project_directory() {
    local project_name="$1"

    if [[ ! -d "$project_name" ]]; then
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

        if [[ -f "$template_path" ]]; then
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

        if [[ -f "$template_path" ]]; then
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

# Display next steps
show_next_steps() {
    print_info "Project initialized in: $(pwd)"
    print_info "Next steps:"
    echo "  1. Add remote: git remote add origin <repository-url>"
    echo "  2. Push to remote: git push -u origin main"
    echo "  3. Create first PR: pr"
}

# Initialize a new git project with first commit
git_init_command() {
    local project_name="${1:-}"
    local description="${2:-}"

    if [[ -z "$project_name" ]]; then
        print_error "Project name is required"
        echo "Usage: git-init <project-name> [description]"
        return 1
    fi

    print_header "Initializing Git Project: $project_name"

    setup_project_directory "$project_name"
    initialize_git_repo
    create_readme "$project_name" "$description"
    create_gitignore
    create_initial_commit
    show_next_steps
}

# Main execution
main() {
    git_init_command "$@"
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
