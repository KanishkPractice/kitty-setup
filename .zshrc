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

# ── 4. COMPLETION SYSTEM (FAST CACHED & CASE-INSENSITIVE) ───
autoload -Uz compinit
# Check dump file age once a day to keep shell startup fast
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.m+1) ]]; then
  compinit
else
  compinit -C
fi

# Enable menu selection
zstyle ':completion:*' menu select

# Case-insensitive (all), partial-word, and substring completion
# e.g., 'cd doc' matches 'Documents', 'cd down' matches 'Downloads'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Automatic directory correction for cd typos (e.g. cd dokctop -> Desktop)
setopt CORRECT
setopt CDABLE_VARS

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

# ── 7. AUTOSUGGESTIONS, FZF-TAB & SYNTAX HIGHLIGHTING ───────
# fzf-tab replaces default completion menu with interactive popup
[ -f ~/.zsh/fzf-tab/fzf-tab.plugin.zsh ] && \
    source ~/.zsh/fzf-tab/fzf-tab.plugin.zsh

# Preview directory content with eza/ls on tab completion
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=auto $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --line-range :50 $realpath 2>/dev/null'

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

# ── 9. ALIASES & CUTTING-EDGE CLI TOOLS ──────────────────────

# Modern file listing with eza (fallback to ls)
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -lh --icons --group-directories-first --git'
    alias la='eza -lah --icons --group-directories-first --git'
    alias lt='eza --tree --level=2 --icons'
    alias lta='eza --tree --level=3 --icons -a'
else
    alias ll='ls -lah --color=auto'
    alias la='ls -A --color=auto'
fi

# Navigation & File Management
alias ..='cd ..'
alias ...='cd ../..'
alias reload='source ~/.zshrc'
alias cls='clear'
alias path='echo $PATH | tr ":" "\n"'

# bat (Modern cat replacement)
if command -v bat >/dev/null 2>&1; then
    alias catp='bat'
fi

# fd-find alias for standard fd name
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    alias fd='fdfind'
fi

# Git with delta pager integration
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

# ── 10. INTERACTIVE COMMAND SEARCH & INSTALL HELPERS ─────────

# Search all aliases, builtins, functions, and commands with interactive FZF preview
search-cmds() {
    local query="${1:-}"
    local selected
    selected=$(
        {
            # List aliases
            alias | sed 's/^/[alias] /'
            # List builtins and functions
            print -l ${(ok)functions} | sed 's/^/[func]  /'
            print -l ${(ok)builtins} | sed 's/^/[built] /'
            # List custom tool helpers
            echo "[tool]  eza: Modern replacement for ls with icons and git status"
            echo "[tool]  bat: Cat clone with syntax highlighting and Git integration"
            echo "[tool]  rg (ripgrep): Blazing fast recursive codebase search"
            echo "[tool]  fd (fd-find): Simple, fast, and user-friendly alternative to find"
            echo "[tool]  fzf: General-purpose command-line fuzzy finder"
            echo "[tool]  zoxide: Smarter cd command that learns your habits (use 'z <folder>')"
            echo "[tool]  starship: Fast, customizable prompt for any shell"
            echo "[tool]  btop: Resource monitor (CPU, memory, disks, network, processes)"
            echo "[tool]  tldr (tealdeer): Simplified and community-driven man pages"
            echo "[tool]  delta (git-delta): Syntax-highlighting pager for git diffs"
            echo "[tool]  yazi: Blazing fast terminal file manager with image previews"
            echo "[tool]  zellij: Terminal multiplexer workspace manager"
            echo "[tool]  search-cmds: Interactively search and run commands and aliases"
            echo "[tool]  install-tools: Check and install all cutting-edge CLI tools via DNF"
        } | fzf --query="$query" --prompt="🔎 Search Commands > " --header="Select a command to paste or inspect"
    )

    if [[ -n "$selected" ]]; then
        print -z "$(echo "$selected" | sed -E 's/^\[[^]]+\][[:space:]]*//; s/=.*//; s/:.*//')"
    fi
}
alias scmd='search-cmds'
alias help-cmds='search-cmds'

# Inspect and install missing cutting-edge tools
install-tools() {
    local -A tool_packages=(
        ["kitty"]="kitty (GPU terminal emulator)"
        ["zsh"]="zsh (Z shell)"
        ["eza"]="eza (Modern ls with icons)"
        ["bat"]="bat (Cat with syntax highlighting)"
        ["rg"]="ripgrep (Ultra-fast code search)"
        ["fd"]="fd-find (Fast user-friendly find)"
        ["fzf"]="fzf (Fuzzy finder)"
        ["zoxide"]="zoxide (Smart cd jump directory)"
        ["btop"]="btop (System resource monitor)"
        ["tldr"]="tealdeer (Fast tldr cheat sheets)"
        ["delta"]="git-delta (Syntax highlighted git diff)"
        ["fontconfig"]="fontconfig (Font management)"
        ["git"]="git (Version control)"
        ["curl"]="curl (HTTP transfer tool)"
    )

    echo -e "\033[1;36m━━ Modern CLI Tools Status ━━\033[0m"
    local -a missing=()
    for cmd in ${(k)tool_packages}; do
        if command -v "$cmd" >/dev/null 2>&1; then
            printf " \033[32m✓\033[0m %-10s : %s\n" "$cmd" "${tool_packages[$cmd]}"
        else
            printf " \033[31m✗\033[0m %-10s : %s \033[33m(missing)\033[0m\n" "$cmd" "${tool_packages[$cmd]}"
            missing+=("$cmd")
        fi
    done

    # Check starship separately
    if command -v starship >/dev/null 2>&1; then
        printf " \033[32m✓\033[0m %-10s : %s\n" "starship" "Starship prompt"
    else
        printf " \033[31m✗\033[0m %-10s : %s \033[33m(missing)\033[0m\n" "starship" "Starship prompt"
    fi

    echo ""
    if ((${#missing[@]} == 0)); then
        echo -e "\033[1;32mAll cutting-edge tools are installed and ready!\033[0m"
    else
        echo -e "\033[1;33mTo install all missing tools on Fedora, run:\033[0m"
        echo -e "  \033[1msudo dnf install -y kitty zsh fzf zoxide fontconfig curl git bat eza ripgrep fd-find btop tealdeer git-delta\033[0m"
        if ! command -v starship >/dev/null 2>&1; then
            echo -e "  \033[1mcurl -sS https://starship.rs/install.sh | sh\033[0m"
        fi
    fi
}
alias check-tools='install-tools'

# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


