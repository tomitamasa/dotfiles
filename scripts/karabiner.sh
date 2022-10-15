  
#!/bin/bash

config_path=$1
if [ -z "$config_path" ]; then
    config_path=$HOME/.config
fi



karabiner_modifications_path=$config_path/karabiner/assets/complex_modifications

# if [ -d "$karabiner_modifications_path" ]; then
#     exit 0
# fi

mkdir -p $karabiner_modifications_path
ls ./karabiner/complex_modifications/ | xargs -I{} ln -s {} $karabiner_modifications_path/{}

