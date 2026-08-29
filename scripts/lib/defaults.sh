#!/bin/bash

# GUI アプリの設定（plist）の流し込み。
# 書き出し側は scripts/export-app-defaults.sh。

# Import macos/*.plist into their corresponding defaults domains
import_app_defaults() {
  local dotfiles_dir="$1"
  local dir="$dotfiles_dir/macos"

  if [ ! -d "$dir" ]; then
    echo "⏭  macos/ が無いのでスキップ"
    return 0
  fi

  echo "🖥  アプリ設定を流し込み中..."

  local file domain app_running
  for file in "$dir"/*.plist; do
    [ -f "$file" ] || continue

    domain=$(basename "$file" .plist)

    # 起動中のアプリは終了時に自前の設定で上書きしてしまうため、
    # 流し込む前に落とす（起動していなければ何もしない）
    app_running=false
    if pgrep -qf "$domain" 2>/dev/null; then
      app_running=true
      osascript -e "tell application id \"$domain\" to quit" &>/dev/null || true
      sleep 1
    fi

    if defaults import "$domain" "$file"; then
      echo "  ✅ $domain"
    else
      echo "  ⚠️  $domain の流し込みに失敗しました"
    fi

    if [ "$app_running" = true ]; then
      open -gb "$domain" &>/dev/null || true
    fi
  done
}
