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

## 🎨 Features & Keybindings

### Kitty Features
- **Theme**: Catppuccin Mocha with 75% opacity.
- **Font**: Fantasque Sans Mono Nerd Font (size 18.0) with ligature support.
- **Layouts**: Splits, Tall, and Stack modes.

### Key Shortcuts in Kitty:
| Shortcut | Action |
|---|---|
| `Ctrl+Shift+Enter` | Horizontal split pane |
| `Ctrl+Shift+-` | Vertical split pane |
| `Ctrl+Shift+H/J/K/L` | Navigate panes (left/down/up/right) |
| `Ctrl+Shift+Z` | Toggle zoom (stack layout) |
| `Ctrl+Shift+T` | New tab (in current directory) |
| `Ctrl+Shift+W` | Close tab |
| `Ctrl+Shift+1..4` | Jump to tab 1–4 |
| `Ctrl+Shift+Plus/Minus` | Zoom font in / out |
| `Ctrl+Shift+P > F` | Kitten hint: Pick and paste file paths |
| `Ctrl+Shift+P > L` | Kitten hint: Pick line numbers |
| `Ctrl+Shift+A > M/L` | Increase / decrease window opacity |

---

## 🐚 Shell & Modern CLI Suite (Zsh & Bash)

Both `.zshrc` and `.bashrc` are fully configured with:
- **`search-cmds` (or `scmd`)**: Interactive fuzzy search for all aliases, shell functions, and built-in tool guides with live preview.
- **`install-tools` (or `check-tools`)**: Instant visual dashboard of all installed vs missing cutting-edge tools and their installation command.
- **`fzf-tab`**: Replaces the standard Zsh tab menu with an interactive FZF popup with real-time file and directory preview.
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

## 📁 Repository Structure

```
kitty-setup/
├── install.sh                                # Automated fail-proof installer
├── README.md                                 # Documentation
├── terminal.conf                             # Environment variable (TERMINAL=kitty)
├── starship.toml                             # Starship prompt Catppuccin configuration
├── starship.toml.bak                         # Alternate Starship config
├── .zshrc                                    # Zsh configuration
├── .bashrc                                   # Bash configuration (synced tools & aliases)
├── .bash_profile                             # Profile environment loader
├── kitty/
│   ├── kitty.conf                            # Main Kitty configuration
│   └── kitty.conf.bak                        # Backup Kitty configuration
├── fonts/
│   └── fantasque-sans-mono-nerd-fonts/       # Fantasque Sans Mono TTF files
└── zsh/
    ├── zsh-autosuggestions/                  # Zsh autosuggestions plugin
    └── zsh-syntax-highlighting/              # Zsh syntax highlighting plugin
```
