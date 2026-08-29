#!/bin/bash

# GUI アプリの設定を macos/<ドメイン>.plist へ書き出す。
#   ./scripts/export-app-defaults.sh
#
# 対象は「設定画面でしか変えられず、飛ぶと痛いが項目数は少ない」もの。
# 書き出した plist は install.sh が `defaults import` で流し込む。
#
# 除外キーについて: これらのアプリの plist には、インストール識別子・
# セッション履歴・ウィンドウ座標といった、他のマシンで意味を持たないか、
# 公開リポジトリに置きたくない値が混ざる。プレフィックスで落とす。

set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

DOMAINS=(
  com.lwouis.alt-tab-macos
  com.amethyst.Amethyst
)

mkdir -p macos

for domain in "${DOMAINS[@]}"; do
  out="macos/${domain}.plist"

  if ! defaults read "$domain" &>/dev/null; then
    echo "  SKIP $domain (このマシンに設定がありません)"
    continue
  fi

  defaults export "$domain" - | python3 scripts/lib/filter_defaults.py "$out" "$domain"
done

echo
echo "書き出し先: macos/"
echo "反映するには install.sh を流すか、defaults import <ドメイン> <ファイル> を実行してください。"
