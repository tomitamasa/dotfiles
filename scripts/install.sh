#!/bin/bash

# Dotfiles installation script for macOS
set -e  # Exit on error

echo "🚀 Starting dotfiles installation..."

# Get the directory where this script is located (compatible with both bash and zsh)
if [ -n "${BASH_SOURCE[0]}" ]; then
  # Running in bash
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "${(%):-%x}" ] 2>/dev/null; then
  # Running in zsh
  SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
else
  # Fallback: assume script is in current directory
  SCRIPT_DIR="$(pwd)"
fi

DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

echo "📂 Dotfiles directory: $DOTFILES_DIR"

# Check if we're on macOS
if [ "$(uname)" != 'Darwin' ]; then
  echo "❌ This script is designed for macOS only!"
  exit 1
fi

echo "✅ macOS detected"

# Install Homebrew if not already installed
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to PATH for both Intel and Apple Silicon Macs (idempotent)
  if [ -f "/opt/homebrew/bin/brew" ]; then
    # Check if already added to avoid duplication
    if ! grep -q '/opt/homebrew/bin/brew shellenv' ~/.zprofile 2>/dev/null; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
      echo "✅ Added Homebrew to ~/.zprofile"
    else
      echo "✅ Homebrew already configured in ~/.zprofile"
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="/opt/homebrew/bin:$PATH"
  elif [ -f "/usr/local/bin/brew" ]; then
    # Check if already added to avoid duplication
    if ! grep -q '/usr/local/bin/brew shellenv' ~/.zprofile 2>/dev/null; then
      echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
      echo "✅ Added Homebrew to ~/.zprofile"
    else
      echo "✅ Homebrew already configured in ~/.zprofile"
    fi
    eval "$(/usr/local/bin/brew shellenv)"
    export PATH="/usr/local/bin:$PATH"
  fi
else
  echo "✅ Homebrew already installed"
  # Ensure Homebrew is in PATH
  if command -v brew &>/dev/null; then
    eval "$(brew shellenv)"
  fi
fi

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p "$HOME/.config/fish/"{completions,functions,conf.d}
mkdir -p "$HOME/.config/karabiner/assets"

# Function to create symlink with backup (idempotent)
create_symlink() {
  local source="$1"
  local target="$2"
  
  # Check if the correct symlink already exists
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "✅ Symlink already exists: $target -> $source"
    return 0
  fi
  
  # Only backup files that are not plugin-generated files
  if [ -e "$target" ] || [ -L "$target" ]; then
    local filename=$(basename "$target")
    
    # Skip backup for plugin files (they will be regenerated)
    case "$filename" in
      _*|*tide*|*fzf*|fish_mode_prompt.fish|fish_prompt.fish|autopair.fish)
        echo "🗑️  Removing plugin file: $target"
        rm -f "$target"
        ;;
      *)
        echo "🔄 Backing up existing $target to $target.backup"
        mv "$target" "$target.backup"
        ;;
    esac
  fi
  
  ln -s "$source" "$target"
  echo "🔗 Created symlink: $target -> $source"
}

# Create symlinks
echo "🔗 Creating symlinks..."

# Git configuration
create_symlink "$DOTFILES_DIR/git/config" "$HOME/.gitconfig"
create_symlink "$DOTFILES_DIR/git/ignore" "$HOME/.gitignore_global"

# Fish shell configuration
create_symlink "$DOTFILES_DIR/fish/config.fish" "$HOME/.config/fish/config.fish"
create_symlink "$DOTFILES_DIR/fish/fish_plugins" "$HOME/.config/fish/fish_plugins"

# Only symlink our custom functions (not plugin files)
if [ -d "$DOTFILES_DIR/fish/functions" ]; then
  for func_file in "$DOTFILES_DIR/fish/functions"/*.fish; do
    if [ -f "$func_file" ]; then
      filename=$(basename "$func_file")
      # Only symlink files that actually exist in dotfiles (our custom functions)
      create_symlink "$func_file" "$HOME/.config/fish/functions/$filename"
    fi
  done
fi

# Only symlink our custom completions (not plugin files)
if [ -d "$DOTFILES_DIR/fish/completions" ]; then
  for comp_file in "$DOTFILES_DIR/fish/completions"/*.fish; do
    if [ -f "$comp_file" ]; then
      filename=$(basename "$comp_file")
      # Only symlink files that actually exist in dotfiles (our custom completions)
      create_symlink "$comp_file" "$HOME/.config/fish/completions/$filename"
    fi
  done
fi

# Zsh configuration
create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# Amethyst configuration
create_symlink "$DOTFILES_DIR/.amethyst.yml" "$HOME/.amethyst.yml"

# Karabiner configuration
mkdir -p "$HOME/.config/karabiner/assets"
create_symlink "$DOTFILES_DIR/karabiner/complex_modifications" "$HOME/.config/karabiner/assets/complex_modifications"

# Tool versions
create_symlink "$DOTFILES_DIR/.tool-versions" "$HOME/.tool-versions"

# Install packages from Brewfile
echo "📦 Installing packages from Brewfile..."
cd "$DOTFILES_DIR"

if [ "$CI" = "true" ]; then
  echo "🤖 CI environment detected - installing CLI tools only"
  # Use CI-specific Brewfile with only CLI tools
  brew bundle install --file=scripts/Brewfile.ci --no-upgrade || {
    echo "⚠️  Some packages failed to install in CI - continuing..."
  }
else
  echo "💻 Local environment - installing all packages"
  
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
        echo "📝 Or install specific failed packages individually with 'brew install <package>'"
      else
        echo "⚠️  Some packages failed, retrying in 5 seconds..."
        sleep 5
      fi
    fi
  done
fi

# Install fish plugins automatically (idempotent)
echo "🐠 Installing fish plugins..."
if command -v fish &>/dev/null; then
  # Check if fish_plugins file exists and has content
  if [ -f "$HOME/.config/fish/fish_plugins" ] && [ -s "$HOME/.config/fish/fish_plugins" ]; then
    echo "📋 Found fish_plugins file, installing plugins..."
    
    # Read plugins from fish_plugins file
    PLUGINS=$(cat "$HOME/.config/fish/fish_plugins" | grep -v '^#' | grep -v '^$' | tr '\n' ' ')
    
    if [ -n "$PLUGINS" ]; then
      fish -c "
        # Install fisher if not present
        if not type -q fisher
          echo 'Installing fisher...'
          curl -sL https://git.io/fisher | source
        end
        
        # Install plugins with explicit plugin list
        echo 'Installing/updating fish plugins: $PLUGINS'
        fisher install $PLUGINS
        
        echo 'Fish plugins installation completed'
      " || {
        echo "⚠️  Fish plugins installation failed - they will be installed on first fish startup"
        echo "💡 You can manually install with: fish -c 'curl -sL https://git.io/fisher | source && fisher install $PLUGINS'"
      }
    else
      echo "ℹ️  No valid plugins found in fish_plugins file"
    fi
  else
    echo "ℹ️  No fish_plugins file found or empty - skipping plugin installation"
  fi
else
  echo "ℹ️  Fish not installed - skipping plugin installation"
fi

echo ""
echo "🎉 Dotfiles installation completed successfully!"
echo ""
echo "📝 Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Use 'f' command to switch to fish shell"
echo "  3. Fish plugins and Tide prompt are automatically configured"
echo ""
echo "✨ Enjoy your new development environment!"
