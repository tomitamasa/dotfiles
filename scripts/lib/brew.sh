#!/bin/bash

# Homebrew installation and package management utilities
# Used by install.sh for Homebrew setup and package installation

# Install Homebrew if not present
install_homebrew() {
  if command -v brew &>/dev/null; then
    echo "✅ Homebrew already installed"
    eval "$(brew shellenv)"
    return 0
  fi

  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to PATH for both Intel and Apple Silicon Macs
  if [ -f "/opt/homebrew/bin/brew" ]; then
    if ! grep -q '/opt/homebrew/bin/brew shellenv' ~/.zprofile 2>/dev/null; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
      echo "✅ Added Homebrew to ~/.zprofile"
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="/opt/homebrew/bin:$PATH"
  elif [ -f "/usr/local/bin/brew" ]; then
    if ! grep -q '/usr/local/bin/brew shellenv' ~/.zprofile 2>/dev/null; then
      echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
      echo "✅ Added Homebrew to ~/.zprofile"
    fi
    eval "$(/usr/local/bin/brew shellenv)"
    export PATH="/usr/local/bin:$PATH"
  fi
}

# Install packages from Brewfile
install_packages() {
  local dotfiles_dir="$1"
  
  echo "📦 Installing packages from Brewfile..."
  cd "$dotfiles_dir" || return 1

  # Retry logic for network issues
  for attempt in 1 2 3; do
    echo "📦 Installing packages... (attempt $attempt/3)"

    if brew bundle install --file=scripts/Brewfile --no-upgrade; then
      echo "✅ All packages installed successfully"
      break
    else
      if [ $attempt -eq 3 ]; then
        echo "⚠️  Some packages failed to install after 3 attempts"
        echo "🔧 You can run 'brew bundle install --file=scripts/Brewfile' manually later"
      else
        echo "⚠️  Some packages failed, retrying in 5 seconds..."
        sleep 5
      fi
    fi
  done
}

# Install additional fonts if needed (fallback for older systems)
install_additional_fonts() {
  echo "🎨 Checking additional font requirements..."
  
  # Check if we have adequate fonts for Powerlevel10k
  # fc-list is not available on macOS by default, so check Homebrew cask and ~/Library/Fonts
  local has_font=false
  if brew list --cask 2>/dev/null | grep -q "font-.*nerd-font\|font-meslo"; then
    has_font=true
  elif ls ~/Library/Fonts/ 2>/dev/null | grep -qi "nerd\|powerline\|meslo\|fira"; then
    has_font=true
  elif command -v fc-list &>/dev/null && fc-list | grep -i "nerd\|powerline\|meslo\|fira" >/dev/null 2>&1; then
    has_font=true
  fi

  if [ "$has_font" = false ]; then
    echo "⚠️  No Nerd Fonts detected, installing Powerline fonts as fallback..."
    
    local temp_dir
    temp_dir=$(mktemp -d)
    cd "$temp_dir" || return 1

    if git clone https://github.com/powerline/fonts.git --depth=1; then
      cd fonts || return 1
      ./install.sh
      cd ../..
      rm -rf "$temp_dir"
      echo "✅ Powerline fonts installed as fallback"
    else
      echo "⚠️  Failed to install Powerline fonts, using system defaults"
      rm -rf "$temp_dir"
    fi
  else
    echo "✅ Adequate fonts found for Powerlevel10k prompt"
  fi
}
