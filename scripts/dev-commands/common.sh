#!/bin/bash

# Common utilities for development commands
# This file is sourced by other command scripts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Get the current directory name (for project detection)
get_project_name() {
    basename "$(pwd)"
}

# Detect project type based on files in current directory
detect_project_type() {
    local project_type=""
    local use_docker=false
    
    # Prioritize Docker Compose if available
    if [[ -f "docker-compose.yml" || -f "docker-compose.yaml" || -f "compose.yml" || -f "compose.yaml" ]]; then
        project_type="Docker Compose"
        use_docker=true
    elif [[ -f "Dockerfile" ]]; then
        project_type="Docker"
        use_docker=true
    elif [[ -f "deno.json" || -f "deno.jsonc" ]]; then
        project_type="Deno"
    elif [[ -f "package.json" ]]; then
        # Check if it's a Deno project in package.json
        if grep -q '"deno"' package.json 2>/dev/null; then
            project_type="Deno"
        else
            project_type="Node.js"
        fi
    elif [[ -f "requirements.txt" || -f "pyproject.toml" || -f "setup.py" ]]; then
        project_type="Python"
    elif [[ -f "mix.exs" ]]; then
        project_type="Elixir"
        # Check if it's a Phoenix project
        if grep -q "phoenix" mix.exs 2>/dev/null; then
            project_type="Elixir Phoenix"
        fi
    elif [[ -f "Cargo.toml" ]]; then
        project_type="Rust"
    elif [[ -f "go.mod" ]]; then
        project_type="Go"
    elif [[ -f ".git/config" ]]; then
        project_type="Git repository"
    fi
    
    # Return both project type and docker flag
    echo "$project_type|$use_docker"
}

# Check if project has development files
has_project_files() {
    local result=$(detect_project_type)
    local project_type="${result%|*}"
    [[ -n "$project_type" ]]
}

# Get project type only
get_project_type() {
    local result=$(detect_project_type)
    echo "${result%|*}"
}

# Check if project should use Docker
should_use_docker() {
    local result=$(detect_project_type)
    local use_docker="${result#*|}"
    [[ "$use_docker" == "true" ]]
}

# Check if OrbStack is available
check_orbstack() {
    if ! command_exists orb; then
        print_error "OrbStack CLI (orb) is not installed"
        print_info "Install OrbStack from: https://orbstack.dev"
        return 1
    fi
    return 0
}

# Check if GitHub CLI is available
check_github_cli() {
    if ! command_exists gh; then
        print_error "GitHub CLI (gh) is not installed"
        print_info "Install with: brew install gh"
        return 1
    fi
    return 0
}

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        return 1
    fi
    return 0
}

# Check if there are any commits in the repo
check_git_commits() {
    if ! git log --oneline -1 > /dev/null 2>&1; then
        print_error "No commits found. Make some commits first."
        return 1
    fi
    return 0
}