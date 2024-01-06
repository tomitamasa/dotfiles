#!/bin/bash

config_path=$1
if [ -z "$config_path" ]; then
    config_path="$HOME/.config"
fi

mkdir -p "$config_path/git"

ln -snfv $HOME/dotfiles/git/* $config_path/git
