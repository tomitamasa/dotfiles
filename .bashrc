export PATH=$PATH:$HOME/bin

# cf. https://girigiribauer.com/tech/20200420/
# cf. https://blog.ojisan.io/to-fish
### Git系
alias g='git'
alias gb='git branch --all'
alias gbd='git branch -d'
alias gd='git diff'
alias gs='git status'
alias gst='git stash'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit --verbose'
alias gm='git merge'
alias gpo='git push'
alias gp='git pull'
alias gf='git fetch'
alias gl="git log --graph --all --pretty=format:'%Cred%h%Creset %Cgreen(%cI) -%C(yellow)%d%Creset %s %C(bold blue)<%an>%Creset' --abbrev-commit --date=rfc2822"
