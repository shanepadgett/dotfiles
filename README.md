# macOS Development Environment

A comprehensive macOS setup automation repository that configures a complete development environment with applications, CLI tools, dotfiles, and development workflows.

## Quick Start

Bootstrap your Mac with one command:

```bash
curl -fsSL https://raw.githubusercontent.com/shanepadgett/dotfiles/main/install.sh | bash
```

**Prerequisites:** You'll need a 1Password account as the setup integrates with 1Password for secure credential management.

## What's Included

### What's Installed
- **CLI Tools**: Modern shell utilities, development tools, and container management via OrbStack
- **Applications**: Productivity apps, code editors, AI coding tools, browsers, and utilities
- **Fonts**: Programming-optimized fonts for development
- **Shell**: Shell configurations, editor settings, terminal setup, and tool configurations
- **macOS Defaults**: System preferences, dock configuration, trackpad settings, and desktop behavior
- **1Password Integration**: Secure credential management for git configuration and SSH keys

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

## 1Password Integration

This setup integrates with 1Password for secure credential management:

### During Installation
1. **1Password Desktop App**: Installed and launched for initial sign-in
2. **CLI Integration**: 1Password CLI is configured with app integration
3. **Git Configuration**: Automatically configured from 1Password credentials

### Required 1Password Setup
For automatic git configuration, create a **"Git Config"** item in your **Private** vault with:
- **name** field: Your full name for git commits
- **email** field: Your git email address

### Manual Configuration
If 1Password is unavailable, you can manually create `~/.gitconfig.local`:
```bash
[user]
    name = Your Name
    email = your.email@example.com
```

## Development Workflow

After installation, you'll have access to several global development utilities:

### Configuration Management
- **`update-configs`** - Pull latest changes from repository and re-run setup
- **`reset-configs`** - Reset repository to clean state (discards local changes)
- **`teardown`** - Complete removal of dotfiles and applications

### Project Management
- **`dev`** - Intelligent project environment management with auto-detection
- **`git-init <name> [desc]`** - Initialize new git project with first commit
- **`pr [title]`** - Create pull request using GitHub CLI

**Key Features:**
- Auto-detection of project types and smart environment setup
- Docker Compose workflow management
- Isolated Linux development environments
- Multi-language project support
- Safe configuration updates and rollbacks

## Architecture

### Installation Flow
1. **`install.sh`** - Bootstrap script (Homebrew, Git, repo setup)
2. **`scripts/setup.sh`** - Main orchestrator (packages, AI tools, directories, macOS defaults)
3. **`scripts/setup-shell.sh`** - Shell configuration management with backup/restore

### File Organization
- `config/shell/` - Shell configuration files (stored without leading dots)
- `config/tools/` - Application-specific configurations (VS Code, Zed, Ghostty, direnv, etc.)
- `scripts/` - Automation and utility scripts
- `scripts/dev-commands/` - Development utility commands
- `Brewfile` - Package definitions for Homebrew

### Key Features
- **Backup System**: Existing configs backed up to `~/.config-backup-YYYY-MM-DD`
- **Symlink Management**: Shell configs symlinked from `shell/` to home directory
- **System Configuration**: Automated dock setup, trackpad settings, and desktop preferences
- **Logging**: All operations logged to `~/config.log` with timestamps
- **Error Handling**: Robust error handling with retry mechanisms

## Customization

### Adding Packages
Edit `Brewfile`:
```ruby
brew "cli-tool-name"
cask "gui-app-name"
```

### Modifying Configurations
Edit files in `config/shell/` or `config/tools/` directories, then run:
```bash
./scripts/setup-shell.sh
```

### Machine-Specific Overrides
See [CONFIGURATION.md](CONFIGURATION.md) for detailed customization options.

## Shell Functions & Aliases

After installation, you'll have access to numerous shell functions and aliases for enhanced productivity:

### Development Workflow Functions

**Repository Management:**
```bash
git-init <name> [desc]         # Initialize new git project with GitHub integration
delete-repo <name>             # Delete repository (both GitHub and local)
dr <name>                      # Alias for delete-repo
gcp "commit message"           # Git add, commit, and push in one command
```

**Examples:**
```bash
# Create new repository with interactive wizard
git-init

# Delete current repository (if inside a git repo)
delete-repo .

# Delete specific repository by name
dr my-old-project

# Quick commit and push
gcp "fix: resolve authentication issue"
```

**Docker Development:**
```bash
docker-cleanup                 # Complete Docker cleanup (containers, images, volumes, networks)
dnuke                          # Alias for docker-cleanup
```

**Example:**
```bash
# Clean up all Docker resources (with confirmation)
docker-cleanup

# Quick cleanup (same as above)
dnuke
```
**⚠️ Warning:** `docker-cleanup` removes ALL Docker containers, images, volumes, and networks. Use with caution as this will delete persistent data.

**Environment Management:**
```bash
node-env [development|production|test]  # Set NODE_ENV for current session
with-node-env <env> <command>  # Run command with specific NODE_ENV
dev-env                        # Set NODE_ENV to development
prod-env                       # Set NODE_ENV to production
test-env                       # Set NODE_ENV to test
clear-env                      # Unset NODE_ENV
npm-dev <command>              # Run npm with NODE_ENV=development
yarn-dev <command>             # Run yarn with NODE_ENV=development
pnpm-dev <command>             # Run pnpm with NODE_ENV=development
```

### Modern CLI Tool Aliases

**File Operations (when available):**
```bash
ls                             # eza (modern ls replacement)
ll                             # eza -alF (detailed list)
la                             # eza -a (show hidden files)
l                              # eza -F (with file type indicators)
lt                             # eza -a --tree --level=2 (tree view)
cat                            # bat (syntax highlighted cat)
grep                           # rg (ripgrep - faster text search)
cd                             # z (zoxide - smart directory navigation)
top                            # htop (better process viewer)
```

**FZF Integration (when available):**
```bash
f                              # fzf (fuzzy finder)
fh                             # fzf --history
fe                             # fzf --exact
fzf-git-branch                 # Browse git branches with fzf
fzf-git-log                    # Browse git commits with fzf
fzf-git-stash                  # Browse git stashes with fzf
fzf-history                    # Browse shell history with fzf
fzf-files                      # Browse files with fzf
```

### Git Shortcuts
```bash
gs                             # git status
ga                             # git add
gaa                            # git add --all
gc                             # git commit
gcm                            # git commit -m
gp                             # git push
gpl                            # git pull
gl                             # git log --oneline
gd                             # git diff
gb                             # git branch
gco                            # git checkout
grh                            # git reset --hard
gclean                         # git clean -fdx
gnuke                          # git reset --hard && git clean -fd
```

### System Utilities
```bash
..                             # cd ..
...                            # cd ../..
....                           # cd ../../..
reload                         # Reload shell configuration
path                           # Display PATH entries line by line
hosts                          # Edit /etc/hosts file
```

## Available Commands

**Global Development Utilities:**
```bash
git-init <name> [desc]         # Initialize new git project with first commit
pr [title]                     # Create pull request using gh CLI
dev [action] [project]         # Manage development environments
update-configs [opts]          # Update dotfiles from repository
reset-configs [opts]           # Reset dotfiles to repository state
teardown [opts]                # Remove dotfiles and applications
```

**Maintenance Scripts:**
```bash
./scripts/check-health.sh      # Verify installation state
./scripts/update-brewfile.sh   # Update Brewfile from current system
./scripts/cleanup.sh           # Uninstall and cleanup
./scripts/setup-shell.sh       # Re-run shell configuration setup
```

## Troubleshooting

**Homebrew Issues**: Install Xcode Command Line Tools first
```bash
xcode-select --install
```

**Symlink Conflicts**: Backups are automatically created in `~/.config-backup-YYYY-MM-DD`

**Missing Applications**: Check availability with `brew search app-name`

**View Logs**: Check `~/config.log` for detailed installation logs

## Teardown

To completely remove the development environment and restore your system to pre-setup state:

```bash
teardown                        # Interactive teardown with confirmations
teardown --dry-run             # Preview what would be removed
teardown --yes                 # Skip all confirmations
```

**Important:** Teardown must be run from Terminal.app or iTerm2, not from Ghostty, VS Code, or Zed terminals (since these applications will be uninstalled).

The teardown process will:
- Uninstall all Homebrew packages and casks from the Brewfile
- Remove AI coding tools (Claude Code, OpenCode)
- Remove all symlinks from your home directory
- Remove global development utility commands
- Restore original configuration files from backup
- Clean up development directories and logs
- Optionally remove the dotfiles repository itself

## License

MIT
