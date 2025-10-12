# Dotfiles

macOS用の個人dotfiles設定。

## 🚀 インストール

```bash
git clone https://github.com/tomitamasa/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/install.sh
```

## 📁 構成

### アプリケーション設定
- **Git**: グローバル設定とignore
- **Fish**: シェル設定、カスタムコマンド
- **Zsh**: デフォルトシェル設定
- **Amethyst**: タイル型ウィンドウマネージャー
- **Karabiner**: キーボードカスタマイズ
- **VSCode**: 拡張機能とワークスペース設定

### 開発ツール
- **Homebrew**: パッケージマネージャー
- **asdf**: バージョン管理
- **Docker**: コンテナ環境
- **AWS CLI**: クラウド管理

## 📁 ファイル構造

### 設定ファイル（Gitで管理）
```
dotfiles/
├── fish/
│   ├── config.fish        # メイン設定
│   ├── fish_plugins       # プラグインリスト
│   ├── functions/         # カスタム関数
│   └── completions/       # カスタム補完
├── git/
│   ├── config            # Git設定
│   └── ignore            # グローバルignore
├── karabiner/            # キーボード設定
├── scripts/
│   ├── install.sh        # メインインストーラー
│   ├── Brewfile          # パッケージ定義
│   └── lib/              # ユーティリティライブラリ
│       ├── brew.sh       # Homebrew管理
│       ├── symlinks.sh   # シンボリンク作成
│       └── fish.sh       # Fish設定
└── .zshrc               # Zsh設定
```

### 設計原則
1. **モジュラー**: 機能別にファイルを分離
2. **シンプル**: 複雑な処理を避け、理解しやすい構造
3. **冪等性**: 何度実行しても安全
4. **自動化**: 手動設定を最小限に抑制

## 🔧 主要コマンド

### Fish
```bash
f                     # fishシェルに切り替え
gca                   # git add -A && git commit -v
ghq_fzf_repo         # Ctrl+G でリポジトリ検索
```

### Docker
```bash
dcom                  # docker compose
ded                   # docker compose exec dev-server
dew                   # docker compose exec web
```

## 🎨 プロンプト

**Tide**を使用したモダンなプロンプト：
- Git情報表示
- 実行時間表示
- エラーステータス表示
- Nerd Fontsアイコン対応

### フォント
以下のNerd Fontsが自動インストールされます：
- FiraCode Nerd Font
- MesloLGS Nerd Font
- Hack Nerd Font

## ⌨️ キーボードカスタマイズ

### Karabiner設定
- **Caps Lock** → **Right Option**（手動設定が必要）
- **Home/End**キーのmacOS対応
- **Vim風**ナビゲーション
- **アプリ切り替え**最適化

### おすすめ設定手順
1. Karabiner-Elementsを起動
2. Simple Modifications → Add item
3. From: `caps_lock` → To: `right_option`

## 🔄 更新

```bash
cd ~/dotfiles
git pull origin main
./scripts/install.sh  # 冪等性保証
```

## 📝 カスタマイズ

### 新しいFish関数を追加
```bash
# fish/functions/my_function.fish に追加
./scripts/install.sh  # シンボリンクが自動作成される
```

### 新しいBrewパッケージを追加
```bash
# scripts/Brewfile にパッケージを追加
brew bundle install --file=scripts/Brewfile
```

## 🏗️ アーキテクチャ

### 冪等性の保証
- 何度実行しても同じ状態
- 既存ファイルのバックアップ
- 重複インストールの回避

### クロスプラットフォーム対応
- Intel Mac / Apple Silicon対応
- CI環境での軽量インストール
- エラー耐性とリトライ機能

### セキュリティ
- 秘密鍵・認証情報の除外
- 個人情報の分離
- 安全なdefault設定

---

**🌟 快適な開発環境をお楽しみください！**
