# Mac Setup

A comprehensive macOS setup automation repository for quickly configuring a new Mac with essential development tools, applications, and dotfiles.

## Quick Start

Run this command to bootstrap your Mac setup:

```bash
curl -fsSL https://raw.githubusercontent.com/username/mac-setup/main/install.sh | bash
```

## What's Included

### CLI Tools
- `zsh` - Modern shell
- `zoxide` - Smarter cd command
- `gh` - GitHub CLI
- `bruno` - API testing tool

### Applications
- **Productivity**: Raycast, Rectangle, Obsidian, 1Password
- **Development**: Ghostty, Zed, VS Code, Claude Code, OpenCode
- **Communication**: Discord
- **Browsers**: Brave
- **Utilities**: Logi Options+, VoiceInk

### Dotfiles
- Shell configurations (.zshrc, .bashrc)
- Editor settings (VS Code, Zed)
- Terminal configurations (Ghostty)
- Developer tool configs

## Installation Options

### Full Installation
```bash
./install.sh
```

### Dry Run (Preview Changes)
```bash
./install.sh --dry-run
```

### Skip Dotfiles
```bash
./install.sh --skip-dotfiles
```

### Skip Applications
```bash
./install.sh --skip-apps
```

## Manual Setup

Some applications may require manual installation if not available via Homebrew:
- Claude Code
- VoiceInk
- OpenCode

Follow the links in the installation output for manual setup instructions.

## Customization

### Adding Applications
Edit the `Brewfile` to add or remove applications:
```ruby
brew "your-cli-tool"
cask "your-gui-app"
```

### Modifying Dotfiles
All dotfiles are stored in the `dotfiles/` directory. Edit them directly and run:
```bash
./scripts/setup-dotfiles.sh
```

## Maintenance

### Update Brewfile from Current System
```bash
./scripts/update-brewfile.sh
```

### Check Installation Health
```bash
./scripts/check-health.sh
```

### Uninstall
```bash
./scripts/cleanup.sh
```

## Troubleshooting

### Homebrew Installation Failed
Ensure you have Xcode Command Line Tools installed:
```bash
xcode-select --install
```

### Symlink Conflicts
The setup script backs up existing configs to `~/.config-backup-YYYY-MM-DD`. To restore:
```bash
./scripts/cleanup.sh --restore
```

### Application Not Found
Check if the application is available via Homebrew:
```bash
brew search app-name
```

## License

MIT