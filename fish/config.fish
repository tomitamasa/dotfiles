if status is-interactive
    # Commands to run in interactive sessions can go here
    
    set PATH /opt/homebrew/bin $PATH
    eval (/opt/homebrew/bin/brew shellenv)
    set PATH $HOME/go/bin $PATH
    set PATH $HOME/bin $PATH
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
  bind \ct peco_select_history
  bind \cg ghq_peco_repo
end

# bobthefish prompt
set -g theme_newline_cursor yes
set -g theme_newline_prompt '$ '
set -g theme_color_scheme zenburn
set -g fish_prompt_pwd_dir_length 0

set -g theme_display_git_ahead_verbose yes
set -g theme_display_git_dirty_verbose yes
set -g theme_display_git_default_branch yes

set -g theme_show_exit_status yes

# fzf用
set -U FZF_LEGACY_KEYBINDINGS 0

# asdf用に一応読み込んでおく
source /opt/homebrew/opt/asdf/libexec/asdf.fish

# git系
abbr -a ga git add
abbr -a gca git_commit_all_verbose
abbr -a gc git commit -v
abbr -a gp git push origin
abbr -a gph git push origin HEAD
abbr -a gpl git pull origin
abbr -a gb git branch --all
abbr -a gco git checkout
abbr -a gswc git switch -c
abbr -a gsw git switch 
abbr -a gsm git switch master
abbr -a gd git diff
abbr -a gf git fetch
abbr -a gm git merge
abbr -a gl git log --graph --all --pretty=format:'%Cred%h%Creset %Cgreen(%cI) -%C(yellow)%d%Creset %s %C(bold blue)<%an>%Creset' --abbrev-commit --date=rfc2822
abbr -a glo git log --oneline
abbr -a gs git status

# docker系
abbr -a dcom docker compose
abbr -a ded docker compose exec dev-server
abbr -a dew docker compose exec web
abbr -a du docker compose up
abbr -a dd docker compose down
abbr -a yarn docker compose exec dev-server yarn  
abbr -a rubo docker compose exec dev-server bundle exec rubocop -a
abbr -a rc docker compose exec web rails c -s 
abbr -a rdbrb docker compose exec web rails db:rollback 
abbr -a rdbmg docker compose exec web rails db:migrate

# fish
alias fconf "cat ~/.config/fish/config.fish"
alias fsource "source ~/.config/fish/config.fish"