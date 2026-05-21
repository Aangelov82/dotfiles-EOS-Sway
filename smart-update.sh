#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOTFILES_DIR="$HOME/dotfiles"
cd "$DOTFILES_DIR" || exit 1

echo -e "${GREEN}[SCAN] Checking for new packages...${NC}"

# Detect new packages (optional feature)
CURRENT_PKGS=$(pacman -Qqe | sort)
STORED_PKGS=$(cat pkglist.txt 2>/dev/null | grep -v "^#" | sort)

NEW_PKGS=$(comm -23 <(echo "$CURRENT_PKGS") <(echo "$STORED_PKGS"))

if [ -n "$NEW_PKGS" ]; then
    echo -e "${YELLOW}[DETECTED] New packages found:${NC}"
    echo "$NEW_PKGS" | sed 's/^/  - /'
    echo ""
    read -p "Add these packages to dotfiles? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for pkg in $NEW_PKGS; do
            echo "$pkg" >> pkglist.txt
        done
        echo -e "${GREEN}[OK] Packages added to pkglist.txt${NC}"
    fi
fi

# Run normal update
./update.sh
