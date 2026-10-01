#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S_%N)"

AUTO_YES=false
for arg in "$@"; do
    case "$arg" in
        -y|--yes) AUTO_YES=true ;;
        -h|--help)
            cat <<EOF
Kitty & Modern CLI Setup Installer

Usage: ./install.sh [options]

Options:
  -y, --yes    Proceed without interactive confirmation prompts
  -h, --help   Show this help message
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            echo "Usage: ./install.sh [-y|--yes]" >&2
            exit 2
            ;;
    esac
done

if [[ -n "${SUDO_USER:-}" && "$SUDO_USER" != root ]]; then
    TARGET_USER="$SUDO_USER"
    TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
else
    TARGET_USER="$(id -un)"
    TARGET_HOME="${HOME:?HOME is not set}"
fi
[[ -n "$TARGET_HOME" ]] || { echo "Could not find the home directory for $TARGET_USER." >&2; exit 1; }

USER_BIN="$TARGET_HOME/.local/bin"
BACKUP_DIR="$TARGET_HOME/.config/kitty-setup-backups/$TIMESTAMP"

info() { printf '\033[1;36m›\033[0m %s\n' "$*"; }
success() { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*" >&2; }
fail() { printf '\033[1;31m✗\033[0m %s\n' "$*" >&2; exit 1; }

confirm_action() {
    local prompt_msg="$1"
    local default_yes="${2:-true}"
    if "$AUTO_YES"; then
        return 0
    fi
    if [[ ! -t 0 ]]; then
        return 1
    fi
    local choice
    if "$default_yes"; then
        read -r -p "$(printf '\033[1;33m? %s [Y/n]: \033[0m' "$prompt_msg")" choice
        [[ -z "$choice" || "$choice" =~ ^[Yy]$ ]]
    else
        read -r -p "$(printf '\033[1;33m? %s [y/N]: \033[0m' "$prompt_msg")" choice
        [[ "$choice" =~ ^[Yy]$ ]]
    fi
}

as_user() {
    if [[ $(id -u) -eq 0 && "$TARGET_USER" != root ]]; then
        sudo -u "$TARGET_USER" -H env "HOME=$TARGET_HOME" "PATH=$USER_BIN:$PATH" "$@"
    else
        env "PATH=$USER_BIN:$PATH" "$@"
    fi
}

as_root() {
    if [[ $(id -u) -eq 0 ]]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        fail "Install sudo or run this script as root to install packages."
    fi
}

deploy() {
    local src="$1" dst="$2" mode="${3:-0644}"
    [[ -f "$src" ]] || return 0

    as_user mkdir -p "$(dirname "$dst")"
    if [[ -L "$dst" ]]; then
        warn "Keeping existing symlink: $dst"
        return 0
    fi
    if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
        if [[ "$mode" == 0755 && ! -x "$dst" ]]; then
            as_user chmod 0755 -- "$dst"
        fi
        return 0
    fi
    if [[ -e "$dst" ]]; then
        local backup="$BACKUP_DIR/${dst#"$TARGET_HOME"/}"
        as_user mkdir -p "$(dirname "$backup")"
        as_user cp -a -- "$dst" "$backup"
        info "Backed up existing file to $backup"
    fi
    as_user install -m "$mode" -- "$src" "$dst"
}

# ── Detect distribution & package manager ────────────────────────────────────
DISTRO=""
PM=""

has_pacman=false
has_dnf=false
command -v pacman >/dev/null 2>&1 && has_pacman=true
command -v dnf >/dev/null 2>&1 && has_dnf=true

if "$has_pacman" && "$has_dnf"; then
    info "Both pacman and dnf package managers detected."
    os_id=""
    if [[ -f /etc/os-release ]]; then
        os_id="$(. /etc/os-release 2>/dev/null && echo "${ID_LIKE:-$ID}")"
    fi
    if [[ "$os_id" =~ (arch|manjaro|endeavouros) ]]; then
        DISTRO="arch"
        PM="pacman"
    elif [[ "$os_id" =~ (fedora|rhel|centos) ]]; then
        DISTRO="fedora"
        PM="dnf"
    else
        if confirm_action "Use pacman (Arch) instead of dnf (Fedora)?" true; then
            DISTRO="arch"
            PM="pacman"
        else
            DISTRO="fedora"
            PM="dnf"
        fi
    fi
elif "$has_pacman"; then
    DISTRO="arch"
    PM="pacman"
elif "$has_dnf"; then
    DISTRO="fedora"
    PM="dnf"
else
    fail "Unsupported system. This installer supports Arch (pacman) and Fedora (dnf)."
fi

printf '\nKitty and CLI setup for %s (%s via %s)\n\n' "$TARGET_USER" "$DISTRO" "$PM"

if ! confirm_action "Proceed with setup for user '$TARGET_USER' using $PM?" true; then
    info "Installation aborted by user."
    exit 0
fi

as_user mkdir -p "$USER_BIN"
export PATH="$USER_BIN:$PATH"

info "Checking packages via $PM package manager"
if [[ "$PM" == "pacman" ]]; then
    packages=(kitty zsh fzf zoxide fontconfig curl git bat eza ripgrep fd btop tealdeer git-delta cmatrix neovim gcc make tar unzip fastfetch tmux lazygit starship)
    missing_packages=()
    for pkg in "${packages[@]}"; do
        if ! pacman -Q "$pkg" >/dev/null 2>&1; then
            missing_packages+=("$pkg")
        fi
    done

    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        info "Missing pacman package(s): ${missing_packages[*]}"
        if confirm_action "Install ${#missing_packages[@]} missing package(s) via sudo pacman?" true; then
            as_root pacman -S --needed --noconfirm "${missing_packages[@]}"
            success "Packages installed successfully."
        else
            warn "Skipping pacman package installation."
        fi
    else
        success "All required pacman packages are already installed."
    fi

    # cbonsai is only available in the AUR
    if ! command -v cbonsai >/dev/null 2>&1; then
        if command -v yay >/dev/null 2>&1; then
            if confirm_action "Install optional cbonsai from AUR via yay?" true; then
                as_user yay -S --needed --noconfirm cbonsai || warn "Could not install optional cbonsai from AUR."
            fi
        elif command -v paru >/dev/null 2>&1; then
            if confirm_action "Install optional cbonsai from AUR via paru?" true; then
                as_user paru -S --needed --noconfirm cbonsai || warn "Could not install optional cbonsai from AUR."
            fi
        else
            warn "cbonsai is AUR-only. Install an AUR helper (yay/paru) or build it manually."
        fi
    fi
elif [[ "$PM" == "dnf" ]]; then
    packages=(kitty zsh util-linux-user fzf zoxide fontconfig curl git bat eza ripgrep fd-find btop tealdeer git-delta cmatrix cbonsai neovim gcc make tar unzip fastfetch tmux)
    missing_packages=()
    for pkg in "${packages[@]}"; do
        if ! rpm -q "$pkg" >/dev/null 2>&1; then
            missing_packages+=("$pkg")
        fi
    done

    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        info "Missing dnf package(s): ${missing_packages[*]}"
        if confirm_action "Install ${#missing_packages[@]} missing package(s) via sudo dnf?" true; then
            as_root dnf install -y "${missing_packages[@]}"
            success "Packages installed successfully."
        else
            warn "Skipping dnf package installation."
        fi
    else
        success "All required dnf packages are already installed."
    fi

    # These optional tools are provided by Fedora COPR repositories.
    if ! command -v lazygit >/dev/null 2>&1; then
        if confirm_action "Enable COPR and install lazygit via dnf?" true; then
            as_root dnf copr enable -y dejan/lazygit >/dev/null 2>&1 && as_root dnf install -y lazygit || warn "Could not install optional lazygit."
        fi
    fi
fi

if ! command -v starship >/dev/null 2>&1 && [[ ! -x "$USER_BIN/starship" ]]; then
    if confirm_action "Install Starship prompt binary to $USER_BIN?" true; then
        info "Installing Starship"
        as_user bash -c 'curl -fsSL https://starship.rs/install.sh | sh -s -- --bin-dir "$1" --yes' _ "$USER_BIN"
    fi
fi

info "Installing Fantasque Nerd Font"
font_src="$SCRIPT_DIR/fonts/fantasque-sans-mono-nerd-fonts"
font_dst="$TARGET_HOME/.local/share/fonts/fantasque-sans-mono-nerd-fonts"
if [[ -d "$font_src" ]]; then
    as_user mkdir -p "$font_dst"
    as_user find "$font_src" -maxdepth 1 -type f -name '*.ttf' -exec install -m 0644 '{}' "$font_dst/" \;
    as_user fc-cache -f "$TARGET_HOME/.local/share/fonts" >/dev/null
fi

info "Installing Zsh plugins"
plugins=(
    "zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions"
    "zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting"
    "zsh-completions https://github.com/zsh-users/zsh-completions"
    "zsh-history-substring-search https://github.com/zsh-users/zsh-history-substring-search"
    "zsh-you-should-use https://github.com/MichaelAquilina/zsh-you-should-use"
    "fzf-tab https://github.com/Aloxaf/fzf-tab"
)
for plugin in "${plugins[@]}"; do
    name="${plugin%% *}"
    url="${plugin#* }"
    plugin_dir="$TARGET_HOME/.zsh/$name"
    if [[ ! -d "$plugin_dir" ]]; then
        as_user mkdir -p "$(dirname "$plugin_dir")"
        as_user git clone --depth 1 "$url" "$plugin_dir" || warn "Could not download $name."
    fi
done

info "Installing Kitty, shell, and application configs"
for file in "$SCRIPT_DIR"/kitty/*.conf; do
    deploy "$file" "$TARGET_HOME/.config/kitty/$(basename "$file")"
done

for file in "$SCRIPT_DIR"/bin/*; do
    [[ -f "$file" ]] && deploy "$file" "$USER_BIN/${file##*/}" 0755
done

deploy "$SCRIPT_DIR/starship.toml" "$TARGET_HOME/.config/starship.toml"
deploy "$SCRIPT_DIR/terminal.conf" "$TARGET_HOME/.config/environment.d/terminal.conf"
deploy "$SCRIPT_DIR/.zshrc" "$TARGET_HOME/.zshrc"
deploy "$SCRIPT_DIR/.bashrc" "$TARGET_HOME/.bashrc"
deploy "$SCRIPT_DIR/.bash_profile" "$TARGET_HOME/.bash_profile"
deploy "$SCRIPT_DIR/.tmux.conf" "$TARGET_HOME/.tmux.conf"
deploy "$SCRIPT_DIR/fastfetch/config.jsonc" "$TARGET_HOME/.config/fastfetch/config.jsonc"

if [[ -d "$SCRIPT_DIR/nvim" ]]; then
    while IFS= read -r -d '' file; do
        rel="${file#"$SCRIPT_DIR/nvim/"}"
        deploy "$file" "$TARGET_HOME/.config/nvim/$rel"
    done < <(find "$SCRIPT_DIR/nvim" -type f -print0)
fi

zsh_path="$(command -v zsh || true)"
login_shell="$(getent passwd "$TARGET_USER" | cut -d: -f7)"
if [[ -n "$zsh_path" && "$login_shell" != "$zsh_path" ]]; then
    if confirm_action "Set Zsh as default login shell for $TARGET_USER?" true; then
        info "Setting Zsh as the login shell"
        if [[ $(id -u) -eq 0 ]]; then
            chsh -s "$zsh_path" "$TARGET_USER"
        else
            chsh -s "$zsh_path"
        fi
    fi
fi

success "Setup complete. Open Kitty or start a new shell to load the configs."
info "Backups of replaced config files are in $BACKUP_DIR (if any were needed)."
