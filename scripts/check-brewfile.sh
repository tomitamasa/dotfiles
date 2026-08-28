#!/bin/bash

# Brewfile の実在検査。
#   ./scripts/check-brewfile.sh
#
# `brew bundle list` はファイルを読んで名前を並べるだけで、パッケージが実在するか
# は見ない（存在しない名前でも終了コード 0）。タイポや rename・削除された
# パッケージは新しいマシンで install.sh を流すまで露見しないため、`brew info`
# で実在を確かめる。
#
# tap 修飾名（hashicorp/tap/terraform 等）は tap しないと引けないので、
# ここでは「その tap が同じ Brewfile で宣言されているか」だけを見る。

set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

if ! command -v brew &>/dev/null; then
  echo "  SKIP brew が無いのでスキップ"
  exit 0
fi

FAILED=0

check_file() {
  local file="$1"
  echo
  echo "== $file"

  if [ ! -f "$file" ]; then
    echo "  SKIP 存在しません"
    return 0
  fi

  local taps formulae casks tap_qualified
  taps=$(grep -oE '^tap "[^"]+"' "$file" | sed 's/tap "//;s/"//')
  formulae=$(grep -oE '^brew "[^"]+"' "$file" | sed 's/brew "//;s/"//')
  casks=$(grep -oE '^cask "[^"]+"' "$file" | sed 's/cask "//;s/"//')

  # tap 修飾名は宣言済みの tap に属しているか
  tap_qualified=$(echo "$formulae" | grep '/' || true)
  for name in $tap_qualified; do
    local tap="${name%/*}"
    if echo "$taps" | grep -qx "$tap"; then
      echo "  OK   $name (tap: $tap は宣言済み)"
    else
      echo "  FAIL $name の tap \"$tap\" が同じファイルで宣言されていません"
      FAILED=1
    fi
  done

  # tap 修飾でない formula はまとめて実在確認
  local plain
  plain=$(echo "$formulae" | grep -v '/' || true)
  if [ -n "$plain" ]; then
    # shellcheck disable=SC2086  # 名前を個別の引数として渡したい
    if brew info --formula $plain >/dev/null 2>&1; then
      echo "  OK   formula $(echo "$plain" | wc -l | tr -d ' ') 件すべて実在"
    else
      echo "  FAIL 実在しない formula があります:"
      for name in $plain; do
        brew info --formula "$name" >/dev/null 2>&1 || echo "       $name"
      done
      FAILED=1
    fi
  fi

  if [ -n "$casks" ]; then
    # shellcheck disable=SC2086
    if brew info --cask $casks >/dev/null 2>&1; then
      echo "  OK   cask $(echo "$casks" | wc -l | tr -d ' ') 件すべて実在"
    else
      echo "  FAIL 実在しない cask があります:"
      for name in $casks; do
        brew info --cask "$name" >/dev/null 2>&1 || echo "       $name"
      done
      FAILED=1
    fi
  fi
}

check_file scripts/Brewfile
check_file scripts/Brewfile.personal

echo
if [ "$FAILED" -eq 0 ]; then
  echo "Brewfile 検査: すべて通過"
else
  echo "Brewfile 検査: 失敗あり"
fi
exit "$FAILED"
