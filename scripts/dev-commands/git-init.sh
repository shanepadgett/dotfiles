#!/bin/bash

# Git project initialization command
# Creates a new project with git repo, README, .gitignore, and initial commit

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

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
    
    # Create project directory if it doesn't exist
    if [[ ! -d "$project_name" ]]; then
        print_info "Creating project directory: $project_name"
        mkdir -p "$project_name"
    fi
    
    cd "$project_name"
    
    # Initialize git if not already a repo
    if [[ ! -d ".git" ]]; then
        print_info "Initializing git repository..."
        git init
        print_success "Git repository initialized"
    else
        print_warning "Git repository already exists"
    fi
    
    # Create basic files if they don't exist
    if [[ ! -f "README.md" ]]; then
        print_info "Creating README.md..."
        cat > README.md << EOF
# $project_name

${description:-A new project}

## Getting Started

TODO: Add setup instructions

## Development

TODO: Add development instructions

## Contributing

TODO: Add contribution guidelines
EOF
        print_success "README.md created"
    fi
    
    if [[ ! -f ".gitignore" ]]; then
        print_info "Creating .gitignore..."
        cat > .gitignore << EOF
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Dependencies
node_modules/
vendor/

# Build outputs
dist/
build/
*.o
*.so
*.dylib

# Environment files
.env
.env.local
.env.*.local
EOF
        print_success ".gitignore created"
    fi
    
    # Stage and commit files
    print_info "Staging files for initial commit..."
    git add .
    
    print_info "Creating initial commit..."
    git commit -m "Initial commit

- Add README.md with project structure
- Add comprehensive .gitignore
- Set up basic project foundation"
    
    print_success "Initial commit created"
    print_info "Project initialized in: $(pwd)"
    print_info "Next steps:"
    echo "  1. Add remote: git remote add origin <repository-url>"
    echo "  2. Push to remote: git push -u origin main"
    echo "  3. Create first PR: pr"
}

# Main execution
main() {
    git_init_command "$@"
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi