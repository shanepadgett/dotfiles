#!/bin/bash

# Development environment management command
# Handles Docker Compose and OrbStack Linux machines

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

# Install language-specific tools in OrbStack machine
install_language_tools() {
    local project_name="$1"
    local project_type="$2"
    
    case "$project_type" in
        "Deno")
            print_info "Detected Deno project, installing Deno..."
            orb run "$project_name" -- curl -fsSL https://deno.land/install.sh | sh
            orb run "$project_name" -- echo 'export PATH="$HOME/.deno/bin:$PATH"' >> ~/.bashrc
            ;;
        "Node.js")
            print_info "Detected Node.js project, installing Node.js..."
            orb run "$project_name" -- curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            orb run "$project_name" -- sudo apt install -y nodejs
            ;;
        "Python")
            print_info "Detected Python project, installing Python..."
            orb run "$project_name" -- sudo apt install -y python3 python3-pip python3-venv
            ;;
        "Elixir"|"Elixir Phoenix")
            print_info "Detected Elixir project, installing Elixir and Erlang..."
            orb run "$project_name" -- sudo apt install -y erlang elixir
            orb run "$project_name" -- mix local.hex --force
            orb run "$project_name" -- mix local.rebar --force
            
            if [[ "$project_type" == "Elixir Phoenix" ]]; then
                print_info "Detected Phoenix project, installing Node.js for assets..."
                orb run "$project_name" -- curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                orb run "$project_name" -- sudo apt install -y nodejs
                orb run "$project_name" -- sudo apt install -y inotify-tools
            fi
            ;;
        "Rust")
            print_info "Detected Rust project, installing Rust..."
            orb run "$project_name" -- curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            ;;
        "Go")
            print_info "Detected Go project, installing Go..."
            orb run "$project_name" -- sudo apt install -y golang-go
            ;;
    esac
}

# Handle Docker Compose workflow
handle_docker_compose() {
    local action="$1"
    local service="${2:-}"
    
    case "$action" in
        "start"|"up")
            print_info "Starting Docker Compose services..."
            if docker compose up -d; then
                print_success "Services started successfully"
                print_info "Services are running with automatic domain names"
                print_info "Use 'dev logs' to view logs"
                print_info "Use 'dev stop' to stop services"
            else
                print_error "Failed to start Docker Compose services"
                return 1
            fi
            ;;
        "logs")
            print_info "Showing Docker Compose logs..."
            if [[ -n "$service" ]]; then
                docker compose logs -f "$service"
            else
                docker compose logs -f
            fi
            ;;
        "stop"|"down")
            print_info "Stopping Docker Compose services..."
            docker compose down
            print_success "Services stopped"
            ;;
    esac
}

# Handle OrbStack Linux machine workflow
handle_linux_machine() {
    local action="$1"
    local project_name="$2"
    local project_type="$3"
    
    case "$action" in
        "setup")
            print_info "Setting up development environment for: $project_name"
            
            if orb list | grep -q "$project_name"; then
                print_warning "Machine '$project_name' already exists"
                print_info "Use 'dev shell $project_name' to connect"
                return 0
            fi
            
            print_info "Creating new Ubuntu machine: $project_name"
            if ! orb create ubuntu "$project_name"; then
                print_error "Failed to create machine"
                return 1
            fi
            print_success "Machine '$project_name' created"
            
            print_info "Installing development tools..."
            orb run "$project_name" -- sudo apt update
            orb run "$project_name" -- sudo apt install -y git curl wget build-essential
            
            # Install language-specific tools
            install_language_tools "$project_name" "$project_type"
            
            print_success "Development environment setup complete"
            print_info "To connect: dev shell $project_name"
            ;;
        "shell")
            if orb list | grep -q "$project_name"; then
                print_info "Connecting to development environment: $project_name"
                print_info "Note: OrbStack machines are persistent and stay running"
                orb shell "$project_name"
            else
                print_error "Machine '$project_name' not found"
                print_info "Available machines:"
                orb list
                echo
                print_info "Create with: dev setup $project_name"
                print_info "Or run 'dev' to auto-detect and create if needed"
                return 1
            fi
            ;;
        "destroy")
            if orb list | grep -q "$project_name"; then
                print_warning "This will permanently delete the machine: $project_name"
                read -p "Are you sure? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    orb delete "$project_name"
                    print_success "Machine '$project_name' deleted"
                else
                    print_info "Cancelled"
                fi
            else
                print_error "Machine '$project_name' not found"
                return 1
            fi
            ;;
    esac
}

# Main dev command logic
dev_command() {
    local action="${1:-auto}"
    local project_name="${2:-}"
    
    # Check if OrbStack is available
    check_orbstack || return 1
    
    # Auto-detect project name from current directory if not provided
    if [[ -z "$project_name" && "$action" != "status" ]]; then
        project_name=$(get_project_name)
    fi
    
    case "$action" in
        "auto"|"")
            print_header "Development Environment"
            
            if has_project_files; then
                local project_type=$(get_project_type)
                print_info "Detected $project_type project: $project_name"
                
                if should_use_docker; then
                    # Use Docker/Docker Compose workflow
                    if [[ -f "docker-compose.yml" || -f "docker-compose.yaml" || -f "compose.yml" || -f "compose.yaml" ]]; then
                        handle_docker_compose "start"
                    else
                        print_info "Dockerfile detected. Build and run manually:"
                        echo "  docker build -t $project_name ."
                        echo "  docker run -it --rm $project_name"
                    fi
                else
                    # Use Linux machine workflow for non-Docker projects
                    if orb list | grep -q "$project_name"; then
                        print_info "Development environment exists for: $project_name"
                        print_info "Connecting to development environment..."
                        orb shell "$project_name"
                    else
                        print_info "No development environment found for: $project_name"
                        read -p "Create development environment? (Y/n): " -n 1 -r
                        echo
                        if [[ $REPLY =~ ^[Nn]$ ]]; then
                            print_info "Cancelled"
                            return 0
                        fi
                        handle_linux_machine "setup" "$project_name" "$project_type"
                        if [[ $? -eq 0 ]]; then
                            print_info "Setup complete. Connecting to environment..."
                            orb shell "$project_name"
                        fi
                    fi
                fi
            else
                # No project files detected, show status
                print_info "No project files detected in current directory"
                print_info "OrbStack status:"
                orb status
                print_info "Available machines:"
                orb list
                echo
                print_info "To create a development environment: dev setup [project-name]"
                print_info "To connect to existing environment: dev shell [project-name]"
            fi
            ;;
        "status")
            print_header "Development Environment Status"
            print_info "OrbStack status:"
            orb status
            print_info "Available machines:"
            orb list
            ;;
        "setup")
            print_header "Setting Up Development Environment"
            
            if [[ -z "$project_name" ]]; then
                print_error "Project name is required"
                echo "Usage: dev setup <project-name>"
                return 1
            fi
            
            local project_type=$(get_project_type)
            handle_linux_machine "setup" "$project_name" "$project_type"
            ;;
        "shell")
            if [[ -z "$project_name" ]]; then
                print_error "Project name is required"
                echo "Usage: dev shell <project-name>"
                return 1
            fi
            
            handle_linux_machine "shell" "$project_name" ""
            ;;
        "logs")
            if [[ -f "docker-compose.yml" || -f "docker-compose.yaml" || -f "compose.yml" || -f "compose.yaml" ]]; then
                handle_docker_compose "logs" "$project_name"
            else
                print_error "No docker-compose file found in current directory"
                return 1
            fi
            ;;
        "stop")
            if [[ -f "docker-compose.yml" || -f "docker-compose.yaml" || -f "compose.yml" || -f "compose.yaml" ]]; then
                handle_docker_compose "stop"
            else
                print_error "No docker-compose file found in current directory"
                return 1
            fi
            ;;
        "destroy")
            if [[ -z "$project_name" ]]; then
                print_error "Project name is required for destroy action"
                echo "Usage: dev destroy <project-name>"
                return 1
            fi
            
            handle_linux_machine "destroy" "$project_name" ""
            ;;
        *)
            print_error "Unknown action: $action"
            echo "Available actions:"
            echo "  (no args)           - Smart detection: start Docker Compose or connect to machine"
            echo "  status              - Show OrbStack status and machines"
            echo "  setup <project>     - Create and setup development environment"
            echo "  shell <project>     - Connect to development environment"
            echo "  logs [service]      - Show Docker Compose logs (for containerized projects)"
            echo "  stop                - Stop Docker Compose services (for containerized projects)"
            echo "  destroy <project>   - Delete development environment"
            echo
            echo "Supported project types:"
            echo "  - Docker Compose (docker-compose.yml) - Preferred for containerized apps"
            echo "  - Docker (Dockerfile)"
            echo "  - Deno (deno.json, deno.jsonc)"
            echo "  - Node.js (package.json)"
            echo "  - Python (requirements.txt, pyproject.toml, setup.py)"
            echo "  - Elixir/Phoenix (mix.exs)"
            echo "  - Rust (Cargo.toml)"
            echo "  - Go (go.mod)"
            return 1
            ;;
    esac
}

# Main execution
main() {
    dev_command "$@"
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi