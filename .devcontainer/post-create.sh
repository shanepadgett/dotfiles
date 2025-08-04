#!/bin/bash
set -e

# Check if running in a container environment
if [ ! -f /.dockerenv ] && [ -z "$REMOTE_CONTAINERS" ] && [ -z "$CODESPACES" ]; then
  echo "❌ This script should only be run inside a dev container!"
  echo "Please open this project in a dev container and try again."
  exit 1
fi

echo "Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash -s latest

# shellcheck disable=SC2016
echo 'export PATH="$HOME/.local/bin:$PATH"' >>~/.bashrc

# Install shfmt (shell formatter)
echo "🔧 Installing shfmt (shell formatter)..."
go install mvdan.cc/sh/v3/cmd/shfmt@latest

# Add Go bin to PATH if not already there
if ! grep -q "GOPATH" ~/.bashrc; then
  echo "export GOPATH=/go" >>~/.bashrc
  # shellcheck disable=SC2016
  echo 'export PATH="$GOPATH/bin:$PATH"' >>~/.bashrc
fi

# Fix Claude symlinks for devcontainer
echo "🔗 Fixing Claude configuration symlinks..."
if [ -L ~/.claude/settings.json ]; then
  rm ~/.claude/settings.json
  ln -sf /workspaces/dotfiles/config/tools/claude/settings.json ~/.claude/settings.json
fi
if [ -L ~/.claude/mcp.json ]; then
  rm ~/.claude/mcp.json
  ln -sf /workspaces/dotfiles/config/tools/claude/mcp.json ~/.claude/mcp.json
fi

# Make scripts executable
echo "🔧 Making scripts executable..."
find /workspaces/dotfiles/scripts -name "*.sh" -exec chmod +x {} \;

echo "✅ Development environment ready!"
echo ""
echo "Available tools:"
echo "  - Claude Code"
echo "  - shellcheck (linting)"
echo "  - shfmt (formatting)"
echo "  - Go $(go version | cut -d' ' -f3)"
echo "  - VS Code extensions for shell development"
echo ""
echo "Shell formatting options:"
echo "  - Format on save: enabled"
echo "  - Manual format: Ctrl+Shift+I or right-click -> Format Document"
echo "  - CLI format: shfmt -i 2 -ci -s -w *.sh"
echo ""
echo "Ready for dotfiles development!"
