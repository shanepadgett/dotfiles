# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a macOS setup automation repository (dotfiles management) designed to configure a new Mac with development tools, applications, and personal configurations. The project uses Homebrew for package management and shell scripts for automation.

## Key Commands

### Installation
```bash
# One-line remote install
curl -fsSL https://raw.githubusercontent.com/username/mac-setup/main/install.sh | bash

# Local installation options
./install.sh                  # Full installation
./install.sh --dry-run       # Preview changes
./install.sh --skip-dotfiles # Skip dotfile setup
./install.sh --skip-apps     # Skip application installation
```

### Development Commands
```bash
# Make scripts executable
chmod +x install.sh
chmod +x scripts/*.sh

# Test the Brewfile syntax
brew bundle check --file=Brewfile

# List what would be installed
brew bundle list --file=Brewfile
```

## Architecture

### Entry Point Flow
1. `install.sh` - Bootstrap script that:
   - Checks for macOS
   - Installs Homebrew and Git if needed
   - Clones/updates repo to `~/.mac-setup`
   - Calls `scripts/setup.sh`

2. `scripts/setup.sh` - Main orchestrator that:
   - Runs `brew bundle install`
   - Handles manual app installations
   - Calls `scripts/setup-dotfiles.sh`
   - Manages installation options

3. `scripts/setup-dotfiles.sh` - Dotfiles manager that:
   - Creates backups to `~/.config-backup-YYYY-MM-DD`
   - Creates symlinks from home to `dotfiles/`
   - Handles conflicts

### File Organization
- `dotfiles/` - Configuration files (without leading dots)
- `scripts/` - Utility scripts for setup, updates, and maintenance
- Root level - Entry points and package definitions

## Important Implementation Notes

1. **Symlink Strategy**: Dotfiles are stored without leading dots in `dotfiles/` and symlinked to their proper locations with dots.

2. **Manual Installations**: Claude Code, VoiceInk, and OpenCode are marked for manual installation as they're not in Homebrew.

3. **Logging**: All operations log to `~/.mac-setup.log` with timestamps.

4. **Error Handling**: The `install.sh` uses `set -euo pipefail` and has trap handlers. Continue this pattern in all scripts.

5. **Color Output**: Use the color variables defined in `install.sh` for consistent output formatting.

## Package Categories in Brewfile

- **CLI Tools**: zsh, zoxide, gh, bruno
- **Productivity**: Raycast, Rectangle, Obsidian, 1Password
- **Development**: Ghostty, Zed, VS Code
- **Communication**: Discord
- **Browsers**: Brave
- **Utilities**: Logi Options+