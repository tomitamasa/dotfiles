#!/bin/bash

# Dotfiles installation script for macOS
# Refactored for simplicity and modularity

# shellcheck source-path=SCRIPTDIR
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
# shellcheck source=lib/brew.sh
source "$SCRIPT_DIR/lib/brew.sh"
# shellcheck source=lib/symlinks.sh
source "$SCRIPT_DIR/lib/symlinks.sh"
# shellcheck source=lib/zsh.sh
source "$SCRIPT_DIR/lib/zsh.sh"
# shellcheck source=lib/macos.sh
source "$SCRIPT_DIR/lib/macos.sh"
# shellcheck source=lib/defaults.sh
source "$SCRIPT_DIR/lib/defaults.sh"

# Install Homebrew
install_homebrew

# Create configuration symlinks
create_dotfiles_symlinks "$DOTFILES_DIR"

# Install packages from Brewfile
# set -e で即座に落とさず、symlink 済みの環境を最後まで整えたうえで
# 最後に失敗を報告する（パッケージが欠けても他の設定は使えるため）。
INSTALL_STATUS=0
install_packages "$DOTFILES_DIR" || INSTALL_STATUS=1

# Install additional fonts if needed
install_additional_fonts

# Install Zsh plugins
install_zsh_plugins

# Configure macOS system preferences
configure_macos

# Import GUI app settings (AltTab, Amethyst)
import_app_defaults "$DOTFILES_DIR"

echo ""
if [ "$INSTALL_STATUS" -ne 0 ]; then
  echo "⚠️  一部のパッケージが入りませんでした（上のログを確認してください）"
  echo "   App Store 経由（mas）のアプリは sudo が必要で、install.sh からは入りません。"
  echo "   その場合は App Store から手で入れてください。"
  echo ""
fi
echo "🎉 Dotfiles installation completed!"
echo ""
echo "📝 Next steps:"
echo "  1. Restart your terminal or run: exec zsh"
echo "  2. Run 'p10k configure' to customize your prompt"
echo "  3. Customize aliases in ~/dotfiles/zsh/aliases.zsh"
echo ""
echo "✨ Enjoy your new development environment!"

exit "$INSTALL_STATUS"
