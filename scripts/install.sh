#!/bin/bash

# OS Detection
if [ "$(uname)" == 'Darwin' ]; then
  OS='macOS'
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi

config_path=$HOME/.config
if [ $OS == "macOS" ]; then
  ./scripts/brew.sh
  ./scripts/karabiner.sh "$config_path"
  ln -snfv ./.amethyst.yml "$HOME/.amethyst.yml"
elif [ $OS == "Linux" ]; then
  # nothing to do
  apt update
fi

./scripts/fish.sh "$config_path"

mkdir -p "$config_path/git"
ln -snfv ./git/* "$config_path/git"
