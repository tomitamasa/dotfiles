#!/bin/bash

# OS Detection
if [ "$(uname)" != 'Darwin' ]; then
  echo "Not macOS!"
  exit 1
fi

if ! command -v brew &>/dev/null; then
  echo "installing brew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/$USER/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "installed yet"
fi
