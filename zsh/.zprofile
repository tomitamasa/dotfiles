# Homebrew is optional. Do not write machine-specific paths into tracked config.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
[[ -d "$HOME/.docker/bin" ]] && export PATH="$HOME/.docker/bin:$PATH"
