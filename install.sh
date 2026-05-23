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
# Base packages (required for any system)
# ============================================================================
echo -e "\n${CYAN}[STEP 1/4] Installing base packages...${NC}"

BASE_PACKAGES=(
    # Shell & Terminal
    zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting
    
    # Core system
    git rsync htop btop neofetch
    
    # Audio
    pipewire pipewire-pulse wireplumber pavucontrol
    
    # Sway & Wayland
    sway waybar kitty mako swaylock swayidle
    
    # Screenshots
    grim slurp swappy
    
    # File management (basic)
    thunar mousepad mpv
    
    # Portals
    xdg-desktop-portal-wlr
    
    # Qt5
    qt5ct
)

sudo pacman -S --needed --noconfirm "${BASE_PACKAGES[@]}"

# Install yay if not present
if ! command -v yay &> /dev/null; then
    echo -e "${YELLOW}Installing yay (AUR helper)...${NC}"
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    cd ~
fi

# ============================================================================
# Create symlinks
# ============================================================================
echo -e "\n${CYAN}[STEP 2/4] Creating configuration symlinks...${NC}"

mkdir -p ~/.config ~/.local/bin

# Base configs
for dir in sway waybar kitty mako swappy gtk-3.0 mpv; do
    [ -d "$DOTFILES_DIR/.config/$dir" ] && ln -sf "$DOTFILES_DIR/.config/$dir" ~/.config/
done

# Base files
for file in mimeapps.list pavucontrol.ini QtProject.conf; do
    [ -f "$DOTFILES_DIR/.config/$file" ] && ln -sf "$DOTFILES_DIR/.config/$file" ~/.config/
done

# Scripts
[ -d "$DOTFILES_DIR/.local/bin" ] && cp -r "$DOTFILES_DIR/.local/bin"/* ~/.local/bin/ 2>/dev/null

# ============================================================================
# Setup ZSH
# ============================================================================
echo -e "\n${CYAN}[STEP 3/4] Setting up ZSH...${NC}"

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

# ============================================================================
# Start services
# ============================================================================
echo -e "\n${CYAN}[STEP 4/4] Starting user services...${NC}"
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null

echo -e "\n${GREEN}✅ Base installation complete!${NC}"
echo -e "${YELLOW}📝 For ThinkPad X390 specific setup, run: ./install-x390.sh${NC}"
echo -e "${BLUE}🔗 GitHub: https://github.com/Aangelov82/dotfiles-EOS-Sway${NC}\n"
