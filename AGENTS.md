# AGENTS.md

This file provides guidance for AI coding agents working with this macOS dotfiles repository.

## Build/Test Commands

```bash
# Full installation (dry run to test)
./install.sh --dry-run

# Test Brewfile syntax
brew bundle check --file=Brewfile

# Health check (verify installation state)
./scripts/check-health.sh

# Setup dotfiles only
./scripts/setup-dotfiles.sh

# Update Brewfile with current packages
./scripts/update-brewfile.sh
```

## Code Style Guidelines

- **Shell Scripts**: Use `set -euo pipefail` for error handling, follow existing color variable patterns
- **Error Handling**: Use trap handlers, log all operations to `~/.dotfiles.log` with timestamps
- **Functions**: Prefix with descriptive verbs (`print_`, `setup_`, `install_`, `check_`)
- **Variables**: Use UPPER_CASE for constants, snake_case for local vars
- **Logging**: Use `log()` function for all operations, include timestamps
- **Colors**: Use predefined color variables (RED, GREEN, YELLOW, BLUE, CYAN, NC)
- **Symlinks**: Store dotfiles without leading dots, create symlinks with proper backup handling
- **Comments**: Include purpose comments for complex operations, avoid obvious comments
