# Modern CLI（標準コマンドの置き換え）
# 素の挙動が必要なときは `command cat` のように command を前置する
alias cat='bat --paging=never'
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -l --icons=auto --git --group-directories-first'
alias la='eza -la --icons=auto --git --group-directories-first'
alias lt='eza --tree --level=2 --icons=auto'
alias lg='lazygit'

# Git
# 使用実績のあるものだけ残す（履歴 7169 件で実測）
alias gsw='git switch'
alias gsm='git switch master'
alias gph='git push origin HEAD'

# Docker
# du は標準の du（ディスク使用量）を隠すので注意。実測で使っていたため残す
alias du='docker compose up'
alias yarn='docker compose exec dev-server yarn'
