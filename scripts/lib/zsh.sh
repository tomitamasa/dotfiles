#!/bin/bash

# Zsh plugin installation utilities
# Used by install.sh for Sheldon plugin management

# Install Zsh plugins via Sheldon
install_zsh_plugins() {
  echo "🔌 Installing Zsh plugins via Sheldon..."

  if ! command -v sheldon &>/dev/null; then
    echo "⚠️  Sheldon not installed - skipping plugin installation"
    echo "💡 Install with: brew install sheldon"
    return 1
  fi

  if [ ! -f "$HOME/.config/sheldon/plugins.toml" ]; then
    echo "⚠️  plugins.toml not found - skipping plugin installation"
    return 1
  fi

  sheldon lock --update || {
    echo "⚠️  Sheldon plugin installation failed"
    echo "💡 You can manually install with: sheldon lock --update"
    return 1
  }

  echo "✅ Zsh plugins installed"
}
