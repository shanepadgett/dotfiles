# Configuration Files Guide

This document explains all configuration files in the shell directory and how to customize them.

## Shell Configuration

### `.zshrc` (Zsh)
Location: `shell/zshrc` → `~/.zshrc`

**Features:**
- Zoxide integration for smart directory navigation
- Git aliases for common operations
- Custom prompt with colors
- History configuration
- Machine-specific overrides via `~/.zshrc.local`

**Key Aliases:**
- `ll`, `la`, `l` - Enhanced ls commands
- `gs`, `ga`, `gc`, `gp`, `gl` - Git shortcuts
- `cd` → `z` - Zoxide navigation
- `cdi` → `zi` - Interactive directory selection

**Customization:**
Create `~/.zshrc.local` for machine-specific settings:
```bash
# Work-specific settings
export WORK_DIR="~/work"
alias work="cd $WORK_DIR"

# Personal settings
export PERSONAL_DIR="~/personal"
alias personal="cd $PERSONAL_DIR"
```

### `.bashrc` (Bash)
Location: `shell/bashrc` → `~/.bashrc`

Fallback configuration for systems where Zsh isn't available. Includes similar features as `.zshrc`.

## Editor Configurations

### VS Code Settings
Location: `shell/vscode/` → `~/.config/Code/User/`

**Key Features:**
- JetBrains Mono font
- Auto-format on save
- Organize imports on save
- 80/120 character rulers
- Git integration
- TypeScript/JavaScript optimized

**Extensions to install:**
- Prettier - Code formatter
- ESLint
- GitLens
- VSCode-icons
- Auto Rename Tag
- Bracket Pair Colorizer

### Zed Settings
Location: `shell/zed/` → `~/.config/zed/`

**Features:**
- Ayu Dark theme
- JetBrains Mono font
- TypeScript/JavaScript optimized
- Inlay hints enabled
- Auto-save after 1 second delay

### Ghostty Configuration
Location: `shell/ghostty/config` → `~/.config/ghostty/config`

**Features:**
- JetBrains Mono font
- Dark theme
- 120x40 window size
- 10px padding
- macOS-specific optimizations

## Directory Navigation

### Zoxide Configuration
Location: `shell/zoxide/config.toml`

**Features:**
- Fzf integration for interactive selection
- Case-insensitive matching
- Score display
- Exclude temp directories

## Customization Examples

### Work vs Personal Setup

Create separate configurations for different environments:

```bash
# ~/.zshrc.local (work)
export WORK_EMAIL="work@company.com"
export WORK_DIR="~/work"
alias work="cd $WORK_DIR"
alias deploy="./scripts/deploy.sh"

# ~/.zshrc.local (personal)
export PERSONAL_EMAIL="me@personal.com"
export PERSONAL_DIR="~/personal"
alias blog="cd ~/personal/blog"
alias photos="cd ~/Pictures"
```

### Adding New Tools

To add a new tool to your configuration:

1. **Add to Brewfile:**
   ```bash
   brew "new-tool"
   cask "new-app"
   ```

2. **Update shell configuration:**
   ```bash
   # Add to shell/zshrc
   alias nt="new-tool"
   ```

3. **Add editor configuration:**
   ```bash
   # Add to shell/vscode/settings.json
   "new-tool.path": "/usr/local/bin/new-tool"
   ```

### Machine-Specific Overrides

Each configuration supports local overrides:

- Shell: `~/.zshrc.local` or `~/.bashrc.local`
- VS Code: `~/.config/Code/User/settings.json` (overrides shell)
- Zed: `~/.config/zed/settings.json` (overrides shell)

### Environment Variables

Common environment variables to set:

```bash
# Editor
export EDITOR="code"
export VISUAL="code"

# Git
export GIT_AUTHOR_NAME="Your Name"
export GIT_AUTHOR_EMAIL="your.email@example.com"

# Development
export NODE_ENV="development"
export PYTHONPATH="$HOME/.local/lib/python3.9/site-packages"
```

## Troubleshooting

### Configuration Not Loading
1. Check symlink: `ls -la ~/.zshrc`
2. Verify file exists: `cat ~/.zshrc`
3. Reload shell: `source ~/.zshrc`

### Conflicts with Existing Configs
The setup script creates backups automatically:
- Check `~/.config-backup-YYYY-MM-DD/` for previous configurations
- Use `scripts/cleanup.sh` to restore backups

### Missing Tools
Run `scripts/check-health.sh` to verify all tools are installed correctly.
