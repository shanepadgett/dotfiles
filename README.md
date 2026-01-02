# Dotfiles

Managed with [chezmoi](https://chezmoi.io).

## Install

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply shanepadgett
```

## What's Included

- **zsh** - Shell config with nvm, zoxide, aliases
- **chezmoi-symlink** - Script for managing externally-modified config files

## chezmoi-symlink

Some config files (like `settings.json`) are modified by their applications. Standard chezmoi tracking causes conflicts. The `chezmoi-symlink` script handles this by:

1. Storing the file in `.chezmoi_symlinks/`
2. Creating a symlink template that points to it
3. Apps edit the symlinked file directly in the chezmoi source

### Usage

```bash
chezmoi-symlink add <file>      # Set up symlink management (default)
chezmoi-symlink remove <file>   # Restore as regular file
chezmoi-symlink edit <file>     # Edit + auto commit/push
```

### Options

- `--dry-run` - Show what would be done
- `--purge` - (remove only) Delete stored copy
- `--no-apply` - Skip `chezmoi apply`

### Files Currently Managed

- `~/.claude/settings.json`
- `~/.config/opencode/opencode.json`
- `~/.config/zed/settings.json`
