#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Base Dotfiles Installer - EndeavourOS           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

DOTFILES_DIR="$HOME/dotfiles"

# ============================================================================
# Install yay (AUR helper)
# ============================================================================
echo -e "\n${CYAN}[STEP 1/5] Installing yay (AUR helper)...${NC}"
if ! command -v yay &> /dev/null; then
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    cd ~
    echo -e "${GREEN}[OK] yay installed${NC}"
else
    echo -e "${GREEN}[OK] yay already installed${NC}"
fi

# ============================================================================
# Base packages
# ============================================================================
echo -e "\n${CYAN}[STEP 2/5] Installing base packages...${NC}"

BASE_PACKAGES=(
    zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting
    git rsync htop btop neofetch
    pipewire pipewire-pulse wireplumber pavucontrol pulseaudio-utils
    sway waybar kitty mako swaylock swayidle wofi
    grim slurp swappy
    thunar mousepad mpv
    xdg-desktop-portal-wlr polkit-gnome network-manager-applet
    brightnessctl qt5ct
)

sudo pacman -S --needed --noconfirm "${BASE_PACKAGES[@]}"

# ============================================================================
# AUR packages
# ============================================================================
echo -e "\n${CYAN}[STEP 3/5] Installing AUR packages...${NC}"
AUR_PACKAGES=(autotiling)
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"

# ============================================================================
# Create symlinks
# ============================================================================
echo -e "\n${CYAN}[STEP 4/5] Creating configuration symlinks...${NC}"
mkdir -p ~/.config ~/.local/bin

for dir in sway waybar kitty mako swappy gtk-3.0 mpv; do
    [ -d "$DOTFILES_DIR/.config/$dir" ] && ln -sf "$DOTFILES_DIR/.config/$dir" ~/.config/
done

for file in mimeapps.list pavucontrol.ini QtProject.conf; do
    [ -f "$DOTFILES_DIR/.config/$file" ] && ln -sf "$DOTFILES_DIR/.config/$file" ~/.config/
done

[ -d "$DOTFILES_DIR/.local/bin" ] && cp -r "$DOTFILES_DIR/.local/bin"/* ~/.local/bin/ 2>/dev/null
chmod +x ~/.local/bin/* 2>/dev/null

# ============================================================================
# Setup ZSH
# ============================================================================
echo -e "\n${CYAN}[STEP 5/5] Setting up ZSH...${NC}"
if command -v zsh &> /dev/null; then
    ZSH_PATH=$(which zsh)
    if ! grep -q "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi
    if [ "$SHELL" != "$ZSH_PATH" ]; then
        chsh -s "$ZSH_PATH"
        echo -e "${GREEN}[OK] Default shell changed to zsh (logout required)${NC}"
    fi
fi

# Start services
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null

echo -e "\n${GREEN}✅ Base installation complete!${NC}"

# Auto-detect ThinkPad X390
if [ -f /sys/devices/virtual/dmi/id/product_name ]; then
    PRODUCT=$(cat /sys/devices/virtual/dmi/id/product_name)
    if echo "$PRODUCT" | grep -qi "ThinkPad X390"; then
        echo -e "\n${GREEN}========================================${NC}"
        echo -e "${GREEN}✅ ThinkPad X390 Detected!${NC}"
        echo -e "${GREEN}========================================${NC}"
        if [ -f "$DOTFILES_DIR/install-x390.sh" ]; then
            "$DOTFILES_DIR/install-x390.sh"
        else
            echo -e "${RED}❌ install-x390.sh not found!${NC}"
        fi
    fi
fi
