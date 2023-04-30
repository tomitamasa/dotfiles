#!/bin/bash

config_path=$1
if [ -z "$config_path" ]; then
    config_path="$HOME/.config"
fi

mkdir -p "$config_path/karabiner/assets/complex_modifications"
ln -sfv ${PWD}/karabiner/complex_modifications/* "$config_path/karabiner/assets/complex_modifications"
