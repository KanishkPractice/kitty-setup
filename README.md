# Kitty configuration backup

This backup contains the complete user Kitty configuration directory and the
Starship prompt configuration as they existed on 2026-08-18.

## Quick Automated Setup

To automatically install all dependencies (Kitty, Zsh, Starship, Zoxide, FZF, fonts, plugins) and deploy configurations:

```sh
chmod +x install.sh
./install.sh
```

Pass `-y` for non-interactive / automatic confirmation:
```sh
./install.sh -y
```

## Manual Restore

Then restart Kitty. The active Kitty configuration is `kitty/kitty.conf`.
`kitty/kitty.conf.bak` is an older, slightly different saved version.

The Starship prompt files are `starship.toml` and `starship.toml.bak`. Copy the
active one to `~/.config/starship.toml` on a new machine. Your Zsh setup also
needs this line in `~/.zshrc`:

```sh
eval "$(starship init zsh)"
```

Additional shell files saved here are `.zshrc`, `.bashrc`, `.bash_profile`, and
`terminal.conf`. Restore them to their original locations if you want the same
shell aliases, environment, and Kitty selection:

```sh
cp .zshrc .bashrc .bash_profile ~/
mkdir -p ~/.config/environment.d
cp terminal.conf ~/.config/environment.d/
```

The active configuration selects the `FantasqueSansM Nerd Font Mono` font. Install
that font separately on the new machine if you want the same appearance.

The referenced Zsh plugin directories are also included under `zsh/`.
The FantasqueSansM Nerd Font files are included under `fonts/`.

Install the font files with:

```sh
mkdir -p ~/.local/share/fonts
cp fonts/fantasque-sans-mono-nerd-fonts/*.ttf ~/.local/share/fonts/
fc-cache -f
```

FZF, zoxide, and Starship themselves are installed programs and should be
installed separately on the new machine.
