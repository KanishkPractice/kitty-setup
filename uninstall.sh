#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
#  🕷️  KITTY & MODERN TERMINAL RICE / LAZYVIM SAFE UNINSTALLER
#  Safe uninstaller for Kitty setup. Never removes modified user files.
# ═══════════════════════════════════════════════════════════════════════════
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
    TARGET_USER=$(id -un)
    TARGET_HOME=${HOME:?HOME is not set}
fi
readonly TARGET_USER TARGET_HOME

# 24-bit TrueColor Palette
bold='\033[1m'
dim='\033[2m'
reset='\033[0m'
c_red='\033[38;2;255;77;109m'
c_crimson='\033[38;2;255;51;85m'
c_coral='\033[38;2;255;117;143m'
c_neon_blue='\033[38;2;0;245;212m'
c_cyan='\033[38;2;137;220;235m'
c_green='\033[38;2;166;227;161m'
c_yellow='\033[38;2;249;226;175m'
c_purple='\033[38;2;180;142;255m'
c_gold='\033[38;2;255;183;3m'

info() { printf "${c_cyan}◆${reset} %b\n" "$*"; }
ok() { printf "${c_green}✔${reset} %b\n" "$*"; }
warn() { SKIPPED+=("$*"); printf "${c_yellow}▲${reset} %b\n" "$*" >&2; }
fail() { ERRORS+=("$*"); printf "${c_red}✖${reset} %b\n" "$*" >&2; }
section() {
    local title="$*"
    if [[ ! -t 1 ]] || "$AUTO_YES" || "$DRY_RUN" || ! "$ANIMATE"; then
        printf "\n${bold}${c_purple}━━━ %s ━━━${reset}\n" "$title"
        return
    fi
    printf "\n"
    animate_text "━━━ ✦ $title ✦ ━━━" 0.0005 "${bold}${c_purple}"
}

animate_text() {
    local text="$1"
    local delay="${2:-0.0008}"
    local color="${3:-}"
    if [[ ! -t 1 ]] || "$AUTO_YES" || "$DRY_RUN" || ! "$ANIMATE"; then
        printf "%b%s%b\n" "$color" "$text" "$reset"
        return
    fi
    printf "%b" "$color"
    local i char
    for (( i=0; i<${#text}; i++ )); do
        char="${text:$i:1}"
        printf "%s" "$char"
        sleep "$delay"
    done
    printf "%b\n" "$reset"
}

show_uninstall_banner() {
    if [[ ! -t 1 ]] || "$AUTO_YES" || "$DRY_RUN" || ! "$ANIMATE"; then
        printf "\n${bold}${c_crimson} ╭──────────────────────────────────────────────────────────╮\n"
        printf " │           🕷️  KITTY SETUP — SAFE UNINSTALL               │\n"
        printf " ╰──────────────────────────────────────────────────────────╯${reset}\n"
        return
    fi

    clear 2>/dev/null || true
    printf "\n"

    local -a spider_art=(
        "              \033[38;2;255;77;109m⡔      ⣆\033[0m"
        "             \033[38;2;255;77;109m⣼⠁      ⠸⣆\033[0m"
        "           \033[38;2;255;51;85m⡀⢰⣿        ⣿ ⢀\033[0m"
        "          \033[38;2;255;51;85m⣾ ⢸⣿        ⣿⠇⠘⣇\033[0m"
        "         \033[38;2;255;77;109m⢰⣿ ⠘⠿⣦⣄\033[38;2;0;245;212m⣴⣀⣸⡦\033[38;2;255;77;109m⣠⡼⠿  ⣿\033[0m"
        "         \033[38;2;255;51;85m⢸⣿⡶⠶⠶⠶\033[38;2;0;245;212m⣽⣿⣿⣿⣿⣵\033[38;2;255;51;85m⠶⠶⠶⢶⣿\033[0m"
        "        \033[38;2;255;77;109m⣤⣤⣶⡶⠾\033[38;2;0;245;212m⣛⣫⣽⣿⣿⣿⣿⣯⣟⡛\033[38;2;255;77;109m⠷⣶⣶⣤⣄\033[0m"
        "        \033[38;2;255;51;85m⣿⣿⠁\033[38;2;255;77;109m⣴⡿⠋\033[38;2;0;245;212m⢹⣿⣿⣿⣿⣿⣿⡎\033[38;2;255;77;109m⠙⢷⣦\033[38;2;255;51;85m⢨⣿⡟\033[0m"
        "        \033[38;2;255;77;109m⢹⣿⡀⣿⡇ \033[38;2;0;245;212m⢸⣟⢿⣿⣿⡿⣹⡇ \033[38;2;255;77;109m⢸⡏⢸⣿⠇\033[0m"
        "        \033[38;2;255;51;85m⠈⣿⡇⢹⡇  \033[38;2;0;245;212m⠻⣦⣙⣫⣼⠏  \033[38;2;255;51;85m⣿⡇⣼⡿\033[0m"
        "         \033[38;2;255;77;109m⠹⣿⡈\033[38;2;255;51;85m⣷   ⠈⠛⠋⠁   \033[38;2;255;51;85m⡿⢠⣿⠃\033[0m"
        "          \033[38;2;255;51;85m⠹⣧\033[38;2;255;77;109m⠹⡄        ⣸⢃\033[38;2;255;51;85m⣾⠋\033[0m"
        "           \033[38;2;255;77;109m⠙⢧⠱       ⠠⢃⡾⠁\033[0m"
        "            \033[38;2;255;51;85m⠈⠳⡀      ⢠⠎\033[0m"
    )

    for line in "${spider_art[@]}"; do
        printf "%b\n" "$line"
        sleep 0.008
    done
    printf "\n"

    local top_border=" ╭──────────────────────────────────────────────────────────╮"
    local title_line=" │          🕷️  KITTY SETUP — SAFE UNINSTALL                 │"
    local sub_line=" │   Preserves User Modifications & Restores Backups Safe   │"
    local bot_border=" ╰──────────────────────────────────────────────────────────╯"

    animate_text "$top_border" 0.0008 "${c_crimson}${bold}"
    animate_text "$title_line" 0.0008 "${c_coral}${bold}"
    animate_text "$sub_line"   0.0008 "${c_neon_blue}${bold}"
    animate_text "$bot_border" 0.0008 "${c_crimson}${bold}"
    printf "\n"
    sleep 0.05
}

usage() { cat <<EOF
${bold}${c_crimson}🕷️  KITTY SETUP — SAFE UNINSTALLER${reset}

${bold}Usage:${reset} ./uninstall.sh [options]

${bold}Options:${reset}
  ${c_cyan}-y, --yes${reset}           Do not ask before removing matching configuration files
  ${c_cyan}--dry-run${reset}           Preview actions without changing files
  ${c_cyan}--restore-latest${reset}    Restore the newest kitty-setup backup instead of removing files
  ${c_cyan}--no-animation${reset}      Disable the ASCII intro animation
  ${c_cyan}-h, --help${reset}          Show this help message
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

remove_if_managed() {
    local source=$1 destination=$2 label=$3
    [[ -e $destination || -L $destination ]] || return 0
    if [[ -L $destination ]]; then
        warn "Left $label untouched (custom symlink: $destination)"
        return 0
    fi
    if ! cmp -s "$source" "$destination"; then
        warn "Left modified $label untouched ($destination)"
        return 0
    fi
    if "$DRY_RUN"; then
        info "[dry-run] Would remove $label ($destination)"
        return 0
    fi
    if run_as_user rm -rf -- "$destination"; then
        REMOVED+=("$label")
        ok "Removed $label"
    else
        fail "Could not remove $label ($destination)"
    fi
}

restore_latest() {
    section "Restoring From Latest Backup"
    local backup_root="$TARGET_HOME/.config/kitty-setup-backups" latest
    [[ -d $backup_root ]] || { fail "No kitty-setup backup directory exists."; return; }
    latest=$(find "$backup_root" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort | tail -n 1)
    [[ -n $latest ]] || { fail "No installer backup is available."; return; }
    latest="$backup_root/$latest"
    info "Restoring files from: ${c_cyan}$latest${reset}"
    local relative source destination
    while IFS= read -r -d '' source; do
        relative=${source#"$latest"/}; destination="$TARGET_HOME/$relative"
        if "$DRY_RUN"; then info "[dry-run] restore $relative"; continue; fi
        run_as_user mkdir -p "$(dirname "$destination")" && run_as_user cp -a "$source" "$destination" && ok "Restored $relative" || fail "Could not restore $relative"
    done < <(find "$latest" -type f -print0)
}

main() {
    show_uninstall_banner
    info "Target user: ${bold}$TARGET_USER${reset} (Home: ${c_cyan}$TARGET_HOME${reset})"

    if "$RESTORE_LATEST"; then
        restore_latest
    else
        if ! "$AUTO_YES" && [[ -t 0 ]]; then
            printf "\n"
            read -r -p "$(printf "${c_yellow}▲ Remove repository-managed configuration files? [y/N] ${reset}")" answer
            [[ $answer =~ ^[Yy]$ ]] || { info "Uninstall aborted. Nothing changed."; exit 0; }
        fi

        section "Cleaning Managed Dotfiles & Configurations"
        
        # Kitty terminal files
        remove_if_managed "$SCRIPT_DIR/kitty/kitty.conf" "$TARGET_HOME/.config/kitty/kitty.conf" "Kitty config"
        remove_if_managed "$SCRIPT_DIR/kitty/keybindings.conf" "$TARGET_HOME/.config/kitty/keybindings.conf" "Kitty keybindings"
        remove_if_managed "$SCRIPT_DIR/kitty/open-actions.conf" "$TARGET_HOME/.config/kitty/open-actions.conf" "Kitty open-actions"
        remove_if_managed "$SCRIPT_DIR/kitty/theme.conf" "$TARGET_HOME/.config/kitty/theme.conf" "Kitty active theme"
        
        if [[ -d "$SCRIPT_DIR/kitty/textures" ]]; then
            for tex in "$SCRIPT_DIR/kitty/textures"/*; do
                [[ -f "$tex" ]] || continue
                remove_if_managed "$tex" "$TARGET_HOME/.config/kitty/textures/$(basename "$tex")" "Kitty texture $(basename "$tex")"
            done
        fi

        if [[ -d "$SCRIPT_DIR/kitty/sessions" ]]; then
            for session_file in "$SCRIPT_DIR/kitty/sessions"/*; do
                [[ -f "$session_file" ]] || continue
                remove_if_managed "$session_file" "$TARGET_HOME/.config/kitty/sessions/$(basename "$session_file")" "Kitty session $(basename "$session_file")"
            done
        fi

        # Shell & Tools configs
        remove_if_managed "$SCRIPT_DIR/starship.toml" "$TARGET_HOME/.config/starship.toml" "Starship config"
        remove_if_managed "$SCRIPT_DIR/terminal.conf" "$TARGET_HOME/.config/environment.d/terminal.conf" "Terminal env config"
        remove_if_managed "$SCRIPT_DIR/.zshrc" "$TARGET_HOME/.zshrc" "Zsh config"
        remove_if_managed "$SCRIPT_DIR/.bashrc" "$TARGET_HOME/.bashrc" "Bash config"
        remove_if_managed "$SCRIPT_DIR/.bash_profile" "$TARGET_HOME/.bash_profile" "Bash profile"
        [[ -f "$SCRIPT_DIR/.gitconfig" ]] && remove_if_managed "$SCRIPT_DIR/.gitconfig" "$TARGET_HOME/.gitconfig" "Git config"
        [[ -f "$SCRIPT_DIR/.tmux.conf" ]] && remove_if_managed "$SCRIPT_DIR/.tmux.conf" "$TARGET_HOME/.tmux.conf" "Tmux config"

        # Cava, Fastfetch, Yazi
        remove_if_managed "$SCRIPT_DIR/cava/config" "$TARGET_HOME/.config/cava/config" "Cava config"
        if [[ -d "$SCRIPT_DIR/cava/shaders" ]]; then
            for shader_file in "$SCRIPT_DIR/cava/shaders"/*; do
                [[ -f "$shader_file" ]] || continue
                remove_if_managed "$shader_file" "$TARGET_HOME/.config/cava/shaders/$(basename "$shader_file")" "Cava shader $(basename "$shader_file")"
            done
        fi
        remove_if_managed "$SCRIPT_DIR/fastfetch/config.jsonc" "$TARGET_HOME/.config/fastfetch/config.jsonc" "Fastfetch config"
        remove_if_managed "$SCRIPT_DIR/fastfetch/fastfetch-random.sh" "$TARGET_HOME/.config/fastfetch/fastfetch-random.sh" "Fastfetch random script"
        if [[ -d "$SCRIPT_DIR/fastfetch/arts" ]]; then
            for art_file in "$SCRIPT_DIR/fastfetch/arts"/*; do
                [[ -f "$art_file" ]] || continue
                remove_if_managed "$art_file" "$TARGET_HOME/.config/fastfetch/arts/$(basename "$art_file")" "Fastfetch art $(basename "$art_file")"
            done
        fi
        remove_if_managed "$SCRIPT_DIR/yazi/yazi.toml" "$TARGET_HOME/.config/yazi/yazi.toml" "Yazi config"

        # Binaries
        if [[ -d "$SCRIPT_DIR/bin" ]]; then
            for b in "$SCRIPT_DIR/bin"/*; do
                [[ -f "$b" ]] || continue
                remove_if_managed "$b" "$TARGET_HOME/.local/bin/$(basename "$b")" "CLI tool $(basename "$b")"
            done
        fi

        # LazyVim files
        if [[ -d "$SCRIPT_DIR/nvim" ]]; then
            while IFS= read -r -d '' file; do
                rel_path="${file#"$SCRIPT_DIR/nvim/"}"
                remove_if_managed "$file" "$TARGET_HOME/.config/nvim/$rel_path" "Neovim $rel_path"
            done < <(find "$SCRIPT_DIR/nvim" -type f -print0)
        fi
    fi

    printf "\n${bold}${c_purple}━━━━━━━━━━━━━━━━━━━━━ Uninstallation Summary ━━━━━━━━━━━━━━━━━━━━━${reset}\n"
    printf "  ${c_green}✔ %d managed file(s) safely removed.${reset}\n" "${#REMOVED[@]}"
    ((${#SKIPPED[@]})) && printf "  ${c_yellow}▲ %d customized / unmanaged file(s) intentionally preserved.${reset}\n" "${#SKIPPED[@]}"
    if ((${#ERRORS[@]} > 0)); then
        printf "  ${c_red}✖ %d error(s) occurred.${reset}\n\n" "${#ERRORS[@]}"
        exit 1
    else
        printf "  ${c_neon_blue}✨ Uninstallation complete.${reset}\n\n"
    fi
}

main "$@"
