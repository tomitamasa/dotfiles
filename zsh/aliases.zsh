# Config management
alias scom='cat ~/dotfiles/zsh/aliases.zsh | grep'
alias lscom='cat ~/dotfiles/zsh/aliases.zsh | grep "alias "'
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
alias gl="git --no-pager log --graph --all --pretty=format:'%Cred%h%Creset %Cgreen(%cI) -%C(yellow)%d%Creset %C(bold blue)<%an>%Creset %s' --abbrev-commit"
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
alias zconf='cat ~/dotfiles/zsh/.zshrc'
alias zsource='source ~/.zshrc'
alias f='fish'
