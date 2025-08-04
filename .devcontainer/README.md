# Development Container Setup

This dev container provides a complete development environment for the dotfiles repository with all necessary tools pre-installed.

## Included Tools

- **Go 1.21.5** - Required for shfmt
- **shellcheck** - Shell script linting
- **shfmt** - Shell script formatting
- **Claude Code** - AI-powered development assistant
- **Standard development tools** - git, curl, wget, jq, etc.

## Shell Formatting

The container includes automatic shell script formatting with `shfmt`:

### VS Code Integration
- **Format on save**: Enabled for shell scripts
- **Manual formatting**: `Ctrl+Shift+I` or right-click → Format Document
- **Configuration**: 2-space indentation, case statement indenting, code simplification

### CLI Usage
```bash
# Format all scripts
./scripts/format-shell.sh

# Check formatting (CI-friendly)
./scripts/format-shell.sh --check

# Format specific file
shfmt -i 2 -ci -s -w script.sh
```

## Configuration Files

- `.shfmt` - Shell formatting configuration
- `.devcontainer/devcontainer.json` - VS Code dev container settings
- `.devcontainer/post-create.sh` - Container initialization script

## Getting Started

1. Open the repository in VS Code
2. Click "Reopen in Container" when prompted
3. Wait for the container to build and initialize
4. Start developing with full shell linting and formatting support!