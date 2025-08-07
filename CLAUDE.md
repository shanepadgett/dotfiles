# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a comprehensive macOS development environment setup repository that automates the configuration of development tools, applications, and shell configurations. The repository uses Bash scripts to orchestrate the installation and management of a complete development environment.

## Environment Detection (Critical for Claude Code)

**IMPORTANT**: Before performing any file operations, always detect whether you're running in a dev container or on the host machine, as file paths differ between environments.

### Detection Method
Use this bash command to detect the environment:
```bash
# Detect environment before any file operations
if [[ -d "/workspaces" ]] || [[ -n "${REMOTE_CONTAINERS:-}" ]] || [[ -n "${CODESPACES:-}" ]] || [[ -n "${DEVCONTAINER:-}" ]] || [[ -f "/.dockerenv" ]]; then
    echo "Dev container environment detected"
    REPO_PATH="/workspaces/dotfiles"
else
    echo "Host machine environment detected"  
    REPO_PATH="$HOME/.dotfiles"
fi
```

### Environment-Specific File Paths
- **Host Machine**: Repository is at `~/.dotfiles` (`/Users/username/.dotfiles`)
- **Dev Container**: Repository is at `/workspaces/dotfiles`

### Claude Code Usage Guidelines
1. **Always detect environment first** before reading files or listing directories
2. Use `$PWD` or run detection script to determine correct paths
3. Never assume file paths - always verify the environment first
4. If unsure, run `pwd` and `ls` to orient yourself

Example workflow:
```bash
# Step 1: Detect environment
pwd
ls -la

# Step 2: Use appropriate paths based on detection
# Dev container: use /workspaces/dotfiles/...
# Host machine: use ~/.dotfiles/... or current working directory
```

## Key Commands

### Installation and Setup
```bash
./install.sh                  # Full installation
./install.sh --dry-run       # Preview changes without installing
./install.sh --skip-shell    # Skip shell configuration
./install.sh --skip-apps     # Skip application installation
```

### Development Utilities (Available globally after installation)
```bash
update-configs               # Pull latest changes and re-run setup
reset-configs               # Reset to clean repository state
teardown                    # Complete removal of dotfiles and applications
dev <command>              # Docker Compose development environment management
git-init <name> [desc]     # Initialize new git project (shell function)
pr [title]                 # Create GitHub pull request
```

### Production Scripts
```bash
./scripts/setup.sh             # Main setup orchestrator
./scripts/setup-shell.sh       # Re-run shell configuration
./scripts/update-brewfile.sh   # Update Brewfile from current system
./scripts/cleanup.sh           # Uninstall and cleanup
```

### Development Scripts (Dev Container Only)
These scripts require the dev container environment with shellcheck, shfmt, and other tools:
```bash
./dev/check-health.sh          # Verify installation state
./dev/lint-shell.sh            # Lint all shell scripts with shellcheck
./dev/format-shell.sh          # Format all shell scripts with shfmt
./dev/validate-shell.sh        # Run both linting and formatting (recommended)
```

## Architecture

### Directory Structure
- `config/` - Configuration files
  - `shell/` - Shell configurations (bashrc, zshrc, aliases, functions, exports)
  - `tools/` - Application configs (VS Code, Zed, Ghostty, Git, etc.)
- `scripts/` - Production automation scripts
  - `dev-commands/` - Global development utilities
  - `lib/` - Shared libraries (logger, sudo helpers)
- `dev/` - Development scripts (require dev container)
- `templates/` - Project templates
- `Brewfile` - Homebrew package definitions

### Core Scripts
1. **install.sh** - Entry point that bootstraps Homebrew, Git, and clones repository
2. **scripts/setup.sh** - Main orchestrator for packages, tools, and system configuration
3. **scripts/setup-shell.sh** - Manages shell configuration with backup/restore functionality

### Key Features
- **1Password Integration**: Secure credential management for git config and SSH keys
- **Backup System**: Automatic backup of existing configs to `~/.config-backup-YYYY-MM-DD`
- **Symlink Management**: Shell and tool configs symlinked from repository to home directory
- **Logging**: All operations logged to `~/config.log` with timestamps
- **Docker Compose Dev Environment**: `dev` command for container-based development workflows
- **Code Quality**: All shell scripts pass shellcheck linting and shfmt formatting
- **Automated Validation**: Comprehensive shell script linting with detailed error reporting

## Development Workflow

### Testing Changes
When modifying configuration files:
1. Edit files in `config/shell/` or `config/tools/`
2. Run `./scripts/setup-shell.sh` to apply changes
3. Use `./scripts/check-health.sh` to verify installation state

### Code Quality
When modifying shell scripts:
1. All scripts are linted with `shellcheck` and formatted with `shfmt`
2. **REQUIRED**: Run `./scripts/lint-shell.sh` after any shell script changes
3. **REQUIRED**: Run `./scripts/format-shell.sh` after any shell script changes
4. VS Code automatically formats on save in dev container

#### Shell Script Validation Commands (Dev Container Only)
**IMPORTANT:** These scripts require the dev container environment and will fail on the host machine.

```bash
# Check all shell scripts for issues (run in dev container)
./dev/lint-shell.sh

# Show detailed fix suggestions
./dev/lint-shell.sh --fix

# Check specific files only
./dev/lint-shell.sh install.sh scripts/setup.sh

# Format all shell scripts
./dev/format-shell.sh

# Check formatting without changing files
./dev/format-shell.sh --check
```

#### For Claude Code Users
When making changes to shell scripts:

**If in dev container:**
```bash
./dev/validate-shell.sh
```

**If on host machine:**
Claude Code will detect the environment and instruct you to open the project in a dev container to run validation.

The validation script:
1. Runs `shellcheck` on all scripts and shows any issues
2. Auto-formats all scripts with `shfmt`
3. Re-runs `shellcheck` to verify all issues are resolved

### Testing Commands in Dev Container

**IMPORTANT**: Claude Code should NEVER attempt to execute the following commands in the dev container:
- Global symlinked commands: `pr`, `update-configs`, `reset-configs`, `teardown`, `dev`
- Commands requiring root access or system installation
- Commands that interact with GitHub authentication or 1Password

**NOTE**: `delete-repo` and `git-init` are now sourced shell functions and may work in dev container, but should still be tested carefully.

Instead, after making changes to these scripts:
1. Run `./scripts/validate-shell.sh` to ensure code quality
2. **Ask the user to test the changes** on their host system
3. Request feedback on the functionality and any issues encountered

**Testing workflow for Claude Code:**
1. Make code changes
2. **Check environment first** - if on host machine, instruct user to open dev container
3. If in dev container: validate with `./dev/validate-shell.sh`
4. If on host: instruct user to test in dev container

### Adding New Packages
1. Edit `Brewfile` to add new packages
2. Run `brew bundle install --file=Brewfile`
3. Commit changes to repository

### Creating Development Environments
The `dev` command provides Docker Compose management:
- `dev create` - Interactive menu for stack selection (Elixir/Phoenix, Deno, Rust)
- `dev start` - Start Docker Compose services
- `dev logs [service]` - View container logs
- `dev stop` - Stop services

## Important Notes

- The repository expects to be cloned to `~/.dotfiles` for proper operation
- Shell configurations are stored without leading dots in the repository and symlinked with dots
- **Symlinks use relative paths** to ensure compatibility between host machines and devcontainers
- The teardown process must be run from Terminal.app or iTerm2, not from applications that will be uninstalled
- All global commands are installed to `/usr/local/bin` via symlinks from `scripts/dev-commands/`
- The setup integrates with 1Password - ensure a "Git Config" item exists in the Private vault with name and email fields