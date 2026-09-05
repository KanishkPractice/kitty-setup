#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
#  KITTY TERMINAL & MODERN CLI SETUP INSTALLER
#  Simple, reliable, robust installation for Fedora / DNF & Linux systems
# ═══════════════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

AUTO_YES=false
DRY_RUN=false
ONLY_CONFIGS=false
SKIP_PKGS=false
CHANGE_SHELL=false

# Identify target user & home directory
if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    TARGET_USER="$SUDO_USER"
    TARGET_HOME="$(getent passwd "$TARGET_USER" 2>/dev/null | cut -d: -f6)"
    TARGET_HOME="${TARGET_HOME:-/home/$TARGET_USER}"
else
    TARGET_USER="$(id -un)"
    TARGET_HOME="${HOME:?HOME variable is not set}"
fi

USER_BIN="$TARGET_HOME/.local/bin"
BACKUP_DIR="$TARGET_HOME/.config/kitty-setup-backups/$TIMESTAMP"

# Clean ANSI styling
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

has() { command -v "$1" >/dev/null 2>&1; }

run_cmd() {
    if "$DRY_RUN"; then
        info "[dry-run] $*"
    else
        "$@"
    fi
}

run_as_user() {
    if [[ $(id -u) -eq 0 && "$TARGET_USER" != "root" ]]; then
        run_cmd sudo -u "$TARGET_USER" -H env "HOME=$TARGET_HOME" "PATH=$USER_BIN:$PATH" "$@"
    else
        run_cmd env "PATH=$USER_BIN:$PATH" "$@"
    fi
}

run_elevated() {
    if [[ $(id -u) -eq 0 ]]; then
        run_cmd "$@"
    elif has sudo; then
        run_cmd sudo "$@"
    else
        run_cmd "$@"
    fi
}

ensure_dir() {
    run_as_user mkdir -p "$1"
}

copy_config_file() {
    local src="$1"
    local dst="$2"

    [[ -f "$src" ]] || return 0
    ensure_dir "$(dirname "$dst")"

    # Avoid overwriting custom symlinks
    if [[ -L "$dst" ]]; then
        info "Preserving existing symlink: $dst"
        return 0
    fi

    # Backup changed existing file
    if [[ -e "$dst" ]] && ! cmp -s "$src" "$dst"; then
        local backup="$BACKUP_DIR/${dst#"$TARGET_HOME"/}"
        ensure_dir "$(dirname "$backup")"
        run_as_user cp -a "$dst" "$backup"
        info "Backed up: ${dst#"$TARGET_HOME"/}"
    fi

    run_as_user install -m 0644 "$src" "$dst"
    success "Deployed: ${dst#"$TARGET_HOME"/}"
}

usage() {
    cat <<EOF
${c_bold}Kitty & Modern CLI Suite Installer${c_reset}

${c_bold}Usage:${c_reset} ./install.sh [options]

${c_bold}Options:${c_reset}
  -y, --yes          Non-interactive mode (auto-accept all prompts)
  --change-shell     Set Zsh as the default login shell
  --only-configs     Deploy configuration files only (skip package installations)
  --no-pkg           Skip DNF system package manager
  --dry-run          Simulate actions without modifying files
  -h, --help         Show this help message
EOF
}

# Parse Arguments
for arg in "$@"; do
    case "$arg" in
        -y|--yes|--non-interactive) AUTO_YES=true ;;
        --change-shell) CHANGE_SHELL=true ;;
        --only-configs) ONLY_CONFIGS=true ;;
        --no-pkg) SKIP_PKGS=true ;;
        --dry-run) DRY_RUN=true ;;
        -h|--help) usage; exit 0 ;;
        *) fail "Unknown option: $arg"; usage; exit 2 ;;
    esac
done

main() {
    printf "\n${c_bold}${c_cyan}╭──────────────────────────────────────────────────────────╮${c_reset}\n"
    printf "${c_bold}${c_cyan}│          ✨ KITTY TERMINAL & MODERN CLI INSTALLER        │${c_reset}\n"
    printf "${c_bold}${c_cyan}╰──────────────────────────────────────────────────────────╯${c_reset}\n\n"

    info "Target User: ${c_bold}$TARGET_USER${c_reset} | Target Home: ${c_bold}$TARGET_HOME${c_reset}"
    ensure_dir "$USER_BIN"
    export PATH="$USER_BIN:$PATH"

    # 1. System packages (Fedora DNF)
    if ! "$ONLY_CONFIGS" && ! "$SKIP_PKGS" && has dnf; then
        section "1. Installing Core Packages via DNF"
        local pkgs=(
            kitty zsh fzf zoxide fontconfig curl git bat
            eza ripgrep fd-find btop tealdeer git-delta cmatrix cbonsai
            neovim gcc make tar unzip cava fastfetch
        )
        info "Running DNF package installation..."
        run_elevated dnf install -y "${pkgs[@]}" || warn "Some DNF packages were skipped or already installed."
        
        # Optional useful packages from COPR
        if ! has lazygit; then
            run_elevated dnf copr enable -y dejan/lazygit 2>/dev/null || true
            run_elevated dnf install -y lazygit 2>/dev/null || true
        fi
        if ! has yazi; then
            run_elevated dnf copr enable -y atim/yazi 2>/dev/null || true
            run_elevated dnf install -y yazi 2>/dev/null || true
        fi
    fi

    # 2. User-space fallbacks for utilities
    section "2. User-Space Utilities & Prompts"
    if ! has starship && [[ ! -x "$USER_BIN/starship" ]]; then
        info "Installing Starship prompt..."
        run_as_user bash -c 'curl -fsSL https://starship.rs/install.sh | sh -s -- --bin-dir "$1" --yes' _ "$USER_BIN" || warn "Starship install skipped."
    else
        success "Starship prompt ready"
    fi

    if ! has zoxide && [[ ! -x "$USER_BIN/zoxide" ]]; then
        info "Installing Zoxide..."
        run_as_user bash -c 'curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh' || warn "Zoxide install skipped."
    else
        success "Zoxide ready"
    fi

    # 3. Fonts deployment
    section "3. Deploying Typography & Fonts"
    local font_src="$SCRIPT_DIR/fonts/fantasque-sans-mono-nerd-fonts"
    local font_dst="$TARGET_HOME/.local/share/fonts/fantasque-sans-mono-nerd-fonts"
    if [[ -d "$font_src" ]]; then
        ensure_dir "$font_dst"
        run_as_user find "$font_src" -maxdepth 1 -type f -name '*.ttf' -exec cp -f {} "$font_dst/" \;
        if has fc-cache; then
            run_as_user fc-cache -f "$TARGET_HOME/.local/share/fonts" >/dev/null 2>&1 || true
        fi
        success "Nerd Fonts installed and font cache updated"
    fi

    # 4. Zsh plugins
    section "4. Installing Zsh Plugins"
    local -A zsh_plugins=(
        ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
        ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
        ["zsh-completions"]="https://github.com/zsh-users/zsh-completions"
        ["zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search"
        ["zsh-you-should-use"]="https://github.com/MichaelAquilina/zsh-you-should-use"
    )

    for plug in "${!zsh_plugins[@]}"; do
        local pdir="$TARGET_HOME/.zsh/$plug"
        if [[ ! -d "$pdir" ]]; then
            info "Cloning plugin $plug..."
            run_as_user git clone --depth 1 "${zsh_plugins[$plug]}" "$pdir" >/dev/null 2>&1 || warn "Could not clone $plug"
        else
            success "Plugin $plug already present"
        fi
    done

    # 5. Configuration files deployment
    section "5. Deploying Modular Configurations"

    # Kitty configurations
    copy_config_file "$SCRIPT_DIR/kitty/kitty.conf" "$TARGET_HOME/.config/kitty/kitty.conf"
    copy_config_file "$SCRIPT_DIR/kitty/keybindings.conf" "$TARGET_HOME/.config/kitty/keybindings.conf"
    copy_config_file "$SCRIPT_DIR/kitty/open-actions.conf" "$TARGET_HOME/.config/kitty/open-actions.conf"
    copy_config_file "$SCRIPT_DIR/kitty/theme.conf" "$TARGET_HOME/.config/kitty/theme.conf"

    if [[ -d "$SCRIPT_DIR/kitty/textures" ]]; then
        for tex in "$SCRIPT_DIR/kitty/textures"/*; do
            [[ -f "$tex" ]] && copy_config_file "$tex" "$TARGET_HOME/.config/kitty/textures/$(basename "$tex")"
        done
    fi

    if [[ -d "$SCRIPT_DIR/kitty/sessions" ]]; then
        for sess in "$SCRIPT_DIR/kitty/sessions"/*; do
            [[ -f "$sess" ]] && copy_config_file "$sess" "$TARGET_HOME/.config/kitty/sessions/$(basename "$sess")"
        done
    fi

    # CLI Helper binaries
    if [[ -d "$SCRIPT_DIR/bin" ]]; then
        ensure_dir "$USER_BIN"
        for b in "$SCRIPT_DIR/bin"/*; do
            if [[ -f "$b" ]]; then
                run_as_user install -m 0755 "$b" "$USER_BIN/$(basename "$b")"
                success "Installed CLI tool: $(basename "$b")"
            fi
        done
    fi

    # Starship, Cava, Environment, Shells
    copy_config_file "$SCRIPT_DIR/starship.toml" "$TARGET_HOME/.config/starship.toml"
    copy_config_file "$SCRIPT_DIR/terminal.conf" "$TARGET_HOME/.config/environment.d/terminal.conf"
    copy_config_file "$SCRIPT_DIR/cava/config" "$TARGET_HOME/.config/cava/config"
    copy_config_file "$SCRIPT_DIR/.zshrc" "$TARGET_HOME/.zshrc"
    copy_config_file "$SCRIPT_DIR/.bashrc" "$TARGET_HOME/.bashrc"
    copy_config_file "$SCRIPT_DIR/.bash_profile" "$TARGET_HOME/.bash_profile"
    copy_config_file "$SCRIPT_DIR/.tmux.conf" "$TARGET_HOME/.tmux.conf"

    if [[ -d "$SCRIPT_DIR/cava/shaders" ]]; then
        for s in "$SCRIPT_DIR/cava/shaders"/*; do
            [[ -f "$s" ]] && copy_config_file "$s" "$TARGET_HOME/.config/cava/shaders/$(basename "$s")"
        done
    fi

    # Fastfetch & Yazi
    copy_config_file "$SCRIPT_DIR/fastfetch/config.jsonc" "$TARGET_HOME/.config/fastfetch/config.jsonc"
    copy_config_file "$SCRIPT_DIR/fastfetch/fastfetch-random.sh" "$TARGET_HOME/.config/fastfetch/fastfetch-random.sh"
    [[ -f "$TARGET_HOME/.config/fastfetch/fastfetch-random.sh" ]] && chmod +x "$TARGET_HOME/.config/fastfetch/fastfetch-random.sh" 2>/dev/null || true

    if [[ -d "$SCRIPT_DIR/fastfetch/arts" ]]; then
        for art in "$SCRIPT_DIR/fastfetch/arts"/*; do
            [[ -f "$art" ]] && copy_config_file "$art" "$TARGET_HOME/.config/fastfetch/arts/$(basename "$art")"
        done
    fi

    if [[ -f "$SCRIPT_DIR/yazi/yazi.toml" ]]; then
        copy_config_file "$SCRIPT_DIR/yazi/yazi.toml" "$TARGET_HOME/.config/yazi/yazi.toml"
    fi

    # Neovim (LazyVim) IDE configuration
    if [[ -d "$SCRIPT_DIR/nvim" ]]; then
        section "6. Setting Up Neovim (LazyVim)"
        ensure_dir "$TARGET_HOME/.config/nvim"
        find "$SCRIPT_DIR/nvim" -type f | while read -r nvim_file; do
            rel_file="${nvim_file#"$SCRIPT_DIR/nvim/"}"
            copy_config_file "$nvim_file" "$TARGET_HOME/.config/nvim/$rel_file"
        done
    fi

    # 7. Shell option
    if "$CHANGE_SHELL" && has zsh; then
        local zsh_path
        zsh_path="$(command -v zsh)"
        if [[ $(id -u) -eq 0 ]]; then
            chsh -s "$zsh_path" "$TARGET_USER" 2>/dev/null || true
        else
            chsh -s "$zsh_path" 2>/dev/null || true
        fi
        success "Changed default login shell to Zsh"
    fi

    printf "\n${c_bold}${c_green}✨ Setup complete! Everything is configured and ready to use.${c_reset}\n\n"
    printf "  ${c_bold}Quick Commands:${c_reset}\n"
    printf "  • ${c_cyan}kitty${c_reset}      → Open Kitty terminal\n"
    printf "  • ${c_cyan}scmd${c_reset}       → Interactive command search & cheat sheet (or press Alt+S)\n"
    printf "  • ${c_cyan}cool${c_reset}       → Visual screensaver & tools menu\n"
    printf "  • ${c_cyan}v / nvim${c_reset}   → Open Neovim IDE\n\n"
}

main "$@"
