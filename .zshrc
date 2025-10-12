# Zsh Configuration for dotfiles

# Fish shell aliases
alias f="fish"
alias fish="/opt/homebrew/bin/fish"

# Function to start fish shell
function start_fish() {
    exec fish
}

# Optional: Add homebrew to PATH (if needed)
export PATH="/opt/homebrew/bin:$PATH"
