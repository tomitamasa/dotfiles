# Modern CLI（標準コマンドの置き換え）
# 素の挙動が必要なときは `command cat` のように command を前置する
alias cat='bat --paging=never'
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -l --icons=auto --git --group-directories-first'
alias la='eza -la --icons=auto --git --group-directories-first'
alias lt='eza --tree --level=2 --icons=auto'
alias lg='lazygit'

# プロジェクト固有
# git / docker の短縮エイリアスは、手で叩いていた頃の名残なので持たない。
# yarn だけはコンテナ内で動かす必要があるため残す。
alias yarn='docker compose exec dev-server yarn'
