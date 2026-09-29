# Kitty setup

A terminal setup with Kitty, Zsh, Starship, Neovim, and useful command-line tools for Arch Linux and Fedora. Kitty uses a translucent background with blur, the Arch Linux prompt character, and the bundled Fantasque Nerd Font.

## Install

From this directory, run:

```sh
./install.sh
```

The installer auto-detects your distribution (Arch Linux via `pacman` or Fedora via `dnf`) and uses sudo for package management, installs Zsh plugins and Starship, deploys the bundled font, copies the configurations, and sets Zsh as the login shell. It backs up any existing files it replaces under `~/.config/kitty-setup-backups/`. Internet access is needed for packages and downloads.

The installer intentionally has no modes or flags: it applies the complete setup in one run. Do not run it with `sudo`; it requests sudo only for package installation and uses your account for configuration files.

## Useful Kitty shortcuts

`Ctrl+Shift+Enter` creates a horizontal split; `Ctrl+Shift+-` creates a vertical split. Use `Ctrl+Shift+H/J/K/L` to move between panes, `Ctrl+Shift+T` for a tab, `Alt+1..9` to switch tabs, and `Ctrl+Shift+F5` to reload Kitty's config.

Use `Ctrl+Shift+A` followed by `M` or `L` to adjust background opacity on the fly.

## Restore or remove

To restore files from the most recent install backup:

```sh
./uninstall.sh --restore-latest
```

Files currently in the way are saved under `~/.config/kitty-setup-restore-snapshots/` before restoration. To remove unchanged setup files, run `./uninstall.sh` in a terminal and confirm, or use `./uninstall.sh --yes`.
