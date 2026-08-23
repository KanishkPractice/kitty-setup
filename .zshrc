# ~/.zshrc
# Zsh Configuration — Catppuccin Mocha Theme & Modern CLI Integration

# ── 1. HISTORY SETTINGS ──────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_DUPS SHARE_HISTORY APPEND_HISTORY INC_APPEND_HISTORY

# ── 2. SHELL OPTIONS ─────────────────────────────────────────
setopt AUTO_CD              # Type directory name to cd into it
setopt INTERACTIVE_COMMENTS # Allow inline #comments in shell
unsetopt BEEP

# ── 3. COLORS & EXPORTS (Catppuccin Mocha) ───────────────────
autoload -U colors && colors

# LS_COLORS categorized styling
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

# ── 4. COMPLETION SYSTEM (FAST CACHED) ───────────────────────
autoload -Uz compinit
# Check dump file age once a day to keep shell startup fast
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.m+1) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ── 5. KEYBINDINGS & HISTORY SEARCH ──────────────────────────
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^P"   up-line-or-beginning-search
bindkey "^N"   down-line-or-beginning-search

# Word & Line Navigation
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[f"      forward-word
bindkey "^[b"      backward-word
bindkey "^[[H"     beginning-of-line
bindkey "^[[F"     end-of-line
bindkey "^?"       backward-delete-char

# ── 6. FZF & ZOXIDE INTEGRATION ──────────────────────────────
# fzf keybindings & popup styling (multi-distro fallback search)
for _fzf_kb in \
    /usr/share/fzf/shell/key-bindings.zsh \
    /usr/share/fzf/key-bindings.zsh \
    /usr/share/doc/fzf/examples/key-bindings.zsh \
    /etc/profile.d/fzf-key-bindings.zsh \
    "$HOME/.fzf.zsh"; do
    if [ -f "$_fzf_kb" ]; then
        source "$_fzf_kb"
        break
    fi
done
unset _fzf_kb

for _fzf_comp in \
    /usr/share/fzf/shell/completion.zsh \
    /usr/share/fzf/completion.zsh \
    /usr/share/doc/fzf/examples/completion.zsh \
    /etc/profile.d/fzf-completion.zsh; do
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

# zoxide initialization
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# ── 7. AUTOSUGGESTIONS & SYNTAX HIGHLIGHTING ────────────────
[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086"

# Syntax highlighting MUST be sourced last
[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── 8. STARSHIP PROMPT ───────────────────────────────────────
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# ── 9. ALIASES ───────────────────────────────────────────────

# Navigation & File Management
alias ll='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'
alias reload='source ~/.zshrc'
alias cls='clear'
alias path='echo $PATH | tr ":" "\n"'

# bat (Modern cat replacement)
if command -v bat >/dev/null 2>&1; then
    #alias cat='bat --paging=never'
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


# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


