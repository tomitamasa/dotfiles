#!/bin/bash

# Symlink creation utilities
# Used by install.sh for creating configuration symlinks

# Function to create symlink with backup (idempotent)
create_symlink() {
  local source="$1"
  local target="$2"
  
  # Check if the correct symlink already exists
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "✅ $target"
    return 0
  fi
  
  # Ensure the parent directory exists
  mkdir -p "$(dirname "$target")"

  # Handle existing files/links
  if [ -e "$target" ] || [ -L "$target" ]; then
    local filename
    filename=$(basename "$target")
    
    mv "$target" "$target.backup"
    echo "🔄 Backed up $filename"
  fi
  
  ln -s "$source" "$target"
  echo "🔗 $target"
}

# Create all dotfiles symlinks
create_dotfiles_symlinks() {
  local dotfiles_dir="$1"
  
  echo "🔗 Creating symlinks..."
  
  # Git configuration
  create_symlink "$dotfiles_dir/git/config" "$HOME/.gitconfig"
  create_symlink "$dotfiles_dir/git/ignore" "$HOME/.gitignore_global"
  
  # Zsh configuration
  create_symlink "$dotfiles_dir/zsh/.zshrc" "$HOME/.zshrc"
  create_symlink "$dotfiles_dir/zsh/.zprofile" "$HOME/.zprofile"
  create_symlink "$dotfiles_dir/zsh/plugins.toml" "$HOME/.config/sheldon/plugins.toml"
  if [ -f "$dotfiles_dir/zsh/.p10k.zsh" ]; then
    create_symlink "$dotfiles_dir/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
  fi

  # Ghostty（cmux も同じ設定ファイルを読む）
  create_symlink "$dotfiles_dir/ghostty/config" "$HOME/.config/ghostty/config"

  # atuin（シェル履歴）
  create_symlink "$dotfiles_dir/atuin/config.toml" "$HOME/.config/atuin/config.toml"

  # Other configurations
  create_symlink "$dotfiles_dir/.amethyst.yml" "$HOME/.amethyst.yml"
  create_symlink "$dotfiles_dir/karabiner/complex_modifications" "$HOME/.config/karabiner/assets/complex_modifications"
}
