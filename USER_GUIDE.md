# 📖 Complete User Guide: Kitty & Modern CLI Setup

Welcome to your unified terminal, shell, and editor environment. This setup brings together **Kitty**, **Starship**, **Catppuccin Mocha**, **Zsh/Bash**, **Modern CLI utilities**, **Tmux**, and **Neovim (Lazy.nvim)** into an integrated, fast, and aesthetically pleasing workflow.

---

## 📑 Table of Contents

1. [⚡ Quick Installation & Synchronization](#-quick-installation--synchronization)
2. [🖥️ Kitty Terminal Workflow](#️-kitty-terminal-workflow)
3. [🐚 Shell Experience (Zsh & Bash)](#-shell-experience-zsh--bash)
4. [🛠️ Modern CLI Tools Cheatsheet](#️-modern-cli-tools-cheatsheet)
5. [⌨️ Shell Aliases & Shortcuts](#️-shell-aliases--shortcuts)
6. [🚀 Neovim (Lazy.nvim) IDE Workflow](#-neovim-lazynvim-ide-workflow)
7. [🧵 Tmux Fallback (Remote / SSH)](#-tmux-fallback-remote--ssh)
8. [🔄 Maintenance & Customization](#-maintenance--customization)

---

## ⚡ Quick Installation & Synchronization

### 1. Run the Automated Installer
To install all necessary packages, fonts, plugins, and deploy configurations:
```sh
cd ~/Desktop/kitty-setup
chmod +x install.sh uninstall.sh
./install.sh
```

**Installer Options:**
- `./install.sh -y` — Non-interactive installation (skips confirmation prompts).
- `./install.sh --change-shell` — Prompts / sets Zsh as default login shell (`chsh`).
- `./install.sh --dry-run` — Previews file changes and package installs without writing.

### 2. Verify Your Setup
Inside the terminal, run:
```sh
check-tools   # or install-tools
```
This displays an interactive visual dashboard of all installed tools vs missing packages.

---

## 🖥️ Kitty Terminal Workflow

Kitty is configured with **Catppuccin Mocha**, **75% opacity**, **Fantasque Sans Mono Nerd Font (size 18.0)**, smooth cursor trail animations, and modular configs (`kitty.conf`, `keybindings.conf`, `open-actions.conf`).

### Essential Kitty Keybindings

| Category | Shortcut | Action |
|---|---|---|
| **Splits & Panes** | `Ctrl+Shift+Enter` | Horizontal split (in current directory) |
| | `Ctrl+Shift+-` | Vertical split (in current directory) |
| | `Ctrl+Shift+H` | Navigate to left pane |
| | `Ctrl+Shift+J` | Navigate to lower pane |
| | `Ctrl+Shift+K` | Navigate to upper pane |
| | `Ctrl+Shift+L` | Navigate to right pane |
| | `Ctrl+Shift+Z` | Toggle zoom / maximize pane (Stack layout) |
| | `Ctrl+Shift+Shift+Z` | Cycle next layout (`splits`, `tall`, `stack`, `grid`) |
| | `Ctrl+Shift+R` | Interactive window resize mode |
| **Tabs** | `Ctrl+Shift+T` | New tab (in current directory) |
| | `Ctrl+Shift+W` | Close active tab |
| | `Ctrl+Shift+Shift+H / L` | Switch previous / next tab |
| | `Ctrl+Shift+1..4` | Jump to tab 1 to 4 |
| | `Alt+1..9` | Fast tab switch (1 to 9) |
| | `Ctrl+Shift+Shift+D` | Detach tab into separate window |
| **Font Zoom** | `Ctrl+Shift+=` or `Ctrl+=` | Increase font size |
| | `Ctrl+Shift+-` or `Ctrl+-` | Decrease font size |
| | `Ctrl+Shift+0` or `Ctrl+0` | Reset font size to default (18pt) |
| **Pickers (Leader: `Ctrl+Shift+P`)** | `Ctrl+Shift+P > F` | Hint: Select & paste file path |
| | `Ctrl+Shift+P > L` | Hint: Select & copy line number |
| | `Ctrl+Shift+P > H` | Hint: Select git commit hash |
| | `Ctrl+Shift+P > I` | Hint: Select IP address |
| | `Ctrl+Shift+P > Y` | Hint: Select word |
| **Opacity (Leader: `Ctrl+Shift+A`)** | `Ctrl+Shift+A > M` | Increase background opacity (+0.1) |
| | `Ctrl+Shift+A > L` | Decrease background opacity (-0.1) |
| | `Ctrl+Shift+A > 1` | Set full opacity (1.0 / solid) |
| | `Ctrl+Shift+A > D` | Reset opacity to default (0.75) |
| **Utilities** | `Ctrl+Shift+F5` | Hot reload Kitty configuration |
| | `Ctrl+Shift+F8` | Open full scrollback buffer in pager |
| | `Ctrl+Shift+D` | Open side-by-side Kitten diff |
| | `Ctrl+Shift+B` | Broadcast typing to all open windows |
| | `Ctrl+Shift+G` | View last command output in overlay |

### Dev Session Launcher
Launch a pre-configured multi-tab development workspace:
```sh
dev   # Opens Neovim + Terminal split in Tab 1, and Lazygit in Tab 2
```

---

## 🐚 Shell Experience (Zsh & Bash)

Both `.zshrc` and `.bashrc` provide feature parity with Catppuccin Mocha colors and fast completion.

### Key Shell Features
- **Smart Directory Jump**: Type `z <name>` to jump into any directory based on frecency.
- **Typo Auto-Correction**: Mistyped folder names automatically correct (e.g. `cd dokctop` -> `Desktop`).
- **Syntax Highlighting & Autosuggestions**: As you type, fish-like grey suggestions appear; press `→` or `End` to accept.
- **FZF Fuzzy Finder**:
  - `Ctrl+R`: Fuzzy history search with syntax preview.
  - `Ctrl+T`: Fuzzy file picker.
  - `Alt+C`: Fuzzy directory switcher.
- **Alt+S Shortcut**: Opens the visual **Command & Shortcut Cheatsheet** with live tldr previews.

---

## 🛠️ Modern CLI Tools Cheatsheet

| Replacement Tool | Replaced Command | Key Features & Usage |
|---|---|---|
| **`eza`** | `ls` | `ls` / `ll` (with git status) / `la` / `lt` (tree view) |
| **`bat`** | `cat` | `catp <file>` syntax-highlighted paging with line numbers |
| **`ripgrep` (`rg`)** | `grep` | `rg "pattern"` ultra-fast recursive code search |
| **`fd-find` (`fd`)** | `find` | `fd <name>` fast case-insensitive file & directory lookup |
| **`zoxide` (`z`)** | `cd` | `z repo` jumps directly to matching directory |
| **`tealdeer` (`tldr`)** | `man` | `tldr git commit` instant practical command examples |
| **`btop`** | `top` / `htop` | `btop` interactive CPU, GPU, memory, disks & network visualizer |
| **`git-delta`** | `git diff` | Side-by-side syntax-highlighted git diffs |
| **`cava`** | - | `cava` vibrant audio visualizer with Cyberpunk / Catppuccin gradients |
| **`fastfetch`** | `neofetch` | `fastfetch` fast, modern system specs & hardware summary with ASCII art |
| **`asciiquarium`** | - | `asciiquarium` animated underwater ASCII ocean screensaver |
| **`tty-clock`** | - | `tty-clock -C 6 -c -s -b` minimalist terminal digital clock |
| **`cmatrix` / `cbonsai` / `pipes-rs`** | - | `matrix` / `bonsai` / `pipes` terminal animations & screensavers |
| **`sl`** | - | `sl` animated steam locomotive train |
| **`oneko`** | - | `oneko &` retro pixel cat that chases your cursor around the screen |
| **`figlet` / `toilet`** | - | `figlet "TEXT" \| lolcat` or `toilet -f slant --filter metal "TEXT"` ASCII art banners |
| **`cowsay` / `fortune`** | - | `fortune \| cowsay \| lolcat` quote of the day in speech bubble |
| **`chafa`** | - | `chafa <image/gif>` renders high-res images & animated GIFs in terminal |

---

## ⌨️ Shell Aliases & Shortcuts

### Interactive Search & Guides
- `cool`: Visual status & quick launch cheatsheet for all aesthetic/rice tools.
- `cool -i` (or `cool menu`): Interactive fuzzy launcher to pick and launch any screensaver or visualizer.
- `scmd` or `search-cmds` (or press `Alt+S`): Interactive fuzzy search across all aliases, shortcuts, and commands with live documentation preview.
- `check-tools` or `install-tools`: Tool readiness audit dashboard.

### Git Aliases
- `gs` -> `git status`
- `ga` -> `git add`
- `gc` -> `git commit`
- `gp` -> `git push`
- `gl` -> `git log --oneline --graph --decorate --all`
- `gd` -> `git diff`
- `gco` -> `git checkout`
- `gb` -> `git branch`

### Docker & Kubernetes Aliases
- `dps` -> `docker ps`
- `dpsa` -> `docker ps -a`
- `di` -> `docker images`
- `dex <container> sh` -> `docker exec -it`
- `dlog <container>` -> `docker logs -f`
- `dc` -> `docker compose`
- `k` -> `kubectl`
- `kgp` -> `kubectl get pods`
- `kgs` -> `kubectl get svc`
- `kl <pod>` -> `kubectl logs -f`
- `kdp <pod>` -> `kubectl describe pod`

### Navigation & Utilities
- `..` -> `cd ..`
- `...` -> `cd ../..`
- `reload` -> `source ~/.zshrc`
- `cls` -> `clear`
- `path` -> Formatted `$PATH` list
- `sc <svc>` -> `sudo systemctl`
- `scs <svc>` -> `systemctl status`
- `jc` -> `journalctl -xe`

---

## 🚀 Neovim (Lazy.nvim) IDE Workflow

Launch Neovim via `v` or `nvim`. Configuration is modularly organized in `nvim/lua/`.

### Leader Key: `Space` (`<leader>`)

#### Navigation & Windows
- `<leader>e` — Toggle `nvim-tree` file explorer
- `<C-h> / <C-j> / <C-k> / <C-l>` — Navigate between split windows
- `<C-Up> / <C-Down> / <C-Left> / <C-Right>` — Resize window dimensions
- `<leader>w` — Quick save file (`:w`)
- `<leader>q` — Quick quit (`:q`)
- `<C-\>` — Toggle floating terminal (`toggleterm`)
- `<leader>gg` — Open floating `lazygit`

#### Fuzzy Finding (Telescope)
- `<leader>ff` — Find files in project
- `<leader>fg` — Live grep text across project
- `<leader>fb` — Switch active buffers
- `<leader>fo` — Open recent files
- `<leader>fk` or `<leader>sk` — Search all Neovim keymaps & commands
- `<leader>ft` — Find TODO comments (`todo-comments`)

#### LSP & Code Intelligence
- `gd` — Go to definition
- `gr` — Go to references
- `K` — Hover documentation
- `<leader>rn` — Rename symbol across codebase
- `<leader>ca` — Code actions (quick fixes, imports)
- `[d` / `]d` — Jump to previous / next diagnostic warning/error
- `<leader>cf` — Format buffer (`conform.nvim` with Stylua, Ruff, Prettier, Shfmt)
- `<leader>xx` — Toggle Trouble diagnostics panel

#### Coding Helpers & Animations
- `gcc` or `<leader>/` — Toggle line comment
- `ysaw"` / `cs"'` / `ds"` — Surround text with quotes/brackets (`nvim-surround`)
- Visual mode `J` / `K` — Move selected lines up or down
- `<leader>mr` — **Make it Rain** code animation (`cellular-automaton`)
- `<leader>mg` — **Game of Life** code animation (`cellular-automaton`)
- **Fluid Inline Diagnostics**: Diagnostics automatically animate in place with `tiny-inline-diagnostic.nvim`.
- **Smooth Window Resizing**: Window splits and floating popups smoothly resize/open with `mini.animate`.

---

## 🧵 Tmux Fallback (Remote / SSH)

When working over SSH or inside headless environments where Kitty is not running:
- **Prefix Key**: `Ctrl+A`
- **Splits**: `Ctrl+A Enter` (horizontal split), `Ctrl+A -` (vertical split)
- **Navigation**: `Ctrl+A h/j/k/l`
- **New Window**: `Ctrl+A c`
- **Reload**: `Ctrl+A r`

---

## 🔄 Maintenance & Customization

### Adding Custom Aliases
Add custom aliases to `~/.zshrc` or `~/.bashrc` under section `9. ALIASES`. Reload with `reload`.

### Modifying Kitty Themes & Fonts
- Edit `kitty/kitty.conf` to change font sizes or transparency.
- Edit `kitty/keybindings.conf` to adjust hotkeys.
- Apply changes immediately inside Kitty with `Ctrl+Shift+F5`.

### Safe Uninstallation / Backup Restore
If you ever want to revert or restore prior configs:
```sh
./uninstall.sh --restore-latest   # Restores the newest pre-install backup
./uninstall.sh --yes              # Safely removes only repo-managed configs
```
