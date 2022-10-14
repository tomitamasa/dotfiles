#!/usr/bin/env bash
# OS Detection
if [ "$(uname)" == 'Darwin' ]; then
  OS='Mac'
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi


if [ $OS == "Mac" ]; then
  brew install karabiner
  mkdir -p ~/.config/karabiner/assets
  ln -s ~/dotfiles/karabiner/complex_modifications ~/.config/karabiner/assets
elif [ $OS == "Linux" ]; then
  apt update
fi
