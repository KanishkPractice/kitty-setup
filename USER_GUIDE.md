# Quick reference

Install the complete setup by running `./install.sh` from this directory. It detects Arch Linux or Fedora, installs packages, fonts, shell plugins, and configuration files, then makes Zsh the login shell. Existing files replaced by the installer are backed up in `~/.config/kitty-setup-backups/`.

## Kitty

The terminal background is solid `#181818`; the font is Fantasque Sans Mono Nerd Font Mono at 14.5 pt.

| Shortcut | Action |
| --- | --- |
| `Ctrl+Shift+Enter` | Horizontal split |
| `Ctrl+Shift+-` | Vertical split |
| `Ctrl+Shift+H/J/K/L` | Move between panes |
| `Ctrl+Shift+Z` | Toggle stacked layout for the current pane |
| `Ctrl+Shift+Alt+Z` | Cycle layouts |
| `Ctrl+Shift+T` | New tab |
| `Ctrl+Shift+W` | Close tab |
| `Alt+1..9` | Switch to tab |
| `Ctrl+=` | Increase font size |
| `Ctrl+-` | Decrease font size |
| `Ctrl+Shift+F5` | Reload Kitty config |
| `Ctrl+Shift+Alt+G` | Show last command output in a pager |
| `Ctrl+Shift+U` | Pick a URL from terminal output |
| `Ctrl+Shift+E` | Pick a path and open it in Neovim |
| `Ctrl+Shift+Alt+E/R/D` | Open the dev/rice/dashboard session |

## Commands

- `rice` opens the Cava and system monitor session.
- `dev` opens the Neovim and Git session.
- `scmd` searches the command guide; `cool` opens the visual tools menu.
- `y` opens Yazi and changes to the selected directory when it exits.

## Backups

Restore the latest install backup with `./uninstall.sh --restore-latest`. Any existing files replaced during restore are saved under `~/.config/kitty-setup-restore-snapshots/`. To remove setup files that still match the repository, run `./uninstall.sh` in a terminal and confirm.
