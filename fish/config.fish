if status is-interactive
    # Commands to run in interactive sessions can go here
    
    set PATH /opt/homebrew/bin $PATH
    eval (/opt/homebrew/bin/brew shellenv)
    set PATH $HOME/go/bin $PATH
    set PATH $HOME/bin $PATH
end
