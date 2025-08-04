#!/bin/bash

# Development environment management command
# Handles Docker Compose workflows for containerized development

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

# Check if Docker and Docker Compose are available
check_docker() {
  if ! command -v docker &>/dev/null; then
    print_error "Docker is not installed or not in PATH"
    print_info "Please install Docker Desktop or OrbStack"
    return 1
  fi

  if ! docker compose version &>/dev/null; then
    print_error "Docker Compose is not available"
    return 1
  fi

  return 0
}

# Find compose file in current directory
find_compose_file() {
  local compose_files=("docker-compose.yml" "docker-compose.yaml" "compose.yml" "compose.yaml")

  for file in "${compose_files[@]}"; do
    if [[ -f $file ]]; then
      echo "$file"
      return 0
    fi
  done

  return 1
}

# Handle Docker Compose workflow
handle_docker_compose() {
  local action="$1"
  local service="${2:-}"

  case "$action" in
    "start" | "up")
      print_info "Starting Docker Compose services..."
      if docker compose up -d; then
        print_success "Services started successfully"
        print_info "Use 'dev logs' to view logs"
        print_info "Use 'dev stop' to stop services"
      else
        print_error "Failed to start Docker Compose services"
        return 1
      fi
      ;;
    "logs")
      print_info "Showing Docker Compose logs..."
      if [[ -n $service ]]; then
        docker compose logs -f "$service"
      else
        docker compose logs -f
      fi
      ;;
    "stop" | "down")
      print_info "Stopping Docker Compose services..."
      docker compose down
      print_success "Services stopped"
      ;;
    "restart")
      print_info "Restarting Docker Compose services..."
      docker compose restart
      print_success "Services restarted"
      ;;
    "build")
      print_info "Building Docker Compose services..."
      docker compose build
      print_success "Build complete"
      ;;
    "ps" | "status")
      docker compose ps
      ;;
  esac
}

# Show help information
show_help() {
  echo "Development environment management with Docker Compose"
  echo
  echo "Usage: dev <command> [options]"
  echo
  echo "Commands:"
  echo "  start               Start Docker Compose services"
  echo "  stop                Stop Docker Compose services"
  echo "  restart             Restart Docker Compose services"
  echo "  build               Build Docker Compose services"
  echo "  logs [service]      Show container logs"
  echo "  ps                  Show running containers"
  echo "  create              Interactive stack selection menu"
  echo "  help                Show this help message"
  echo
  echo "Available stacks:"
  echo "  • Elixir Phoenix app with PostgreSQL database"
  echo "  • Deno app with SQLite database"
  echo "  • Rust app with SQLite database"
  echo
  echo "Examples:"
  echo "  dev start           # Start services defined in docker-compose.yml"
  echo "  dev create          # Interactive menu to create a new stack"
  echo "  dev logs app        # Show logs for 'app' service"
}

# Interactive stack selection menu
select_stack() {
  local stacks=("elixir-phoenix" "deno-sqlite" "rust-sqlite")
  local descriptions=("Elixir Phoenix + PostgreSQL" "Deno + SQLite" "Rust + SQLite")
  local selected=0
  local total=${#stacks[@]}

  # Hide cursor
  tput civis

  # Function to cleanup on exit
  cleanup() {
    tput cnorm # Show cursor
    echo
  }
  trap cleanup EXIT

  while true; do
    # Clear screen and move to top
    clear

    print_header "Select Development Stack"
    echo "Use ↑/↓ arrow keys to navigate, Enter to select, q/Esc to quit"
    echo

    # Display options
    for i in "${!stacks[@]}"; do
      if [[ $i -eq $selected ]]; then
        echo "  → ${descriptions[$i]}"
      else
        echo "    ${descriptions[$i]}"
      fi
    done

    # Read single character
    read -rsn1 key

    # Handle special keys (arrow keys send 3 characters: ESC [ A/B)
    if [[ $key == $'\x1b' ]]; then
      read -rsn2 key
      case $key in
        '[A') # Up arrow
          ((selected--))
          if [[ $selected -lt 0 ]]; then
            selected=$((total - 1))
          fi
          ;;
        '[B') # Down arrow
          ((selected++))
          if [[ $selected -ge $total ]]; then
            selected=0
          fi
          ;;
      esac
    elif [[ $key == '' ]]; then # Enter key
      clear
      echo "${stacks[$selected]}"
      return 0
    elif [[ $key == 'q' || $key == 'Q' || $key == $'\x1b' ]]; then # Quit (q, Q, or Esc)
      clear
      return 1
    fi
  done
}

# Create predefined stack configurations
create_stack() {
  local stack="$1"

  if [[ -f "docker-compose.yml" || -f "compose.yml" ]]; then
    print_warning "Compose file already exists"
    return 1
  fi

  case "$stack" in
    "elixir-phoenix")
      print_info "Creating Elixir Phoenix + PostgreSQL stack..."
      cat >docker-compose.yml <<'EOF'
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: app_dev
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  app:
    build: .
    ports:
      - "4000:4000"
    volumes:
      - .:/app
    environment:
      - DATABASE_URL=ecto://postgres:postgres@db/app_dev
      - PHX_HOST=localhost
    depends_on:
      - db
    command: mix phx.server

volumes:
  postgres_data:
EOF

      cat >Dockerfile <<'EOF'
FROM elixir:1.15-alpine

RUN apk add --no-cache build-base npm git python3 curl inotify-tools

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get

COPY assets/package*.json assets/
RUN cd assets && npm install

COPY . .
RUN mix deps.compile

EXPOSE 4000

CMD ["mix", "phx.server"]
EOF
      print_success "Created Elixir Phoenix + PostgreSQL stack"
      ;;
    "deno-sqlite")
      print_info "Creating Deno + SQLite stack..."
      cat >docker-compose.yml <<'EOF'
services:
  app:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - .:/app
      - sqlite_data:/app/data
    command: deno run --allow-net --allow-read --allow-write --watch main.ts

volumes:
  sqlite_data:
EOF

      cat >Dockerfile <<'EOF'
FROM denoland/deno:alpine

WORKDIR /app

COPY . .

RUN deno cache main.ts

EXPOSE 8000

CMD ["deno", "run", "--allow-net", "--allow-read", "--allow-write", "main.ts"]
EOF
      print_success "Created Deno + SQLite stack"
      ;;
    "rust-sqlite")
      print_info "Creating Rust + SQLite stack..."
      cat >docker-compose.yml <<'EOF'
services:
  app:
    build: .
    ports:
      - "8080:8080"
    volumes:
      - .:/app
      - sqlite_data:/app/data
      - cargo_cache:/usr/local/cargo/registry
    command: cargo run

volumes:
  sqlite_data:
  cargo_cache:
EOF

      cat >Dockerfile <<'EOF'
FROM rust:1.75-alpine

RUN apk add --no-cache musl-dev sqlite-dev

WORKDIR /app

COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm src/main.rs

COPY . .
RUN cargo build --release

EXPOSE 8080

CMD ["cargo", "run", "--release"]
EOF
      print_success "Created Rust + SQLite stack"
      ;;
    *)
      print_error "Unknown stack: $stack"
      echo "Available stacks: elixir-phoenix, deno-sqlite, rust-sqlite"
      return 1
      ;;
  esac

  print_info "Stack created successfully!"
  print_info "Use 'dev start' to run the services"
}

# Main dev command logic
dev_command() {
  local action="${1:-help}"
  local arg="${2:-}"

  case "$action" in
    "start" | "up")
      # Check if Docker is available
      check_docker || return 1

      local compose_file
      if compose_file=$(find_compose_file); then
        print_info "Found $compose_file"
        handle_docker_compose "start"
      else
        print_error "No docker-compose file found in current directory"
        print_info "Use 'dev create <stack>' to create a new stack"
        return 1
      fi
      ;;
    "logs")
      check_docker || return 1
      if find_compose_file >/dev/null; then
        handle_docker_compose "logs" "$arg"
      else
        print_error "No docker-compose file found in current directory"
        return 1
      fi
      ;;
    "stop" | "down")
      check_docker || return 1
      if find_compose_file >/dev/null; then
        handle_docker_compose "stop"
      else
        print_error "No docker-compose file found in current directory"
        return 1
      fi
      ;;
    "restart")
      check_docker || return 1
      if find_compose_file >/dev/null; then
        handle_docker_compose "restart"
      else
        print_error "No docker-compose file found in current directory"
        return 1
      fi
      ;;
    "build")
      check_docker || return 1
      if find_compose_file >/dev/null; then
        handle_docker_compose "build"
      else
        print_error "No docker-compose file found in current directory"
        return 1
      fi
      ;;
    "ps" | "status")
      check_docker || return 1
      if find_compose_file >/dev/null; then
        handle_docker_compose "ps"
      else
        print_error "No docker-compose file found in current directory"
        return 1
      fi
      ;;
    "create")
      check_docker || return 1
      if [[ -n $arg ]]; then
        # Direct stack specification (for backwards compatibility)
        create_stack "$arg"
      else
        # Interactive selection
        local selected_stack
        if selected_stack=$(select_stack); then
          create_stack "$selected_stack"
        else
          print_info "Stack creation cancelled"
          return 0
        fi
      fi
      ;;
    "help" | "--help" | "-h")
      show_help
      ;;
    *)
      print_error "Unknown command: $action"
      echo
      show_help
      return 1
      ;;
  esac
}

# Main execution
main() {
  dev_command "$@"
}

# Only run main if script is executed directly (not sourced)
if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  main "$@"
fi
