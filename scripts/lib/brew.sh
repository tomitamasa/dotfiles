#!/bin/bash
# Homebrew itself is installed manually from the official instructions.
require_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    echo 'Homebrew is missing. Review https://brew.sh/ and install it manually.' >&2
    return 1
  fi
}
install_brewfile() {
  local file="$1"
  [ -f "$file" ] || { echo "Missing Brewfile: $file" >&2; return 1; }
  brew bundle install --file="$file" --no-upgrade
}
