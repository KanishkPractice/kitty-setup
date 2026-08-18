#!/usr/bin/env bash
# ==============================================================================
# Fail-Proof Kitty, Zsh, Starship & Environment Installer
# Portable, Multi-Distro, Idempotent, and Non-Root / Sudo Aware
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

# Error handler for unexpected failures
trap 'on_error $? $LINENO' ERR
on_error() {
    local exit_code=$1
    local line_no=$2
    error "An error occurred at line ${line_no} (exit code: ${exit_code})."
    warn "Continuing with remaining setup steps where possible..."
}

# ── 2. ENVIRONMENT & USER DETECTION ──────────────────────────
# Detect real user even when run with `sudo`
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

has_cmd() { command -v "$1" >/dev/null 2>&1; }

run_elevated() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif has_cmd sudo; then
        sudo "$@"
    else
        warn "Sudo not available. Skipping elevated command: $*"
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

# ── 3. SYSTEM PACKAGE INSTALLATION ───────────────────────────
install_system_dependencies() {
    step "Checking & Installing System Dependencies"
    
    if has_cmd pacman; then
        info "Package manager: pacman (Arch/Manjaro)"
        run_elevated pacman -S --needed --noconfirm kitty zsh fzf zoxide starship bat fontconfig curl git 2>/dev/null || warn "pacman install reported issues, checking fallbacks."
    elif has_cmd apt-get; then
        info "Package manager: apt (Debian/Ubuntu/Mint)"
        run_elevated apt-get update -y 2>/dev/null || warn "apt-get update had non-zero exit, proceeding..."
        run_elevated apt-get install -y kitty zsh fzf fontconfig curl git 2>/dev/null || warn "apt-get install had warnings."
        
        if ! has_cmd bat && ! has_cmd batcat; then
            run_elevated apt-get install -y bat 2>/dev/null || true
        fi
    elif has_cmd dnf; then
        info "Package manager: dnf (Fedora/RHEL)"
        run_elevated dnf install -y kitty zsh fzf zoxide starship bat fontconfig curl git 2>/dev/null || warn "dnf install reported issues."
    elif has_cmd zypper; then
        info "Package manager: zypper (openSUSE)"
        run_elevated zypper --non-interactive install kitty zsh fzf zoxide starship bat fontconfig curl git 2>/dev/null || warn "zypper install reported issues."
    elif has_cmd apk; then
        info "Package manager: apk (Alpine)"
        run_elevated apk add kitty zsh fzf zoxide starship bat fontconfig curl git 2>/dev/null || warn "apk install reported issues."
    elif has_cmd xbps-install; then
        info "Package manager: xbps (Void Linux)"
        run_elevated xbps-install -Sy kitty zsh fzf zoxide starship bat fontconfig curl git 2>/dev/null || warn "xbps install reported issues."
    else
        warn "No supported package manager detected or non-root environment. Proceeding with user-space binaries."
    fi

    # Fallback user-space installation for starship and zoxide if not installed
    local user_bin="${TARGET_HOME}/.local/bin"
    mkdir -p "$user_bin"

    if ! has_cmd starship; then
        if has_cmd curl; then
            info "Installing Starship into ${user_bin}..."
            run_as_user curl -sS https://starship.rs/install.sh | run_as_user sh -s -- --bin-dir "$user_bin" -y 2>/dev/null || warn "Starship script installer failed."
        fi
    fi

    if ! has_cmd zoxide; then
        if has_cmd curl; then
            info "Installing Zoxide into ${user_bin}..."
            run_as_user curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | run_as_user sh 2>/dev/null || warn "Zoxide script installer failed."
        fi
    fi
}

# ── 4. BACKUP HELPER ──────────────────────────────────────────
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

# ── 5. FONTS DEPLOYMENT ───────────────────────────────────────
install_fonts() {
    step "Installing Fantasque Sans Mono Nerd Font"
    local font_dst="${TARGET_HOME}/.local/share/fonts/fantasque-sans-mono-nerd-fonts"
    mkdir -p "$font_dst"

    local src_font_dir="${SCRIPT_DIR}/fonts/fantasque-sans-mono-nerd-fonts"
    if [ -d "$src_font_dir" ] && [ "$(ls -A "$src_font_dir" 2>/dev/null)" ]; then
        cp -r "$src_font_dir"/* "$font_dst/" 2>/dev/null || true
        success "Font files installed to $font_dst"
    else
        warn "Local font files not found. Attempting online fallback download..."
        if has_cmd curl && has_cmd unzip; then
            local temp_zip="/tmp/fantasque_font_$$.zip"
            curl -fLo "$temp_zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FantasqueSansMono.zip" 2>/dev/null && {
                unzip -q -o "$temp_zip" -d "$font_dst" 2>/dev/null || true
                rm -f "$temp_zip"
                success "Downloaded and extracted Fantasque Sans Mono font."
            } || warn "Could not download fonts automatically."
        fi
    fi

    # Fix ownership
    chown -R "$TARGET_USER":"$(id -gn "$TARGET_USER" 2>/dev/null || id -g)" "${TARGET_HOME}/.local/share/fonts" 2>/dev/null || true

    # Update font cache
    if has_cmd fc-cache; then
        fc-cache -f "${TARGET_HOME}/.local/share/fonts" >/dev/null 2>&1 || true
        success "Font cache refreshed."
    fi
}

# ── 6. ZSH PLUGINS SETUP ─────────────────────────────────────
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

# ── 7. CONFIGURATION DEPLOYMENT ──────────────────────────────
deploy_configurations() {
    step "Deploying Configurations"

    # Kitty
    safe_backup_and_copy "${SCRIPT_DIR}/kitty/kitty.conf" "${TARGET_HOME}/.config/kitty/kitty.conf"
    [ -f "${SCRIPT_DIR}/kitty/kitty.conf.bak" ] && safe_backup_and_copy "${SCRIPT_DIR}/kitty/kitty.conf.bak" "${TARGET_HOME}/.config/kitty/kitty.conf.bak"

    # Starship
    safe_backup_and_copy "${SCRIPT_DIR}/starship.toml" "${TARGET_HOME}/.config/starship.toml"
    [ -f "${SCRIPT_DIR}/starship.toml.bak" ] && safe_backup_and_copy "${SCRIPT_DIR}/starship.toml.bak" "${TARGET_HOME}/.config/starship.toml.bak"

    # Terminal environment
    safe_backup_and_copy "${SCRIPT_DIR}/terminal.conf" "${TARGET_HOME}/.config/environment.d/terminal.conf"

    # Shell RC files
    for rc in .zshrc .bashrc .bash_profile; do
        if [ -f "${SCRIPT_DIR}/${rc}" ]; then
            safe_backup_and_copy "${SCRIPT_DIR}/${rc}" "${TARGET_HOME}/${rc}"
        fi
    done

    # Ensure ~/.local/bin exists in directory structure
    mkdir -p "${TARGET_HOME}/.local/bin"
    chown -R "$TARGET_USER":"$(id -gn "$TARGET_USER" 2>/dev/null || id -g)" "${TARGET_HOME}/.config" "${TARGET_HOME}/.local" 2>/dev/null || true
}

# ── 8. DEFAULT SHELL CONFIGURATION ───────────────────────────
configure_default_shell() {
    step "Configuring Default Shell"
    local zsh_bin
    zsh_bin="$(command -v zsh 2>/dev/null || which zsh 2>/dev/null || true)"

    if [ -z "$zsh_bin" ]; then
        warn "Zsh binary not found. Skipping default shell change."
        return 0
    fi

    # Ensure zsh is in /etc/shells if we have permissions
    if [ -f /etc/shells ] && ! grep -Fxq "$zsh_bin" /etc/shells 2>/dev/null; then
        info "Adding $zsh_bin to /etc/shells..."
        if [ "$(id -u)" -eq 0 ]; then
            echo "$zsh_bin" >> /etc/shells 2>/dev/null || true
        elif has_cmd sudo; then
            echo "$zsh_bin" | sudo tee -a /etc/shells >/dev/null 2>&1 || true
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

    # Check if we can interactively prompt
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

# ── 9. MAIN ROUTINE ──────────────────────────────────────────
main() {
    echo -e "${BOLD}${BLUE}"
    echo "========================================================"
    echo "  Kitty & Environment Automated Installer"
    echo "  Target User : ${TARGET_USER}"
    echo "  Target Home : ${TARGET_HOME}"
    echo "========================================================"
    echo -e "${RESET}"

    install_system_dependencies
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
    echo -e "To start your new environment now:"
    echo -e "  1. Start a new Kitty terminal: ${BOLD}kitty &${RESET}"
    echo -e "  2. Or start Zsh immediately:  ${BOLD}zsh${RESET}\n"
}

main "$@"
