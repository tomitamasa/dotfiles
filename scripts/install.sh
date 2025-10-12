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
  (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/$USER/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "✅ Homebrew already installed"
fi

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p ~/.config/fish
mkdir -p ~/.config/karabiner

# Function to create symlink with backup
create_symlink() {
  local source="$1"
  local target="$2"
  
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
brew bundle install --file=scripts/Brewfile

echo ""
echo "🎉 Dotfiles installation completed successfully!"
echo ""
echo "📝 Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Use 'f' command to switch to fish shell"
echo "  3. Install fish plugins by running: fisher install"
echo ""
echo "✨ Enjoy your new development environment!"
