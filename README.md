# macOS Development Environment

A comprehensive macOS setup automation repository that configures a complete development environment with applications, CLI tools, dotfiles, and development workflows.

## Quick Start

Bootstrap your Mac with one command:

```bash
curl -fsSL https://raw.githubusercontent.com/shanepadgett/dotfiles/main/install.sh | bash
```

## What's Included

### What's Installed
- **CLI Tools**: Modern shell utilities, development tools, and container management via OrbStack
- **Applications**: Productivity apps, code editors, AI coding tools, browsers, and utilities
- **Fonts**: Programming-optimized fonts for development
- **Shell**: Shell configurations, editor settings, terminal setup, and tool configurations

### Development Environment Management
- **Smart Project Detection**: Automatic environment setup based on project type
- **Container Workflows**: Docker Compose management with automatic domain names
- **Isolated Environments**: Per-project Linux VMs via OrbStack
- **Multi-Language Support**: Auto-detection and setup for popular programming languages

## Installation Options

```bash
./install.sh                  # Full installation
./install.sh --dry-run       # Preview changes without installing
./install.sh --skip-shell    # Skip shell configuration
./install.sh --skip-apps     # Skip application installation
```

## Development Workflow

The `dev` command provides intelligent project management. Run `dev` without arguments for help and available commands.

**Key Features:**
- Auto-detection of project types and smart environment setup
- Docker Compose workflow management
- Isolated Linux development environments
- Multi-language project support

## Architecture

### Installation Flow
1. **`install.sh`** - Bootstrap script (Homebrew, Git, repo setup)
2. **`scripts/setup.sh`** - Main orchestrator (packages, AI tools, directories)
3. **`scripts/setup-shell.sh`** - Shell configuration management with backup/restore

### File Organization
- `shell/` - Shell configuration files (stored without leading dots)
- `scripts/` - Automation and utility scripts
- `Brewfile` - Package definitions for Homebrew

### Key Features
- **Backup System**: Existing configs backed up to `~/.config-backup-YYYY-MM-DD`
- **Symlink Management**: Shell configs symlinked from `shell/` to home directory
- **Logging**: All operations logged to `~/.dotfiles.log` with timestamps
- **Error Handling**: Robust error handling with retry mechanisms

## Customization

### Adding Packages
Edit `Brewfile`:
```ruby
brew "cli-tool-name"
cask "gui-app-name"
```

### Modifying Configurations
Edit files in `shell/` directory, then run:
```bash
./scripts/setup-shell.sh
```

### Machine-Specific Overrides
See [CONFIGURATION.md](CONFIGURATION.md) for detailed customization options.

## Available Commands

**Maintenance:**
```bash
./scripts/check-health.sh      # Verify installation state
./scripts/update-brewfile.sh   # Update Brewfile from current system
./scripts/cleanup.sh           # Uninstall and cleanup
```

**Development:**
- Run `dev` for project environment management
- Additional utilities available in `scripts/dev-commands/` for Git workflows and development tasks

## Troubleshooting

**Homebrew Issues**: Install Xcode Command Line Tools first
```bash
xcode-select --install
```

**Symlink Conflicts**: Backups are automatically created in `~/.config-backup-YYYY-MM-DD`

**Missing Applications**: Check availability with `brew search app-name`

**View Logs**: Check `~/.dotfiles.log` for detailed installation logs

## License

MIT
