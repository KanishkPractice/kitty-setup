#!/usr/bin/env bash
# Safe uninstaller for the Kitty setup. It never removes modified user files.
set -uo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
RESTORE_LATEST=false
ANIMATE=true
declare -a REMOVED=() SKIPPED=() ERRORS=()

if [[ -n ${SUDO_USER:-} && ${SUDO_USER} != root ]]; then
    TARGET_USER=$SUDO_USER
    TARGET_HOME=$(getent passwd "$TARGET_USER" 2>/dev/null | cut -d: -f6)
    TARGET_HOME=${TARGET_HOME:-/home/$TARGET_USER}
else
    TARGET_USER=$(id -un); TARGET_HOME=${HOME:?HOME is not set}
fi
readonly TARGET_USER TARGET_HOME

bold='\033[1m'; green='\033[32m'; yellow='\033[33m'; red='\033[31m'; cyan='\033[36m'; reset='\033[0m'
info() { printf "${cyan}•${reset} %s\n" "$*"; }
ok() { printf "${green}✓${reset} %s\n" "$*"; }
warn() { SKIPPED+=("$*"); printf "${yellow}!${reset} %s\n" "$*" >&2; }
fail() { ERRORS+=("$*"); printf "${red}✗${reset} %s\n" "$*" >&2; }

usage() { cat <<'EOF'
Usage: ./uninstall.sh [--yes] [--dry-run] [--restore-latest] [--no-animation]
  -y, --yes           Do not ask before removing matching configuration files
  --dry-run           Preview actions without changing files
  --restore-latest    Restore the newest kitty-setup backup instead of removing files
  --no-animation      Disable the ASCII animation
  -h, --help          Show this help
EOF
}

AUTO_YES=false
for arg in "$@"; do
    case $arg in
        -y|--yes) AUTO_YES=true ;;
        --dry-run) DRY_RUN=true ;;
        --restore-latest) RESTORE_LATEST=true ;;
        --no-animation) ANIMATE=false ;;
        -h|--help) usage; exit 0 ;;
        *) fail "Unknown option: $arg"; usage; exit 2 ;;
    esac
done

run_as_user() {
    if "$DRY_RUN"; then info "[dry-run] $*"; return 0; fi
    if [[ $(id -u) -eq 0 && $TARGET_USER != root ]]; then sudo -u "$TARGET_USER" -H env "HOME=$TARGET_HOME" "$@"; else "$@"; fi
}
can_animate() { "$ANIMATE" && ! "$DRY_RUN" && [[ -t 1 && -t 2 && -z ${CI:-} ]]; }
eat_animation() {
    can_animate || return
    local -a frames=(
        $'  . . .   C\n         /\\\n        /  \\   configuration'
        $'  . . .  < C\n         /\\\n        /  \\   configuration'
        $'  . . .   C\n          /\\\n         /  \\  configuration'
        $'  . . .  < C\n           /\\\n          /  \\ configuration'
        $'  . . .   C\n              /\\\n             /  \\  gone safely'
    )
    local frame
    printf "${yellow}\n"
    for frame in "${frames[@]}"; do
        printf '\r%s\033[3A' "$frame"
        sleep 0.13
    done
    printf '\r%s\n\n%s' "${frames[-1]}" "$reset"
}

remove_if_managed() {
    local source=$1 destination=$2 label=$3
    [[ -e $destination || -L $destination ]] || { info "$label is not installed"; return; }
    [[ -L $destination ]] && { warn "Left $label untouched because it is a symlink."; return; }
    if ! cmp -s "$source" "$destination"; then
        warn "Left modified $label untouched."; return
    fi
    if "$DRY_RUN"; then
        info "[dry-run] Would remove $label ($destination)"
        return
    fi
    eat_animation
    run_as_user rm -- "$destination" && { REMOVED+=("$label"); ok "Removed $label"; } || fail "Could not remove $label"
}

restore_latest() {
    local backup_root="$TARGET_HOME/.config/kitty-setup-backups" latest
    [[ -d $backup_root ]] || { fail "No kitty-setup backup directory exists."; return; }
    latest=$(find "$backup_root" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | tail -n 1)
    [[ -n $latest ]] || { fail "No installer backup is available."; return; }
    latest="$backup_root/$latest"
    info "Restoring files from $latest"
    local relative source destination
    while IFS= read -r -d '' source; do
        relative=${source#"$latest"/}; destination="$TARGET_HOME/$relative"
        if "$DRY_RUN"; then info "[dry-run] restore $relative"; continue; fi
        run_as_user mkdir -p "$(dirname "$destination")" && run_as_user cp -a "$source" "$destination" && ok "Restored $relative" || fail "Could not restore $relative"
    done < <(find "$latest" -type f -print0)
}

main() {
    printf "${bold}${yellow}\n  ╭──────────────────────────────────────╮\n  │      Kitty setup — safe uninstall     │\n  ╰──────────────────────────────────────╯${reset}\n"
    info "Target: $TARGET_USER ($TARGET_HOME)"
    if "$RESTORE_LATEST"; then restore_latest; else
        if ! "$AUTO_YES" && [[ -t 0 ]]; then
            read -r -p "Remove repository-managed configuration files? [y/N] " answer
            [[ $answer =~ ^[Yy]$ ]] || { info "Nothing changed."; exit 0; }
        fi
        remove_if_managed "$SCRIPT_DIR/kitty/kitty.conf" "$TARGET_HOME/.config/kitty/kitty.conf" "Kitty configuration"
        remove_if_managed "$SCRIPT_DIR/starship.toml" "$TARGET_HOME/.config/starship.toml" "Starship configuration"
        remove_if_managed "$SCRIPT_DIR/terminal.conf" "$TARGET_HOME/.config/environment.d/terminal.conf" "Terminal environment configuration"
        remove_if_managed "$SCRIPT_DIR/.zshrc" "$TARGET_HOME/.zshrc" "Zsh configuration"
        remove_if_managed "$SCRIPT_DIR/.bashrc" "$TARGET_HOME/.bashrc" "Bash configuration"
        remove_if_managed "$SCRIPT_DIR/.bash_profile" "$TARGET_HOME/.bash_profile" "Bash profile"
    fi
    printf "\n${bold}Summary${reset}\n"
    printf '%s managed file(s) removed.\n' "${#REMOVED[@]}"
    ((${#SKIPPED[@]})) && printf "${yellow}%s file(s) were intentionally left untouched.${reset}\n" "${#SKIPPED[@]}"
    ((${#ERRORS[@]} == 0)) || exit 1
}
main "$@"
