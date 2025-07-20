# Mac Setup Repository Implementation Checklist

## Phase 1: Repository Structure Setup
- [ ] Create repository with initial structure
- [ ] Add `README.md` with usage instructions
- [ ] Create `install.sh` bootstrap script (curl-able entry point)
- [ ] Create `scripts/` directory for utility scripts
- [ ] Create `dotfiles/` directory for configuration files
- [ ] Create `Brewfile` for package management

## Phase 2: Brewfile Creation
- [ ] Add CLI tools to Brewfile:
  - [ ] `zsh` (shell)
  - [ ] `zoxide` (better cd command)
  - [ ] `gh` (GitHub CLI)
  - [ ] `bruno` (API testing tool)
- [ ] Add GUI applications to Brewfile (via casks):
  - [ ] `raycast` (launcher/productivity)
  - [ ] `ghostty` (terminal emulator)
  - [ ] `zed` (code editor)
  - [ ] `visual-studio-code` (VS Code)
  - [ ] `discord` (communication)
  - [ ] `brave-browser` (web browser)
  - [ ] `rectangle` (window management)
  - [ ] `obsidian` (note-taking)
  - [ ] `1password` (password manager)
  - [ ] `logi-options-plus` (Logitech device management)
  - [ ] `claude-code` (if available via brew, otherwise manual install)
  - [ ] `voiceink` (if available via brew, otherwise manual install)
  - [ ] `opencode` (if available via brew, otherwise manual install)
- [ ] Add comments explaining each package's purpose
- [ ] Group packages by category (CLI tools, productivity, development, etc.)

## Phase 3: Bootstrap Script (`install.sh`)
- [ ] Add macOS detection and exit if not macOS
- [ ] Install Homebrew if not present
- [ ] Install Git if not present
- [ ] Clone repository to `~/.mac-setup` or update if exists
- [ ] Call main setup script with proper error handling
- [ ] Add progress indicators and clear output messages

## Phase 4: Main Setup Script
- [ ] Create `scripts/setup.sh` for main installation logic
- [ ] Run `brew bundle install` with error handling
- [ ] Handle manual installations for apps not in Homebrew
- [ ] Call dotfiles setup script
- [ ] Add option flags (--dry-run, --skip-dotfiles, --skip-apps)
- [ ] Create installation log with timestamp

## Phase 5: Dotfiles Management
- [ ] Create `scripts/setup-dotfiles.sh`
- [ ] Create backup directory (`~/.config-backup-YYYY-MM-DD`)
- [ ] Add dotfiles with symlink mapping:
  - [ ] `.zshrc` → `dotfiles/zshrc`
  - [ ] `.bashrc` → `dotfiles/bashrc`
  - [ ] `~/.config/zoxide/` → `dotfiles/zoxide/`
  - [ ] VS Code settings → `dotfiles/vscode/`
  - [ ] Zed settings → `dotfiles/zed/`
  - [ ] Ghostty config → `dotfiles/ghostty/`
  - [ ] Claude Code config → `dotfiles/claude-code/` (if applicable)
  - [ ] OpenCode config → `dotfiles/opencode/` (if applicable)
- [ ] Create symlinks with conflict detection
- [ ] Handle broken symlinks cleanup

## Phase 6: Configuration Templates
- [ ] Create `.zshrc` with zoxide integration and common aliases
- [ ] Create `.bashrc` as fallback shell configuration
- [ ] Create VS Code `settings.json` with sensible defaults
- [ ] Create Zed configuration with themes and extensions
- [ ] Create Ghostty terminal configuration
- [ ] Add template system for machine-specific configs (work vs personal)

## Phase 7: Utility Scripts
- [ ] Create `scripts/update-brewfile.sh` to sync current system state
- [ ] Create `scripts/cleanup.sh` to remove symlinks and restore backups
- [ ] Create `scripts/check-health.sh` to verify installation state
- [ ] Add dry-run functionality to preview changes

## Phase 8: Error Handling & Logging
- [ ] Add comprehensive error messages for common failures
- [ ] Continue processing if individual items fail
- [ ] Log all changes to `~/.mac-setup.log`
- [ ] Add retry mechanism for network-dependent installations

## Phase 9: Documentation
- [ ] Write comprehensive README with:
  - [ ] One-line install command
  - [ ] Manual setup steps for apps not in Homebrew
  - [ ] Configuration customization guide
  - [ ] Troubleshooting section
- [ ] Document all configuration files and their purposes
- [ ] Add examples of customizing the setup for different use cases

## Phase 10: Testing & Validation
- [ ] Test bootstrap script on fresh macOS installation
- [ ] Verify all symlinks are created correctly
- [ ] Confirm all applications install and launch
- [ ] Test update and cleanup scripts
- [ ] Validate that running setup multiple times is safe (idempotent)

## Usage Command
```bash
curl -fsSL https://raw.githubusercontent.com/username/mac-setup/main/install.sh | bash
```