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

echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.bashrc

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
echo "  - Augment Code extension"
echo "  - OpenCode CLI"
echo "  - VS Code extensions for shell development"
echo ""
echo "Ready for dotfiles development!"
