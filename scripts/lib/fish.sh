#!/bin/bash

# Fish shell plugin installation utilities
# Used by install.sh for Fish plugin management

# Install fish plugins automatically
install_fish_plugins() {
  echo "🐠 Installing fish plugins..."
  
  if ! command -v fish &>/dev/null; then
    echo "ℹ️  Fish not installed - skipping plugin installation"
    return 0
  fi

  if [ ! -f "$HOME/.config/fish/fish_plugins" ] || [ ! -s "$HOME/.config/fish/fish_plugins" ]; then
    echo "ℹ️  No fish_plugins file found or empty - skipping plugin installation"
    return 0
  fi

  echo "📋 Found fish_plugins file, installing plugins..."
  
  # Read plugins from fish_plugins file
  local plugins=$(cat "$HOME/.config/fish/fish_plugins" | grep -v '^#' | grep -v '^$' | tr '\n' ' ')
  
  if [ -z "$plugins" ]; then
    echo "ℹ️  No valid plugins found in fish_plugins file"
    return 0
  fi

  fish -c "
    # Install fisher if not present
    if not type -q fisher
      echo 'Installing fisher...'
      curl -sL https://git.io/fisher | source
    end
    
    # Install plugins with explicit plugin list
    echo 'Installing/updating fish plugins: $plugins'
    fisher install $plugins
    
    echo 'Fish plugins installation completed'
  " || {
    echo "⚠️  Fish plugins installation failed - they will be installed on first fish startup"
    echo "💡 You can manually install with: fish -c 'curl -sL https://git.io/fisher | source && fisher install $plugins'"
  }
}
