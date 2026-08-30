# Dotfiles

macOS用の個人dotfiles設定。

## 🚀 インストール

```bash
git clone https://github.com/tomitamasa/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/install.sh
```

私用端末なら、インストール前にプロファイルを指定します（業務端末には不要なものを分けるため）:
```bash
echo personal > ~/.dotfiles-profile
```

インストール後:
```bash
exec zsh                # シェル再起動
p10k configure          # プロンプトのカスタマイズ
```

## 📁 構成

### アプリケーション設定
- **Ghostty**: メインターミナル（設定は `ghostty/config`）
- **cmux**: AIエージェント並走用ターミナル（Ghostty の設定をそのまま読む）
- **Zsh**: メインシェル（Sheldon + Powerlevel10k）
- **Git**: グローバル設定とignore
- **Amethyst**: タイル型ウィンドウマネージャー
- **Karabiner**: キーボードカスタマイズ（実際に効いている `karabiner.json` ごと管理）
- **VSCode**: 拡張機能とワークスペース設定

### 開発ツール
- **Homebrew**: パッケージマネージャー
- **mise**: バージョン管理（asdf後継）
- **uv**: Python のパッケージ管理（`uv "openhands"` の前提でもある）
- **fzf**: ファジーファインダー
- **ghq**: リポジトリ管理
- **モダンCLI**: ripgrep / fd / bat / eza / zoxide / lazygit / git-delta
- **atuin**: シェル履歴の全文検索（同期は無効。履歴は端末内に留まる）
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
├── atuin/
│   └── config.toml       # シェル履歴の設定（同期は無効）
├── mise/
│   └── config.toml       # ランタイムのバージョン固定
├── vscode/
│   ├── settings.json     # VS Code のユーザー設定
│   └── keybindings.json  # 同キーバインド
├── macos/
│   └── *.plist           # GUIアプリの設定（AltTab・Amethyst）
├── ghostty/
│   └── config            # Ghostty設定（cmuxも同じファイルを読む）
├── git/
│   ├── config            # Git設定（delta pager 込み）
│   └── ignore            # グローバルignore
├── karabiner/            # ~/.config/karabiner をディレクトリごとリンク
│   ├── karabiner.json    # 実際に効いている設定（Karabinerが直接書き込む）
│   └── assets/           # インポート用の複雑なルール定義
├── scripts/
│   ├── install.sh        # メインインストーラー
│   ├── check.sh          # 静的検査（CIと共通・手元でも回せる）
│   ├── check-brewfile.sh # Brewfile のパッケージ実在検査
│   ├── Brewfile          # パッケージ定義（全端末共通）
│   ├── Brewfile.personal # 私用端末でのみ入れるもの
│   └── lib/
│       ├── brew.sh       # Homebrew管理
│       ├── symlinks.sh   # シンボリックリンク作成
│       ├── zsh.sh        # Sheldonプラグイン管理
│       └── check_karabiner.py # karabiner.json の構造検査
└── .amethyst.yml         # ウィンドウマネージャー設定
```

### 設計原則
1. **モジュラー**: 機能別にファイルを分離
2. **シンプル**: 複雑な処理を避け、理解しやすい構造
3. **冪等性**: 何度実行しても安全
4. **自動化**: 手動設定を最小限に抑制

## 🔧 主要コマンド

### プロジェクト固有
```bash
yarn                  # docker compose exec dev-server yarn
```

git / docker の短縮エイリアスは持っていません。手で叩いていた頃の名残であり、
実際にコマンドを打つのは Claude Code 側になったためです。
`yarn` だけはコンテナ内で動かす必要があるので残しています。

### モダンCLI
標準コマンドを置き換えています。素の挙動が必要なときは `command cat` のように `command` を前置します。

| コマンド | 実体 | 備考 |
|---------|------|------|
| `cat` | bat | シンタックスハイライト付き。パイプ時は自動で素の出力 |
| `ls` / `ll` / `la` | eza | アイコン・Git差分状態つき |
| `lt` | eza --tree | 2階層までのツリー表示 |
| `cd` | zoxide | 実在パスは通常の `cd`、それ以外は訪問履歴から推測して移動 |
| `cdi` | zoxide | 候補を fzf で選んで移動 |
| `lg` | lazygit | Git操作のTUI |
| `fd` | fd | `find` 代替（`.gitignore` を自動尊重） |
| `rg` | ripgrep | `grep` 代替 |

`git diff` / `git show` / `git log` は delta 経由で表示されます（`--no-pager` 付きのエイリアスは従来どおり素の出力）。
`fd` と `rg` はオプション体系が `find` / `grep` と異なるため、名前は置き換えていません。

### ナビゲーション
```bash
Ctrl+G                # ghq + fzf でリポジトリ検索・移動
Ctrl+R                # atuin でコマンド履歴検索（実行ディレクトリ・終了コードで絞込可）
Ctrl+T                # fzf でファイル検索
Alt+C                 # fzf でディレクトリ移動
↑                     # zsh 標準の履歴（atuin には奪わせていない）
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
- MesloLGS Nerd Font（Powerlevel10k / Ghostty で使用）
- FiraCode Nerd Font（VSCode で使用）
- Hack Nerd Font

Ghostty の日本語は `BIZ UDGothic` にフォールバックし、`font-feature = -dlig` で
合字化け（「プログラム」→「プロ㌘」）を無効化しています。

## ⌨️ キーボードカスタマイズ

### Karabiner設定
`install.sh` を流すだけで、下記がすべて適用されます。GUI での手動インポートは不要です。

- **Caps Lock** → **Right Option**
- **左Command** ⇄ **左Control** の入れ替え
- **Home/End** キーのmacOS対応
- **Vim風**ナビゲーション、カーソル移動

アプリ・ウィンドウの切り替えは AltTab（ライブサムネイル付き）に任せているため、
Karabiner 側では扱いません。

`~/.config/karabiner` をディレクトリごとリンクしています。`karabiner.json` を単体でリンクすると
Karabiner-Elements が保存のたびにリンクを消してファイルで置き換えるため、
[公式ドキュメント](https://karabiner-elements.pqrs.org/docs/manual/misc/configuration-file-path/)の指示どおりディレクトリ単位にしています。

GUI で設定を変えると `karabiner/karabiner.json` に差分が出るので、そのままコミットすれば
別のマシンにも反映されます。設定ディレクトリを手で移した場合は、下記でサービスを再起動します。

```bash
launchctl kickstart -k "gui/$(id -u)/org.pqrs.service.agent.karabiner_console_user_server"
```

## ✅ 検査

コミット前に手元で回せます。CI の静的検査ジョブは同じスクリプトを呼んでいるので、
ここが通れば CI も通ります。

```bash
./scripts/check.sh           # 設定ファイルの妥当性 + 秘密情報スキャン
./scripts/check-brewfile.sh  # Brewfile のパッケージが実在するか（brew が必要）
```

`check.sh` は「直しようのない FAIL」を出さないようにしています。たとえば TOML の
検査は `tomllib`（Python 3.11 以降）が要りますが、mise や pyenv の shim 越しに
古い `python3` が出てくる端末があります。そこで壊れていないファイルを FAIL と
報告すると検査そのものが信用されなくなるため、使える `python3` を探し、無ければ
その検査だけ SKIP します。

`check.sh` が見ているもの:

| 対象 | 見つけたいもの |
|------|--------------|
| shellcheck / `zsh -n` | シェルスクリプトと zsh 設定の構文エラー |
| actionlint | GitHub Actions ワークフローの誤り（`uses` のタグ、`${{ }}` の式、`run` 内の shell）|
| JSON / TOML / YAML / plist | 壊れた設定ファイル（配ると新しいマシンでキーボードやシェルが動かない） |
| Karabiner の構造 | JSON としては読めるが manipulators が欠けている等、リマップが効かない状態 |
| 秘密情報・個人情報 | 絶対パスのハードコード、トークン・秘密鍵、意図しないメールアドレス |
| 社内固有の識別子 | 社内ドメイン・サービス名など。パターンは `~/.dotfiles-deny-patterns` に書く（下記） |

このリポジトリは public です。`brew bundle dump` のように実機の状態を機械的に吐いた
ファイルは、絶対パスや社内固有のパッケージ名をそのまま素通しします。目視では滑るので
機械で見ます。

### 社内固有語の検査

社内のドメインやサービス名は、**パターンそのものが社内情報**なのでリポジトリに置けません。
`~/.dotfiles-deny-patterns` に1行1正規表現で書くと `check.sh` が読みます（Git管理外）。
ファイルが無ければこの検査はスキップされます。

## 🖥 GUIアプリの設定

設定画面でしか変えられないものは `macos/*.plist` に置き、`install.sh` が
`defaults import` で流し込みます。対象は AltTab（ウィンドウ切り替え）と
Amethyst（ウィンドウ配置のキーバインド）です。

設定を変えたら書き出し直します。

```bash
./scripts/export-app-defaults.sh
```

インストール識別子・セッション履歴・ウィンドウ座標といった、他のマシンで意味を
持たない値や公開したくない値は書き出し時に除外されます。

## 🔄 更新

```bash
cd ~/dotfiles
git pull origin main
./scripts/install.sh  # 冪等性保証
```

## 🔒 シークレット管理

APIキーやトークンは `~/.secrets` に記述（gitで追跡されません）：

```bash
# ~/.secrets を作成
touch ~/.secrets
chmod 600 ~/.secrets
```

```bash
# 記述例
export GITHUB_TOKEN="ghp_xxxx"
export OPENAI_API_KEY="sk-xxxx"
```

`.zshrc` が起動時に自動で読み込みます。グローバルgitignoreにより、`.secrets` は全リポジトリで無視されます。

## 🚫 意図的に管理しないもの

以下は「入れ忘れ」ではなく、検討したうえで管理外にしています。棚卸しのたびに
再検討しないための記録です（2026-08-29 の判断）。

| 対象 | 理由 |
|------|------|
| launchd ジョブ（日報生成・vault メンテ等） | plist を置いても呼び先のスクリプトが dotfiles の外にあり、単独では動かない |
| BetterTouchTool の設定 | 設定量が多く、更新のたびに巨大な差分が出て運用が重い |
| Raycast の設定 | エクスポートが暗号化されたバイナリで、差分が読めず git に向かない |
| `~/.secrets` | API キー・トークン。公開リポジトリに置けない |
| `~/.dotfiles-profile` / `~/.dotfiles-deny-patterns` | 端末ごとの値。前者は端末の種別、後者は社内固有語で、いずれもリポジトリに載せない |
| `~/.config/mise/config.local.toml` | 端末ごとのランタイム版の上書き。共通の版は `mise/config.toml` で管理する |

新しいマシンではこれらを手で設定します。管理対象に加えたくなったら、まず
「更新のたびに差分を読めるか」を判断基準にしてください。読めない形式のものは
入れても腐ります。

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

全端末で使うものは `scripts/Brewfile` に、私用端末だけで使うものは `scripts/Brewfile.personal` に書きます。

```bash
brew bundle install --file=scripts/Brewfile
brew bundle install --file=scripts/Brewfile.personal   # 私用端末のみ
```

### 端末プロファイル

`install.sh` は 共通の `Brewfile` → `Brewfile.<プロファイル名>` の順に `brew bundle` を回します。
プロファイルは次の優先順で決まり、未設定なら共通分だけを入れます。

1. 環境変数 `DOTFILES_PROFILE`
2. `~/.dotfiles-profile` の1行目（Git管理外。`.secrets` と同じくローカルにだけ置く）

```bash
echo personal > ~/.dotfiles-profile   # 私用端末
```

新しい区分を増やしたいときは `scripts/Brewfile.<名前>` を置き、`~/.dotfiles-profile` にその名前を書きます（例: `work`）。

### ランタイムのバージョンを端末ごとに変える

`mise/config.toml` は全端末共通のバージョンを決めています。特定の端末だけ別の
バージョンを使いたいときは、リポジトリを書き換えず `~/.config/mise/config.local.toml`
に置きます（Git管理外）。同じディレクトリの `config.toml`（= リポジトリへの symlink）
より優先されます。

```bash
printf '[tools]\nnode = "24"\n' > ~/.config/mise/config.local.toml
mise trust ~/.config/mise/config.local.toml
```

効いているかは `mise current node` で確かめます。

`~/.config/mise/conf.d/*.toml` は **使えません**。conf.d は `config.toml` に負けるため、
置いても共通の版のまま変わりません（mise 2026.3.8 で実測）。

なお作業ディレクトリがこのリポジトリの中にあるときは、`mise/config.toml` が
プロジェクト設定として扱われ、端末ローカルの上書きより優先されます。dotfiles を
編集している間だけ共通の版になるということで、他のプロジェクトには影響しません。

共通のバージョンを変えたいだけなら `mise/config.toml` を直接編集してコミットします。

## 🏗️ アーキテクチャ

### 冪等性の保証
- 何度実行しても同じ状態。CI が `create_dotfiles_symlinks` を繰り返し実行し、退避ファイルが増えないことを検査します
- 既存の実ファイル・実ディレクトリは `.backup` に退避（退避先が埋まっていれば日時を付与するため、入れ子にならない）
- 別の場所を指すシンボリックリンクは退避せず張り替え
- 重複インストールの回避

### クロスプラットフォーム対応
- Intel Mac / Apple Silicon対応
- CI環境での軽量インストール
- エラー耐性とリトライ機能

### セキュリティ
- **グローバルgitignore**: `.env`, `.secrets`, 秘密鍵等を全リポジトリで自動除外（`git/ignore`）
- **`~/.secrets`**: APIキー等をgit管理外で安全に読み込み（`.zshrc`でsource）
- **ファイルパーミッション**: `~/.secrets`は`chmod 600`で保護推奨

---

**🌟 快適な開発環境をお楽しみください！**
