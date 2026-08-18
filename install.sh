#!/usr/bin/env bash
# ==============================================================================
# Complete Fail-Proof Kitty, Shell & Modern CLI Environment Installer
# Portable, Multi-Distro, Idempotent, Non-Root & Sudo-Aware with Auto-Fallbacks
# ==============================================================================

set -uo pipefail

# ── 1. COLOR & LOGGING HELPERS ────────────────────────────────
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
RESET="\033[0m"

info()    { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[OK]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*"; }
step()    { echo -e "\n${BOLD}${CYAN}==> $*${RESET}"; }

# ── 2. ENVIRONMENT & USER DETECTION ──────────────────────────
if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
    TARGET_USER="$SUDO_USER"
    TARGET_HOME="$(getent passwd "$TARGET_USER" 2>/dev/null | cut -d: -f6)"
    [ -z "$TARGET_HOME" ] && TARGET_HOME="/home/$TARGET_USER"
    IS_SUDO_RUN=true
else
    TARGET_USER="$(id -un)"
    TARGET_HOME="${HOME:-/home/$TARGET_USER}"
    IS_SUDO_RUN=false
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="${TARGET_HOME}/.config/dotfiles_backup_${TIMESTAMP}"
USER_BIN="${TARGET_HOME}/.local/bin"

mkdir -p "$USER_BIN"
export PATH="${USER_BIN}:${PATH}"

has_cmd() { command -v "$1" >/dev/null 2>&1; }

AUTO_YES=false
for arg in "$@"; do
    if [ "$arg" = "-y" ] || [ "$arg" = "--yes" ] || [ "$arg" = "--non-interactive" ]; then
        AUTO_YES=true
        break
    fi
done

run_elevated() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif sudo -n true 2>/dev/null; then
        sudo -n "$@"
    elif [ "$AUTO_YES" = false ] && [ -t 0 ] && has_cmd sudo; then
        sudo "$@"
    else
        return 1
    fi
}

run_as_user() {
    if [ "$IS_SUDO_RUN" = true ]; then
        sudo -u "$TARGET_USER" -H "$@"
    else
        "$@"
    fi
}

# ── 3. SYSTEM PACKAGE INSTALLATION (BEST-EFFORT) ─────────────
install_system_dependencies() {
    step "Checking System Package Manager"
    
    local pkg_success=false

    if has_cmd pacman; then
        info "Package manager detected: pacman (Arch/Manjaro)"
        if run_elevated pacman -S --needed --noconfirm kitty zsh fzf zoxide starship bat fontconfig curl git 2>/dev/null; then
            pkg_success=true
            success "System packages installed via pacman."
        fi
    elif has_cmd dnf; then
        info "Package manager detected: dnf (Fedora/RHEL)"
        if run_elevated dnf install -y kitty zsh fzf zoxide starship bat fontconfig curl git 2>/dev/null; then
            pkg_success=true
            success "System packages installed via dnf."
        fi
    elif has_cmd apt-get; then
        info "Package manager detected: apt (Debian/Ubuntu/Mint)"
        if run_elevated apt-get update -y 2>/dev/null && run_elevated apt-get install -y kitty zsh fzf fontconfig curl git bat 2>/dev/null; then
            pkg_success=true
            success "System packages installed via apt."
        fi
    elif has_cmd zypper; then
        info "Package manager detected: zypper (openSUSE)"
        if run_elevated zypper --non-interactive install kitty zsh fzf zoxide starship bat fontconfig curl git 2>/dev/null; then
            pkg_success=true
            success "System packages installed via zypper."
        fi
    elif has_cmd apk; then
        info "Package manager detected: apk (Alpine)"
        if run_elevated apk add kitty zsh fzf zoxide starship bat fontconfig curl git 2>/dev/null; then
            pkg_success=true
            success "System packages installed via apk."
        fi
    elif has_cmd xbps-install; then
        info "Package manager detected: xbps (Void Linux)"
        if run_elevated xbps-install -Sy kitty zsh fzf zoxide starship bat fontconfig curl git 2>/dev/null; then
            pkg_success=true
            success "System packages installed via xbps."
        fi
    fi

    if [ "$pkg_success" = false ]; then
        info "System package manager install skipped or requires sudo. Proceeding with automatic user-space fallbacks."
    fi
}

# ── 4. AUTOMATIC KITTY INSTALLATION (STANDALONE FALLBACK) ────
install_kitty_binary() {
    step "Verifying Kitty Terminal Installation"

    if has_cmd kitty; then
        success "Kitty is installed at: $(command -v kitty) ($(kitty --version 2>/dev/null || echo 'available'))"
        return 0
    fi

    info "Kitty binary not found in PATH. Installing official standalone Kitty release..."
    if has_cmd curl; then
        run_as_user curl -L https://sw.kovidgoyal.net/kitty/installer.sh | run_as_user sh /dev/stdin launch=n

        # Create symlinks to ~/.local/bin
        mkdir -p "$USER_BIN"
        ln -sf "${TARGET_HOME}/.local/kitty.app/bin/kitty" "${USER_BIN}/kitty"
        ln -sf "${TARGET_HOME}/.local/kitty.app/bin/kitten" "${USER_BIN}/kitten"

        # Desktop integration & icons
        local app_dir="${TARGET_HOME}/.local/share/applications"
        mkdir -p "$app_dir"
        if [ -f "${TARGET_HOME}/.local/kitty.app/share/applications/kitty.desktop" ]; then
            cp "${TARGET_HOME}/.local/kitty.app/share/applications/kitty.desktop" "${app_dir}/"
            cp "${TARGET_HOME}/.local/kitty.app/share/applications/kitty-open.desktop" "${app_dir}/" 2>/dev/null || true
            sed -i "s|Icon=kitty|Icon=${TARGET_HOME}/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" "${app_dir}"/kitty*.desktop 2>/dev/null || true
            sed -i "s|Exec=kitty|Exec=${TARGET_HOME}/.local/kitty.app/bin/kitty|g" "${app_dir}"/kitty*.desktop 2>/dev/null || true
            
            if has_cmd update-desktop-database; then
                update-desktop-database "$app_dir" 2>/dev/null || true
            fi
        fi

        if [ -x "${USER_BIN}/kitty" ]; then
            success "Kitty standalone installer completed successfully."
        else
            warn "Kitty binary installation requires manual verification."
        fi
    else
        error "curl is required to download Kitty standalone installer."
    fi
}

# ── 5. AUTOMATIC CLI TOOLS (STARSHIP, ZOXIDE, FZF) ───────────
install_cli_tools() {
    step "Verifying & Installing Modern CLI Tools (Starship, Zoxide, FZF)"

    # 1. Starship Prompt
    if has_cmd starship; then
        success "Starship is installed: $(starship --version 2>/dev/null | head -n 1 || echo 'available')"
    else
        if has_cmd curl; then
            info "Downloading & installing Starship into ${USER_BIN}..."
            run_as_user curl -sS https://starship.rs/install.sh | run_as_user sh -s -- --bin-dir "$USER_BIN" -y 2>/dev/null || warn "Starship installer had warnings."
        fi
    fi

    # 2. Zoxide
    if has_cmd zoxide; then
        success "Zoxide is installed: $(zoxide --version 2>/dev/null || echo 'available')"
    else
        if has_cmd curl; then
            info "Downloading & installing Zoxide..."
            run_as_user curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | run_as_user sh 2>/dev/null || warn "Zoxide installer had warnings."
        fi
    fi

    # 3. FZF
    if has_cmd fzf; then
        success "FZF is installed: $(fzf --version 2>/dev/null || echo 'available')"
    else
        local fzf_dir="${TARGET_HOME}/.fzf"
        if [ ! -d "$fzf_dir" ] && has_cmd git; then
            info "Cloning and installing FZF into ${fzf_dir}..."
            git clone --depth 1 https://github.com/junegunn/fzf.git "$fzf_dir" 2>/dev/null && \
                "$fzf_dir"/install --bin --no-key-bindings --no-completion --no-update-rc 2>/dev/null || true
        fi
        if [ -x "${fzf_dir}/bin/fzf" ]; then
            ln -sf "${fzf_dir}/bin/fzf" "${USER_BIN}/fzf"
            success "FZF binary installed into ${USER_BIN}/fzf"
        fi
    fi
}

# ── 6. BACKUP HELPER ──────────────────────────────────────────
safe_backup_and_copy() {
    local src="$1"
    local dst="$2"

    if [ ! -f "$src" ]; then
        warn "Source file missing: $src (skipped)"
        return 0
    fi

    local dst_dir
    dst_dir="$(dirname "$dst")"
    mkdir -p "$dst_dir"

    # If destination exists and differs from source, create backup
    if [ -f "$dst" ] || [ -L "$dst" ]; then
        if ! cmp -s "$src" "$dst"; then
            mkdir -p "$BACKUP_DIR"
            local rel_name
            rel_name="$(basename "$dst")"
            cp -a "$dst" "${BACKUP_DIR}/${rel_name}"
            info "Backed up existing ${dst} -> ${BACKUP_DIR}/${rel_name}"
        fi
    fi

    cp "$src" "$dst"
    chown "$TARGET_USER":"$(id -gn "$TARGET_USER" 2>/dev/null || id -g)" "$dst" 2>/dev/null || true
    success "Deployed: $dst"
}

# ── 7. FONTS DEPLOYMENT ───────────────────────────────────────
install_fonts() {
    step "Installing Fantasque Sans Mono Nerd Font"
    local font_dst="${TARGET_HOME}/.local/share/fonts/fantasque-sans-mono-nerd-fonts"
    mkdir -p "$font_dst"

    local src_font_dir="${SCRIPT_DIR}/fonts/fantasque-sans-mono-nerd-fonts"
    if [ -d "$src_font_dir" ] && [ "$(ls -A "$src_font_dir" 2>/dev/null)" ]; then
        cp -r "$src_font_dir"/* "$font_dst/" 2>/dev/null || true
        success "Font files installed to $font_dst"
    else
        warn "Local font files not found. Attempting online download..."
        if has_cmd curl && has_cmd unzip; then
            local temp_zip="/tmp/fantasque_font_$$.zip"
            curl -fLo "$temp_zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FantasqueSansMono.zip" 2>/dev/null && {
                unzip -q -o "$temp_zip" -d "$font_dst" 2>/dev/null || true
                rm -f "$temp_zip"
                success "Downloaded and extracted Fantasque Sans Mono font."
            } || warn "Could not download fonts automatically."
        fi
    fi

    chown -R "$TARGET_USER":"$(id -gn "$TARGET_USER" 2>/dev/null || id -g)" "${TARGET_HOME}/.local/share/fonts" 2>/dev/null || true

    if has_cmd fc-cache; then
        fc-cache -f "${TARGET_HOME}/.local/share/fonts" >/dev/null 2>&1 || true
        success "Font cache refreshed."
    fi
}

# ── 8. ZSH PLUGINS SETUP ─────────────────────────────────────
setup_zsh_plugins() {
    step "Setting up Zsh Plugins"
    local zsh_dir="${TARGET_HOME}/.zsh"
    mkdir -p "$zsh_dir"

    # 1. zsh-autosuggestions
    local auto_src="${SCRIPT_DIR}/zsh/zsh-autosuggestions"
    local auto_dst="${zsh_dir}/zsh-autosuggestions"
    if [ -d "$auto_src" ] && [ "$(ls -A "$auto_src" 2>/dev/null)" ]; then
        mkdir -p "$auto_dst"
        cp -r "$auto_src"/* "$auto_dst/" 2>/dev/null || true
        success "Installed zsh-autosuggestions from backup."
    elif [ ! -d "$auto_dst" ] && has_cmd git; then
        info "Cloning zsh-autosuggestions..."
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$auto_dst" 2>/dev/null || warn "Failed to clone zsh-autosuggestions."
    fi

    # 2. zsh-syntax-highlighting
    local syn_src="${SCRIPT_DIR}/zsh/zsh-syntax-highlighting"
    local syn_dst="${zsh_dir}/zsh-syntax-highlighting"
    if [ -d "$syn_src" ] && [ "$(ls -A "$syn_src" 2>/dev/null)" ]; then
        mkdir -p "$syn_dst"
        cp -r "$syn_src"/* "$syn_dst/" 2>/dev/null || true
        success "Installed zsh-syntax-highlighting from backup."
    elif [ ! -d "$syn_dst" ] && has_cmd git; then
        info "Cloning zsh-syntax-highlighting..."
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$syn_dst" 2>/dev/null || warn "Failed to clone zsh-syntax-highlighting."
    fi

    chown -R "$TARGET_USER":"$(id -gn "$TARGET_USER" 2>/dev/null || id -g)" "$zsh_dir" 2>/dev/null || true
}

# ── 9. CONFIGURATION DEPLOYMENT ──────────────────────────────
deploy_configurations() {
    step "Deploying Configurations"

    # Kitty configuration
    safe_backup_and_copy "${SCRIPT_DIR}/kitty/kitty.conf" "${TARGET_HOME}/.config/kitty/kitty.conf"
    [ -f "${SCRIPT_DIR}/kitty/kitty.conf.bak" ] && safe_backup_and_copy "${SCRIPT_DIR}/kitty/kitty.conf.bak" "${TARGET_HOME}/.config/kitty/kitty.conf.bak"

    # Starship configuration
    safe_backup_and_copy "${SCRIPT_DIR}/starship.toml" "${TARGET_HOME}/.config/starship.toml"
    [ -f "${SCRIPT_DIR}/starship.toml.bak" ] && safe_backup_and_copy "${SCRIPT_DIR}/starship.toml.bak" "${TARGET_HOME}/.config/starship.toml.bak"

    # Terminal environment
    safe_backup_and_copy "${SCRIPT_DIR}/terminal.conf" "${TARGET_HOME}/.config/environment.d/terminal.conf"

    # Shell RC files (.zshrc, .bashrc, .bash_profile)
    for rc in .zshrc .bashrc .bash_profile; do
        if [ -f "${SCRIPT_DIR}/${rc}" ]; then
            safe_backup_and_copy "${SCRIPT_DIR}/${rc}" "${TARGET_HOME}/${rc}"
        fi
    done

    chown -R "$TARGET_USER":"$(id -gn "$TARGET_USER" 2>/dev/null || id -g)" "${TARGET_HOME}/.config" "${TARGET_HOME}/.local" 2>/dev/null || true
}

# ── 10. DEFAULT SHELL CONFIGURATION & GUIDANCE ───────────────
configure_default_shell() {
    step "Configuring Shell Environment"
    local zsh_bin
    zsh_bin="$(command -v zsh 2>/dev/null || true)"

    if [ -z "$zsh_bin" ]; then
        warn "Zsh is not installed on this system."
        info "Kitty is configured with 'shell .' to launch your system default shell ($SHELL) seamlessly."
        info "To install Zsh anytime:"
        if has_cmd dnf; then
            echo -e "    ${BOLD}sudo dnf install zsh${RESET}"
        elif has_cmd apt-get; then
            echo -e "    ${BOLD}sudo apt install zsh${RESET}"
        elif has_cmd pacman; then
            echo -e "    ${BOLD}sudo pacman -S zsh${RESET}"
        fi
        echo -e "  Then run ${BOLD}chsh -s \$(which zsh)${RESET} to make it default."
        return 0
    fi

    # Ensure zsh is listed in /etc/shells
    if [ -f /etc/shells ] && ! grep -Fxq "$zsh_bin" /etc/shells 2>/dev/null; then
        if [ "$(id -u)" -eq 0 ]; then
            echo "$zsh_bin" >> /etc/shells 2>/dev/null || true
        elif sudo -n true 2>/dev/null; then
            echo "$zsh_bin" | sudo -n tee -a /etc/shells >/dev/null 2>&1 || true
        fi
    fi

    local current_user_shell
    current_user_shell="$(getent passwd "$TARGET_USER" 2>/dev/null | cut -d: -f7 || echo "$SHELL")"

    if [ "$current_user_shell" = "$zsh_bin" ]; then
        success "Zsh is already the default shell for ${TARGET_USER}."
        return 0
    fi

    local auto_yes=false
    for arg in "$@"; do
        if [ "$arg" = "-y" ] || [ "$arg" = "--yes" ] || [ "$arg" = "--non-interactive" ]; then
            auto_yes=true
            break
        fi
    done

    if [ "$auto_yes" = false ] && [ -t 0 ]; then
        read -r -p "Set Zsh ($zsh_bin) as default shell for $TARGET_USER? [Y/n] " choice
        choice=${choice:-Y}
        if [[ ! "$choice" =~ ^[Yy]$ ]]; then
            info "Skipping default shell change as requested."
            return 0
        fi
    fi

    info "Setting default shell to $zsh_bin for $TARGET_USER..."
    if [ "$(id -u)" -eq 0 ]; then
        chsh -s "$zsh_bin" "$TARGET_USER" 2>/dev/null || usermod -s "$zsh_bin" "$TARGET_USER" 2>/dev/null || warn "Could not change shell automatically."
    else
        chsh -s "$zsh_bin" 2>/dev/null || warn "Could not change default shell. Run manually: chsh -s $zsh_bin"
    fi
}

# ── 11. MAIN ROUTINE ──────────────────────────────────────────
main() {
    echo -e "${BOLD}${BLUE}"
    echo "========================================================"
    echo "  Kitty & Modern CLI Environment Automated Installer"
    echo "  Target User : ${TARGET_USER}"
    echo "  Target Home : ${TARGET_HOME}"
    echo "========================================================"
    echo -e "${RESET}"

    install_system_dependencies
    install_kitty_binary
    install_cli_tools
    install_fonts
    setup_zsh_plugins
    deploy_configurations
    configure_default_shell "$@"

    echo -e "\n${BOLD}${GREEN}========================================================"
    echo "  Installation Completed Successfully!"
    echo "========================================================${RESET}"
    if [ -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}Existing configuration backups saved in:${RESET}"
        echo -e "  ${BACKUP_DIR}\n"
    fi
    echo -e "You can now launch Kitty immediately:"
    echo -e "  ${BOLD}kitty &${RESET}\n"
}

main "$@"
