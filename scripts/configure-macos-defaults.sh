#!/bin/bash

# macOS System Defaults Configuration
# Sets up system preferences and dock configuration

set -e

echo "🍎 Configuring macOS system defaults..."

# Dock Configuration
echo "  → Configuring Dock settings..."
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.5
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock orientation -string "bottom"
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock minimize-to-application -bool true

# Trackpad Configuration
echo "  → Configuring trackpad settings..."
# Enable two-finger swipe for back/forward navigation
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
# Enable three-finger drag (requires restart)
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Finder Configuration
echo "  → Configuring Finder settings..."
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Clear existing dock
echo "  → Clearing existing dock..."
defaults write com.apple.dock persistent-apps -array

# Add GUI applications to dock
echo "  → Adding applications to dock..."

# Define applications to add to dock (in order)
apps=(
    "/Applications/Brave Browser.app"
    "/Applications/Visual Studio Code.app"
    "/Applications/Zed.app"
    "/Applications/Ghostty.app"
    "/Applications/Bruno.app"
    "/Applications/Obsidian.app"
    "/Applications/1Password 7 - Password Manager.app"
    "/Applications/Raycast.app"
    "/Applications/Discord.app"
    "/Applications/OrbStack.app"
)

# Add each application to dock if it exists
for app in "${apps[@]}"; do
    if [ -d "$app" ]; then
        echo "    Adding $(basename "$app" .app) to dock..."
        defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
    else
        echo "    ⚠️  $(basename "$app" .app) not found, skipping..."
    fi
done

# Restart affected services
echo "  → Restarting Dock and Finder..."
killall Dock
killall Finder

echo "✅ macOS defaults configured successfully!"
echo "📝 Note: Some trackpad settings may require a logout/login to take effect."