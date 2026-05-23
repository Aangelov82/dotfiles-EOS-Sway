#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     ThinkPad X390 Specific Setup - EndeavourOS            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

DOTFILES_DIR="$HOME/dotfiles"

# Check if running on ThinkPad
if ! grep -q "ThinkPad" /sys/devices/virtual/dmi/id/product_name 2>/dev/null; then
    echo -e "${RED}❌ This script is for ThinkPad X390 only!${NC}"
    exit 1
fi

# Install X390 specific packages
echo -e "\n${CYAN}[STEP 1/4] Installing ThinkPad X390 specific packages...${NC}"
X390_PACKAGES=(
    tlp tlp-rdw throttled
    thunar-volman gvfs udisks2 tumbler ffmpegthumbnailer
    fuzzel
)

sudo pacman -S --needed --noconfirm "${X390_PACKAGES[@]}"
yay -S --needed --noconfirm auto-cpufreq

# Enable services
echo -e "\n${CYAN}[STEP 2/4] Enabling services...${NC}"
sudo systemctl enable --now tlp
sudo systemctl enable --now throttled
sudo systemctl enable --now auto-cpufreq

# Restore X390 configs
echo -e "\n${CYAN}[STEP 3/4] Restoring X390 configs...${NC}"
[ -f "$DOTFILES_DIR/etc-x390/tlp.conf" ] && sudo cp "$DOTFILES_DIR/etc-x390/tlp.conf" /etc/
[ -f "$DOTFILES_DIR/etc-x390/throttled.conf" ] && sudo cp "$DOTFILES_DIR/etc-x390/throttled.conf" /etc/
[ -f "$DOTFILES_DIR/etc-x390/tlp.d/99-zram.conf" ] && sudo mkdir -p /etc/tlp.d && sudo cp "$DOTFILES_DIR/etc-x390/tlp.d/99-zram.conf" /etc/tlp.d/
[ -f "$DOTFILES_DIR/etc-x390/default/grub" ] && sudo cp "$DOTFILES_DIR/etc-x390/default/grub" /etc/default/grub && sudo grub-mkconfig -o /boot/grub/grub.cfg

# Create X390 scripts
echo -e "\n${CYAN}[STEP 4/4] Creating X390 scripts...${NC}"
mkdir -p ~/.local/bin

cat > ~/.local/bin/battery-status << 'SCRIPT'
#!/bin/bash
bat0=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
[ -n "$bat0" ] && echo "🔋 ${bat0}% (${status})"
SCRIPT

cat > ~/.local/bin/throttle-status << 'SCRIPT'
#!/bin/bash
systemctl is-active --quiet throttled && echo "❄️ throttled active" || echo "🔥 throttled inactive"
SCRIPT

chmod +x ~/.local/bin/battery-status ~/.local/bin/throttle-status

echo -e "\n${GREEN}✅ ThinkPad X390 setup complete! Reboot to apply changes.${NC}"
