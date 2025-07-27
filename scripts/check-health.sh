#!/bin/bash

# Health check script to verify installation state
# Usage: ./scripts/check-health.sh

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Mac Setup Health Check ===${NC}"
echo

# Check Homebrew
if command -v brew &> /dev/null; then
    echo -e "${GREEN}✓ Homebrew is installed${NC}"
    echo -e "  Version: $(brew --version | head -1)"
else
    echo -e "${RED}✗ Homebrew is not installed${NC}"
fi

# Check Brewfile packages
echo
echo -e "${BLUE}Checking Brewfile packages...${NC}"
if [ -f "Brewfile" ]; then
    brew bundle check --file=Brewfile 2>/dev/null && \
        echo -e "${GREEN}✓ All Brewfile packages are installed${NC}" || \
        echo -e "${YELLOW}! Some Brewfile packages are missing${NC}"
else
    echo -e "${YELLOW}! Brewfile not found${NC}"
fi

# Check symlinks
echo
echo -e "${BLUE}Checking symlinks...${NC}"

check_symlink() {
    local source="$1"
    local target="$2"
    local description="$3"

    if [ -L "$target" ]; then
        if [ "$(readlink "$target")" = "$source" ]; then
            echo -e "${GREEN}✓ $description${NC}"
        else
            echo -e "${YELLOW}! $description (points to wrong location)${NC}"
        fi
    elif [ -e "$target" ]; then
        echo -e "${YELLOW}! $description (exists but not a symlink)${NC}"
    else
        echo -e "${RED}✗ $description (missing)${NC}"
    fi
}

DOTFILES_DIR="$HOME/.dotfiles/dotfiles"
check_symlink "$DOTFILES_DIR/zshrc" "$HOME/.zshrc" "Zsh configuration"
check_symlink "$DOTFILES_DIR/bashrc" "$HOME/.bashrc" "Bash configuration"
check_symlink "$DOTFILES_DIR/vscode" "$HOME/.config/Code/User" "VS Code settings"
check_symlink "$DOTFILES_DIR/zed" "$HOME/.config/zed" "Zed settings"
check_symlink "$DOTFILES_DIR/ghostty" "$HOME/.config/ghostty" "Ghostty configuration"

# Check applications
echo
echo -e "${BLUE}Checking applications...${NC}"

apps=(
    "Raycast:/Applications/Raycast.app"
    "Ghostty:/Applications/Ghostty.app"
    "Zed:/Applications/Zed.app"
    "VS Code:/Applications/Visual Studio Code.app"
    "Discord:/Applications/Discord.app"
    "Brave:/Applications/Brave Browser.app"
    "Rectangle:/Applications/Rectangle.app"
    "Obsidian:/Applications/Obsidian.app"
    "1Password:/Applications/1Password.app"
)

for app in "${apps[@]}"; do
    IFS=':' read -r name path <<< "$app"
    if [ -d "$path" ]; then
        echo -e "${GREEN}✓ $name${NC}"
    else
        echo -e "${RED}✗ $name${NC}"
    fi
done

# Check CLI tools
echo
echo -e "${BLUE}Checking CLI tools...${NC}"

tools=(
    "zsh:zsh --version"
    "zoxide:zoxide --version"
    "gh:gh --version"
    "bruno:bruno --version"
)

for tool in "${tools[@]}"; do
    IFS=':' read -r name cmd <<< "$tool"
    if command -v "$name" &> /dev/null; then
        echo -e "${GREEN}✓ $name${NC}"
    else
        echo -e "${RED}✗ $name${NC}"
    fi
done

# Check log file
echo
echo -e "${BLUE}Checking log file...${NC}"
if [ -f "$HOME/.dotfiles.log" ]; then
    echo -e "${GREEN}✓ Log file exists${NC}"
    echo -e "  Last update: $(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$HOME/.dotfiles.log")"
else
    echo -e "${YELLOW}! Log file not found${NC}"
fi

echo
echo -e "${BLUE}=== Health check complete ===${NC}"
