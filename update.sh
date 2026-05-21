#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOTFILES_DIR="$HOME/dotfiles"
cd "$DOTFILES_DIR" || exit 1

echo -e "${GREEN}[SYNC] Uploading changes to GitHub...${NC}"

# Sync configs
cp -r ~/.config/kitty "$DOTFILES_DIR/.config/" 2>/dev/null
cp -r ~/.config/mako "$DOTFILES_DIR/.config/" 2>/dev/null
cp -r ~/.config/sway "$DOTFILES_DIR/.config/" 2>/dev/null
cp -r ~/.config/waybar "$DOTFILES_DIR/.config/" 2>/dev/null
cp -r ~/.config/swappy "$DOTFILES_DIR/.config/" 2>/dev/null
cp -r ~/.config/gtk-3.0 "$DOTFILES_DIR/.config/" 2>/dev/null
cp -r ~/.config/mpv "$DOTFILES_DIR/.config/" 2>/dev/null

# Sync config files
cp ~/.config/mimeapps.list "$DOTFILES_DIR/.config/" 2>/dev/null
cp ~/.config/pavucontrol.ini "$DOTFILES_DIR/.config/" 2>/dev/null
cp ~/.config/QtProject.conf "$DOTFILES_DIR/.config/" 2>/dev/null

# Sync scripts
if [ -d ~/.local/bin ]; then
    mkdir -p "$DOTFILES_DIR/.local/bin"
    cp -r ~/.local/bin/* "$DOTFILES_DIR/.local/bin/" 2>/dev/null
fi

# Git operations
git add .
git commit -m "Update dotfiles: $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main

echo -e "${GREEN}[OK] Changes uploaded to GitHub${NC}"
