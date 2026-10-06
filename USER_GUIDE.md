# Quick reference

Install the complete setup by running `./install.sh` from this directory. It checks whether Arch Linux (`pacman`) or Fedora (`dnf`) is present, prompts for confirmation before executing actions, installs packages, fonts, shell plugins, and configuration files, and sets Zsh as the login shell (use `-y` or `--yes` to auto-confirm). Existing files replaced by the installer are backed up in `~/.config/kitty-setup-backups/`.

## Kitty

The terminal background features a borderless frosted-glass look (0.85 opacity with 32 blur), a floating rounded pill tab bar, animated cursor trails, and Fantasque Sans Mono Nerd Font Mono at 17 pt (with modern font alternatives commented in `kitty.conf`). Starship uses a right-facing arrow for both successful and failed commands. Adjust opacity on the fly using `Ctrl+Shift+A` then `M` (increase), `L` (decrease), `D` (default), or `1` (solid).

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
| `Ctrl+Shift+S` / `F8` | Open terminal scrollback in Neovim (press `q` to exit) |
| `Ctrl+Shift+Alt+T` | Interactive live theme switcher overlay |
| `Ctrl+Shift+F` | Aesthetic floating FZF file finder overlay |
| `Ctrl+Shift+Alt+G` | Show last command output in a pager |
| `Ctrl+Shift+U` | Pick a URL from terminal output |
| `Ctrl+Shift+E` | Pick a path and open it in Neovim |
| `Ctrl+Shift+A > M/L` | Increase / decrease background opacity |

## Shell & CLI Features

* **Interactive Tab Completion (`fzf-tab`)**: Press `Tab` on `cd`, `git`, or flags to open floating fuzzy search popups with live directory and syntax previews.
* **Neovim Scrollback Pager**: Press `Ctrl+Shift+S` to dump terminal history directly into Neovim with full colors, search (`/`), and visual selection (`q` exits).
* **Smart Tab Bar Visibility**: Change `tab_bar_min_tabs 1` (always-on dock) to `2` in `~/.config/kitty/kitty.conf` to auto-hide the pill bar until a second tab is created.
* **Seamless Remote SSH (`kssh`)**: Use `kssh user@host` (or `kitten ssh`) to automatically sync Kitty terminfo and enable clipboard forwarding on remote machines.
* **Inline Image & Media Rendering**: Use `icat <image>` or `img <image>` to render high-res images directly in the terminal, or click any image link to preview in an overlay.

## Backups

Restore the latest install backup with `./uninstall.sh --restore-latest`. Any existing files replaced during restore are saved under `~/.config/kitty-setup-restore-snapshots/`. To remove setup files that still match the repository, run `./uninstall.sh` in a terminal and confirm.
