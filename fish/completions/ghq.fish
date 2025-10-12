# ghq completion for fish shell
# Based on https://github.com/x-motemen/ghq

complete -c ghq -f
complete -c ghq -s h -l help -d 'Show help'
complete -c ghq -s v -l version -d 'Show version'
complete -c ghq -l silent -d 'Run in silent mode'
complete -c ghq -l update -d 'Update an existing repository'
complete -c ghq -l shallow -d 'Do a shallow clone'
complete -c ghq -l look -d 'Look into a local repository'
complete -c ghq -l vcs -a 'git svn hg darcs fossil bzr' -d 'Specify VCS backend'
complete -c ghq -l root -d 'Specify root directory'

# Subcommands
complete -c ghq -n '__fish_use_subcommand' -a 'get' -d 'Clone/sync with a remote repository'
complete -c ghq -n '__fish_use_subcommand' -a 'list' -d 'List local repositories'
complete -c ghq -n '__fish_use_subcommand' -a 'look' -d 'Look into a local repository'
complete -c ghq -n '__fish_use_subcommand' -a 'root' -d 'Show repositories root'

# Completions for 'ghq look' and 'ghq list'
complete -c ghq -n '__fish_seen_subcommand_from look list' -a '(ghq list)' -d 'Repository'
