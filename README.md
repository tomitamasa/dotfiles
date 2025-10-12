# Dotfiles

macOS向けの個人的なdotfiles設定です。Fish shell、モダンなCLIツール、AI開発ツールを使った開発環境を構築できます。

## インストール

```bash
git clone https://github.com/tomitamasa/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/install.sh
```

インストール後、ターミナルを再起動するか `source ~/.zshrc` を実行してください。

## 主な内容

### CLIツール
- **fish** - モダンなシェル
- **fzf** - ファジーファインダー  
- **ghq** - Gitリポジトリ管理
- **asdf** - 言語バージョン管理
- **jq** - JSON処理
- その他開発に便利なツール

### アプリケーション
- **Visual Studio Code** - エディタ
- **Docker Desktop** - コンテナ環境
- **Raycast** - ランチャー
- **Karabiner Elements** - キーボードカスタマイズ
- **Amethyst** - ウィンドウ管理
- その他

### 設定内容
- Git設定（エイリアス、グローバルignore）
- Fish shell設定（略語、関数、プラグイン）
- Karabinerキーボード設定
- その他各種dotfiles

## 使い方

### Fish shellの使用
zshからfishに切り替える：
```bash
f        # fishに切り替え
```

### 主要なショートカット
- `Ctrl+G` - ghq + fzfでリポジトリ検索
- `Ctrl+R` - コマンド履歴をfzfで検索

### Gitエイリアス（fish内）
```bash
ga    # git add
gc    # git commit -v
gp    # git push origin
gs    # git status
gd    # git diff
gb    # git branch --all
```

### Dockerエイリアス（fish内）
```bash
dcom  # docker compose
du    # docker compose up
dd    # docker compose down
```

## カスタマイズ

### パッケージの追加
Brewfileにパッケージを追加：
```bash
echo 'brew "package-name"' >> scripts/Brewfile
brew bundle install --file=scripts/Brewfile
```

### Fishプラグインの追加
```bash
echo 'author/plugin-name' >> fish/fish_plugins
fisher install
```

### Git設定の変更
`git/config` を直接編集してください。シンボリンク経由で即座に反映されます。

## 更新・メンテナンス

dotfilesの更新：
```bash
cd ~/dotfiles
git pull origin main
./scripts/install.sh  # 再実行して更新を適用
```

パッケージの更新：
```bash
brew update && brew upgrade
fisher update  # fishプラグインの更新
```

## トラブルシューティング

### パッケージインストールが失敗する場合
ネットワーク問題でインストールが失敗することがあります。スクリプトは3回まで自動リトライしますが、手動で実行することもできます：

```bash
cd ~/dotfiles
brew bundle install --file=scripts/Brewfile
```

### Fishプラグインが読み込まれない場合
```bash
fish
curl -sL https://git.io/fisher | source && fisher install
```

### Git設定が反映されない場合
シンボリンクが正しく作成されているか確認：
```bash
ls -la ~/.gitconfig
```

### 新しいMacでの使用
このスクリプトは新しいMacでも使用できます。Homebrewも自動でインストールされます。

## アンインストール

dotfilesを削除したい場合：
```bash
# シンボリンクを削除
rm ~/.gitconfig ~/.zshrc ~/.amethyst.yml
rm -rf ~/.config/fish ~/.config/karabiner/complex_modifications

# パッケージも削除する場合（オプション）
brew bundle cleanup --file=scripts/Brewfile --force
```

## CI/CD

GitHub Actionsでmacος環境での動作確認を自動化しています。
