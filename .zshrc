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

# LS_COLORS categorized styling (Catppuccin Mocha Vibrant)
c_dir="1;38;2;137;180;250"      # bold blue    — directories
c_exec="1;38;2;166;227;161"     # bold green   — executables
c_link="1;38;2;137;220;235"     # bold sky/cyan— symlinks
c_image="38;2;245;194;231"      # vibrant pink — images
c_video="38;2;250;179;135"      # peach        — video
c_audio="38;2;249;226;175"      # yellow       — audio
c_doc="38;2;243;139;168"        # red/rose     — documents
c_archive="1;38;2;235;160;172"  # maroon       — archives / zips
c_code="38;2;148;226;213"       # teal/mint    — source code
c_config="38;2;203;166;247"     # mauve        — config/data
c_lock="38;2;108;112;134"       # dim gray     — lockfiles
c_build="38;2;180;190;254"      # lavender     — build artifacts

_ls_colors="di=${c_dir}:ex=${c_exec}:ln=${c_link}"
_ls_colors+=":*.jpg=${c_image}:*.jpeg=${c_image}:*.png=${c_image}:*.gif=${c_image}:*.bmp=${c_image}:*.svg=${c_image}:*.webp=${c_image}:*.ico=${c_image}:*.tiff=${c_image}"
_ls_colors+=":*.mp4=${c_video}:*.mkv=${c_video}:*.avi=${c_video}:*.mov=${c_video}:*.webm=${c_video}:*.flv=${c_video}:*.wmv=${c_video}"
_ls_colors+=":*.mp3=${c_audio}:*.flac=${c_audio}:*.wav=${c_audio}:*.ogg=${c_audio}:*.m4a=${c_audio}:*.aac=${c_audio}:*.opus=${c_audio}"
_ls_colors+=":*.pdf=${c_doc}:*.doc=${c_doc}:*.docx=${c_doc}:*.odt=${c_doc}:*.ppt=${c_doc}:*.pptx=${c_doc}:*.xls=${c_doc}:*.xlsx=${c_doc}:*.epub=${c_doc}:*.txt=${c_doc}:*.md=${c_doc}"
_ls_colors+=":*.tar=${c_archive}:*.gz=${c_archive}:*.zip=${c_archive}:*.7z=${c_archive}:*.rar=${c_archive}:*.bz2=${c_archive}:*.xz=${c_archive}:*.zst=${c_archive}:*.tgz=${c_archive}"
_ls_colors+=":*.py=${c_code}:*.js=${c_code}:*.ts=${c_code}:*.jsx=${c_code}:*.tsx=${c_code}:*.c=${c_code}:*.h=${c_code}:*.cpp=${c_code}:*.hpp=${c_code}:*.rs=${c_code}:*.go=${c_code}:*.java=${c_code}:*.rb=${c_code}:*.php=${c_code}:*.lua=${c_code}:*.sh=${c_code}:*.zsh=${c_code}:*.sql=${c_code}:*.html=${c_code}:*.css=${c_code}:*.scss=${c_code}"
_ls_colors+=":*.json=${c_config}:*.yaml=${c_config}:*.yml=${c_config}:*.toml=${c_config}:*.ini=${c_config}:*.conf=${c_config}:*.xml=${c_config}:*.csv=${c_config}:*.env=${c_config}:Dockerfile=${c_config}:Containerfile=${c_config}"
_ls_colors+=":*.lock=${c_lock}:package-lock.json=${c_lock}:yarn.lock=${c_lock}:Cargo.lock=${c_lock}"
_ls_colors+=":*.o=${c_build}:*.so=${c_build}:*.dylib=${c_build}:*.dll=${c_build}:*.exe=${c_build}:*.out=${c_build}:*.class=${c_build}"
export LS_COLORS="$_ls_colors"
unset _ls_colors

# Eza (modern ls) colors configuration (Vibrant Catppuccin)
export EZA_COLORS="da=38;2;127;132;156:ur=38;2;243;139;168:uw=38;2;250;179;135:ux=1;38;2;166;227;161:ue=1;38;2;166;227;161:gr=38;2;180;190;254:gw=38;2;250;179;135:gx=38;2;166;227;161:tr=38;2;180;190;254:tw=38;2;250;179;135:tx=38;2;166;227;161:sn=38;2;148;226;213:sb=38;2;137;180;250:df=38;2;203;166;247:ds=1;38;2;137;180;250"

# Bat (modern cat) & Pager theme
export BAT_THEME="Catppuccin Mocha"
export BAT_PAGER="less -RF"

# Colored man pages via less termcap
export LESS_TERMCAP_mb=$'\e[1;38;2;243;139;168m'      # begin blinking (red)
export LESS_TERMCAP_md=$'\e[1;38;2;137;220;235m'      # begin bold / headings (sky blue)
export LESS_TERMCAP_me=$'\e[0m'                         # end mode
export LESS_TERMCAP_se=$'\e[0m'                         # end standout-mode
export LESS_TERMCAP_so=$'\e[38;2;0;0;0;48;2;203;166;247m' # standout (mauve bar)
export LESS_TERMCAP_ue=$'\e[0m'                         # end underline
export LESS_TERMCAP_us=$'\e[4;38;2;166;227;161m'      # underline / flags (green)

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
# fzf keybindings & popup styling (built-in generator or fallback)
if command -v fzf >/dev/null 2>&1; then
    if fzf --zsh >/dev/null 2>&1; then
        source <(fzf --zsh)
    else
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
    fi
fi

export FZF_DEFAULT_OPTS="\
  --height 45% --layout=reverse --border=rounded \
  --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7 \
  --color=fg+:#ffffff,bg+:#283457,hl+:#7dcfff \
  --color=info:#e0af68,prompt:#7aa2f7,pointer:#7dcfff \
  --color=marker:#9ece6a,spinner:#bb9af7,header:#565f89,border:#7aa2f7"

# zoxide initialization
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# ── 7. AUTOSUGGESTIONS & SYNTAX HIGHLIGHTING ─────────────────
[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# Crisp, readable suggestion preview (Tokyo Slate)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#565f89,italic"

# Syntax highlighting custom styling & activation (MUST be sourced last)
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#7dcfff,bold'          # Electric Cyan for commands
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#7aa2f7,bold'          # Bright Azure for builtins
ZSH_HIGHLIGHT_STYLES[alias]='fg=#9ece6a,bold'            # Vibrant Emerald Green for aliases
ZSH_HIGHLIGHT_STYLES[function]='fg=#73daca,bold'         # Radiant Mint for shell functions
ZSH_HIGHLIGHT_STYLES[path]='fg=#e0af68,underline'        # Warm Golden Amber with underline for valid paths
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#e0af68'           # Golden Amber for partial paths
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#ff9e64' # Orange for single quotes
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#ff9e64' # Orange for double quotes
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#ff9e64' # Orange for $'' strings
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#bb9af7'   # Luminous Violet for command substitutions
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#bb9af7'   # Violet for short flags (-a)
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#bb9af7'   # Violet for long flags (--all)
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f7768e,bold'     # Vivid Coral Red for typos/unknown commands
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#b4befe,bold'     # Soft Lavender for keywords (if/then/for)

# Extra completions for common tools (docker, cargo, nix, etc.)
[ -d ~/.zsh/zsh-completions/src ] && fpath=(~/.zsh/zsh-completions/src $fpath)

# Remind you when an alias exists for a command you just typed
[ -f ~/.zsh/zsh-you-should-use/you-should-use.plugin.zsh ] && \
    source ~/.zsh/zsh-you-should-use/you-should-use.plugin.zsh

# Syntax highlighting (MUST be sourced last among plugins)
[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# History substring search (source AFTER syntax highlighting)
[ -f ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh ] && \
    source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
if type history-substring-search-up &>/dev/null; then
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
fi

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

# Editor
if command -v nvim >/dev/null 2>&1; then
    alias v='nvim'
    alias vim='nvim'
    export EDITOR='nvim'
    export VISUAL='nvim'
fi

# Yazi (terminal file manager) with dynamic directory switching on exit
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
alias y='yy'

# Animation & fun screensavers / aesthetic tools
alias theme='theme-switch'
alias themes='theme-switch'
alias scmd='scmd'
alias cheatsheet='scmd'
alias torii='torii-banner'
alias torii-banner='torii-banner'
alias rice='kitty --session ~/.config/kitty/sessions/rice.session &>/dev/null &'
alias matrix-red='matrix-red'
alias matrix='command -v cmatrix >/dev/null 2>&1 && cmatrix || echo "Install cmatrix with: sudo dnf install cmatrix"'
alias pipes='command -v pipes-rs >/dev/null 2>&1 && pipes-rs || (command -v pipes.sh >/dev/null 2>&1 && pipes.sh || echo "Run: cargo install pipes-rs or install pipes.sh")'
alias bonsai='command -v cbonsai >/dev/null 2>&1 && cbonsai -l || echo "Install cbonsai with: sudo dnf install cbonsai"'
alias aquarium='command -v asciiquarium >/dev/null 2>&1 && asciiquarium || echo "Install asciiquarium with: sudo dnf install asciiquarium"'

# Kitty terminal features (image protocol, SSH, sessions)
if [[ "$TERM" == "xterm-kitty" || -n "$KITTY_PID" ]]; then
    alias icat='kitten icat'
    alias img='kitten icat --align=left'
    alias imgfit='kitten icat --place=80x24@0x0'
    alias kssh='kitten ssh'
    alias kdiff='kitten diff'
    alias dev='kitty --session ~/.config/kitty/sessions/dev.session &>/dev/null &'
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

# Search all aliases, functions, cheatsheets, and CLI tools with rich visual preview panel
search-cmds() {
    local query="${1:-}"
    local selected
    selected=$(
        {
            # Git category
            printf "%-12s | %-16s | %s\n" "Git" "gs" "git status — Check modified and untracked files"
            printf "%-12s | %-16s | %s\n" "Git" "ga" "git add — Stage changes for commit"
            printf "%-12s | %-16s | %s\n" "Git" "gc" "git commit — Record changes to repository"
            printf "%-12s | %-16s | %s\n" "Git" "gp" "git push — Push commits to remote repo"
            printf "%-12s | %-16s | %s\n" "Git" "gl" "git log --graph --oneline — Visual commit history tree"
            printf "%-12s | %-16s | %s\n" "Git" "gd" "git diff — Inspect unstaged code differences"
            printf "%-12s | %-16s | %s\n" "Git" "gco" "git checkout / switch branch"
            printf "%-12s | %-16s | %s\n" "Git" "gb" "git branch — List or manage branches"

            # File & Navigation category
            printf "%-12s | %-16s | %s\n" "Files" "ls / ll / la" "eza / ls — Modern file listing with icons & permissions"
            printf "%-12s | %-16s | %s\n" "Files" "lt / lta" "eza --tree — Show directory hierarchy tree view"
            printf "%-12s | %-16s | %s\n" "Files" "catp <file>" "bat — View file contents with syntax highlighting"
            printf "%-12s | %-16s | %s\n" "Files" "z <folder>" "zoxide — Jump instantly to any directory by frecency"
            printf "%-12s | %-16s | %s\n" "Files" ".." "cd .. — Move up one directory level"
            printf "%-12s | %-16s | %s\n" "Files" "..." "cd ../.. — Move up two directory levels"
            printf "%-12s | %-16s | %s\n" "Files" "cls" "clear — Clear terminal screen"
            printf "%-12s | %-16s | %s\n" "Files" "reload" "source ~/.zshrc — Reload shell configuration"
            printf "%-12s | %-16s | %s\n" "Files" "path" "Print system PATH formatted on separate lines"

            # Search & Discovery category
            printf "%-12s | %-16s | %s\n" "Search" "rg <query>" "ripgrep — Ultra-fast regex search across files"
            printf "%-12s | %-16s | %s\n" "Search" "fd <name>" "fd-find — Fast, case-insensitive file/folder finder"
            printf "%-12s | %-16s | %s\n" "Search" "fzf" "fzf — Fuzzy finder (Ctrl+T for files, Ctrl+R for history)"
            printf "%-12s | %-16s | %s\n" "Search" "tldr <cmd>" "tealdeer — Practical command cheat sheet with examples"
            printf "%-12s | %-16s | %s\n" "Search" "apropos <word>" "Search manual page descriptions for keywords"

            # Docker category
            printf "%-12s | %-16s | %s\n" "Docker" "dps" "docker ps — List running containers"
            printf "%-12s | %-16s | %s\n" "Docker" "dpsa" "docker ps -a — List all containers"
            printf "%-12s | %-16s | %s\n" "Docker" "di" "docker images — List local container images"
            printf "%-12s | %-16s | %s\n" "Docker" "dex <c> sh" "docker exec -it — Open interactive shell in container"
            printf "%-12s | %-16s | %s\n" "Docker" "dlog <c>" "docker logs -f — Stream container log output"
            printf "%-12s | %-16s | %s\n" "Docker" "dc" "docker compose — Multi-container Docker management"

            # Kubernetes category
            printf "%-12s | %-16s | %s\n" "Kubernetes" "k" "kubectl — Kubernetes CLI client"
            printf "%-12s | %-16s | %s\n" "Kubernetes" "kgp" "kubectl get pods — List running pods"
            printf "%-12s | %-16s | %s\n" "Kubernetes" "kgs" "kubectl get svc — List cluster services"
            printf "%-12s | %-16s | %s\n" "Kubernetes" "kdp <pod>" "kubectl describe pod — Show detailed pod health"
            printf "%-12s | %-16s | %s\n" "Kubernetes" "kl <pod>" "kubectl logs -f — Stream pod logs"

            # System category
            printf "%-12s | %-16s | %s\n" "System" "btop" "btop — Interactive CPU, GPU, memory, disk & process monitor"
            printf "%-12s | %-16s | %s\n" "System" "sc <svc>" "sudo systemctl — Manage systemd system services"
            printf "%-12s | %-16s | %s\n" "System" "scs <svc>" "systemctl status — Check service status"
            printf "%-12s | %-16s | %s\n" "System" "scu <svc>" "systemctl --user — Manage user-level services"
            printf "%-12s | %-16s | %s\n" "System" "jc" "journalctl -xe — View system logs with explanations"
            printf "%-12s | %-16s | %s\n" "System" "install-tools" "install-tools — Audit and install modern CLI suite via DNF"

            # Kitty shortcuts
            printf "%-12s | %-16s | %s\n" "Kitty UI" "Ctrl+Shift+Enter" "Kitty: Split window horizontally"
            printf "%-12s | %-16s | %s\n" "Kitty UI" "Ctrl+Shift+-" "Kitty: Split window vertically"
            printf "%-12s | %-16s | %s\n" "Kitty UI" "Ctrl+Shift+H/J/K/L" "Kitty: Navigate window panes (vim-style)"
            printf "%-12s | %-16s | %s\n" "Kitty UI" "Ctrl+Shift+Z" "Kitty: Zoom/Maximize current pane (toggle stack)"
            printf "%-12s | %-16s | %s\n" "Kitty UI" "Ctrl+Shift+T" "Kitty: Open new tab in current working directory"
            printf "%-12s | %-16s | %s\n" "Kitty UI" "Ctrl+Shift+W" "Kitty: Close active tab"
            printf "%-12s | %-16s | %s\n" "Kitty UI" "Ctrl+Shift+P > F" "Kitty: Hint picker to select and copy file paths"
            printf "%-12s | %-16s | %s\n" "Kitty UI" "Alt+S" "Shell: Open interactive Command Search & Cheat Sheet"

            # Other custom user aliases
            alias | while read -r line; do
                local aname="${line%%=*}"
                local aval="${line#*=}"
                printf "%-12s | %-16s | alias %s\n" "Custom Alias" "$aname" "$aval"
            done
        } | sort -u | fzf \
            --query="$query" \
            --delimiter=' \| ' \
            --with-nth=1,2,3 \
            --header="📂 [CATEGORY]       COMMAND / SHORTCUT | DESCRIPTION (Enter to Paste, Esc to Exit)" \
            --prompt="🔎 Search > " \
            --preview='echo -e "\033[1;36mCategory:\033[0m {1}\n\033[1;32mCommand:\033[0m  {2}\n\033[1;33mDetail:\033[0m   {3}\n\n\033[1;35mQuick Example / Help:\033[0m\n$(tldr {2} 2>/dev/null || which {2} 2>/dev/null || echo "Shell builtin / alias: {2}")"' \
            --preview-window=right:48%:wrap
    )

    if [[ -n "$selected" ]]; then
        local cmd
        cmd=$(echo "$selected" | awk -F ' \\| ' '{print $2}' | awk '{print $1}')
        # If it is a shortcut like Ctrl+Shift, do not execute
        if [[ "$cmd" =~ "Ctrl\+" || "$cmd" =~ "Alt\+" ]]; then
            echo -e "\n\033[1;36mKitty Shortcut:\033[0m $selected"
        else
            print -z "$cmd"
        fi
    fi
}
search-cmds-widget() {
    search-cmds
    zle redisplay
}
zle -N search-cmds-widget
bindkey "^[s" search-cmds-widget   # Alt+S shortcut
bindkey "^[S" search-cmds-widget

alias scmd='search-cmds'
alias help-cmds='search-cmds'

# Inspect and install missing cutting-edge tools
install-tools() {
    local -A tool_packages=(
        ["kitty"]="kitty (GPU terminal emulator)"
        ["nvim"]="neovim (Modern IDE / editor)"
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
        ["cmatrix"]="cmatrix (Matrix falling code animation)"
        ["cbonsai"]="cbonsai (Animated bonsai growth)"
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
        echo -e "  \033[1msudo dnf install -y kitty neovim zsh fzf zoxide fontconfig curl git bat eza ripgrep fd-find btop tealdeer git-delta cmatrix cbonsai\033[0m"
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

# ── Auto-run Fastfetch on Shell Launch ──
if [[ -o interactive ]] && [[ -t 1 ]] && command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi



# ── Red Forest Torii FZF Theme ──
export FZF_DEFAULT_OPTS=" \
--color=bg+:#4a1525,bg:#100b14,spinner:#ff758f,hl:#ff3355 \
--color=fg:#f2edf5,header:#ff758f,info:#ffb703,pointer:#ff3355 \
--color=marker:#52b788,fg+:#ffffff,prompt:#ff3355,hl+:#ff4d6d \
--prompt='󰄯 ' --pointer='▶' --marker='✓' --layout=reverse --border"
