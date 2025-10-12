#!/bin/bash

# Dotfiles installation script for macOS
set -e  # Exit on error

echo "🚀 Starting dotfiles installation..."

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
  
  # Add Homebrew to PATH for both Intel and Apple Silicon Macs
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="/opt/homebrew/bin:$PATH"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile  
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
mkdir -p ~/.config/fish
mkdir -p ~/.config/karabiner

# Function to create symlink with backup (idempotent)
create_symlink() {
  local source="$1"
  local target="$2"
  
  # Check if the correct symlink already exists
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "✅ Symlink already exists: $target -> $source"
    return 0
  fi
  
  # Backup existing file/link if it exists and is different
  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "🔄 Backing up existing $target to $target.backup"
    mv "$target" "$target.backup"
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
create_symlink "$DOTFILES_DIR/fish/completions" "$HOME/.config/fish/completions"
create_symlink "$DOTFILES_DIR/fish/functions" "$HOME/.config/fish/functions"

# Zsh configuration
create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# Amethyst configuration
create_symlink "$DOTFILES_DIR/.amethyst.yml" "$HOME/.amethyst.yml"

# Karabiner configuration
create_symlink "$DOTFILES_DIR/karabiner/complex_modifications" "$HOME/.config/karabiner/complex_modifications"

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

echo ""
echo "🎉 Dotfiles installation completed successfully!"
echo ""
echo "📝 Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Use 'f' command to switch to fish shell"
echo "  3. Install fish plugins by running: fisher install"
echo ""
echo "✨ Enjoy your new development environment!"
