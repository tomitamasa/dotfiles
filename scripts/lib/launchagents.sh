#!/bin/bash

# LaunchAgent（GUI 抜きで常駐させるサービス）の配置。
#
# launchagents/*.plist.template の __HOME__ を実際のホームに置き換えて
# ~/Library/LaunchAgents/ へ書き出し、launchctl に読み込ませる。
# symlink ではなく生成にしているのは、plist はシェルと違って $HOME を展開せず、
# ログの出力先を絶対パスで書くしかないため（このリポジトリは public なので
# /Users/<name> をそのまま置けない。check.sh が弾く）。

# Render launchagents/*.plist.template into ~/Library/LaunchAgents and load them
install_launch_agents() {
  local dotfiles_dir="$1"
  local dir="$dotfiles_dir/launchagents"
  local dest="$HOME/Library/LaunchAgents"

  if [ ! -d "$dir" ]; then
    echo "⏭  launchagents/ が無いのでスキップ"
    return 0
  fi

  # 私用端末でのみ。業務端末に音声合成エンジンを常駐させる理由がない。
  local profile
  profile=$(resolve_profile)
  if [ "$profile" != "personal" ]; then
    echo "⏭  LaunchAgent は personal プロファイルのみ（現在: ${profile:-未設定}）"
    return 0
  fi

  echo "🧩 LaunchAgent を配置中..."
  mkdir -p "$dest" "$HOME/Library/Logs"

  local uid tpl label out required
  uid=$(id -u)

  for tpl in "$dir"/*.plist.template; do
    [ -f "$tpl" ] || continue
    label=$(basename "$tpl" .plist.template)
    out="$dest/$label.plist"

    # 対象アプリが入っていない端末に置くと、KeepAlive が起動失敗を延々と
    # 繰り返すだけになる。ProgramArguments の先頭（実行ファイル）で判定する。
    required=$(sed -n 's:.*<string>\(/Applications/[^<]*\)</string>.*:\1:p' "$tpl" | head -n 1)
    if [ -n "$required" ] && [ ! -e "$required" ]; then
      # 変数の直後が全角括弧だと、bash が UTF-8 の先頭バイトを識別子の一部と
      # みなして $label が空に化ける。多バイト文字が続くときは必ず {} で括る。
      echo "  ⏭  ${label}（$required が無い）"
      continue
    fi

    sed "s:__HOME__:$HOME:g" "$tpl" > "$out"

    # 読み込み済みだと bootstrap が失敗するので、必ず外してから入れ直す。
    # bootout は即座に返るが停止は非同期で、SIGTERM を送った直後はまだ登録が
    # 残っている。そのまま bootstrap すると "Bootstrap failed: 5: Input/output
    # error" で両方とも読み込めず、サービスが落ちたままになる（実測）。
    # print が引けなくなる = 登録が消えたことを確かめてから入れ直す。
    launchctl bootout "gui/$uid/$label" &>/dev/null || true
    local waited=0
    while launchctl print "gui/$uid/$label" &>/dev/null && [ "$waited" -lt 30 ]; do
      sleep 0.5
      waited=$((waited + 1))
    done

    if launchctl bootstrap "gui/$uid" "$out" &>/dev/null; then
      echo "  ✅ $label"
    else
      echo "  ⚠️  $label の読み込みに失敗しました（launchctl print gui/$uid/$label で確認）"
    fi
  done
}
