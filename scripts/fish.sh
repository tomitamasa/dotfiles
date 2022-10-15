#!/bin/bash

config_path=$1
if [ -z "$config_path" ]; then
    config_path=$HOME/.config
fi

mkdir -p $config_path/fish/functions
mkdir -p $config_path/fish/completions
mkdir -p $config_path/fish/themes

ln -snfv ./fish/config.fish $config_path/fish
ln -snfv ./fish/fish_plugins $config_path/fish_plugins
ln -snfv ./fish/fish_variables $config_path/fish_variables
ln -snfv ./fish/functions/* $config_path/fish/functions
ln -snfv ./fish/completions/* $config_path/fish/completions
ln -snfv ./fish/themes/* $config_path/fish/themes
