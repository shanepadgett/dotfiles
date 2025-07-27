#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Install Claude Code
install_claude_code() {
    print_header "Installing Claude Code"
    
    if command -v claude &> /dev/null; then
        print_success "Claude Code already installed"
        return 0
    fi
    
    print_info "Installing Claude Code via official installer..."
    if curl -fsSL claude.ai/install.sh | bash; then
        print_success "Claude Code installed successfully"
    else
        print_error "Failed to install Claude Code"
        return 1
    fi
}

# Install OpenCode
install_opencode() {
    print_header "Installing OpenCode"
    
    if command -v opencode &> /dev/null; then
        print_success "OpenCode already installed"
        return 0
    fi
    
    print_info "Installing OpenCode via official installer..."
    if curl -fsSL https://opencode.ai/install | bash; then
        print_success "OpenCode installed successfully"
    else
        print_error "Failed to install OpenCode"
        return 1
    fi
}

# Uninstall AI coding tools
uninstall_ai_tools() {
    print_header "Uninstalling AI Coding Tools"
    
    local tools_removed=0
    
    # Claude Code
    if command -v claude &> /dev/null; then
        print_info "Uninstalling Claude Code..."
        if [[ -f "$HOME/.local/bin/claude" ]]; then
            rm -f "$HOME/.local/bin/claude"
            rm -rf "$HOME/.claude"
            print_success "Claude Code uninstalled"
            ((tools_removed++))
        fi
    fi
    
    # OpenCode
    if command -v opencode &> /dev/null; then
        print_info "Uninstalling OpenCode..."
        if [[ -f "$HOME/.local/bin/opencode" ]]; then
            rm -f "$HOME/.local/bin/opencode"
            rm -rf "$HOME/.opencode"
            print_success "OpenCode uninstalled"
            ((tools_removed++))
        fi
    fi
    
    # Clean PATH entries
    local shell_configs=("$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile")
    for config in "${shell_configs[@]}"; do
        if [[ -f "$config" ]]; then
            sed -i.bak '/\.local\/bin/d' "$config" 2>/dev/null || true
        fi
    done
    
    echo
    if [[ $tools_removed -eq 0 ]]; then
        print_info "No AI coding tools found to uninstall"
    else
        print_success "$tools_removed AI coding tool(s) uninstalled"
    fi
}

# Main execution
main() {
    local action="${1:-install}"
    
    case "$action" in
        install)
            print_header "AI Coding Tools Installation"
            
            local failed=0
            install_claude_code || ((failed++))
            install_opencode || ((failed++))
            
            echo
            if [[ $failed -eq 0 ]]; then
                print_success "All AI coding tools installed successfully!"
            else
                print_warning "$failed tool(s) failed to install. Check the log for details."
                return 1
            fi
            ;;
        uninstall)
            uninstall_ai_tools
            ;;
        *)
            echo "Usage: $0 [install|uninstall]"
            echo "  install   - Install AI coding tools (default)"
            echo "  uninstall - Remove AI coding tools"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"