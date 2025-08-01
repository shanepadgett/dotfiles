#!/bin/bash
set -e

# Check if running in a container environment
if [ ! -f /.dockerenv ] && [ -z "$REMOTE_CONTAINERS" ] && [ -z "$CODESPACES" ]; then
    echo "❌ This script should only be run inside a dev container!"
    echo "Please open this project in a dev container and try again."
    exit 1
fi

echo "🚀 Setting up dotfiles development environment..."

# Install OpenCode CLI for development
echo "📦 Installing OpenCode CLI..."
curl -fsSL https://opencode.ai/install | bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc



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
