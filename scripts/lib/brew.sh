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
      # shellcheck disable=SC2016  # literal line is written verbatim to ~/.zprofile by design
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
      echo "✅ Added Homebrew to ~/.zprofile"
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="/opt/homebrew/bin:$PATH"
  elif [ -f "/usr/local/bin/brew" ]; then
    if ! grep -q '/usr/local/bin/brew shellenv' ~/.zprofile 2>/dev/null; then
      # shellcheck disable=SC2016  # literal line is written verbatim to ~/.zprofile by design
      echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
      echo "✅ Added Homebrew to ~/.zprofile"
    fi
    eval "$(/usr/local/bin/brew shellenv)"
    export PATH="/usr/local/bin:$PATH"
  fi
}

# Resolve the machine profile used to pick an extra Brewfile.
# 私用端末と業務端末で入れるものを分けるための仕組み。
# 優先順: 環境変数 DOTFILES_PROFILE > ~/.dotfiles-profile > 未設定（共通のみ）
# プロファイル名はファイル名の一部になるため、英数字・ハイフン・アンダースコアに限る。
resolve_profile() {
  local profile=""

  if [ -n "${DOTFILES_PROFILE:-}" ]; then
    profile="$DOTFILES_PROFILE"
  elif [ -f "$HOME/.dotfiles-profile" ]; then
    profile=$(head -n 1 "$HOME/.dotfiles-profile" | tr -d '[:space:]')
  fi

  case "$profile" in
    "") return 0 ;;
    *[!a-zA-Z0-9_-]*)
      echo "⚠️  プロファイル名に使えない文字が含まれています: $profile" >&2
      return 0
      ;;
    *) echo "$profile" ;;
  esac
}

# Install packages from a single Brewfile (with retry for network issues)
install_brewfile() {
  local file="$1"

  for attempt in 1 2 3; do
    echo "📦 Installing packages from $file... (attempt $attempt/3)"

    if brew bundle install --file="$file" --no-upgrade; then
      echo "✅ $file: all packages installed successfully"
      return 0
    fi

    if [ "$attempt" -eq 3 ]; then
      echo "⚠️  $file: some packages failed to install after 3 attempts"
      echo "🔧 You can run 'brew bundle install --file=$file' manually later"
    else
      echo "⚠️  Some packages failed, retrying in 5 seconds..."
      sleep 5
    fi
  done
}

# Install packages from the shared Brewfile plus the profile overlay
install_packages() {
  local dotfiles_dir="$1"
  local profile overlay

  cd "$dotfiles_dir" || return 1

  install_brewfile "scripts/Brewfile"

  profile=$(resolve_profile)
  if [ -z "$profile" ]; then
    echo "ℹ️  プロファイル未設定のため共通分のみ入れました"
    echo "   私用端末なら: echo personal > ~/.dotfiles-profile"
    return 0
  fi

  overlay="scripts/Brewfile.$profile"
  if [ ! -f "$overlay" ]; then
    echo "⚠️  プロファイル '$profile' 用の $overlay が無いため共通分のみ入れました"
    return 0
  fi

  echo "📦 プロファイル: $profile"
  install_brewfile "$overlay"
}

# Install additional fonts if needed (fallback for older systems)
install_additional_fonts() {
  echo "🎨 Checking additional font requirements..."
  
  # Check if we have adequate fonts for Powerlevel10k
  # fc-list is not available on macOS by default, so check Homebrew cask and ~/Library/Fonts
  local has_font=false
  if brew list --cask 2>/dev/null | grep -q "font-.*nerd-font\|font-meslo"; then
    has_font=true
  elif [ -n "$(find "$HOME/Library/Fonts" -maxdepth 1 \( -iname '*nerd*' -o -iname '*powerline*' -o -iname '*meslo*' -o -iname '*fira*' \) -print -quit 2>/dev/null)" ]; then
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
