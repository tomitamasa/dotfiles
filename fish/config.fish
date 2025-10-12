if status is-interactive
    # Commands to run in interactive sessions can go here
    
    set PATH /opt/homebrew/bin $PATH
    eval (/opt/homebrew/bin/brew shellenv)
    set PATH $HOME/go/bin $PATH
    set PATH $HOME/bin $PATH
end

# Modern fzf + ghq integration
function ghq_fzf_repo
  set selected_repository (ghq list -p | fzf --query "$argv" --select-1 --exit-0)
  if [ -n "$selected_repository" ]
    cd $selected_repository
    echo " $selected_repository "
    commandline -f repaint
  end
end

function fish_user_key_bindings
  # fzf.fish provides Ctrl+R for history, Ctrl+Alt+F for files, etc.
  # Custom keybinding for ghq
  bind \cg ghq_fzf_repo
end

# Tide prompt configuration (modern replacement for bobthefish)
# Load custom Tide settings
if test -f ~/dotfiles/fish/tide_setup.fish
    source ~/dotfiles/fish/tide_setup.fish
end

# asdf用に一応読み込んでおく
source /opt/homebrew/opt/asdf/libexec/asdf.fish

# 自作に省略コマンドをいい感じにするやつ
abbr -a scom "cat ~/dotfiles/fish/config.fish | grep" 
abbr -a lscom "cat ~/dotfiles/fish/config.fish | grep abbr"
abbr -a acom "vi ~/dotfiles/fish/config.fish" 

# git系 (with --no-pager for safety)
abbr -a ga git add
abbr -a gca git_commit_all_verbose
abbr -a gc git commit -v
abbr -a gp git push origin
abbr -a gph git push origin HEAD
abbr -a gpl git pull origin
abbr -a gb "git --no-pager branch --all"
abbr -a gco git checkout
abbr -a gswc git switch -c
abbr -a gsw git switch 
abbr -a gsm git switch master
abbr -a gd "git --no-pager diff"
abbr -a gf git fetch
abbr -a gm git merge
abbr -a gl "git --no-pager log --graph --all --pretty=format:'%Cred%h%Creset %Cgreen(%cI) -%C(yellow)%d%Creset %C(bold blue)<%an>%Creset %s' --abbrev-commit"
abbr -a glo "git --no-pager log --oneline"
abbr -a gs "git --no-pager status"

# docker系
abbr -a dcom docker compose
abbr -a ded docker compose exec dev-server
abbr -a dew docker compose exec web
abbr -a du docker compose up
abbr -a dd docker compose down
abbr -a yarn docker compose exec dev-server yarn  
abbr -a rubo docker compose exec web bundle exec rubocop -a
abbr -a rc docker compose exec web rails c -s 
abbr -a rdbrb docker compose exec web rails db:rollback 
abbr -a rdbmg docker compose exec web rails db:migrate

# fish
alias fconf "cat ~/.config/fish/config.fish"
alias fsource "source ~/.config/fish/config.fish"
