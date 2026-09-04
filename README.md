# Kitty & Modern CLI Setup

A complete, battle-tested terminal configuration featuring **Kitty**, **Starship Prompt**, **Catppuccin Mocha** color palette, **Fantasque Sans Mono Nerd Font**, **Zsh** (with autosuggestions & syntax highlighting), **FZF**, and **Zoxide**.

---

## ⚡ Quick Automated Setup

Run the safe, repeatable installer to set up the configurations, fonts, plugins, and available tools:

```sh
chmod +x install.sh
./install.sh
```

For automated / non-interactive installation (no prompts):
```sh
./install.sh -y
```

Preview every action without changing the system:

```sh
./install.sh --dry-run
```

Interactive terminals show a short 3D ASCII Kitty cube at startup and a download animation for long operations. Both are automatically disabled in CI and redirected output; use `--no-animation` to disable them manually.

### Safe uninstall

`uninstall.sh` removes only files that still match this repository. It leaves modified files, plugins, fonts, and downloaded tools untouched. To restore the newest configuration backup instead, use `--restore-latest`.

```sh
./uninstall.sh --yes
./uninstall.sh --restore-latest
```

### What the installer does automatically (Fedora / DNF):
1. **DNF Packages**: Installs `kitty`, `zsh`, `fzf`, `zoxide`, `fontconfig`, `curl`, `git`, `bat`, and `util-linux-user` directly via `dnf`.
2. **Kitty Application Setup**: Ensures Kitty and its desktop shortcuts (`kitty.desktop`) and icons are registered.
3. **Starship Prompt**: Installs the latest Starship prompt release directly into `~/.local/bin`.
4. **Fonts**: Installs **Fantasque Sans Mono Nerd Font** into `~/.local/share/fonts` and updates font cache.
5. **Zsh Plugins**: Clones `zsh-autosuggestions` and `zsh-syntax-highlighting` into `~/.zsh/`.
6. **Config Files**: Deploys `kitty.conf`, `starship.toml`, `terminal.conf`, `.zshrc`, `.bashrc`, and `.bash_profile` (creating backups of previous files).
7. **Login Shell**: Optionally configures Zsh as your login shell with `--change-shell`.

The installer downloads Zsh plugins itself. If you also want the optional repository submodules for offline inspection, clone with `git clone --recurse-submodules <repository-url>`.

---

## 🎨 Themes, Visibility & Aesthetics

### Curated Reddit & Unixporn Color Themes
Switch between top-rated community themes at any time without restarting your terminal:
- **`Red Forest Torii`** *(New Active Theme)*: Mystic Japanese Torii shrine in crimson mist — obsidian plum background, glowing vermilion & red accents, Shinto lantern gold, pine jade, and luminous sakura moonlight text.
- **`Tokyo Night`**: Reddit's #1 favorite — deep slate midnight background, crisp ice-blue/white text, radiant neon cyan cursor, glowing sapphire selection highlight.
- **`Catppuccin Mocha`**: High-visibility pastel palette with boosted contrast and soft mauve accents.
- **`Rosé Pine Moon`**: Moody natural palette with pine, foam, and warm gold highlights.
- **`Dracula Pro`**: High-contrast retrowave dark theme with vivid neon pink, cyan, and emerald.
- **`Gruvbox Dark Material`**: Retro compute aesthetic, easy on the eyes for extended coding sessions.
- **`Cyberpunk Glow`**: Ultra-vibrant electric neon on deep OLED pitch black.

```sh
theme             # Open interactive fuzzy picker with live preview
theme red-torii   # Instantly switch to Red Forest Torii
theme tokyo-night # Instantly switch to Tokyo Night
theme rose-pine   # Instantly switch to Rosé Pine
```

### Visual Enhancements:
- **High-Visibility Selection**: Text highlight uses non-destructive luminous accents (`#33467c` / `#45475a`) ensuring syntax colors remain crystal clear under selection.
- **Fluid Cursor Trail**: Smooth animated cursor motion (`cursor_trail 3`) with glowing beam/block indicator.
- **Enhanced Syntax Highlighting**: Vivid color hierarchy for commands (cyan), aliases (green), paths (amber underline), flags (violet), and errors (coral red).
- **Material Blur (Frosted Glass)**: 82% opacity with GPU-accelerated material background blur (`background_blur 32`) for a sleek frosted acrylic aesthetic with high text contrast. Dynamic opacity shortcuts: `Ctrl+Shift+A > M / L`.

### Key Shortcuts in Kitty:
| Shortcut | Action |
|---|---|
| `Ctrl+Shift+Enter` | Horizontal split pane |
| `Ctrl+Shift+-` | Vertical split pane |
| `Ctrl+Shift+H/J/K/L` | Navigate panes (left/down/up/right) |
| `Ctrl+Shift+Z` | Toggle zoom (stack layout) |
| `Ctrl+Shift+T` | New tab (in current directory) |
| `Ctrl+Shift+W` | Close tab |
| `Ctrl+Shift+1..9` | Jump to tab 1–9 |
| `Ctrl+Shift+Plus/Minus` | Zoom font in / out |
| `Ctrl+Shift+U` | **Kitten URL Picker**: Open any on-screen link with 1 key |
| `Ctrl+Shift+E` | **Kitten File Picker**: Open any on-screen path directly in Neovim |
| `Ctrl+Shift+S` | **Interactive Cheatsheet**: Search and execute commands with `scmd` |
| `Ctrl+Shift+Shift+R` | **Aesthetic Lounge**: Launch 3-pane Cava + Btop + Clock session |
| `Ctrl+Shift+A > M/L` | Increase / decrease window opacity |
| `Ctrl+Shift+F5` | Hot reload Kitty configuration |

### ✨ Aesthetic Commands & Visual Rice:
- **`rice`**: Launches the 3-pane aesthetic lounge (Cava visualizer + Btop + Tty-Clock).
- **`scmd`**: Interactive fuzzy finder cheatsheet for all shell aliases and Kitty shortcuts.
- **`cool`**: Interactive launcher for terminal screensavers, visualizers, and art.
- **`matrix-red`**: Crimson Red Matrix digital rain screensaver.

---

## 🐚 Shell & Modern CLI Suite (Zsh & Bash)

Both `.zshrc` and `.bashrc` are fully configured with:
- **`search-cmds` (or `scmd`)**: Interactive fuzzy search for all aliases, shell functions, and built-in tool guides with live preview.
- **`install-tools` (or `check-tools`)**: Instant visual dashboard of all installed vs missing cutting-edge tools and their installation command.
- **`eza`**: Modern `ls` with icons, git status, permissions, and directory tree view (`ls`, `ll`, `la`, `lt`).
- **`bat`**: Syntax-highlighted `cat` replacement (`catp`).
- **`fd` / `ripgrep`**: Ultra-fast search replacements for `find` and `grep`.
- **`Starship Prompt`**: Minimal Catppuccin Mocha prompt with Git status and command execution timing.
- **`Zoxide`**: Smart directory jumping (`z <directory>`).
- **`FZF`**: Fuzzy finder with Catppuccin Mocha styling (`Ctrl+R` history, `Ctrl+T` file finder).
- **Aliases**: Git (`gs`, `ga`, `gc`, `gp`, `gl`, `gd`), Docker (`dps`, `di`, `dex`, `dc`), Kubectl (`k`, `kgp`, `kgs`, `kl`), and Systemd (`sc`, `scs`, `jc`).

### Enabling Zsh as your default shell (Optional):
If you want to use Zsh:
```sh
# Fedora / RHEL:
sudo dnf install zsh

# Ubuntu / Debian:
sudo apt install zsh

# Arch / Manjaro:
sudo pacman -S zsh
```
Then set it as your default shell:
```sh
chsh -s $(which zsh)
```
Kitty will automatically launch Zsh on next startup!

---

## 🚀 Neovim (LazyVim Modern IDE Setup)

Complete state-of-the-art Neovim IDE environment built on **LazyVim**:
- **Package Manager**: Lazy.nvim with fast asynchronous bootstrapping and health validation.
- **Themes**: Tokyo Night (default), Catppuccin Mocha, and Rosé Pine with transparent backgrounds matching Kitty.
- **LSP & Tools**: `nvim-lspconfig`, `mason.nvim`, `mason-lspconfig`, `conform.nvim` (auto-formatting on save with stylua, ruff, prettierd, shfmt).
- **Completion**: `blink.cmp` / `nvim-cmp` with fast fuzzy matching and snippets.
- **Syntax Highlighting**: Treesitter parsers for Python, TypeScript, Lua, Rust, Go, Bash, Docker, Markdown, JSON, YAML, TOML, and more.
- **Navigation & Search**: `snacks.nvim` picker / explorer, `folke/flash.nvim` instant jump, `grug-far.nvim` search & replace.
- **UI & Diagnostics**: `lualine.nvim` (custom powerline statusline), `bufferline.nvim` (sleek tabs), `snacks.nvim` dashboard with Japanese Torii ASCII art, `trouble.nvim` diagnostics viewer, `todo-comments.nvim`, `which-key.nvim`.

---

## 📁 Repository Structure

```
kitty-setup/
├── install.sh                                # Automated fail-proof installer (DNF, configs, tools)
├── uninstall.sh                              # Safe uninstaller and backup restore utility
├── README.md                                 # Main overview & quick start
├── USER_GUIDE.md                             # Complete in-depth usage & shortcut guide
├── terminal.conf                             # Environment variable (TERMINAL=kitty)
├── starship.toml                             # Starship prompt configuration (Nerd Font glyphs)
├── .zshrc                                    # Zsh configuration (plugins, FZF Torii theme, aliases)
├── .bashrc                                   # Bash configuration (synced tools & FZF Torii theme)
├── .bash_profile                             # Profile environment loader
├── .gitconfig                                # Git delta syntax-highlighted pager
├── .tmux.conf                                # Tmux fallback config (truecolor & vi-mode)
├── bin/                                      # CLI tools & aesthetic runners
│   ├── cool                                  # Aesthetic visual tools hub & FZF launcher
│   ├── matrix-red                            # Crimson Red Matrix rain
│   ├── rice                                  # Aesthetic Lounge 3-pane session runner
│   ├── scmd                                  # Fuzzy command / shortcut cheatsheet & runner
│   └── set-login-wallpaper                   # SDDM/Login wallpaper setup helper
├── cava/                                     # Audio visualizer config & shaders
│   ├── config                                # Cava gradient & framerate config
│   └── shaders/                              # Custom Cava fragment shaders
├── fastfetch/                                # System information tool config & arts
│   ├── config.jsonc                          # Fastfetch layout, progress bars, thermals & colors
│   ├── fastfetch-random.sh                   # Shell startup randomizer script
│   └── arts/                                 # Colored braille artwork collection
│       ├── cat.txt                           # Neon Crimson Cat braille art
│       ├── fox.txt                           # Amber Gold Kitsune braille art
│       ├── spider.txt                        # Miles Morales Crimson Spider braille art
│       └── warrior.txt                       # Electric Violet Warrior braille art
├── kitty/                                    # Kitty terminal configuration
│   ├── kitty.conf                            # Main Kitty configuration
│   ├── keybindings.conf                      # Modular Kitty keybindings & hints
│   ├── open-actions.conf                     # File type handlers & preview triggers
│   ├── sessions/                             # Multi-pane sessions (rice, dashboard, dev)
│   └── themes/                               # 8 curated color themes
├── nvim/                                     # LazyVim Neovim IDE configuration
│   ├── init.lua                              # Neovim entry point
│   └── lua/
│       ├── config/                           # options, keymaps, autocmds, lazy bootstrap
│       └── plugins/                          # colorscheme, UI, LSP, treesitter, coding, tools
├── yazi/                                     # Yazi terminal file manager config
│   └── yazi.toml                             # File opener & Kitty image preview config
├── fonts/
│   └── fantasque-sans-mono-nerd-fonts/       # Fantasque Sans Mono TTF files
└── zsh/
    ├── zsh-autosuggestions/                  # Zsh autosuggestions plugin submodule
    └── zsh-syntax-highlighting/              # Zsh syntax highlighting plugin submodule
```
