# ghq + fzf integration (Ctrl+G)
ghq_fzf_repo() {
  local selected=$(ghq list -p | fzf --query "$LBUFFER" --select-1 --exit-0)
  if [[ -n "$selected" ]]; then
    BUFFER="cd ${selected}"
    zle accept-line
  fi
  zle reset-prompt
}
zle -N ghq_fzf_repo
bindkey '^g' ghq_fzf_repo
