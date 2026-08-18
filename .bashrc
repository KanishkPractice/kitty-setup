# .bashrc - Enhanced Bash Configuration with Catppuccin Mocha & Modern CLI

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment & PATH
if ! [[ "$PATH" =~ "$HOME/.local/bin" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# ── 1. COLORS & EXPORTS (Catppuccin Mocha) ───────────────────
c_dir="1;38;2;249;226;175"      # bold yellow  — directories
c_exec="1;38;2;250;179;135"     # bold peach   — executables
c_link="38;2;243;139;168"       # red          — symlinks
c_image="38;2;245;224;220"      # rosewater    — images
c_video="38;2;250;179;135"      # peach        — video
c_audio="38;2;249;226;175"      # yellow       — audio
c_doc="38;2;243;139;168"        # red          — documents
c_archive="2;38;2;235;160;172"  # dim maroon   — archives
c_code="38;2;137;180;250"       # blue         — source code
c_config="38;2;148;226;213"     # teal         — config/data

_ls_colors="di=${c_dir}:ex=${c_exec}:ln=${c_link}"
_ls_colors+=":*.jpg=${c_image}:*.jpeg=${c_image}:*.png=${c_image}:*.gif=${c_image}:*.bmp=${c_image}:*.svg=${c_image}:*.webp=${c_image}:*.ico=${c_image}"
_ls_colors+=":*.mp4=${c_video}:*.mkv=${c_video}:*.avi=${c_video}:*.mov=${c_video}:*.webm=${c_video}:*.flv=${c_video}:*.wmv=${c_video}"
_ls_colors+=":*.mp3=${c_audio}:*.flac=${c_audio}:*.wav=${c_audio}:*.ogg=${c_audio}:*.m4a=${c_audio}:*.aac=${c_audio}:*.opus=${c_audio}"
_ls_colors+=":*.pdf=${c_doc}:*.doc=${c_doc}:*.docx=${c_doc}:*.odt=${c_doc}:*.ppt=${c_doc}:*.pptx=${c_doc}:*.xls=${c_doc}:*.xlsx=${c_doc}:*.epub=${c_doc}"
_ls_colors+=":*.tar=${c_archive}:*.gz=${c_archive}:*.zip=${c_archive}:*.7z=${c_archive}:*.rar=${c_archive}:*.bz2=${c_archive}:*.xz=${c_archive}:*.zst=${c_archive}:*.tgz=${c_archive}"
_ls_colors+=":*.py=${c_code}:*.js=${c_code}:*.ts=${c_code}:*.jsx=${c_code}:*.tsx=${c_code}:*.c=${c_code}:*.h=${c_code}:*.cpp=${c_code}:*.hpp=${c_code}:*.rs=${c_code}:*.go=${c_code}:*.java=${c_code}:*.rb=${c_code}:*.php=${c_code}:*.lua=${c_code}:*.sh=${c_code}:*.zsh=${c_code}"
_ls_colors+=":*.json=${c_config}:*.yaml=${c_config}:*.yml=${c_config}:*.toml=${c_config}:*.ini=${c_config}:*.conf=${c_config}:*.xml=${c_config}:*.csv=${c_config}:*.env=${c_config}"
export LS_COLORS="$_ls_colors"
unset _ls_colors

# Bat syntax highlighter theme
export BAT_THEME="Catppuccin Mocha"

# ── 2. FZF INTEGRATION ───────────────────────────────────────
for _fzf_kb in \
    "$HOME/.fzf/shell/key-bindings.bash" \
    /usr/share/fzf/shell/key-bindings.bash \
    /usr/share/fzf/key-bindings.bash \
    /usr/share/doc/fzf/examples/key-bindings.bash \
    /etc/profile.d/fzf.bash; do
    if [ -f "$_fzf_kb" ]; then
        source "$_fzf_kb"
        break
    fi
done
unset _fzf_kb

for _fzf_comp in \
    "$HOME/.fzf/shell/completion.bash" \
    /usr/share/fzf/shell/completion.bash \
    /usr/share/fzf/completion.bash \
    /usr/share/doc/fzf/examples/completion.bash; do
    if [ -f "$_fzf_comp" ]; then
        source "$_fzf_comp"
        break
    fi
done
unset _fzf_comp

export FZF_DEFAULT_OPTS="\
  --height 40% --layout=reverse --border=rounded \
  --color=fg:#cdd6f4,bg:#1e1e2e,hl:#f38ba8 \
  --color=fg+:#cdd6f4,bg+:#313244,hl+:#cba6f7 \
  --color=info:#f9e2af,prompt:#f38ba8,pointer:#f5c2e7 \
  --color=marker:#f9e2af,spinner:#cba6f7,header:#6c7086"

# ── 3. ZOXIDE INTEGRATION ────────────────────────────────────
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi

# ── 4. STARSHIP PROMPT ───────────────────────────────────────
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi

# ── 5. ALIASES ───────────────────────────────────────────────
# Navigation & File Management
alias ll='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'
alias reload='source ~/.bashrc'
alias cls='clear'
alias path='echo $PATH | tr ":" "\n"'

# bat (Modern cat replacement)
if command -v bat >/dev/null 2>&1; then
    alias catp='bat'
fi

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# Docker
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dc='docker compose'

# Kubectl
if command -v kubectl >/dev/null 2>&1; then
    alias k='kubectl'
    alias kgp='kubectl get pods'
    alias kgs='kubectl get svc'
    alias kdp='kubectl describe pod'
    alias kl='kubectl logs -f'
fi

# Systemd & Journalctl
alias sc='sudo systemctl'
alias scs='systemctl status'
alias scu='systemctl --user'
alias jc='journalctl -xe'

# User specific aliases and functions in .bashrc.d
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
