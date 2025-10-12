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
  
  # Handle existing files/links
  if [ -e "$target" ] || [ -L "$target" ]; then
    local filename=$(basename "$target")
    
    # Remove plugin files (they will be regenerated)
    case "$filename" in
      _*|*tide*|*fzf*|fish_mode_prompt.fish|fish_prompt.fish|autopair.fish)
        rm -f "$target"
        ;;
      *)
        mv "$target" "$target.backup"
        echo "🔄 Backed up $filename"
        ;;
    esac
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
  
  # Fish shell configuration
  create_symlink "$dotfiles_dir/fish/config.fish" "$HOME/.config/fish/config.fish"
  create_symlink "$dotfiles_dir/fish/fish_plugins" "$HOME/.config/fish/fish_plugins"
  create_symlink "$dotfiles_dir/fish/tide_setup.fish" "$HOME/.config/fish/tide_setup.fish"
  
  # Custom fish functions
  if [ -d "$dotfiles_dir/fish/functions" ]; then
    for func_file in "$dotfiles_dir/fish/functions"/*.fish; do
      if [ -f "$func_file" ]; then
        local filename=$(basename "$func_file")
        create_symlink "$func_file" "$HOME/.config/fish/functions/$filename"
      fi
    done
  fi
  
  # Custom fish completions
  if [ -d "$dotfiles_dir/fish/completions" ]; then
    for comp_file in "$dotfiles_dir/fish/completions"/*.fish; do
      if [ -f "$comp_file" ]; then
        local filename=$(basename "$comp_file")
        create_symlink "$comp_file" "$HOME/.config/fish/completions/$filename"
      fi
    done
  fi
  
  # Other configurations
  create_symlink "$dotfiles_dir/.zshrc" "$HOME/.zshrc"
  create_symlink "$dotfiles_dir/.zprofile" "$HOME/.zprofile"
  create_symlink "$dotfiles_dir/.amethyst.yml" "$HOME/.amethyst.yml"
  create_symlink "$dotfiles_dir/karabiner/complex_modifications" "$HOME/.config/karabiner/assets/complex_modifications"
  create_symlink "$dotfiles_dir/.tool-versions" "$HOME/.tool-versions"
}
