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

## 🐠 Fish設定の管理方針

### カスタムファイル（Gitで管理）
```
fish/
├── config.fish          # メイン設定
├── fish_plugins         # プラグインリスト
├── functions/
│   └── *.fish          # 自作関数
└── completions/
    └── *.fish          # 自作補完
```

### プラグインファイル（Gitで除外）
```
~/.config/fish/
├── functions/
│   ├── _fzf_*          # fzf.fish
│   ├── _tide_*         # Tide
│   └── _autopair_*     # autopair.fish
├── completions/
│   └── tide.fish       # Tide補完
└── conf.d/
    ├── _tide_init.fish # Tide初期化
    ├── fzf.fish        # fzf設定
    └── autopair.fish   # autopair設定
```

### 設計原則
1. **分離**: 自作ファイルとプラグインファイルを明確に分離
2. **シンボリンク**: ファイル単位でシンボリンク（ディレクトリ全体はNG）
3. **除外**: プラグインファイルは`.gitignore`で確実に除外
4. **自動化**: プラグインは`install.sh`で自動インストール

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
