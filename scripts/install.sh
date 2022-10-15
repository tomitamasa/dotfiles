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
dotfiles_path=$HOME/dotfiles
if [ $OS == "macOS" ]; then
  /bin/bash /brew.sh
  local $karabiner_dst=$config_path/karabiner/assets/complex_modifications
  mkdir -p $karabiner_dst
  ls $dotfiles_path/karabiner/complex_modifications | xargs -I{} ln -s {} $karabiner_dst/{}
elif [ $OS == "Linux" ]; then
  # nothing to do
  apt update
fi
