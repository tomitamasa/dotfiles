# Modern CLI（標準コマンドの置き換え）
# 素の挙動が必要なときは `command cat` のように command を前置する
#
# 置き換え先が入っていない端末で alias だけ効くと、cat / ls のような基本コマンドが
# 「コマンドが見つからない」で止まる。dotfiles は zsh 設定を symlink で配るので、
# git pull した瞬間に brew より先に alias が効いてしまう。実際にそれで壊れたため、
# 存在を確かめてから張る（.zshrc の atuin / zoxide と同じ扱い）。
if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
fi

if command -v eza &>/dev/null; then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -l --icons=auto --git --group-directories-first'
  alias la='eza -la --icons=auto --git --group-directories-first'
  alias lt='eza --tree --level=2 --icons=auto'
fi

if command -v lazygit &>/dev/null; then
  alias lg='lazygit'
fi

# MulmoTerminal（Claude Code を並列で回すブラウザ端末）
# グローバルに入れず @latest を都度取りにいく。起動が数秒遅くなる代わりに
# 更新し忘れが起きない（明示的に npm i -g する運用は続かなかった実績がある）
if command -v npx &>/dev/null; then
  alias mulmo='npx mulmoterminal@latest'
fi

# プロジェクト固有
# git / docker の短縮エイリアスは、手で叩いていた頃の名残なので持たない。
# yarn だけはコンテナ内で動かす必要があるため残す。
alias yarn='docker compose exec dev-server yarn'
