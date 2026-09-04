#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
#  ⛩️  KITTY & MODERN TERMINAL RICE / LAZYVIM IDE INSTALLER (DNF / Fedora)
#  High-Performance, Fault-Tolerant, Fully-Automated Terminal Suite Setup
# ═══════════════════════════════════════════════════════════════════════════
set -uo pipefail

START_TIME=$(date +%s)
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
AUTO_YES=false
DRY_RUN=false
CHANGE_SHELL=false
ONLY_CONFIGS=false
SKIP_PKGS=false
declare -a WARNINGS=() ERRORS=() INSTALLED_ITEMS=()

# Determine user and target home (seamless sudo support)
if [[ -n ${SUDO_USER:-} && ${SUDO_USER} != root ]]; then
    TARGET_USER=$SUDO_USER
    TARGET_HOME=$(getent passwd "$TARGET_USER" 2>/dev/null | cut -d: -f6)
    TARGET_HOME=${TARGET_HOME:-/home/$TARGET_USER}
else
    TARGET_USER=$(id -un)
    TARGET_HOME=${HOME:?HOME is not set}
fi
readonly TARGET_USER TARGET_HOME
readonly USER_BIN="$TARGET_HOME/.local/bin"
readonly BACKUP_DIR="$TARGET_HOME/.config/kitty-setup-backups/$TIMESTAMP"

# 24-bit TrueColor and ANSI Styles (Miles Morales / Cyberpunk & Catppuccin palette)
bold='\033[1m'
dim='\033[2m'
italic='\033[3m'
underline='\033[4m'
reset='\033[0m'

# Rich RGB Palette
c_red='\033[38;2;255;77;109m'
c_crimson='\033[38;2;255;51;85m'
c_coral='\033[38;2;255;117;143m'
c_neon_blue='\033[38;2;0;245;212m'
c_cyan='\033[38;2;137;220;235m'
c_blue='\033[38;2;137;180;250m'
c_green='\033[38;2;166;227;161m'
c_yellow='\033[38;2;249;226;175m'
c_gold='\033[38;2;255;183;3m'
c_magenta='\033[38;2;203;166;247m'
c_purple='\033[38;2;180;142;255m'
c_gray='\033[38;2;108;112;134m'
c_white='\033[38;2;248;249;250m'

blue="$c_blue"
green="$c_green"
yellow="$c_yellow"
red="$c_red"
cyan="$c_cyan"
magenta="$c_magenta"
crimson="$c_crimson"
gold="$c_gold"

info() { printf "${c_cyan}◆${reset} %b\n" "$*"; }
ok() { printf "${c_green}✔${reset} %b\n" "$*"; }
warn() {
    WARNINGS+=("$*")
    printf "${c_yellow}▲${reset} %b\n" "$*" >&2
}
fail() {
    ERRORS+=("$*")
    printf "${c_red}✖${reset} %b\n" "$*" >&2
}
has() { command -v "$1" >/dev/null 2>&1; }

animate_check() {
    local label="$1"
    local status_cmd="$2"
    local delay=0.012
    local -a spin=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

    if [[ ! -t 1 ]] || "$AUTO_YES" || "$DRY_RUN"; then
        if eval "$status_cmd" >/dev/null 2>&1; then
            ok "$label"
            return 0
        else
            warn "$label (check failed or not found)"
            return 1
        fi
    fi

    for s in "${spin[@]}"; do
        printf "\r${c_neon_blue}%s${reset} Checking %s..." "$s" "$label"
        sleep "$delay"
    done

    if eval "$status_cmd" >/dev/null 2>&1; then
        printf "\r\033[K${c_green}✔${reset} %s\n" "$label"
        return 0
    else
        printf "\r\033[K${c_yellow}▲${reset} %s is not active/found\n" "$label"
        return 1
    fi
}

animate_text() {
    local text="$1"
    local delay="${2:-0.0008}"
    local color="${3:-}"
    if [[ ! -t 1 ]] || "$AUTO_YES" || "$DRY_RUN"; then
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

cyber_progress_bar() {
    local title="$1"
    local steps="${2:-20}"
    local delay="${3:-0.005}"

    if [[ ! -t 1 ]] || "$AUTO_YES" || "$DRY_RUN"; then
        return 0
    fi

    printf "  ${c_coral}⚡ %s:${reset} [" "$title"
    local filled=""
    for ((i=1; i<=steps; i++)); do
        local percent=$(( (i * 100) / steps ))
        printf "\r  ${c_coral}⚡ %-28s${reset} ${c_neon_blue}[${c_red}%-${steps}s${c_neon_blue}] ${c_yellow}%3d%%${reset}" "$title" "$(printf '█%.0s' $(seq 1 $i))" "$percent"
        sleep "$delay"
    done
    printf "\r\033[K  ${c_green}✔ %-28s${reset} ${c_neon_blue}[${c_green}%-${steps}s${c_neon_blue}] ${c_green}100%% DONE${reset}\n" "$title" "$(printf '█%.0s' $(seq 1 $steps))"
}

show_celebration_animation() {
    if [[ ! -t 1 ]] || "$AUTO_YES" || "$DRY_RUN"; then
        return 0
    fi

    local -a sparks=(
        "        ✨  ✦   .  *  .  ✦  ✨       "
        "      ✦  .  *  [ SYSTEM READY ] *  .  ✦      "
        "        ✨  ✦   .  *  .  ✦  ✨       "
    )

    for spark in "${sparks[@]}"; do
        printf "${c_gold}${bold}%s${reset}\n" "$spark"
        sleep 0.02
    done
}

section() {
    local title="$*"
    if [[ ! -t 1 ]] || "$AUTO_YES" || "$DRY_RUN"; then
        printf "\n${bold}${c_purple}━━━ %s ━━━${reset}\n" "$title"
        return
    fi
    printf "\n"
    animate_text "━━━ ✦ $title ✦ ━━━" 0.0005 "${bold}${c_purple}"
}

show_intro_animation() {
    if [[ ! -t 1 ]] || "$AUTO_YES" || "$DRY_RUN"; then
        printf "\n${c_crimson}${bold} ╭──────────────────────────────────────────────────────────╮\n"
        printf " │      🕷️  KITTY & MODERN TERMINAL RICE / LAZYVIM          │\n"
        printf " │             Dedicated Fedora & DNF Edition               │\n"
        printf " ╰──────────────────────────────────────────────────────────╯${reset}\n\n"
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

    # Animated glowing header box
    local top_border=" ╭──────────────────────────────────────────────────────────╮"
    local title_line=" │        🕷️  KITTY & MODERN TERMINAL RICE / LAZYVIM         │"
    local sub_line=" │             Dedicated Fedora & DNF Edition               │"
    local bot_border=" ╰──────────────────────────────────────────────────────────╯"

    animate_text "$top_border" 0.0008 "${c_crimson}${bold}"
    animate_text "$title_line" 0.0008 "${c_coral}${bold}"
    animate_text "$sub_line"   0.0008 "${c_neon_blue}${bold}"
    animate_text "$bot_border" 0.0008 "${c_crimson}${bold}"
    printf "\n"
    sleep 0.05
}

usage() {
    cat <<EOF
${bold}${crimson}⛩️  KITTY & MODERN TERMINAL RICE INSTALLER (Fedora / DNF)${reset}

${bold}Usage:${reset} ./install.sh [options]

${bold}Options:${reset}
  ${cyan}-y, --yes${reset}           Non-interactive mode (auto-accept all prompts)
  ${cyan}--change-shell${reset}      Prompt to make Zsh your default login shell
  ${cyan}--only-configs${reset}      Deploy dotfiles and configurations only (skips DNF package installs)
  ${cyan}--no-pkg${reset}            Skip system package manager (installs user-space binaries only)
  ${cyan}--dry-run${reset}           Simulate all actions without touching files or packages
  ${cyan}-h, --help${reset}          Display this help message

${bold}Included Suite:${reset}
  • ${bold}Terminal:${reset} Kitty (GPU-accelerated, tabs, splits, remote control, 8 curated themes)
  • ${bold}IDE:${reset} LazyVim (Neovim v0.12+ with TokyoNight/Torii theme, Mason LSP, Conform formatting)
  • ${bold}Shell:${reset} Zsh & Bash (Torii FZF theme, Zoxide, Starship prompt, syntax highlighting, autosuggestions)
  • ${bold}Modern CLI:${reset} Yazi, Fastfetch, Cava (with shaders), LazyGit, Bat, Eza, Ripgrep, Btop, Cmatrix, Cbonsai
  • ${bold}CLI Helpers:${reset} cool (visual launcher), samurai / trident (banners), scmd (fuzzy cheatsheet)
EOF
}

# Parse CLI arguments
for arg in "$@"; do
    case $arg in
    -y | --yes | --non-interactive) AUTO_YES=true ;;
    --change-shell) CHANGE_SHELL=true ;;
    --only-configs) ONLY_CONFIGS=true ;;
    --no-pkg) SKIP_PKGS=true ;;
    --dry-run) DRY_RUN=true ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        fail "Unknown option: $arg"
        usage
        exit 2
        ;;
    esac
done

run() {
    if "$DRY_RUN"; then
        info "[dry-run] $*"
    else
        "$@"
    fi
}

run_as_user() {
    if [[ $(id -u) -eq 0 && $TARGET_USER != root ]]; then
        run sudo -u "$TARGET_USER" -H env "HOME=$TARGET_HOME" "PATH=$USER_BIN:$PATH" "$@"
    else
        run env "PATH=$USER_BIN:$PATH" "$@"
    fi
}

run_elevated() {
    if [[ $(id -u) -eq 0 ]]; then
        run "$@"
    elif has sudo; then
        run sudo "$@"
    else
        warn "Running without sudo: $*"
        run "$@"
    fi
}

ensure_dir() {
    run_as_user mkdir -p "$1" || {
        fail "Cannot create directory: $1"
        return 1
    }
}

preflight_checks() {
    section "Pre-flight Environment Checks"
    info "Target user: ${bold}${TARGET_USER}${reset} (Home: ${cyan}${TARGET_HOME}${reset})"
    info "Backup directory: ${dim}${BACKUP_DIR}${reset}"

    if ! has dnf; then
        fail "This installer requires Fedora/RHEL with the DNF package manager."
        return 1
    fi

    # Check internet connectivity
    if curl -s --max-time 3 https://github.com >/dev/null 2>&1; then
        ok "Network connection verified"
    else
        warn "Network connection to GitHub appears slow or unavailable. Standalone downloads may fail."
    fi

    # Check available disk space in home dir (need at least 250MB)
    local avail_mb
    avail_mb=$(df -m "$TARGET_HOME" 2>/dev/null | awk 'NR==2 {print $4}')
    if [[ -n $avail_mb && $avail_mb -lt 250 ]]; then
        warn "Low disk space in $TARGET_HOME (${avail_mb}MB available)."
    else
        ok "Sufficient disk space available (${avail_mb:-OK}MB free)"
    fi
}

install_packages() {
    if "$ONLY_CONFIGS" || "$SKIP_PKGS"; then
        info "Skipping DNF package installation as requested."
        return 0
    fi

    section "DNF System Packages & Developer Tools"
    local -a core_packages=(
        kitty zsh fzf zoxide fontconfig curl git bat util-linux-user
        eza ripgrep fd-find btop tealdeer git-delta cmatrix cbonsai neovim
        gcc make tar unzip cava fastfetch
    )

    info "Installing core packages via DNF..."
    run_elevated dnf install -y "${core_packages[@]}" || warn "Some standard DNF packages were skipped or already up-to-date."

    # Try installing lazygit & yazi from COPR if not already present
    if ! has lazygit; then
        info "Enabling COPR repository for LazyGit..."
        run_elevated dnf copr enable -y dejan/lazygit 2>/dev/null || true
        run_elevated dnf install -y lazygit 2>/dev/null || true
    fi

    if ! has yazi; then
        info "Enabling COPR repository for Yazi file manager..."
        run_elevated dnf copr enable -y atim/yazi 2>/dev/null || true
        run_elevated dnf install -y yazi 2>/dev/null || true
    fi
}

install_kitty() {
    section "Kitty Terminal Configuration"
    if has kitty; then
        ok "Kitty terminal ready: $(kitty --version 2>/dev/null || echo 'installed')"
        INSTALLED_ITEMS+=("Kitty Terminal")
    elif has curl; then
        info "Installing official standalone Kitty release in user space..."
        if run_as_user bash -c 'curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n'; then
            ensure_dir "$USER_BIN"
            run_as_user ln -sfn "$TARGET_HOME/.local/kitty.app/bin/kitty" "$USER_BIN/kitty"
            run_as_user ln -sfn "$TARGET_HOME/.local/kitty.app/bin/kitten" "$USER_BIN/kitten"
            ok "Kitty standalone installed into $USER_BIN"
            INSTALLED_ITEMS+=("Kitty Terminal (Standalone)")
        else
            fail "Could not download Kitty standalone release."
            return 1
        fi
    fi

    # Register Kitty desktop launcher & icons
    ensure_dir "$TARGET_HOME/.local/share/applications"
    ensure_dir "$TARGET_HOME/.local/share/icons/hicolor/256x256/apps"
    if [[ -d "$TARGET_HOME/.local/kitty.app" ]]; then
        run_as_user cp -f "$TARGET_HOME/.local/kitty.app/share/applications/kitty*.desktop" "$TARGET_HOME/.local/share/applications/" 2>/dev/null || true
        run_as_user cp -f "$TARGET_HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png" "$TARGET_HOME/.local/share/icons/hicolor/256x256/apps/" 2>/dev/null || true
        run_as_user sed -i "s|^Icon=kitty|Icon=$TARGET_HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g; s|^Exec=kitty|Exec=$TARGET_HOME/.local/kitty.app/bin/kitty|g" "$TARGET_HOME/.local/share/applications/kitty*.desktop" 2>/dev/null || true
    fi

    if has update-desktop-database; then
        run_as_user update-desktop-database "$TARGET_HOME/.local/share/applications" >/dev/null 2>&1 || true
    fi
}

install_user_binaries() {
    section "User-Space Tool Fallbacks"
    ensure_dir "$USER_BIN"

    # 1. Starship prompt
    if ! has starship && [[ ! -x "$USER_BIN/starship" ]]; then
        info "Installing Starship prompt into $USER_BIN..."
        run_as_user bash -c 'curl -fsSL https://starship.rs/install.sh | sh -s -- --bin-dir "$1" --yes' _ "$USER_BIN" && ok "Starship prompt installed" || warn "Could not install Starship."
    else
        ok "Starship prompt ready"
    fi

    # 2. Zoxide
    if ! has zoxide && [[ ! -x "$USER_BIN/zoxide" ]]; then
        info "Installing Zoxide into user space..."
        run_as_user bash -c 'curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh' && ok "Zoxide installed" || warn "Could not install Zoxide."
    else
        ok "Zoxide smart navigation ready"
    fi

    # 3. FZF
    if ! has fzf && [[ ! -x "$USER_BIN/fzf" ]]; then
        local fzf_dir="$TARGET_HOME/.fzf"
        info "Installing Fzf into $fzf_dir..."
        if [[ ! -d $fzf_dir/.git ]] && run_as_user git clone --depth 1 https://github.com/junegunn/fzf.git "$fzf_dir"; then
            run_as_user "$fzf_dir/install" --bin --no-key-bindings --no-completion --no-update-rc
            run_as_user ln -sfn "$fzf_dir/bin/fzf" "$USER_BIN/fzf"
            ok "Fzf fuzzy finder installed"
        fi
    else
        ok "Fzf fuzzy finder ready"
    fi

    # 4. LazyGit Fallback
    if ! has lazygit && [[ ! -x "$USER_BIN/lazygit" ]]; then
        info "Installing LazyGit binary into $USER_BIN..."
        run_as_user bash -c '
            LG_VER=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po "\"tag_name\": \"v\K[^\"]*")
            if [ -n "$LG_VER" ]; then
                curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LG_VER}_Linux_x86_64.tar.gz"
                tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit
                install -m 0755 /tmp/lazygit "$1/lazygit"
                rm -f /tmp/lazygit.tar.gz /tmp/lazygit
            fi
        ' _ "$USER_BIN" 2>/dev/null && ok "LazyGit installed into $USER_BIN" || warn "Could not install LazyGit fallback."
    else
        ok "LazyGit ready"
    fi

    # 5. Yazi Fallback
    if ! has yazi && [[ ! -x "$USER_BIN/yazi" ]]; then
        info "Installing Yazi binary into $USER_BIN..."
        run_as_user bash -c '
            curl -Lo /tmp/yazi.zip "https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip" 2>/dev/null
            if [ -f /tmp/yazi.zip ]; then
                unzip -q -o /tmp/yazi.zip -d /tmp/yazi-extracted 2>/dev/null
                install -m 0755 /tmp/yazi-extracted/yazi*/yazi "$1/yazi" 2>/dev/null || true
                install -m 0755 /tmp/yazi-extracted/yazi*/ya "$1/ya" 2>/dev/null || true
                rm -rf /tmp/yazi.zip /tmp/yazi-extracted
            fi
        ' _ "$USER_BIN" 2>/dev/null && ok "Yazi installed into $USER_BIN" || warn "Could not install Yazi fallback."
    else
        ok "Yazi file manager ready"
    fi
}

install_fonts() {
    section "Typography & Nerd Fonts"
    local src="$SCRIPT_DIR/fonts/fantasque-sans-mono-nerd-fonts"
    local dst="$TARGET_HOME/.local/share/fonts/fantasque-sans-mono-nerd-fonts"
    if [[ -d $src ]]; then
        ensure_dir "$dst"
        run_as_user find "$src" -maxdepth 1 -type f -name '*.ttf' -exec cp -f {} "$dst/" \;
        ok "Fantasque Sans Mono Nerd Font deployed"
        INSTALLED_ITEMS+=("Fantasque Nerd Font")
    else
        info "Font directory not bundled, verifying existing system font cache..."
    fi

    if has fc-cache; then
        run_as_user fc-cache -f "$TARGET_HOME/.local/share/fonts" >/dev/null 2>&1 || true
        ok "Font cache refreshed"
    fi
}

install_plugin() {
    local name=$1 url=$2 entry=$3 dst
    dst="$TARGET_HOME/.zsh/$name"
    if [[ -f $dst/$entry || -d $dst/$entry ]]; then
        ok "Zsh plugin '$name' up-to-date"
        return 0
    fi
    has git || {
        warn "Cannot clone '$name' (git missing)."
        return 1
    }
    ensure_dir "$TARGET_HOME/.zsh"
    [[ -e $dst ]] && run_as_user rm -rf "$dst"
    if "$DRY_RUN"; then
        info "[dry-run] git clone --depth 1 $url $dst"
        return 0
    fi
    if run_as_user git clone --depth 1 "$url" "$dst" >/dev/null 2>&1 && [[ -f $dst/$entry || -d $dst/$entry ]]; then
        ok "Installed Zsh plugin '$name'"
    else
        warn "Could not clone Zsh plugin '$name'"
    fi
}

copy_file() {
    local src=$1 dst=$2 backup
    [[ -f $src ]] || {
        fail "Source file missing: $src"
        return 1
    }
    ensure_dir "$(dirname "$dst")" || return 1
    if [[ -L $dst ]]; then
        warn "Skipped symlink $dst to preserve custom link."
        return 0
    fi
    if [[ -e $dst ]] && ! cmp -s "$src" "$dst"; then
        backup="$BACKUP_DIR/${dst#"$TARGET_HOME"/}"
        ensure_dir "$(dirname "$backup")" || return 1
        run_as_user cp -a "$dst" "$backup" || {
            fail "Failed to backup $dst"
            return 1
        }
        info "Backed up existing ${dst#"$TARGET_HOME"/}"
    fi
    run_as_user install -m 0644 "$src" "$dst" && ok "Installed ${dst#"$TARGET_HOME"/}" || fail "Could not install $dst"
}

deploy_config() {
    section "Deploying Dotfiles & Theme Configurations"

    # 1. Kitty configurations, themes & textures
    copy_file "$SCRIPT_DIR/kitty/kitty.conf" "$TARGET_HOME/.config/kitty/kitty.conf"
    copy_file "$SCRIPT_DIR/kitty/keybindings.conf" "$TARGET_HOME/.config/kitty/keybindings.conf"
    copy_file "$SCRIPT_DIR/kitty/open-actions.conf" "$TARGET_HOME/.config/kitty/open-actions.conf"
    [[ -f "$SCRIPT_DIR/kitty/theme.conf" ]] && copy_file "$SCRIPT_DIR/kitty/theme.conf" "$TARGET_HOME/.config/kitty/theme.conf"

    if [[ -d "$SCRIPT_DIR/kitty/textures" ]]; then
        ensure_dir "$TARGET_HOME/.config/kitty/textures"
        for tex in "$SCRIPT_DIR/kitty/textures"/*; do
            [[ -f "$tex" ]] || continue
            copy_file "$tex" "$TARGET_HOME/.config/kitty/textures/$(basename "$tex")"
        done
    fi

    if [[ -d "$SCRIPT_DIR/kitty/sessions" ]]; then
        for session_file in "$SCRIPT_DIR/kitty/sessions"/*; do
            [[ -f "$session_file" ]] || continue
            copy_file "$session_file" "$TARGET_HOME/.config/kitty/sessions/$(basename "$session_file")"
        done
    fi

    # 2. CLI Helper Tools in bin/
    if [[ -d "$SCRIPT_DIR/bin" ]]; then
        ensure_dir "$USER_BIN"
        for bin_file in "$SCRIPT_DIR/bin"/*; do
            [[ -f "$bin_file" ]] || continue
            run_as_user install -m 0755 "$bin_file" "$USER_BIN/$(basename "$bin_file")" && ok "Installed CLI helper $(basename "$bin_file")" || warn "Could not install $(basename "$bin_file")"
        done
    fi

    # 3. Starship, Environment, Cava, Shells
    copy_file "$SCRIPT_DIR/starship.toml" "$TARGET_HOME/.config/starship.toml"
    copy_file "$SCRIPT_DIR/terminal.conf" "$TARGET_HOME/.config/environment.d/terminal.conf"
    [[ -f "$SCRIPT_DIR/cava/config" ]] && copy_file "$SCRIPT_DIR/cava/config" "$TARGET_HOME/.config/cava/config"
    if [[ -d "$SCRIPT_DIR/cava/shaders" ]]; then
        for shader_file in "$SCRIPT_DIR/cava/shaders"/*; do
            [[ -f "$shader_file" ]] || continue
            copy_file "$shader_file" "$TARGET_HOME/.config/cava/shaders/$(basename "$shader_file")"
        done
    fi

    copy_file "$SCRIPT_DIR/.zshrc" "$TARGET_HOME/.zshrc"
    copy_file "$SCRIPT_DIR/.bashrc" "$TARGET_HOME/.bashrc"
    copy_file "$SCRIPT_DIR/.bash_profile" "$TARGET_HOME/.bash_profile"

    # 4. Git delta integration
    if [[ -f "$SCRIPT_DIR/.gitconfig" ]]; then
        if [[ ! -e "$TARGET_HOME/.gitconfig" ]]; then
            copy_file "$SCRIPT_DIR/.gitconfig" "$TARGET_HOME/.gitconfig"
        else
            info "Preserved existing ~/.gitconfig (merge delta pager settings manually if desired)"
        fi
    fi

    # 5. Fastfetch & Yazi
    if [[ -f "$SCRIPT_DIR/fastfetch/config.jsonc" ]]; then
        copy_file "$SCRIPT_DIR/fastfetch/config.jsonc" "$TARGET_HOME/.config/fastfetch/config.jsonc"
    fi
    if [[ -d "$SCRIPT_DIR/fastfetch/arts" ]]; then
        ensure_dir "$TARGET_HOME/.config/fastfetch/arts"
        find "$SCRIPT_DIR/fastfetch/arts" -type f -name "*.txt" | while read -r art_file; do
            copy_file "$art_file" "$TARGET_HOME/.config/fastfetch/arts/$(basename "$art_file")"
        done
    fi
    if [[ -f "$SCRIPT_DIR/fastfetch/fastfetch-random.sh" ]]; then
        copy_file "$SCRIPT_DIR/fastfetch/fastfetch-random.sh" "$TARGET_HOME/.config/fastfetch/fastfetch-random.sh"
        chmod +x "$TARGET_HOME/.config/fastfetch/fastfetch-random.sh" 2>/dev/null || true
    fi
    if [[ -f "$SCRIPT_DIR/yazi/yazi.toml" ]]; then
        copy_file "$SCRIPT_DIR/yazi/yazi.toml" "$TARGET_HOME/.config/yazi/yazi.toml"
    fi

    # 6. Tmux fallback
    [[ -f "$SCRIPT_DIR/.tmux.conf" ]] && copy_file "$SCRIPT_DIR/.tmux.conf" "$TARGET_HOME/.tmux.conf"

    # 7. LazyVim Neovim IDE
    if [[ -d "$SCRIPT_DIR/nvim" ]]; then
        section "LazyVim IDE Setup & Bootstrap"
        ensure_dir "$TARGET_HOME/.config/nvim"
        find "$SCRIPT_DIR/nvim" -type f | while read -r nvim_file; do
            rel_file="${nvim_file#"$SCRIPT_DIR/nvim/"}"
            copy_file "$nvim_file" "$TARGET_HOME/.config/nvim/$rel_file"
        done
        if has nvim && ! "$DRY_RUN"; then
            info "Synchronizing LazyVim plugins in headless mode..."
            if run_as_user nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1; then
                ok "LazyVim plugins initialized and verified"
                INSTALLED_ITEMS+=("LazyVim IDE")
            else
                warn "LazyVim will complete plugin synchronization on first interactive launch."
            fi
        fi
    fi
}

change_login_shell() {
    "$CHANGE_SHELL" || return 0
    has zsh || {
        warn "Zsh is not installed; login shell unchanged."
        return 1
    }
    local zsh_bin
    zsh_bin=$(command -v zsh)
    if "$AUTO_YES" || { [[ -t 0 ]] && read -r -p "Make $zsh_bin your default login shell? [y/N] " reply && [[ $reply =~ ^[Yy]$ ]]; }; then
        if [[ $(id -u) -eq 0 ]]; then
            run chsh -s "$zsh_bin" "$TARGET_USER"
        else
            run chsh -s "$zsh_bin"
        fi
        if [[ $? -eq 0 ]]; then
            ok "Default login shell changed to Zsh ($zsh_bin)"
        else
            warn "Could not change login shell automatically. Run: chsh -s $zsh_bin"
        fi
    fi
}

verify() {
    section "Verification & Health Check"
    
    local -a core_bins=(kitty starship zoxide fzf nvim lazygit yazi fastfetch cava btop)
    for b in "${core_bins[@]}"; do
        animate_check "${bold}$b${reset} binary" "has $b || [[ -x $USER_BIN/$b ]]"
    done
    
    animate_check "${bold}Kitty terminal config${reset}" "[[ -f $TARGET_HOME/.config/kitty/kitty.conf ]]"
    animate_check "${bold}LazyVim configuration${reset}" "[[ -f $TARGET_HOME/.config/nvim/init.lua ]]"
    animate_check "${bold}Starship prompt config${reset}" "[[ -f $TARGET_HOME/.config/starship.toml ]]"
    animate_check "${bold}Zsh theme & completions${reset}" "[[ -f $TARGET_HOME/.zshrc ]]"
}

main() {
    show_intro_animation

    "$DRY_RUN" && info "Mode: ${c_yellow}DRY-RUN (Simulating changes without writing files)${reset}"

    ensure_dir "$USER_BIN" || exit 1
    export PATH="$USER_BIN:$PATH"

    preflight_checks
    install_packages
    install_kitty
    install_user_binaries
    install_fonts

    section "Zsh Plugins Suite"
    install_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions zsh-autosuggestions.zsh
    install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting.zsh
    install_plugin zsh-completions https://github.com/zsh-users/zsh-completions src
    install_plugin zsh-history-substring-search https://github.com/zsh-users/zsh-history-substring-search zsh-history-substring-search.zsh
    install_plugin zsh-you-should-use https://github.com/MichaelAquilina/zsh-you-should-use you-should-use.plugin.zsh

    deploy_config
    change_login_shell

    if "$DRY_RUN"; then
        info "[dry-run] Verification skipped in dry-run mode."
    else
        verify
    fi

    local end_time
    end_time=$(date +%s)
    local elapsed=$((end_time - START_TIME))

    printf "\n"
    show_celebration_animation
    printf "${bold}${c_purple}━━━━━━━━━━━━━━━━━━━━━━ Installation Summary ━━━━━━━━━━━━━━━━━━━━━━${reset}\n"
    if ((${#ERRORS[@]} == 0)); then
        printf "${c_green}${bold}✨ Setup completed successfully in %d second(s)!${reset}\n\n" "$elapsed"
        printf "  ${bold}${c_coral}Quick Launch Commands:${reset}\n"
        printf "  • ${c_neon_blue}kitty${reset}          → Launch Kitty Terminal\n"
        printf "  • ${c_neon_blue}v${reset} (or ${c_neon_blue}nvim${reset})     → Open LazyVim IDE\n"
        printf "  • ${c_neon_blue}cool${reset}           → Visual Screensavers, Audio & Art Launcher\n"
        printf "  • ${c_neon_blue}rice${reset}           → Launch 3-Pane Aesthetic Lounge (Cava+Btop+Clock)\n"
        printf "  • ${c_neon_blue}scmd${reset}           → Fuzzy Command & Hotkey Cheatsheet\n"
        printf "  • ${c_neon_blue}fastfetch${reset}      → Display Fastfetch Spec Banner\n"
        printf "  • ${c_neon_blue}matrix-red${reset}     → Crimson Matrix Digital Rain\n\n"
    else
        printf "${c_red}${bold}Completed with %d error(s). Review logs above.${reset}\n" "${#ERRORS[@]}"
    fi

    if ((${#WARNINGS[@]} > 0)); then
        printf "${c_yellow}%d warning(s) noted above.${reset}\n" "${#WARNINGS[@]}"
    fi

    ((${#ERRORS[@]} == 0))
}

main "$@"
