#!/usr/bin/env python3
"""`defaults export` の出力から、持ち運べない値・公開したくない値を落とす。

標準入力で XML plist を受け取り、フィルタして第1引数のパスへ書き出す。

落とすもの:
  - インストール識別子・セッション履歴（AppCenter などのテレメトリ）
  - Sparkle（自動更新）の状態。最終チェック時刻などマシン固有
  - ウィンドウ座標。マルチディスプレイの構成に依存するため他マシンで無意味
  - Amethyst の EncodedWindowManager。現在の画面構成のスナップショット
"""

import plistlib
import sys

DENY_PREFIXES = (
    "MSAppCenter",   # AppCenter のテレメトリ（InstallId / SessionId / UserId など）
    "SU",            # Sparkle の更新状態
    "NSWindow",      # ウィンドウ位置
    "NSStatusItem",  # メニューバー項目の位置
)

DENY_EXACT = {
    "EncodedWindowManager",  # Amethyst: 画面構成のスナップショット
}


def is_portable(key: str) -> bool:
    if key in DENY_EXACT:
        return False
    return not key.startswith(DENY_PREFIXES)


def main() -> int:
    out_path, domain = sys.argv[1], sys.argv[2]

    data = plistlib.loads(sys.stdin.buffer.read())
    kept = {k: v for k, v in data.items() if is_portable(k)}
    dropped = sorted(set(data) - set(kept))

    if not kept:
        print(f"  SKIP {domain} (持ち運べる設定がありません)")
        return 0

    with open(out_path, "wb") as f:
        plistlib.dump(kept, f, sort_keys=True)

    print(f"  OK   {domain} -> {out_path} ({len(kept)} 項目)")
    if dropped:
        print(f"       除外 {len(dropped)} 項目: {', '.join(dropped)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
