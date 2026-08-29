#!/bin/bash

# Symlink creation utilities
# Used by install.sh for creating configuration symlinks

# Function to create symlink with backup (idempotent)
create_symlink() {
  local source="$1"
  local target="$2"

  # Already pointing where we want: nothing to do
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "✅ $target"
    return 0
  fi

  # Ensure the parent directory exists
  mkdir -p "$(dirname "$target")"

  if [ -L "$target" ]; then
    # A symlink pointing somewhere else. Backing it up would only leave
    # broken links behind, so replace it outright.
    rm "$target"
    echo "🔄 Relinked $(basename "$target")"
  elif [ -e "$target" ]; then
    # A real file or directory. Always keep it, and never reuse a backup
    # name that is already taken -- `mv dir dir.backup` would move the
    # directory *inside* the existing backup and nest it one level deeper
    # on every run.
    local backup="$target.backup"
    if [ -e "$backup" ]; then
      backup="$target.backup.$(date +%Y%m%d%H%M%S)"
    fi
    mv "$target" "$backup"
    echo "🔄 Backed up $(basename "$target") -> $(basename "$backup")"
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

  # mise（ランタイムのバージョン固定）
  create_symlink "$dotfiles_dir/mise/config.toml" "$HOME/.config/mise/config.toml"

  # VS Code のユーザー設定（拡張は Brewfile 側）
  create_symlink "$dotfiles_dir/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
  create_symlink "$dotfiles_dir/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"

  # atuin（シェル履歴）
  create_symlink "$dotfiles_dir/atuin/config.toml" "$HOME/.config/atuin/config.toml"

  # Other configurations
  create_symlink "$dotfiles_dir/.amethyst.yml" "$HOME/.amethyst.yml"
  # Karabiner: karabiner.json 自体を symlink にすると、Karabiner-Elements が
  # 保存のたびに symlink を消してファイルで置き換えてしまう。公式ドキュメントの
  # 指示どおりディレクトリごと張る。
  # https://karabiner-elements.pqrs.org/docs/manual/misc/configuration-file-path/
  create_symlink "$dotfiles_dir/karabiner" "$HOME/.config/karabiner"
}
