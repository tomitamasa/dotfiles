#!/bin/bash

config_path=$1
if [ -z "$config_path" ]; then
    config_path=$HOME/.config
    echo set $config_path
fi

fisher update

mkdir -p "$config_path/fish/functions"
mkdir -p "$config_path/fish/completions"

ln -snfv $HOME/dotfiles/fish/completions/* "$config_path/fish/completions"
ln -snfv $HOME/dotfiles/fish/functions/* "$config_path/fish/functions"
ln -snfv $HOME/dotfiles/fish/config.fish "$config_path/fish"
ln -snfv $HOME/dotfiles/fish/fish_plugins "$config_path/fish"

# install powerline font
cd /tmp
git clone https://github.com/powerline/fonts.git
cd fonts
./install.sh
rm -rf ./fonts
