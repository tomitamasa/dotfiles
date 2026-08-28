# Homebrew / PATH (must precede direnv, sheldon, mise, fzf — also runs for non-login shells)
export PATH="/opt/homebrew/bin:$HOME/go/bin:$HOME/bin:$PATH"
eval "$(/opt/homebrew/bin/brew shellenv)"

# direnv: apply environment before instant prompt so its console output
# doesn't trigger the p10k warning (official p10k pattern; hook is installed
# at the bottom of this file)
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv export zsh)"

# Enable Powerlevel10k instant prompt (keep near top; no console output below this)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY

# Completion
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Options
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt INTERACTIVE_COMMENTS

# Sheldon plugins
eval "$(sheldon source)"

# Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Claude Code
export PATH="$HOME/.local/bin:$PATH"

# エディタ。VSCode があれば使い、無ければ vi にフォールバックする。
# -w (--wait) は必須: 呼び出し元がファイルを閉じるまで待つ必要がある。
# git commit のエディタ、Claude Code の Ctrl+G (プロンプトを外部エディタで編集)、
# transcript モードの v (会話をエディタに吐く) などがこれを見る。
if command -v code &>/dev/null; then
  export EDITOR="code -w"
else
  export EDITOR="vi"
fi
export VISUAL="$EDITOR"

# mise (asdf successor, shims mode to avoid p10k precmd conflict)
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh --shims)"
fi

# Flutter / Android development
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
if [[ -d "/Applications/Android Studio.app/Contents/jbr/Contents/Home" ]]; then
  export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

# fzf
if [[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/completion.zsh
fi
if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
fi

# atuin: Ctrl+R を置き換える（fzf の Ctrl+T / Alt+C、ghq の Ctrl+G はそのまま）
# 上矢印は zsh 標準の履歴のまま残す
if command -v atuin &>/dev/null; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# zoxide: cd を置き換える（実在パスは builtin cd へ委譲されるため
# AUTO_CD / AUTO_PUSHD はそのまま効く。cdi で fzf 選択）
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# Load modular configs
DOTFILES_ZSH="${DOTFILES_ZSH:-$HOME/dotfiles/zsh}"
for config_file in "$DOTFILES_ZSH"/{aliases,functions}.zsh; do
  [[ -f "$config_file" ]] && source "$config_file"
done

# Local secrets (API keys etc. - not tracked in git)
[[ -f ~/.secrets ]] && source ~/.secrets

# Powerlevel10k config
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# direnv hook (env already applied before instant prompt at the top)
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"

# sentry
fpath=("$HOME/.local/share/zsh/site-functions" $fpath)
