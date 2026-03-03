#!/bin/bash

# macOS system preferences configuration
# Used by install.sh for configuring macOS defaults

configure_macos() {
  echo "🍎 Configuring macOS system preferences..."

  # --- Dock ---
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock tilesize -int 26
  defaults write com.apple.dock orientation -string "right"
  defaults write com.apple.dock magnification -bool true

  # --- Finder ---
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.finder ShowStatusBar -bool true
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

  # --- Keyboard ---
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 15

  # --- Text Input ---
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

  # --- Screenshot ---
  defaults write com.apple.screencapture type -string "png"

  # Apply changes
  killall Dock 2>/dev/null || true
  killall Finder 2>/dev/null || true

  echo "✅ macOS preferences configured"
}
