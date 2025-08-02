#!/bin/bash

# macOS System Defaults Configuration
# Sets up system preferences and dock configuration

set -e

# Source centralized logging system
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/lib/logger.sh"

log_header "Configuring macOS system defaults"

# Dock Configuration
log_step "Configuring Dock settings"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.5
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock orientation -string "bottom"
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock minimize-to-application -bool true

# Trackpad Configuration
log_step "Configuring trackpad settings"
# Enable two-finger swipe for back/forward navigation
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
# Enable three-finger drag (requires restart)
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Finder Configuration
log_step "Configuring Finder settings"
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Desktop Configuration
log_step "Configuring desktop settings"
# Disable "Show Desktop" gesture (clicking wallpaper to hide all windows)
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# Clear existing dock
log_step "Clearing existing dock"
defaults write com.apple.dock persistent-apps -array

# Add GUI applications to dock
log_step "Adding applications to dock"

# Define applications to add to dock (in order)
apps=(
    "/Applications/Brave Browser.app"
    "/Applications/Visual Studio Code.app"
    "/Applications/Zed.app"
    "/Applications/Ghostty.app"
    "/Applications/Bruno.app"
    "/Applications/Obsidian.app"
    "/Applications/1Password.app"
    "/Applications/Discord.app"
    "/Applications/OrbStack.app"
)

# Add each application to dock if it exists
for app in "${apps[@]}"; do
    if [ -d "$app" ]; then
        log_info "Adding $(basename "$app" .app) to dock"
        defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
    else
        log_warning "$(basename "$app" .app) not found, skipping"
    fi
done

# Restart affected services
log_step "Restarting Dock and Finder"
killall Dock
killall Finder

log_success "macOS defaults configured successfully!"
log_info "Note: Some trackpad settings may require a logout/login to take effect."
