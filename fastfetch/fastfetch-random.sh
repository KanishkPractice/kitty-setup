#!/usr/bin/env bash
# ── Fastfetch Aesthetic Art Gallery Randomizer ──
GALLERY_DIR="$HOME/.config/fastfetch/art_gallery"

if [ -n "$1" ] && [ -f "$GALLERY_DIR/$1" ]; then
    IMG="$GALLERY_DIR/$1"
    shift
elif [ -n "$1" ] && [ -f "$1" ]; then
    IMG="$1"
    shift
elif [ "$1" = "fedora" ]; then
    IMG="$HOME/.config/fastfetch/logos/fedora_neon.png"
    shift
elif [ "$1" = "cyber" ] || [ "$1" = "oni" ]; then
    IMG="$HOME/.config/fastfetch/logos/cyber_oni.png"
    shift
elif [ "$1" = "shellder" ]; then
    IMG="$HOME/.config/fastfetch/logos/shellder.png"
    shift
elif [ -d "$GALLERY_DIR" ]; then
    IMG=$(find "$GALLERY_DIR" -maxdepth 1 -type f -name "*.png" 2>/dev/null | shuf -n 1)
else
    IMG="$HOME/.config/fastfetch/logos/fedora_neon.png"
fi

if [ -f "$IMG" ]; then
    exec fastfetch --kitty "$IMG" --logo-width 28 --logo-height 14 "$@"
else
    exec fastfetch "$@"
fi
