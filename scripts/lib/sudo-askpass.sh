#!/bin/bash

# sudo-askpass helper that uses macOS keychain for temporary password storage
# This script is called by sudo when SUDO_ASKPASS is set

KEYCHAIN_SERVICE="dotfiles-sudo"
KEYCHAIN_ACCOUNT="$(whoami)"

# Try to get password from keychain first
if security find-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" -w 2>/dev/null; then
  exit 0
fi

# If not in keychain, prompt user and store it
if command -v osascript >/dev/null 2>&1; then
  # Use AppleScript for GUI prompt
  PASSWORD=$(osascript -e 'display dialog "Administrator password required for dotfiles setup:" default answer "" with hidden answer' -e 'text returned of result' 2>/dev/null)
  if [[ -n $PASSWORD ]]; then
    # Store in keychain temporarily (will be cleaned up later)
    echo "$PASSWORD" | security add-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" -w
    echo "$PASSWORD"
    exit 0
  fi
fi

# Fallback to terminal prompt
echo "Password required for sudo operations:" >&2
read -r -s PASSWORD
echo "$PASSWORD" | security add-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" -w 2>/dev/null || true
echo "$PASSWORD"
