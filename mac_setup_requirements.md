# Mac Setup Repository Implementation Checklist

## Phase 1: Repository Structure Setup
- [x] Create repository with initial structure
- [x] Add `README.md` with usage instructions
- [x] Create `install.sh` bootstrap script (curl-able entry point)
- [x] Create `scripts/` directory for utility scripts
- [x] Create `dotfiles/` directory for configuration files
- [x] Create `Brewfile` for package management

## Phase 2: Brewfile Creation
- [x] Add CLI tools to Brewfile:
  - [x] `zsh` (shell)
  - [x] `zoxide` (better cd command)
  - [x] `gh` (GitHub CLI)
  - [x] `bruno` (API testing tool)
- [x] Add GUI applications to Brewfile (via casks):
  - [x] `raycast` (launcher/productivity)
  - [x] `ghostty` (terminal emulator)
  - [x] `zed` (code editor)
  - [x] `visual-studio-code` (VS Code)
  - [x] `discord` (communication)
  - [x] `brave-browser` (web browser)
  - [x] `rectangle` (window management)
  - [x] `obsidian` (note-taking)
  - [x] `1password` (password manager)
  - [x] `logi-options-plus` (Logitech device management)
  - [x] `claude-code` (if available via brew, otherwise manual install)
  - [x] `voiceink` (if available via brew, otherwise manual install)
  - [x] `opencode` (if available via brew, otherwise manual install)
- [x] Add comments explaining each package's purpose
- [x] Group packages by category (CLI tools, productivity, development, etc.)

## Phase 3: Bootstrap Script (`install.sh`)
- [x] Add macOS detection and exit if not macOS
- [x] Install Homebrew if not present
- [x] Install Git if not present
- [x] Clone repository to `~/.mac-setup` or update if exists
- [x] Call main setup script with proper error handling
- [x] Add progress indicators and clear output messages

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
- [x] Add comprehensive error messages for common failures
- [ ] Continue processing if individual items fail
- [x] Log all changes to `~/.mac-setup.log`
- [ ] Add retry mechanism for network-dependent installations

## Phase 9: Documentation
- [x] Write comprehensive README with:
  - [x] One-line install command
  - [x] Manual setup steps for apps not in Homebrew
  - [x] Configuration customization guide
  - [x] Troubleshooting section
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