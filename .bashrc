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

# ── 0. CASE-INSENSITIVE COMPLETION & NAVIGATION ──────────────
bind 'set completion-ignore-case on' 2>/dev/null || true
bind 'set show-all-if-ambiguous on' 2>/dev/null || true
bind 'set menu-complete-display-prefix on' 2>/dev/null || true
shopt -s nocaseglob 2>/dev/null || true   # Case-insensitive filename expansion
shopt -s cdspell 2>/dev/null || true      # Correct minor spelling errors in cd
shopt -s dirspell 2>/dev/null || true     # Correct spelling errors during completion
shopt -s autocd 2>/dev/null || true       # Type directory name to cd into it

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

# ── 5. ALIASES & CUTTING-EDGE CLI TOOLS ──────────────────────
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
alias reload='source ~/.bashrc'
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

# ── 6. INTERACTIVE COMMAND SEARCH & INSTALL HELPERS ─────────
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
            printf "%-12s | %-16s | %s\n" "Files" "reload" "source ~/.bashrc — Reload shell configuration"
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
        if [[ "$cmd" =~ "Ctrl\+" || "$cmd" =~ "Alt\+" ]]; then
            echo -e "\n\033[1;36mKitty Shortcut:\033[0m $selected"
        else
            READLINE_LINE="$cmd"
            READLINE_POINT=${#READLINE_LINE}
        fi
    fi
}
bind -x '"\es": search-cmds' 2>/dev/null || true  # Alt+S shortcut
bind -x '"\eS": search-cmds' 2>/dev/null || true

alias scmd='search-cmds'
alias help-cmds='search-cmds'

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
    for cmd in "${!tool_packages[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            printf " \033[32m✓\033[0m %-10s : %s\n" "$cmd" "${tool_packages[$cmd]}"
        else
            printf " \033[31m✗\033[0m %-10s : %s \033[33m(missing)\033[0m\n" "$cmd" "${tool_packages[$cmd]}"
            missing+=("$cmd")
        fi
    done

    if command -v starship >/dev/null 2>&1; then
        printf " \033[32m✓\033[0m %-10s : %s\n" "starship" "Starship prompt"
    else
        printf " \033[31m✗\033[0m %-10s : %s \033[33m(missing)\033[0m\n" "starship" "Starship prompt"
    fi

    echo ""
    if [ ${#missing[@]} -eq 0 ]; then
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
