if status is-interactive
    # Commands to run in interactive sessions can go here
    
    set PATH /opt/homebrew/bin $PATH
    eval (/opt/homebrew/bin/brew shellenv)
    set PATH $HOME/go/bin $PATH
    set PATH $HOME/bin $PATH
    set PATH $HOME/.rd/bin $PATH
end

# cf.https://zenn.dev/sawao/articles/0b40e80d151d6a
# peco setting
set fish_plugins theme peco

# cf. https://public-constructor.com/fish-ghq/
# ghq + peco
function ghq_peco_repo
  set selected_repository (ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_repository" ]
    cd $selected_repository
    echo " $selected_repository "
    commandline -f repaint
  end
end

function fish_user_key_bindings
  bind \cr peco_select_history
  bind \cg ghq_peco_repo
end

# cf. https://girigiribauer.com/tech/20200420/
# git
alias g "git"
alias ga "git add"
alias gaa "git add ."
alias gb "git branch --all"
alias gbd "git branch -d "
alias gc "git commit"
alias gca "git commit -a"
alias gco "git checkout"
alias gcom "git checkout master"
alias gcod "git checkout develop"
alias gcob "git checkout -b"
alias gre "git rebase -i"
alias gd "git diff"
alias gl "git log --graph --all --pretty=format:'%Cred%h%Creset %Cgreen(%cI) -%C(yellow)%d%Creset %s %C(bold blue)<%an>%Creset' --abbrev-commit --date=rfc2822"
alias gp "git pull"
alias gs "git status"
alias gst "git stash"
alias gf "git fetch"

# docker
alias d "docker"
alias dc "docker container" # override original dc command
alias dls 'docker container ls'
alias di "docker image"
alias dils "docker image ls"
alias dn "docker network"
alias dnls "docker network ls"
alias dv "docker volume"
alias dvls "docker volume ls"
alias dcom "docker-compose"
alias drun "docker run"
alias dex "docker exec"
alias dpull "docker pull"

alias fcon "cat ~/.config/fish/config.fish"
alias fsou "source ~/.config/fish/config.fish"

# bobthefish prompt
set -g theme_newline_cursor yes
set -g theme_newline_prompt '$ '
set -g theme_color_scheme zenburn
set -g fish_prompt_pwd_dir_length 0

set -g theme_display_git_ahead_verbose yes
set -g theme_display_git_dirty_verbose yes
set -g theme_display_git_default_branch yes

set -g theme_show_exit_status yes
