#!/bin/bash

# Dotfiles installation script for macOS
# Refactored for simplicity and modularity

set -e  # Exit on error

echo "🚀 Starting dotfiles installation..."

# Get dotfiles directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

echo "📂 Dotfiles directory: $DOTFILES_DIR"

# Check if we're on macOS
if [ "$(uname)" != 'Darwin' ]; then
  echo "❌ This script is designed for macOS only!"
  exit 1
fi

echo "✅ macOS detected"

# Source utility libraries
source "$SCRIPT_DIR/lib/brew.sh"
source "$SCRIPT_DIR/lib/symlinks.sh"
source "$SCRIPT_DIR/lib/zsh.sh"
source "$SCRIPT_DIR/lib/macos.sh"

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p "$HOME/.config/"{sheldon,"karabiner/assets"}
echo "✅ Directories created"

# Install Homebrew
install_homebrew

# Create configuration symlinks
create_dotfiles_symlinks "$DOTFILES_DIR"

# Install packages from Brewfile
install_packages "$DOTFILES_DIR"

# Install additional fonts if needed
install_additional_fonts

# Install Zsh plugins
install_zsh_plugins

# Configure macOS system preferences
configure_macos

echo ""
echo "🎉 Dotfiles installation completed successfully!"
echo ""
echo "📝 Next steps:"
echo "  1. Restart your terminal or run: exec zsh"
echo "  2. Run 'p10k configure' to customize your prompt"
echo "  3. Customize aliases in ~/dotfiles/zsh/aliases.zsh"
echo ""
echo "✨ Enjoy your new development environment!"
