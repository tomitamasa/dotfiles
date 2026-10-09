# Safe to load even when optional tools have not been installed.
typeset -U path
for tool_dir in "$HOME/.local/bin" "$HOME/bin"; do
  [[ -d "$tool_dir" ]] && path=("$tool_dir" $path)
done
unset tool_dir
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE HIST_VERIFY SHARE_HISTORY
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS INTERACTIVE_COMMENTS

# Use installed, locked plugin sources only; first-time downloads are manual.
if (( ${+commands[sheldon]} )) && [[ -r "${XDG_DATA_HOME:-$HOME/.local/share}/sheldon/plugins.lock" ]]; then
  eval "$(sheldon source)"
fi
# Keep security checking enabled; do not use compinit -C/-u.
autoload -Uz compinit
compinit -i

if (( ${+commands[code]} )); then export EDITOR='code -w'; else export EDITOR=vi; fi
export VISUAL="$EDITOR"
if (( ${+commands[mise]} )); then eval "$(mise activate zsh --shims)"; fi
if [[ -d "$HOME/Library/Android/sdk" ]]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  for tool_dir in "$ANDROID_HOME/cmdline-tools/latest/bin" "$ANDROID_HOME/platform-tools" "$ANDROID_HOME/emulator"; do
    [[ -d "$tool_dir" ]] && path=("$tool_dir" $path)
  done
  unset tool_dir
fi
if [[ -d '/Applications/Android Studio.app/Contents/jbr/Contents/Home' ]]; then
  export JAVA_HOME='/Applications/Android Studio.app/Contents/jbr/Contents/Home'
  path=("$JAVA_HOME/bin" $path)
fi
if [[ -o interactive ]]; then
  for fzf_file in /opt/homebrew/opt/fzf/shell/{completion,key-bindings}.zsh /usr/local/opt/fzf/shell/{completion,key-bindings}.zsh; do
    [[ -r "$fzf_file" ]] && source "$fzf_file"
  done
  unset fzf_file
  if (( ${+commands[atuin]} )); then eval "$(atuin init zsh --disable-up-arrow)"; fi
fi
if (( ${+commands[zoxide]} )); then eval "$(zoxide init zsh)"; fi
DOTFILES_ZSH="${DOTFILES_ZSH:-$HOME/dotfiles/zsh}"
for config_file in "$DOTFILES_ZSH"/{aliases,functions}.zsh; do
  [[ -r "$config_file" ]] && source "$config_file"
done
unset config_file

# A local secrets file is executable shell code: require ownership and private mode.
if [[ -f "$HOME/.secrets" && ! -L "$HOME/.secrets" && -O "$HOME/.secrets" ]]; then
  zmodload zsh/stat
  typeset -A secret_stat
  if zstat -H secret_stat "$HOME/.secrets" && (( (secret_stat[mode] & 077) == 0 )); then
    source "$HOME/.secrets"
  else
    print -u2 'Skipped .secrets: require private permissions (chmod 600).'
  fi
  unset secret_stat
fi
[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
if (( ${+commands[direnv]} )); then eval "$(direnv hook zsh)"; fi
if [[ -d "$HOME/.local/share/zsh/site-functions" ]]; then fpath=("$HOME/.local/share/zsh/site-functions" $fpath); fi
