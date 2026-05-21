#!/bin/bash

# ============================================================================
# DOTFILES INSTALLER - Universal for EndeavourOS
# ============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Dotfiles Installer - EndeavourOS                ║${NC}"
echo -e "${BLUE}║                    Universal Setup                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

# Directories
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# ============================================================================
# Helper functions
# ============================================================================

backup_file() {
    local file=$1
    if [ -e "$file" ] && [ ! -L "$file" ]; then
        echo -e "${YELLOW}[BACKUP] $file -> $BACKUP_DIR${NC}"
        mkdir -p "$BACKUP_DIR/$(dirname "$file")"
        cp -r "$file" "$BACKUP_DIR/$(dirname "$file")/"
    fi
}

create_link() {
    local source=$1
    local target=$2
    
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        backup_file "$target"
        rm -rf "$target"
    elif [ -L "$target" ]; then
        rm "$target"
    fi
    
    echo -e "${GREEN}[LINK] $target -> $source${NC}"
    mkdir -p "$(dirname "$target")"
    ln -s "$source" "$target"
}

# ============================================================================
# Step 1: Detect hardware
# ============================================================================
echo -e "\n${CYAN}[STEP 1/7] Detecting hardware...${NC}"

IS_THINKPAD=false
IS_X390=false

if grep -q "ThinkPad" /sys/devices/virtual/dmi/id/product_name 2>/dev/null; then
    IS_THINKPAD=true
    echo -e "${GREEN}[DETECT] ThinkPad detected${NC}"
    
    if grep -q "X390" /sys/devices/virtual/dmi/id/product_name 2>/dev/null; then
        IS_X390=true
        echo -e "${GREEN}[DETECT] ThinkPad X390 detected${NC}"
    fi
else
    echo -e "${YELLOW}[DETECT] Non-ThinkPad system detected${NC}"
fi

# ============================================================================
# Step 2: Install yay (AUR helper)
# ============================================================================
echo -e "\n${CYAN}[STEP 2/7] Installing yay (AUR helper)...${NC}"

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
# Step 3: Install common packages
# ============================================================================
echo -e "\n${CYAN}[STEP 3/7] Installing common packages...${NC}"

# Official packages (common for all)
COMMON_PACKAGES=(
    # Shell & Terminal
    zsh
    zsh-completions
    zsh-autosuggestions
    zsh-syntax-highlighting
    
    # System & Utils
    git
    rsync
    htop
    btop
    neofetch
    
    # Audio
    pipewire
    pipewire-pulse
    wireplumber
    pavucontrol
    
    # Graphics & GUI
    qt5ct
)

sudo pacman -S --needed --noconfirm "${COMMON_PACKAGES[@]}"

# AUR packages (common for all)
COMMON_AUR_PACKAGES=(
    # Window Manager & UI
    sway
    waybar
    kitty
    mako
    swaylock
    swayidle
    
    # Screenshots & Editing
    grim
    slurp
    swappy
    
    # Applications
    thunar
    mousepad
    mpv
    
    # Portals
    xdg-desktop-portal-wlr
)

yay -S --needed --noconfirm "${COMMON_AUR_PACKAGES[@]}"

# ============================================================================
# Step 4: Install ThinkPad specific packages (optional)
# ============================================================================
if [ "$IS_THINKPAD" = true ]; then
    echo -e "\n${CYAN}[STEP 4/7] Installing ThinkPad-specific packages...${NC}"
    
    THINKPAD_PACKAGES=(
        tlp
        tlp-rdw
        throttled
    )
    
    sudo pacman -S --needed --noconfirm "${THINKPAD_PACKAGES[@]}"
    
    # Enable TLP service
    sudo systemctl enable --now tlp
    echo -e "${GREEN}[OK] TLP enabled (power management)${NC}"
    
    if [ "$IS_X390" = true ]; then
        echo -e "${GREEN}[OK] Throttled installed for X390 CPU management${NC}"
    fi
else
    echo -e "\n${YELLOW}[SKIP] ThinkPad-specific packages (not a ThinkPad)${NC}"
fi

# ============================================================================
# Step 5: Create configuration symlinks
# ============================================================================
echo -e "\n${CYAN}[STEP 5/7] Creating configuration symlinks...${NC}"

# Create required directories
mkdir -p ~/.config ~/.local/bin

# Common configuration directories
COMMON_CONFIGS=(
    "kitty"
    "mako"
    "sway"
    "waybar"
    "swappy"
    "gtk-3.0"
    "mpv"
)

for dir in "${COMMON_CONFIGS[@]}"; do
    [ -d "$DOTFILES_DIR/.config/$dir" ] && create_link "$DOTFILES_DIR/.config/$dir" "$HOME/.config/$dir"
done

# Common config files
COMMON_FILES=(
    "mimeapps.list"
    "pavucontrol.ini"
    "QtProject.conf"
)

for file in "${COMMON_FILES[@]}"; do
    [ -f "$DOTFILES_DIR/.config/$file" ] && create_link "$DOTFILES_DIR/.config/$file" "$HOME/.config/$file"
done

# Custom scripts
if [ -d "$DOTFILES_DIR/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
    cp -r "$DOTFILES_DIR/.local/bin/"* "$HOME/.local/bin/" 2>/dev/null
    chmod +x "$HOME/.local/bin/"* 2>/dev/null
    echo -e "${GREEN}[OK] Custom scripts copied${NC}"
fi

# ============================================================================
# Step 6: Restore system configurations (conditional)
# ============================================================================
echo -e "\n${CYAN}[STEP 6/7] Restoring system configurations...${NC}"

# Restore common system configs if they exist
if [ -f "$DOTFILES_DIR/etc/default/grub" ]; then
    echo -e "${YELLOW}[GRUB] Restoring GRUB configuration${NC}"
    sudo cp "$DOTFILES_DIR/etc/default/grub" /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    echo -e "${GREEN}[OK] GRUB restored${NC}"
fi

# Restore ThinkPad configs only on ThinkPad
if [ "$IS_THINKPAD" = true ]; then
    # TLP config
    if [ -f "$DOTFILES_DIR/etc/tlp.conf" ]; then
        sudo cp "$DOTFILES_DIR/etc/tlp.conf" /etc/
        echo -e "${GREEN}[OK] TLP configuration restored${NC}"
    fi
    
    # Throttled config
    if [ -f "$DOTFILES_DIR/etc/throttled.conf" ]; then
        sudo cp "$DOTFILES_DIR/etc/throttled.conf" /etc/
        echo -e "${GREEN}[OK] Throttled configuration restored${NC}"
    fi
    
    # ZRAM config (if present)
    if [ -f "$DOTFILES_DIR/etc/tlp.d/99-zram.conf" ]; then
        sudo mkdir -p /etc/tlp.d
        sudo cp "$DOTFILES_DIR/etc/tlp.d/99-zram.conf" /etc/tlp.d/
        echo -e "${GREEN}[OK] ZRAM configuration restored${NC}"
    fi
else
    echo -e "${YELLOW}[SKIP] ThinkPad-specific system configs (not a ThinkPad)${NC}"
fi

# ============================================================================
# Step 7: Setup ZSH as default shell
# ============================================================================
echo -e "\n${CYAN}[STEP 7/7] Setting up ZSH as default shell...${NC}"

if command -v zsh &> /dev/null; then
    ZSH_PATH=$(which zsh)
    
    # Add zsh to /etc/shells if not present
    if ! grep -q "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi
    
    # Change default shell if not already zsh
    if [ "$SHELL" != "$ZSH_PATH" ]; then
        echo -e "${YELLOW}[ZSH] Changing default shell to zsh${NC}"
        chsh -s "$ZSH_PATH"
        echo -e "${GREEN}[OK] Default shell changed to zsh${NC}"
        echo -e "${YELLOW}[NOTE] Log out and back in for changes to take effect${NC}"
    else
        echo -e "${GREEN}[OK] ZSH is already default shell${NC}"
    fi
fi

# ============================================================================
# Start user services
# ============================================================================
echo -e "\n${CYAN}[SERVICES] Starting user services...${NC}"
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null
echo -e "${GREEN}[OK] Audio services started${NC}"

# ============================================================================
# Final message
# ============================================================================
echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                 INSTALLATION COMPLETE!                     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"

echo -e "${YELLOW}[BACKUP] Old configs saved to: $BACKUP_DIR${NC}"

echo -e "\n${BLUE}══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                    POST-INSTALLATION NOTES                     ${NC}"
echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"

if [ "$IS_THINKPAD" = true ]; then
    echo -e " ✅ ${GREEN}ThinkPad detected${NC} - Power management (TLP) enabled"
    if [ "$IS_X390" = true ]; then
        echo -e " ✅ ${GREEN}ThinkPad X390 detected${NC} - CPU throttling fix applied"
    fi
else
    echo -e " ℹ️  ${YELLOW}Non-ThinkPad system${NC} - Power management features skipped"
fi

echo -e "\n ${GREEN}1.${NC} Restart Sway: ${GREEN}Mod+Shift+E${NC}"
echo -e " ${GREEN}2.${NC} Configure Qt5 apps: Run ${GREEN}qt5ct${NC} and select a theme"
echo -e " ${GREEN}3.${NC} For future updates: ${GREEN}cd ~/dotfiles && ./update.sh${NC}"
echo -e " ${GREEN}4.${NC} Auto-sync: Add alias to ~/.zshrc: ${GREEN}alias dotsync='~/dotfiles/smart-update.sh'${NC}"

if [ "$IS_THINKPAD" = true ]; then
    echo -e "\n ${YELLOW}⚠️  For ThinkPad users:${NC}"
    echo -e "    - TLP service is running (battery optimization)"
    echo -e "    - Check status: ${GREEN}sudo tlp-stat${NC}"
    echo -e "    - Throttled config: ${GREEN}sudo systemctl status throttled${NC}"
fi

echo -e "\n${BLUE}══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🔗 GitHub: https://github.com/Aangelov82/dotfiles-EOS-Sway${NC}"
echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}\n"
