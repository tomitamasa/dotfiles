# Dotfiles

Personal macOS dotfiles configuration with fish shell support.

## 🚀 Quick Start

```bash
git clone https://github.com/tomitamasa/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/install.sh
```

## 📦 What's Included

### Tools & Applications
- **Package Manager**: Homebrew
- **Shell**: Fish shell (with zsh fallback)
- **Version Manager**: asdf
- **Window Manager**: Amethyst
- **Keyboard Customization**: Karabiner Elements
- **Development Tools**: Various CLI tools and VSCode extensions

### Configuration Files
- Git configuration with global ignore patterns
- Fish shell with custom functions and abbreviations
- Zsh configuration for easy fish access
- Amethyst window manager settings
- Karabiner keyboard modifications
- Tool version management with asdf

## 🐠 Shell Usage

This configuration uses **zsh as the default shell** with easy access to fish:

```bash
# Quick fish access
f

# Or explicitly
fish

# Function to start fish and stay in it
start_fish
```

## 🔧 Manual Setup (if needed)

If the automatic installation doesn't work, you can manually create symlinks:

```bash
# Git configuration
ln -s ~/dotfiles/git/config ~/.gitconfig
ln -s ~/dotfiles/git/ignore ~/.gitignore_global

# Fish configuration
mkdir -p ~/.config/fish
ln -s ~/dotfiles/fish/config.fish ~/.config/fish/config.fish
ln -s ~/dotfiles/fish/fish_plugins ~/.config/fish/fish_plugins
ln -s ~/dotfiles/fish/completions ~/.config/fish/completions
ln -s ~/dotfiles/fish/functions ~/.config/fish/functions

# Other configurations
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.amethyst.yml ~/.amethyst.yml
ln -s ~/dotfiles/.tool-versions ~/.tool-versions

# Karabiner
mkdir -p ~/.config/karabiner
ln -s ~/dotfiles/karabiner/complex_modifications ~/.config/karabiner/complex_modifications
```

## 🎯 Key Features

### Git Abbreviations (Fish)
- `ga` - git add
- `gc` - git commit -v
- `gp` - git push origin
- `gb` - git branch --all (with --no-pager)
- `gs` - git status (with --no-pager)
- `gd` - git diff (with --no-pager)
- And many more...

### Docker Abbreviations (Fish)
- `dcom` - docker compose
- `du` - docker compose up
- `dd` - docker compose down
- `dew` - docker compose exec web
- And many more...

### Fish Functions
- **ghq + peco integration** (Ctrl+G)
- **History search with peco** (Ctrl+T)
- **Custom command shortcuts**

## 🛠 Customization

### Adding New Tools
1. Add tools to `scripts/Brewfile`
2. Run `brew bundle install --file=scripts/Brewfile`

### Adding Fish Plugins
1. Add plugin to `fish/fish_plugins`
2. Run `fisher install` in fish shell

### Modifying Git Settings
Edit `git/config` and changes will be reflected immediately through symlinks.

## 📝 Notes

- Requires macOS
- Fish plugins are managed through the `fish_plugins` file
- Git aliases include `--no-pager` for safety in automated environments
- Tool versions are managed through `.tool-versions` (currently empty)

## 🆘 Troubleshooting

### If fish plugins don't load
```bash
# In fish shell
fisher install
```

### If git configuration isn't applied
```bash
# Check if symlink exists
ls -la ~/.gitconfig
```

### If Homebrew packages aren't installing
```bash
cd ~/dotfiles
brew bundle install --file=scripts/Brewfile
```

## 🔄 Updating

To update your dotfiles:

```bash
cd ~/dotfiles
git pull origin main
./scripts/install.sh  # Re-run if needed
