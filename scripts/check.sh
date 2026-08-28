#!/bin/bash

# 静的検査。CI の lint ジョブと手元で同じものを走らせるための入口。
#   ./scripts/check.sh
#
# 見ているのは2点。
#   1. 新しいマシンで install.sh を流したときに壊れないか（設定ファイルの妥当性）
#   2. 公開リポジトリに出してはいけないものが混ざっていないか

set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

FAILED=0
ok()      { echo "  OK   $*"; }
fail()    { echo "  FAIL $*"; FAILED=1; }
skip()    { echo "  SKIP $* (未インストール)"; }
section() { echo; echo "== $1"; }
indent()  { while IFS= read -r line; do echo "       $line"; done; }

# ---------------------------------------------------------------- シェル

section "シェルスクリプト"
if command -v shellcheck &>/dev/null; then
  if shellcheck -x scripts/*.sh scripts/lib/*.sh; then
    ok "shellcheck"
  else
    fail "shellcheck"
  fi
else
  skip "shellcheck"
fi

section "zsh の構文"
if command -v zsh &>/dev/null; then
  for f in zsh/.zshrc zsh/.zprofile zsh/aliases.zsh zsh/functions.zsh zsh/.p10k.zsh; do
    [ -f "$f" ] || continue
    if zsh -n "$f" 2>/dev/null; then
      ok "$f"
    else
      fail "$f に構文エラー"
      zsh -n "$f"
    fi
  done
else
  skip "zsh"
fi

# ---------------------------------------------------- 設定ファイルの妥当性
# 壊れた設定を配ると、新しいマシンでキーボードやシェルが動かなくなる。

section "JSON"
for f in karabiner/karabiner.json karabiner/assets/complex_modifications/*.json; do
  [ -f "$f" ] || continue
  if python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f" 2>/dev/null; then
    ok "$f"
  else
    fail "$f が JSON として壊れている"
  fi
done

section "TOML"
for f in atuin/config.toml zsh/plugins.toml; do
  [ -f "$f" ] || continue
  if python3 -c "import tomllib,sys; tomllib.load(open(sys.argv[1],'rb'))" "$f" 2>/dev/null; then
    ok "$f"
  else
    fail "$f が TOML として壊れている"
  fi
done

section "YAML"
for f in .amethyst.yml .github/workflows/*.yaml .github/workflows/*.yml; do
  [ -f "$f" ] || continue
  if ruby -ryaml -e 'YAML.load_file(ARGV[0])' "$f" 2>/dev/null; then
    ok "$f"
  else
    fail "$f が YAML として壊れている"
  fi
done

# ------------------------------------------------------------- Karabiner
# JSON として読めても、構造が壊れていればキーリマップは効かない。

section "Karabiner の構造"
if [ -f karabiner/karabiner.json ]; then
  if python3 scripts/lib/check_karabiner.py karabiner/karabiner.json; then
    ok "karabiner.json の構造"
  else
    fail "karabiner.json の構造"
  fi
fi

# --------------------------------------------------- 公開リポジトリの安全性
# このリポジトリは public。brew bundle dump のように実機の状態を機械的に
# 吐いた成果物は、絶対パスや社内固有名をそのまま素通しする。人間の目は滑るので
# コミット前に機械で見る。

section "秘密情報・個人情報"

TRACKED=$(git ls-files)

# ホームディレクトリの絶対パス。ユーザー名が漏れるうえ、他のマシンで動かない。
if hits=$(echo "$TRACKED" | xargs grep -nE '/Users/[a-zA-Z0-9._-]+' 2>/dev/null); then
  fail "ホームディレクトリの絶対パスがあります（\$HOME を使ってください）"
  echo "$hits" | indent
else
  ok "絶対パスのハードコードなし"
fi

# 実在しうるトークンだけを狙う。README のダミー（ghp_xxxx）は長さで弾く。
CRED_RE='(ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{50,}|xox[baprs]-[A-Za-z0-9-]{12,}|AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9]{32,}|BEGIN [A-Z ]*PRIVATE KEY)'
if hits=$(echo "$TRACKED" | xargs grep -nE "$CRED_RE" 2>/dev/null); then
  fail "トークン・秘密鍵らしき文字列があります"
  echo "$hits" | indent
else
  ok "トークン・秘密鍵なし"
fi

# メールアドレス。git の noreply は意図して公開しているので除く。
# .p10k.zsh は p10k configure が生成する雛形で、コメントに例示アドレスを含む。
if hits=$(echo "$TRACKED" | grep -v 'zsh/.p10k.zsh' \
    | xargs grep -nE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' 2>/dev/null \
    | grep -v 'users\.noreply\.github\.com'); then
  fail "意図しないメールアドレスがあります"
  echo "$hits" | indent
else
  ok "意図しないメールアドレスなし"
fi

# ----------------------------------------------------------------- 結果

echo
if [ "$FAILED" -eq 0 ]; then
  echo "静的検査: すべて通過"
else
  echo "静的検査: 失敗あり"
fi
exit "$FAILED"
