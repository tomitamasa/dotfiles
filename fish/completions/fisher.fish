# fisher completion for fish shell
# Based on https://github.com/jorgebucaran/fisher

complete -c fisher -f
complete -c fisher -s h -l help -d 'Show help'
complete -c fisher -s v -l version -d 'Show version'

# Subcommands
complete -c fisher -n '__fish_use_subcommand' -a 'install' -d 'Install plugins'
complete -c fisher -n '__fish_use_subcommand' -a 'update' -d 'Update plugins' 
complete -c fisher -n '__fish_use_subcommand' -a 'remove' -d 'Remove plugins'
complete -c fisher -n '__fish_use_subcommand' -a 'list' -d 'List installed plugins'

# Plugin name completion for install/remove commands
complete -c fisher -n '__fish_seen_subcommand_from remove' -a '(fisher list)' -d 'Installed plugin'
