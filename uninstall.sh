#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
#  KITTY TERMINAL & MODERN CLI SETUP UNINSTALLER
#  Safe, clean uninstaller that removes only repo-managed configuration files
# ═══════════════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
AUTO_YES=false
RESTORE_BACKUP=false

# Identify target user & home directory
if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    TARGET_USER="$SUDO_USER"
    TARGET_HOME="$(getent passwd "$TARGET_USER" 2>/dev/null | cut -d: -f6)"
    TARGET_HOME="${TARGET_HOME:-/home/$TARGET_USER}"
else
    TARGET_USER="$(id -un)"
    TARGET_HOME="${HOME:?HOME variable is not set}"
fi

c_cyan='\033[1;36m'
c_green='\033[1;32m'
c_yellow='\033[1;33m'
c_red='\033[1;31m'
c_bold='\033[1m'
c_reset='\033[0m'

info()    { printf "${c_cyan}◆${c_reset} %b\n" "$*"; }
success() { printf "${c_green}✔${c_reset} %b\n" "$*"; }
warn()    { printf "${c_yellow}▲${c_reset} %b\n" "$*"; }
fail()    { printf "${c_red}✖${c_reset} %b\n" "$*"; }

section() {
    printf "\n${c_bold}${c_cyan}━━━ %s ━━━${c_reset}\n" "$*"
}

run_as_user() {
    if [[ $(id -u) -eq 0 && "$TARGET_USER" != "root" ]]; then
        sudo -u "$TARGET_USER" -H env "HOME=$TARGET_HOME" "$@"
    else
        "$@"
    fi
}

remove_managed_file() {
    local source_file="$1"
    local target_file="$2"
    local label="$3"

    [[ -f "$source_file" ]] || return 0
    [[ -e "$target_file" || -L "$target_file" ]] || return 0

    # Preserve custom symlinks
    if [[ -L "$target_file" ]]; then
        warn "Preserving custom symlink: $target_file"
        return 0
    fi

    # Check if unmodified from repo
    if ! cmp -s "$source_file" "$target_file"; then
        warn "Preserving user-modified file: $target_file"
        return 0
    fi

    run_as_user rm -f -- "$target_file"
    success "Removed: $label (${target_file#"$TARGET_HOME"/})"
}

restore_backup() {
    section "Restoring From Latest Backup"
    local backup_root="$TARGET_HOME/.config/kitty-setup-backups"
    if [[ ! -d "$backup_root" ]]; then
        warn "No backups found in $backup_root"
        return 0
    fi

    local latest
    latest=$(find "$backup_root" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort | tail -n 1)
    if [[ -z "$latest" ]]; then
        warn "No valid backup directories found."
        return 0
    fi

    local backup_path="$backup_root/$latest"
    local snapshot_root="$TARGET_HOME/.config/kitty-setup-restore-snapshots/$(date +%Y%m%d_%H%M%S_%N)"
    info "Restoring files from: $backup_path"

    while IFS= read -r -d '' src; do
        local rel="${src#"$backup_path"/}"
        local dst="$TARGET_HOME/$rel"
        if [[ -L "$dst" ]]; then
            warn "Keeping existing symlink: $dst"
            continue
        fi
        if [[ -e "$dst" ]]; then
            local snapshot="$snapshot_root/$rel"
            run_as_user mkdir -p "$(dirname "$snapshot")"
            run_as_user cp -a -- "$dst" "$snapshot"
        fi
        run_as_user mkdir -p "$(dirname "$dst")"
        run_as_user cp -a -- "$src" "$dst"
        success "Restored: $rel"
    done < <(find "$backup_path" -type f -print0)
    info "Files replaced during restore were saved to $snapshot_root."
}

usage() {
    cat <<EOF
${c_bold}Kitty & Modern CLI Suite Uninstaller${c_reset}

${c_bold}Usage:${c_reset} ./uninstall.sh [options]

${c_bold}Options:${c_reset}
  -y, --yes           Auto-confirm uninstall without prompting
  --restore-latest    Restore configurations from the newest backup archive
  -h, --help          Show this help message
EOF
}

# Parse Arguments
for arg in "$@"; do
    case "$arg" in
        -y|--yes) AUTO_YES=true ;;
        --restore-latest) RESTORE_BACKUP=true ;;
        -h|--help) usage; exit 0 ;;
        *) fail "Unknown option: $arg"; usage; exit 2 ;;
    esac
done

main() {
    printf "\n${c_bold}${c_red}╭──────────────────────────────────────────────────────────╮${c_reset}\n"
    printf "${c_bold}${c_red}│         🗑️  KITTY & MODERN CLI SETUP UNINSTALLER         │${c_reset}\n"
    printf "${c_bold}${c_red}╰──────────────────────────────────────────────────────────╯${c_reset}\n\n"

    info "Target User: ${c_bold}$TARGET_USER${c_reset} | Target Home: ${c_bold}$TARGET_HOME${c_reset}"

    if "$RESTORE_BACKUP"; then
        restore_backup
        exit 0
    fi

    if ! "$AUTO_YES"; then
        [[ -t 0 ]] || { fail "Uninstall needs confirmation. Run it in a terminal or pass --yes."; }
        printf "\n"
        read -r -p "$(printf "${c_yellow}Remove setup configuration files? [y/N]: ${c_reset}")" confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            info "Uninstallation aborted."
            exit 0
        fi
    fi

    section "Cleaning Managed Configuration Files"

    # Kitty configurations
    remove_managed_file "$SCRIPT_DIR/kitty/kitty.conf" "$TARGET_HOME/.config/kitty/kitty.conf" "Kitty config"
    remove_managed_file "$SCRIPT_DIR/kitty/keybindings.conf" "$TARGET_HOME/.config/kitty/keybindings.conf" "Kitty keybindings"
    remove_managed_file "$SCRIPT_DIR/kitty/open-actions.conf" "$TARGET_HOME/.config/kitty/open-actions.conf" "Kitty open-actions"
    remove_managed_file "$SCRIPT_DIR/kitty/theme.conf" "$TARGET_HOME/.config/kitty/theme.conf" "Kitty theme"
    remove_managed_file "$SCRIPT_DIR/kitty/tab_bar.py" "$TARGET_HOME/.config/kitty/tab_bar.py" "Kitty tab bar"

    # Shell, prompts & environment
    remove_managed_file "$SCRIPT_DIR/starship.toml" "$TARGET_HOME/.config/starship.toml" "Starship prompt"
    remove_managed_file "$SCRIPT_DIR/terminal.conf" "$TARGET_HOME/.config/environment.d/terminal.conf" "Terminal env"
    remove_managed_file "$SCRIPT_DIR/.zshrc" "$TARGET_HOME/.zshrc" "Zsh rc"
    remove_managed_file "$SCRIPT_DIR/.bashrc" "$TARGET_HOME/.bashrc" "Bash rc"
    remove_managed_file "$SCRIPT_DIR/.bash_profile" "$TARGET_HOME/.bash_profile" "Bash profile"
    remove_managed_file "$SCRIPT_DIR/.tmux.conf" "$TARGET_HOME/.tmux.conf" "Tmux config"

    # Fastfetch
    remove_managed_file "$SCRIPT_DIR/fastfetch/config.jsonc" "$TARGET_HOME/.config/fastfetch/config.jsonc" "Fastfetch config"

    # CLI Helper binaries
    if [[ -d "$SCRIPT_DIR/bin" ]]; then
        for b in "$SCRIPT_DIR/bin"/*; do
            [[ -f "$b" ]] && remove_managed_file "$b" "$TARGET_HOME/.local/bin/$(basename "$b")" "CLI binary $(basename "$b")"
        done
    fi

    # Neovim (LazyVim) configurations
    if [[ -d "$SCRIPT_DIR/nvim" ]]; then
        while IFS= read -r -d '' file; do
            local rel="${file#"$SCRIPT_DIR/nvim/"}"
            remove_managed_file "$file" "$TARGET_HOME/.config/nvim/$rel" "Neovim file $rel"
        done < <(find "$SCRIPT_DIR/nvim" -type f -print0)
    fi

    printf "\n${c_bold}${c_green}✨ Uninstallation complete. User-created files were kept untouched.${c_reset}\n\n"
}

main "$@"
