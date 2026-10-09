#!/bin/bash
# No arguments: plan only. Mutations require --apply.
# shellcheck source-path=SCRIPTDIR
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
APPLY=false
MACOS=false
SERVICES=false
FEATURES=()
usage() {
  echo 'Usage: install.sh [--apply] [--with android|voice|editor|browser|notes|containers|window|cloud|ios|agents] [--macos] [--services]'
}
while [ "$#" -gt 0 ]; do
  case "$1" in
    --apply) APPLY=true ;;
    --macos) MACOS=true ;;
    --services) SERVICES=true ;;
    --with)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      case "$2" in
        android|voice|editor|browser|notes|containers|window|cloud|ios|agents) FEATURES+=("$2") ;;
        *) echo "Unknown feature: $2" >&2; exit 2 ;;
      esac
      shift ;;
    --help|-h) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
  shift
done
if $SERVICES; then
  case " ${FEATURES[*]-} " in
    *' voice '*) ;;
    *) echo '--services requires --with voice' >&2; exit 2 ;;
  esac
fi
echo 'PLAN: basic configuration'
for feature in ${FEATURES[@]+"${FEATURES[@]}"}; do echo "PLAN: $feature"; done
if $MACOS; then echo 'PLAN: macOS preferences'; fi
if $SERVICES; then echo 'PLAN: selected voice services'; fi
if ! $APPLY; then
  echo 'No changes made. Add --apply to apply this selection.'
  exit 0
fi
[ "$(uname)" = Darwin ] || { echo 'macOS only' >&2; exit 1; }
# shellcheck source=lib/brew.sh
source "$SCRIPT_DIR/lib/brew.sh"
# shellcheck source=lib/symlinks.sh
source "$SCRIPT_DIR/lib/symlinks.sh"
require_homebrew
install_brewfile "$SCRIPT_DIR/Brewfile"
for feature in ${FEATURES[@]+"${FEATURES[@]}"}; do install_brewfile "$SCRIPT_DIR/Brewfile.$feature"; done
create_dotfiles_symlinks "$DOTFILES_DIR" ${FEATURES[@]+"${FEATURES[@]}"}
if $MACOS; then
  # shellcheck source=lib/macos.sh
  source "$SCRIPT_DIR/lib/macos.sh"
  configure_macos
fi
if $SERVICES; then
  # shellcheck source=lib/launchagents.sh
  source "$SCRIPT_DIR/lib/launchagents.sh"
  install_launch_agents "$DOTFILES_DIR"
fi
echo 'Selected configuration applied. Plugins are not fetched automatically; see README.'
