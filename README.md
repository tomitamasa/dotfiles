# Dotfiles

macOS用の個人dotfiles設定。

## 🚀 インストール

```bash
git clone https://github.com/tomitamasa/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/install.sh
```

インストール後:
```bash
exec zsh                # シェル再起動
p10k configure          # プロンプトのカスタマイズ
```

## 📁 構成

### アプリケーション設定
- **Zsh**: メインシェル（Sheldon + Powerlevel10k）
- **Git**: グローバル設定とignore
- **Amethyst**: タイル型ウィンドウマネージャー
- **Karabiner**: キーボードカスタマイズ
- **VSCode**: 拡張機能とワークスペース設定

### 開発ツール
- **Homebrew**: パッケージマネージャー
- **mise**: バージョン管理（asdf後継）
- **fzf**: ファジーファインダー
- **ghq**: リポジトリ管理
- **Docker**: コンテナ環境
- **AWS CLI**: クラウド管理

## 📁 ファイル構造

```
dotfiles/
├── zsh/
│   ├── .zshrc            # メイン設定
│   ├── .zprofile         # ログインシェル設定
│   ├── plugins.toml      # Sheldonプラグイン定義
│   ├── aliases.zsh       # エイリアス（Git, Docker等）
│   ├── functions.zsh     # カスタム関数（ghq+fzf等）
│   └── .p10k.zsh         # Powerlevel10kプロンプト設定
├── git/
│   ├── config            # Git設定
│   └── ignore            # グローバルignore
├── karabiner/            # キーボード設定
├── scripts/
│   ├── install.sh        # メインインストーラー
│   ├── Brewfile          # パッケージ定義
│   └── lib/
│       ├── brew.sh       # Homebrew管理
│       ├── symlinks.sh   # シンボリックリンク作成
│       └── zsh.sh        # Sheldonプラグイン管理
└── .amethyst.yml         # ウィンドウマネージャー設定
```

### 設計原則
1. **モジュラー**: 機能別にファイルを分離
2. **シンプル**: 複雑な処理を避け、理解しやすい構造
3. **冪等性**: 何度実行しても安全
4. **自動化**: 手動設定を最小限に抑制

## 🔧 主要コマンド

### Git
```bash
ga                    # git add
gc                    # git commit -v
gs                    # git status
gd                    # git diff
gl                    # git log（グラフ表示）
gp                    # git push origin
gph                   # git push origin HEAD
gpl                   # git pull origin
gsw                   # git switch
gswc                  # git switch -c
gb                    # git branch --all
```

### Docker
```bash
dcom                  # docker compose
du                    # docker compose up
dd                    # docker compose down
ded                   # docker compose exec dev-server
dew                   # docker compose exec web
```

### ナビゲーション
```bash
Ctrl+G                # ghq + fzf でリポジトリ検索・移動
Ctrl+R                # fzf でコマンド履歴検索
Ctrl+T                # fzf でファイル検索
```

### シェル管理
```bash
acom                  # .zshrc を編集
zsource               # .zshrc を再読み込み
zconf                 # .zshrc を表示
scom <keyword>        # エイリアスを検索
lscom                 # エイリアス一覧
```

## 🎨 プロンプト

**Powerlevel10k**を使用したモダンなプロンプト：
- Git情報表示（ブランチ、ステータスを色分け）
- 実行時間表示（3秒以上）
- エラーステータス表示
- Nerd Fontsアイコン対応

### Zshプラグイン（Sheldon管理）
| プラグイン | 機能 |
|-----------|------|
| romkatv/powerlevel10k | プロンプトテーマ |
| zsh-users/zsh-autosuggestions | コマンド入力候補（グレー表示） |
| zsh-users/zsh-syntax-highlighting | コマンド色分け |
| hlissner/zsh-autopair | 括弧・クォート自動補完 |
| zsh-users/zsh-completions | 追加補完定義 |

### フォント
以下のNerd Fontが自動インストールされます：
- MesloLGS Nerd Font

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

### エイリアスを追加
```bash
vi ~/dotfiles/zsh/aliases.zsh   # エイリアスを追記
source ~/.zshrc                  # 反映
```

### プラグインを追加
```bash
vi ~/dotfiles/zsh/plugins.toml  # [plugins.xxx] セクションを追記
sheldon lock --update            # プラグインをインストール
exec zsh                         # 反映
```

### Brewパッケージを追加
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
