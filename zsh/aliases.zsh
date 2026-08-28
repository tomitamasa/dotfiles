# Modern CLI（標準コマンドの置き換え）
# 素の挙動が必要なときは `command cat` のように command を前置する
alias cat='bat --paging=never'
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -l --icons=auto --git --group-directories-first'
alias la='eza -la --icons=auto --git --group-directories-first'
alias lt='eza --tree --level=2 --icons=auto'
alias lg='lazygit'

# Config management
alias scom='rg --no-heading ~/dotfiles/zsh/aliases.zsh -e'
alias lscom='rg "^alias " ~/dotfiles/zsh/aliases.zsh'
alias acom='vi ~/dotfiles/zsh/.zshrc'

# Git
alias ga='git add'
alias gc='git commit -v'
alias gp='git push origin'
alias gph='git push origin HEAD'
alias gpl='git pull origin'
alias gb='git --no-pager branch --all'
alias gco='git checkout'
alias gswc='git switch -c'
alias gsw='git switch'
alias gsm='git switch master'
alias gd='git --no-pager diff'
alias gf='git fetch'
alias gm='git merge'
alias glo='git --no-pager log --oneline'
alias gs='git --no-pager status'

# Docker
alias dcom='docker compose'
alias ded='docker compose exec dev-server'
alias dew='docker compose exec web'
alias du='docker compose up'
alias dd='docker compose down'
alias yarn='docker compose exec dev-server yarn'
alias rubo='docker compose exec web bundle exec rubocop -a'
alias rc='docker compose exec web rails c -s'
alias rdbrb='docker compose exec web rails db:rollback'
alias rdbmg='docker compose exec web rails db:migrate'

# Shell
alias zconf='bat ~/dotfiles/zsh/.zshrc'
alias zsource='source ~/.zshrc'
