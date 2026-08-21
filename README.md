# Kitty & Modern CLI Setup

A complete, battle-tested terminal configuration featuring **Kitty**, **Starship Prompt**, **Catppuccin Mocha** color palette, **Fantasque Sans Mono Nerd Font**, **Zsh** (with autosuggestions & syntax highlighting), **FZF**, and **Zoxide**.

---

## ⚡ Quick Automated Setup

Run the automated installer to set up all tools, fonts, plugins, and configurations:

```sh
chmod +x install.sh
./install.sh
```

For automated / non-interactive installation (no prompts):
```sh
./install.sh -y
```

### What the installer does automatically:
1. **Kitty Installation**: Detects existing Kitty or automatically installs the official standalone Kitty binary and desktop launcher (no root/sudo required).
2. **Modern CLI Tools**: Automatically downloads and installs **Starship**, **Zoxide**, and **FZF** into `~/.local/bin`.
3. **Fonts**: Installs **Fantasque Sans Mono Nerd Font** into `~/.local/share/fonts` and updates the system font cache.
4. **Zsh Plugins**: Deploys `zsh-autosuggestions` and `zsh-syntax-highlighting` into `~/.zsh/`.
5. **Config Files**: Safely deploys `kitty.conf`, `starship.toml`, `terminal.conf`, `.zshrc`, `.bashrc`, and `.bash_profile` (automatically creating timestamped backups of existing configs).
6. **Smart Shell Support**: Configures Kitty with `shell .` so Kitty works seamlessly with your system default shell (Bash or Zsh) without crashing if Zsh is not yet installed.

---

## 🎨 Features & Keybindings

### Kitty Features
- **Theme**: Catppuccin Mocha with 75% opacity and smooth cursor trail animations.
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

## 🐚 Shell Support & Productivity Shortcuts

Both `.zshrc` and `.bashrc` are fully configured with:
- **Starship Prompt** (minimal Catppuccin Mocha style with git status and execution timing).
- **Zoxide** (`z <directory>` smart fuzzy jump).
- **FZF** (fuzzy finder with Catppuccin styling, `Ctrl+R` history search, `Ctrl+T` file finder).
- **Catppuccin LS_COLORS** and **Bat syntax highlighting**.
- **Interactive Shortcuts Cheatsheet (`Ctrl+H` / `Alt+S`)**: Interactive fuzzy popup menu with live previews to search and execute all your aliases and shortcuts.

### ⚡ Interactive Shortcuts Menu
Press <kbd>Ctrl</kbd> + <kbd>H</kbd> (or <kbd>Alt</kbd> + <kbd>S</kbd>, or type `shortcuts`) to open the interactive fuzzy-finder menu:

| Category | Shortcut | Target Command |
|---|---|---|
| **Git** | `gs` | `git status` |
| | `ga` | `git add` |
| | `gc` | `git commit` |
| | `gp` | `git push` |
| | `gl` | `git log --oneline --graph --decorate --all` |
| | `gd` | `git diff` |
| | `gb` | `git branch` |
| | `gco` | `git checkout` |
| **Docker** | `dps` | `docker ps` |
| | `dpsa` | `docker ps -a` |
| | `di` | `docker images` |
| | `dex` | `docker exec -it` |
| | `dlog` | `docker logs -f` |
| | `dc` | `docker compose` |
| **Kubernetes** | `k` | `kubectl` |
| | `kgp` | `kubectl get pods` |
| | `kgs` | `kubectl get svc` |
| | `kdp` | `kubectl describe pod` |
| | `kl` | `kubectl logs -f` |
| **System & Nav** | `ll` | `ls -lah` |
| | `..` / `...` | `cd ..` / `cd ../..` |
| | `cls` | `clear` |
| | `path` | `echo $PATH \| tr ':' '\n'` |
| | `reload` | `source ~/.zshrc` |
| | `sc` | `sudo systemctl` |
| | `scs` | `systemctl status` |
| | `scu` | `systemctl --user` |
| | `jc` | `journalctl -xe` |

---

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
