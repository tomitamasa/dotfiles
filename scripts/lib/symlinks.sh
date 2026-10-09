#!/bin/bash
create_symlink() {
  local source="$1" target="$2" backup
  [ -e "$source" ] || { echo "Missing source: $source" >&2; return 1; }
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then return 0; fi
  mkdir -p "$(dirname "$target")"
  if [ -L "$target" ] || [ -e "$target" ]; then
    backup=$(mktemp -d "${target}.backup.XXXXXXXX") || return 1
    rmdir "$backup" || return 1
    mv "$target" "$backup" || return 1
    echo "Preserved $target as $backup"
  fi
  ln -s "$source" "$target"
}
create_dotfiles_symlinks() {
  local dotfiles_dir="$1" feature
  shift
  create_symlink "$dotfiles_dir/git/config" "$HOME/.gitconfig"
  create_symlink "$dotfiles_dir/git/ignore" "$HOME/.gitignore_global"
  create_symlink "$dotfiles_dir/zsh/.zshrc" "$HOME/.zshrc"
  create_symlink "$dotfiles_dir/zsh/.zprofile" "$HOME/.zprofile"
  create_symlink "$dotfiles_dir/zsh/plugins.toml" "$HOME/.config/sheldon/plugins.toml"
  create_symlink "$dotfiles_dir/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
  create_symlink "$dotfiles_dir/ghostty/config" "$HOME/.config/ghostty/config"
  for feature in "$@"; do
    case "$feature" in
      editor)
        create_symlink "$dotfiles_dir/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
        create_symlink "$dotfiles_dir/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json" ;;
      window)
        create_symlink "$dotfiles_dir/.amethyst.yml" "$HOME/.amethyst.yml"
        create_symlink "$dotfiles_dir/karabiner" "$HOME/.config/karabiner" ;;
    esac
  done
}
