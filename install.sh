#!/usr/bin/env bash
# Safe, repeatable installer for Kitty and a modern shell environment.
set -uo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
AUTO_YES=false; DRY_RUN=false; CHANGE_SHELL=false
declare -a WARNINGS=() ERRORS=()

if [[ -n ${SUDO_USER:-} && ${SUDO_USER} != root ]]; then
    TARGET_USER=$SUDO_USER
    TARGET_HOME=$(getent passwd "$TARGET_USER" 2>/dev/null | cut -d: -f6)
    TARGET_HOME=${TARGET_HOME:-/home/$TARGET_USER}
else
    TARGET_USER=$(id -un); TARGET_HOME=${HOME:?HOME is not set}
fi
readonly TARGET_USER TARGET_HOME
readonly USER_BIN="$TARGET_HOME/.local/bin"
readonly BACKUP_DIR="$TARGET_HOME/.config/kitty-setup-backups/$TIMESTAMP"

bold='\033[1m'; blue='\033[34m'; green='\033[32m'; yellow='\033[33m'; red='\033[31m'; cyan='\033[36m'; reset='\033[0m'
info() { printf "${blue}•${reset} %s\n" "$*"; }
ok() { printf "${green}✓${reset} %s\n" "$*"; }
warn() { WARNINGS+=("$*"); printf "${yellow}!${reset} %s\n" "$*" >&2; }
fail() { ERRORS+=("$*"); printf "${red}✗${reset} %s\n" "$*" >&2; }
section() { printf "\n${bold}${cyan}━━ %s ━━${reset}\n" "$*"; }
has() { command -v "$1" >/dev/null 2>&1; }
usage() { cat <<'EOF'
Usage: ./install.sh [--yes] [--change-shell] [--dry-run] [--no-animation]
  -y, --yes           Non-interactive mode
  --change-shell      Offer to make zsh the login shell
  --dry-run           Preview actions without changing the system
  --no-animation       Disable the download animation
  -h, --help          Show this help
EOF
}

for arg in "$@"; do
    case $arg in
        -y|--yes|--non-interactive) AUTO_YES=true ;;
        --change-shell) CHANGE_SHELL=true ;;
        --dry-run) DRY_RUN=true ;;
        --no-animation) ;;
        -h|--help) usage; exit 0 ;;
        *) fail "Unknown option: $arg"; usage; exit 2 ;;
    esac
done

run() { if "$DRY_RUN"; then info "[dry-run] $*"; else "$@"; fi; }
run_as_user() {
    if [[ $(id -u) -eq 0 && $TARGET_USER != root ]]; then
        run sudo -u "$TARGET_USER" -H env "HOME=$TARGET_HOME" "$@"
    else run "$@"; fi
}
run_elevated() { [[ $(id -u) -eq 0 ]] && { run "$@"; return; }; has sudo && run sudo "$@"; }
ensure_dir() { run_as_user mkdir -p "$1" || { fail "Cannot create $1"; return 1; }; }

# Keep long downloads friendly without hiding errors. Animation is only used on
# a real terminal; logs are printed in full if a command fails.
ANIMATE=true
for arg in "$@"; do [[ $arg == --no-animation ]] && ANIMATE=false; done
can_animate() { "$ANIMATE" && ! "$DRY_RUN" && [[ -t 1 && -t 2 && -z ${CI:-} ]]; }
show_intro_animation() {
    can_animate || return
    local -a frames=(
        $'        .------------.\n       / .--------. /|\n      /_/__KITTY_/ / |\n      | |        | | |\n      | | terminal| |/\n      | '----------' /\n      '------------''
        $'       .------------.\n      / .--------. /|\n     /_/__KITTY_/ / |\n     | |        | | |\n     | | terminal| |/\n     | '----------' /\n     '------------''
        $'      .------------.\n     / .--------. /|\n    /_/__KITTY_/ / |\n    | |        | | |\n    | | terminal| |/\n    | '----------' /\n    '------------''
        $'       .------------.\n      / .--------. /|\n     /_/__KITTY_/ / |\n     | |        | | |\n     | | terminal| |/\n     | '----------' /\n     '------------''
        $'        .------------.\n       / .--------. /|\n      /_/__KITTY_/ / |\n      | |        | | |\n      | | terminal| |/\n      | '----------' /\n      '------------''
    )
    local frame
    printf "${cyan}\n"
    for frame in "${frames[@]}"; do
        printf '\r%s\n\033[7A' "$frame"
        sleep 0.10
    done
    printf '\r%s\n\n%s' "${frames[0]}" "$reset"
}
animated_as_user() {
    local label=$1 log pid status frame=0
    shift
    if ! can_animate; then run_as_user "$@"; return; fi
    log=$(mktemp "${TMPDIR:-/tmp}/kitty-setup.XXXXXX") || { run_as_user "$@"; return; }
    ( run_as_user "$@" ) >"$log" 2>&1 & pid=$!
    local -a frames=('[ . ]' '[ o ]' '[ O ]' '[ o ]')
    while kill -0 "$pid" 2>/dev/null; do
        printf '\r  [%s] %-56s' "${frames[frame % ${#frames[@]}]}" "$label"
        frame=$((frame + 1))
        sleep 0.12
    done
    wait "$pid"; status=$?
    if [[ $status -eq 0 ]]; then
        printf '\r  [✓] %-56s\n' "$label"
    else
        printf '\r  [✗] %-56s\n' "$label" >&2
        sed 's/^/      /' "$log" >&2
    fi
    rm -f "$log"
    return "$status"
}

install_packages() {
    section "System packages (optional)"
    local manager='' ; local -a packages=()
    if has apt-get; then manager=apt; packages=(kitty zsh fzf fontconfig curl git bat); fi
    if has dnf; then manager=dnf; packages=(kitty zsh fzf zoxide starship fontconfig curl git bat); fi
    if has pacman; then manager=pacman; packages=(kitty zsh fzf zoxide starship fontconfig curl git bat); fi
    if has zypper; then manager=zypper; packages=(kitty zsh fzf zoxide starship fontconfig curl git bat); fi
    if has apk; then manager=apk; packages=(kitty zsh fzf zoxide starship fontconfig curl git bat); fi
    if has xbps-install; then manager=xbps; packages=(kitty zsh fzf zoxide starship fontconfig curl git bat); fi
    [[ -n $manager ]] || { warn "No supported package manager found; using user-space fallbacks."; return; }
    info "Detected $manager. Installing available dependencies (sudo may be requested)."
    case $manager in
        apt) run_elevated apt-get update && run_elevated apt-get install -y "${packages[@]}" ;;
        dnf) run_elevated dnf install -y "${packages[@]}" ;;
        pacman) run_elevated pacman -S --needed --noconfirm "${packages[@]}" ;;
        zypper) run_elevated zypper --non-interactive install "${packages[@]}" ;;
        apk) run_elevated apk add "${packages[@]}" ;;
        xbps) run_elevated xbps-install -Sy "${packages[@]}" ;;
    esac || warn "$manager installation was skipped or incomplete."
}

install_kitty() {
    section "Kitty"
    has kitty && { ok "Kitty: $(kitty --version 2>/dev/null || command -v kitty)"; return; }
    has curl || { fail "Kitty is missing and curl is unavailable for the official installer."; return; }
    info "Installing the official Kitty release in user space…"
    if animated_as_user "Downloading Kitty" bash -c 'curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n'; then
        ensure_dir "$USER_BIN"; run_as_user ln -sfn "$TARGET_HOME/.local/kitty.app/bin/kitty" "$USER_BIN/kitty"
        run_as_user ln -sfn "$TARGET_HOME/.local/kitty.app/bin/kitten" "$USER_BIN/kitten"; ok "Kitty installed in $USER_BIN"
    else fail "Could not install Kitty. Check network access and retry."; fi
}

install_starship() {
    has starship && { ok "Starship already installed"; return; }; has curl || { warn "Starship unavailable (curl is missing)."; return; }
    ensure_dir "$USER_BIN" || return; info "Installing Starship in $USER_BIN…"
    animated_as_user "Downloading Starship" bash -c 'curl -fsSL https://starship.rs/install.sh | sh -s -- --bin-dir "$1" --yes' _ "$USER_BIN" && ok "Starship installed" || warn "Could not install Starship."
}
install_zoxide() {
    has zoxide && { ok "Zoxide already installed"; return; }; has curl || { warn "Zoxide unavailable (curl is missing)."; return; }
    info "Installing Zoxide in user space…"
    animated_as_user "Downloading Zoxide" bash -c 'curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh' && ok "Zoxide installed" || warn "Could not install Zoxide."
}
install_fzf() {
    has fzf && { ok "Fzf already installed"; return; }; has git || { warn "Fzf unavailable (git is missing)."; return; }
    local fzf_dir="$TARGET_HOME/.fzf"; ensure_dir "$USER_BIN" || return; info "Installing Fzf in $fzf_dir…"
    if [[ ! -d $fzf_dir/.git ]] && ! animated_as_user "Downloading Fzf" git clone --depth 1 https://github.com/junegunn/fzf.git "$fzf_dir"; then warn "Could not download Fzf."; return; fi
    run_as_user "$fzf_dir/install" --bin --no-key-bindings --no-completion --no-update-rc && run_as_user ln -sfn "$fzf_dir/bin/fzf" "$USER_BIN/fzf" && ok "Fzf installed" || warn "Could not finish Fzf installation."
}

copy_file() {
    local src=$1 dst=$2 backup
    [[ -f $src ]] || { fail "Repository file is missing: $src"; return; }; ensure_dir "$(dirname "$dst")" || return
    [[ -L $dst ]] && { warn "Skipped $dst because it is a symlink; it was left untouched for safety."; return; }
    if [[ -e $dst || -L $dst ]] && ! cmp -s "$src" "$dst"; then
        backup="$BACKUP_DIR/${dst#"$TARGET_HOME"/}"; ensure_dir "$(dirname "$backup")" || return
        run_as_user cp -a "$dst" "$backup" || { fail "Could not back up $dst"; return; }; info "Backed up ${dst#"$TARGET_HOME"/}"
    fi
    run_as_user install -m 0644 "$src" "$dst" && ok "Installed ${dst#"$TARGET_HOME"/}" || fail "Could not install $dst"
}
install_fonts() {
    section "Fonts"; local src="$SCRIPT_DIR/fonts/fantasque-sans-mono-nerd-fonts" dst="$TARGET_HOME/.local/share/fonts/fantasque-sans-mono-nerd-fonts"
    [[ -d $src ]] || { warn "Bundled font directory is missing."; return; }; ensure_dir "$dst" || return
    run_as_user find "$src" -maxdepth 1 -type f -name '*.ttf' -exec cp -f {} "$dst/" \; && ok "Fantasque Nerd Font installed" || warn "Could not copy all font files."
    has fc-cache && run_as_user fc-cache -f "$TARGET_HOME/.local/share/fonts" >/dev/null 2>&1 || true
}
install_plugin() {
    local name=$1 url=$2 entry=$3 dst
    dst="$TARGET_HOME/.zsh/$name"
    [[ -f $dst/$entry ]] && { ok "$name already installed"; return; }; has git || { warn "$name was not installed (git is missing)."; return; }
    ensure_dir "$TARGET_HOME/.zsh" || return
    [[ -e $dst ]] && { warn "$name was not installed because $dst already exists but is incomplete; it was left untouched."; return; }
    animated_as_user "Downloading $name" git clone --depth 1 "$url" "$dst" && [[ -f $dst/$entry ]] && ok "Installed $name" || warn "Could not install $name."
}
deploy_config() {
    section "Configuration"
    copy_file "$SCRIPT_DIR/kitty/kitty.conf" "$TARGET_HOME/.config/kitty/kitty.conf"
    copy_file "$SCRIPT_DIR/starship.toml" "$TARGET_HOME/.config/starship.toml"
    copy_file "$SCRIPT_DIR/terminal.conf" "$TARGET_HOME/.config/environment.d/terminal.conf"
    copy_file "$SCRIPT_DIR/.zshrc" "$TARGET_HOME/.zshrc"; copy_file "$SCRIPT_DIR/.bashrc" "$TARGET_HOME/.bashrc"; copy_file "$SCRIPT_DIR/.bash_profile" "$TARGET_HOME/.bash_profile"
}
change_login_shell() {
    "$CHANGE_SHELL" || return; has zsh || { warn "Zsh is not installed; login shell unchanged."; return; }; local zsh_bin; zsh_bin=$(command -v zsh)
    if "$AUTO_YES" || { [[ -t 0 ]] && read -r -p "Make $zsh_bin your login shell? [y/N] " reply && [[ $reply =~ ^[Yy]$ ]]; }; then
        if [[ $(id -u) -eq 0 ]]; then
            run chsh -s "$zsh_bin" "$TARGET_USER"
        else
            run chsh -s "$zsh_bin"
        fi
        if [[ $? -eq 0 ]]; then ok "Login shell changed to zsh"; else warn "Could not change login shell. Run: chsh -s $zsh_bin"; fi
    fi
}
verify() {
    section "Verification"; local binary
    for binary in kitty starship zoxide fzf; do has "$binary" || [[ -x $USER_BIN/$binary ]] && ok "$binary is available" || warn "$binary is not available yet"; done
    [[ -f $TARGET_HOME/.config/kitty/kitty.conf ]] && ok "Kitty configuration deployed" || fail "Kitty configuration was not deployed"
}
main() {
    printf "${bold}${blue}\n  ╭──────────────────────────────────────╮\n  │       Kitty setup for Linux           │\n  ╰──────────────────────────────────────╯${reset}\n"; info "Target: $TARGET_USER ($TARGET_HOME)"
    show_intro_animation
    "$DRY_RUN" && info "Dry run: no files or packages will be changed."; ensure_dir "$USER_BIN" || exit 1; export PATH="$USER_BIN:$PATH"
    install_packages; install_kitty; section "Command-line tools"; install_starship; install_zoxide; install_fzf; install_fonts
    section "Zsh plugins"; install_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions zsh-autosuggestions.zsh; install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting.zsh
    deploy_config; change_login_shell
    if "$DRY_RUN"; then info "[dry-run] Verification skipped because no files were deployed."; else verify; fi
    printf "\n${bold}Summary${reset}\n"
    if ((${#ERRORS[@]})); then printf "${red}Completed with %d error(s).${reset}\n" "${#ERRORS[@]}"; else printf "${green}Setup completed safely.${reset}\n"; fi
    ((${#WARNINGS[@]})) && printf "${yellow}%d item(s) need attention; rerun after resolving them.${reset}\n" "${#WARNINGS[@]}"; printf 'Launch Kitty with: kitty\n'; ((${#ERRORS[@]} == 0))
}
main "$@"
