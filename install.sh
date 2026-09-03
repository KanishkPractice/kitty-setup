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

# 24-bit TrueColor and ANSI Styles
bold='\033[1m'
dim='\033[2m'
blue='\033[38;2;137;180;250m'
green='\033[38;2;166;227;161m'
yellow='\033[38;2;249;226;175m'
red='\033[38;2;243;139;168m'
cyan='\033[38;2;137;220;235m'
magenta='\033[38;2;203;166;247m'
crimson='\033[38;2;255;51;85m'
gold='\033[38;2;255;183;3m'
reset='\033[0m'

info()    { printf "${blue}•${reset} %s\n" "$*"; }
ok()      { printf "${green}✓${reset} %s\n" "$*"; }
warn()    { WARNINGS+=("$*"); printf "${yellow}!${reset} %s\n" "$*" >&2; }
fail()    { ERRORS+=("$*"); printf "${red}✗${reset} %s\n" "$*" >&2; }
section() { printf "\n${bold}${magenta}━━━ %s ━━━${reset}\n" "$*"; }
has()     { command -v "$1" >/dev/null 2>&1; }

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
  • ${bold}CLI Helpers:${reset} cool (visual launcher), theme (live theme switcher), torii, scmd (fuzzy cheatsheet)
EOF
}

# Parse CLI arguments
for arg in "$@"; do
    case $arg in
        -y|--yes|--non-interactive) AUTO_YES=true ;;
        --change-shell) CHANGE_SHELL=true ;;
        --only-configs) ONLY_CONFIGS=true ;;
        --no-pkg) SKIP_PKGS=true ;;
        --dry-run) DRY_RUN=true ;;
        -h|--help) usage; exit 0 ;;
        *) fail "Unknown option: $arg"; usage; exit 2 ;;
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
    run_as_user mkdir -p "$1" || { fail "Cannot create directory: $1"; return 1; }
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
    has git || { warn "Cannot clone '$name' (git missing)."; return 1; }
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
    [[ -f $src ]] || { fail "Source file missing: $src"; return 1; }
    ensure_dir "$(dirname "$dst")" || return 1
    if [[ -L $dst ]]; then
        warn "Skipped symlink $dst to preserve custom link."
        return 0
    fi
    if [[ -e $dst ]] && ! cmp -s "$src" "$dst"; then
        backup="$BACKUP_DIR/${dst#"$TARGET_HOME"/}"
        ensure_dir "$(dirname "$backup")" || return 1
        run_as_user cp -a "$dst" "$backup" || { fail "Failed to backup $dst"; return 1; }
        info "Backed up existing ${dst#"$TARGET_HOME"/}"
    fi
    run_as_user install -m 0644 "$src" "$dst" && ok "Installed ${dst#"$TARGET_HOME"/}" || fail "Could not install $dst"
}

deploy_config() {
    section "Deploying Dotfiles & Theme Configurations"

    # 1. Kitty configurations & themes
    copy_file "$SCRIPT_DIR/kitty/kitty.conf" "$TARGET_HOME/.config/kitty/kitty.conf"
    copy_file "$SCRIPT_DIR/kitty/keybindings.conf" "$TARGET_HOME/.config/kitty/keybindings.conf"
    copy_file "$SCRIPT_DIR/kitty/open-actions.conf" "$TARGET_HOME/.config/kitty/open-actions.conf"

    if [[ -d "$SCRIPT_DIR/kitty/themes" ]]; then
        for theme_file in "$SCRIPT_DIR/kitty/themes"/*.conf; do
            [[ -f "$theme_file" ]] || continue
            copy_file "$theme_file" "$TARGET_HOME/.config/kitty/themes/$(basename "$theme_file")"
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
        run_as_user ln -sfn "$USER_BIN/theme-switch" "$USER_BIN/theme" 2>/dev/null || true
        run_as_user ln -sfn "$USER_BIN/torii-banner" "$USER_BIN/torii" 2>/dev/null || true
        run_as_user ln -sfn "$USER_BIN/trident-banner" "$USER_BIN/trident" 2>/dev/null || true
        run_as_user ln -sfn "$USER_BIN/samurai-banner" "$USER_BIN/samurai" 2>/dev/null || true
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
    has zsh || { warn "Zsh is not installed; login shell unchanged."; return 1; }
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
    local -a core_bins=(kitty starship zoxide fzf nvim)
    for b in "${core_bins[@]}"; do
        if has "$b" || [[ -x "$USER_BIN/$b" ]]; then
            ok "$b is ready"
        else
            warn "$b is not available in PATH yet"
        fi
    done
    [[ -f "$TARGET_HOME/.config/kitty/kitty.conf" ]] && ok "Kitty terminal config active" || fail "Kitty config missing"
    [[ -f "$TARGET_HOME/.config/nvim/init.lua" ]] && ok "LazyVim configuration active" || fail "LazyVim config missing"
}

main() {
    printf "${bold}${crimson}
  ⛩️  ╭──────────────────────────────────────────────────────────╮
     │         KITTY & MODERN TERMINAL RICE / LAZYVIM           │
     │            Dedicated Fedora & DNF Edition                │
     ╰──────────────────────────────────────────────────────────╯${reset}\n"

    "$DRY_RUN" && info "Mode: ${yellow}DRY-RUN (Simulating changes without writing files)${reset}"

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

    printf "\n${bold}${cyan}━━━━━━━━━━━━━━━━━━━━━━ Installation Summary ━━━━━━━━━━━━━━━━━━━━━━${reset}\n"
    if ((${#ERRORS[@]} == 0)); then
        printf "${green}${bold}✨ Setup completed successfully in %d second(s)!${reset}\n\n" "$elapsed"
        printf "  ${bold}Quick Launch Commands:${reset}\n"
        printf "  • ${cyan}kitty${reset}          → Launch Kitty Terminal\n"
        printf "  • ${cyan}v${reset} (or ${cyan}nvim${reset})     → Open LazyVim IDE\n"
        printf "  • ${cyan}theme${reset}          → Interactive Kitty & Rice Theme Switcher\n"
        printf "  • ${cyan}cool${reset}           → Visual Screensavers, Audio & Art Launcher\n"
        printf "  • ${cyan}rice${reset}           → Launch 3-Pane Aesthetic Lounge (Cava+Btop+Clock)\n"
        printf "  • ${cyan}scmd${reset}           → Fuzzy Command & Hotkey Cheatsheet\n"
        printf "  • ${cyan}torii${reset}          → 24-bit TrueColor ASCII Torii Banner\n\n"
    else
        printf "${red}${bold}Completed with %d error(s). Review logs above.${reset}\n" "${#ERRORS[@]}"
    fi

    if ((${#WARNINGS[@]} > 0)); then
        printf "${yellow}%d warning(s) noted above.${reset}\n" "${#WARNINGS[@]}"
    fi

    ((${#ERRORS[@]} == 0))
}

main "$@"
