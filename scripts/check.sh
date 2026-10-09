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
skip()    { echo "  SKIP $*"; }
section() { echo; echo "== $1"; }

# ---------------------------------------------------------------- シェル

section "シェルスクリプト"
if command -v shellcheck &>/dev/null; then
  if shellcheck --format=gcc -x scripts/*.sh scripts/lib/*.sh; then
    ok "shellcheck"
  else
    fail "shellcheck"
  fi
else
  skip "shellcheck（未インストール）"
fi

section "zsh の構文"
if command -v zsh &>/dev/null; then
  for f in zsh/.zshrc zsh/.zprofile zsh/aliases.zsh zsh/functions.zsh zsh/.p10k.zsh; do
    [ -f "$f" ] || continue
    if zsh -n "$f" 2>/dev/null; then
      ok "$f"
    else
      fail "$f に構文エラー"
    fi
  done
else
  skip "zsh（未インストール）"
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

# TOML を読むには tomllib（Python 3.11 以降）が要る。mise や pyenv の shim を
# 経由すると python3 が古い版に解決される端末があり、そこでは「壊れていない
# ファイルが壊れている」と報告されてしまう。直しようのない FAIL は検査の信用を
# 落とすので、tomllib を持つ python を探し、無ければ検査自体を飛ばす。
find_toml_python() {
  local py
  for py in python3 python3.13 python3.12 python3.11 /opt/homebrew/bin/python3 /usr/bin/python3; do
    command -v "$py" &>/dev/null || continue
    if "$py" -c 'import tomllib' 2>/dev/null; then
      echo "$py"
      return 0
    fi
  done
  return 1
}

section "TOML"
if toml_python=$(find_toml_python); then
  for f in atuin/config.toml zsh/plugins.toml; do
    [ -f "$f" ] || continue
    if "$toml_python" -c "import tomllib,sys; tomllib.load(open(sys.argv[1],'rb'))" "$f" 2>/dev/null; then
      ok "$f"
    else
      fail "$f が TOML として壊れている"
    fi
  done
else
  skip "TOML の検査（tomllib を持つ python3 が無い。Python 3.11 以降が要る）"
fi

section "YAML"
for f in .amethyst.yml .github/workflows/*.yaml .github/workflows/*.yml; do
  [ -f "$f" ] || continue
  if ruby -ryaml -e 'YAML.load_file(ARGV[0])' "$f" 2>/dev/null; then
    ok "$f"
  else
    fail "$f が YAML として壊れている"
  fi
done

# YAML として読めることと、ワークフローとして正しいことは別物。uses のタグ違い、
# ${{ }} の式エラー、run: の中の shell ミスはここでしか捕まらない。
section "GitHub Actions"
if command -v actionlint &>/dev/null; then
  if actionlint -format '{{range .}}{{.Filepath}}:{{.Line}}:{{.Column}}: {{.Kind}}; {{end}}'; then
    ok "actionlint"
  else
    fail "actionlint"
  fi
else
  skip "actionlint（未インストール）"
fi

section "plist"
# plutil は macOS 専用のため、静的検査が ubuntu でも走るよう plistlib で読む
for f in macos/*.plist launchagents/*.plist.template; do
  [ -f "$f" ] || continue
  if python3 -c "import plistlib,sys; plistlib.load(open(sys.argv[1],'rb'))" "$f" 2>/dev/null; then
    ok "$f"
  else
    fail "$f が plist として壊れている"
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

if python3 scripts/lib/security_audit.py; then
  ok "working-file security scan (values redacted)"
else
  fail "working-file security scan"
fi
section "isolated installer tests"
if python3 -m unittest discover -s scripts/tests -v; then
  ok "installer safety tests"
else
  fail "installer safety tests"
fi

# ----------------------------------------------------------------- 結果

echo
if [ "$FAILED" -eq 0 ]; then
  echo "静的検査: すべて通過"
else
  echo "静的検査: 失敗あり"
fi
exit "$FAILED"
