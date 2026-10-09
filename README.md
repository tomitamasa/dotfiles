# 私用Macのdotfiles

必要なものだけを選び、既存設定を退避して適用する。2026-10-09以降、引数なしのインストーラは計画表示のみ。

## 初期設定

Homebrewは [公式サイト](https://brew.sh/) の内容を確認して手動導入する。このリポジトリはオンラインスクリプトを自動実行せず、第三者tapも自動trustしない。

```bash
./scripts/install.sh --with android --with voice --with agents --with notes
# 表示を確認してから適用
./scripts/install.sh --apply --with android --with voice --with agents --with notes
```

基本構成はGhostty、gh、ripgrep、mise、uv、sheldon、fzf、ghq、jqとMesloフォント1つ。シェルとGit設定を配置する。新規ソフトの導入は上記の適用操作時だけで、Mac初期化前の点検では適用しない。

| --with | 追加対象 |
|---|---|
| android | Android Studio。同梱Javaを利用し、SDKはアプリから選択 |
| voice | AivisSpeechの手動導入・モデル復元用。アプリは [公式配布元](https://aivis-project.com/AivisSpeech) から入れる |
| agents | Codex、Claude Code |
| notes | Obsidian |
| editor | Visual Studio Code。ユーザー設定とキーバインドを配置 |
| browser | Chrome |
| containers | Docker Desktop |
| window | Amethyst、Karabiner、AltTab。入力設定はこの選択時だけ配置 |
| cloud | AWS CLI、Fly CLI、Google Cloud CLI |
| ios | Xcode、CocoaPods |

`~/.dotfiles-profile` と `DOTFILES_PROFILE` は自動追加導入に使わない。Brewfile.personalは互換用の空ファイル。CAD、基板開発、加工機ツール、PlatformIO、独立Oracle Java、Leawoは基本・私用構成に含めない。azuki、plant-care、watering、kikurageはWindows機で開発する。

## 明示的な設定変更

`--macos` はDock・Finder等のmacOS設定を変更する。`--with voice --services` は導入済み音声エンジンのLaunchAgentを配置し起動する。どちらも通常適用には含まれない。アプリ設定の一括importも自動では行わない。

```bash
./scripts/install.sh --apply --with voice --services
```

AivisSpeech GUIは10101、常駐エンジンは10102を使う。現在のAIVMXモデル・辞書・設定はNASの `works/AivisSpeech-archive-20261009` に保存し、同梱のREADMEに従って復元する。履歴やモデルが復元できることを確認するまでMacを消去しない。

## シェルとランタイム

オプションのCLIが無くてもシェルが起動する。Android SDKは存在する場合だけPATHへ追加し、Android Studioがあれば同梱Javaを利用する。グローバルなyarn置換は行わず、コンテナ操作は各プロジェクトから実行する。

ghqとfzfが利用できる対話シェルではCtrl+Gでリポジトリを選べる。Claudeのccd/ccw/cwt/cca/ccr/ccb関数は保持している。bat/eza等の補助エイリアスは対象コマンドがある場合だけ有効。zoxideはz/ziを使い、cdは置換しない。

Sheldonは取得済みのlockがある場合だけ読み込む。新しいMacでは `zsh/plugins.toml` の取得元をレビューしてから `sheldon lock` を手動実行し、lockも退避する。更新は取得元と変更内容を確認して明示的に行う。初期インストーラはプラグインをダウンロードしない。

miseのグローバルなランタイム固定は初期適用しない。版は各プロジェクトで選ぶ。既存のmise/config.tomlやherdr/config.tomlは資料として保持し、herdr/cmuxや複数フォントは自動導入しない。必要な場合に個別設定する。

## 保存と秘密情報

既存ファイル・ディレクトリ・別向きsymlinkは `.backup.ランダム値` へ退避する。再適用で同じリンクなら退避を増やさない。欠落した元ファイルはエラーにする。

`~/.secrets` は任意のシェルコードを実行するファイルなので、自分所有の通常ファイルかつ他ユーザーに権限がない場合だけ読み込む。`chmod 600 ~/.secrets` で保護し、Gitや履歴へ値を入れない。認証は可能なら各ツールのログイン機能を使う。

ignoreは.env系・鍵・認証ファイルを除外するが、追跡済みファイルや過去のGit履歴の漏洩は取り消せない。スキャンは既知パターンによる点検で、全ての秘密情報を検出する保証ではない。

```bash
./scripts/check.sh
./scripts/check-brewfile.sh
python3 scripts/lib/security_audit.py --history
```

検査は秘密値を表示せず位置だけを報告する。Mac消去前はコード全ブランチ・worktree・未追跡データ・Git LFS・署名資産・AI履歴を別途退避・検証する。

## 手動復元する設定

BetterTouchTool、Raycast、AIエージェント認証、他リポジトリを呼ぶLaunchAgentsは一括復元しない。Obsidian vaultの設定・添付は個人データとして保全する。AltTab・Amethystのplistは保管しているが、必要な設定だけ手動で適用する。設定書き出しの `scripts/export-app-defaults.sh` は引き続き利用できる。
