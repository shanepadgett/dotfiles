# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a comprehensive macOS development environment setup repository that automates the configuration of development tools, applications, and shell configurations. The repository uses Bash scripts to orchestrate the installation and management of a complete development environment.

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
git-init <name> [desc]     # Initialize new git project
pr [title]                 # Create GitHub pull request
```

### Maintenance Scripts
```bash
./scripts/check-health.sh      # Verify installation state
./scripts/update-brewfile.sh   # Update Brewfile from current system
./scripts/cleanup.sh           # Uninstall and cleanup
./scripts/setup-shell.sh       # Re-run shell configuration
./scripts/lint-shell.sh        # Lint all shell scripts with shellcheck
./scripts/format-shell.sh      # Format all shell scripts with shfmt
./scripts/validate-shell.sh    # Run both linting and formatting (recommended)
```

## Architecture

### Directory Structure
- `config/` - Configuration files
  - `shell/` - Shell configurations (bashrc, zshrc, aliases, functions, exports)
  - `tools/` - Application configs (VS Code, Zed, Ghostty, Git, etc.)
- `scripts/` - Automation scripts
  - `dev-commands/` - Global development utilities
  - `lib/` - Shared libraries (logger, sudo helpers)
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

#### Shell Script Validation Commands
```bash
# Check all shell scripts for issues (Claude Code should run this)
./scripts/lint-shell.sh

# Show detailed fix suggestions for issues
./scripts/lint-shell.sh --fix

# Check specific files only
./scripts/lint-shell.sh install.sh scripts/setup.sh

# Format all shell scripts
./scripts/format-shell.sh

# Check formatting without changing files
./scripts/format-shell.sh --check
```

#### For Claude Code Users
When making changes to shell scripts, **always run this command** to ensure code quality:
```bash
./scripts/validate-shell.sh
```

This single command will:
1. Run `shellcheck` on all scripts and show any issues
2. Auto-format all scripts with `shfmt`
3. Re-run `shellcheck` to verify all issues are resolved

**Alternative manual approach:**
1. `./scripts/lint-shell.sh` - Shows all shellcheck issues that need fixing
2. `./scripts/format-shell.sh` - Ensures consistent formatting
3. `./scripts/lint-shell.sh` - Verify all issues are resolved

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