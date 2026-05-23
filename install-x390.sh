#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           ThinkPad X390 Specific Setup                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

DOTFILES_DIR="$HOME/dotfiles"

# Install X390 specific packages
echo -e "\n${CYAN}[1/4] Installing ThinkPad X390 packages...${NC}"
sudo pacman -S --needed --noconfirm \
    tlp tlp-rdw throttled \
    thunar-volman gvfs udisks2 tumbler ffmpegthumbnailer \
    fuzzel

yay -S --needed --noconfirm auto-cpufreq

# Enable services
echo -e "\n${CYAN}[2/4] Enabling services...${NC}"
sudo systemctl enable --now tlp
sudo systemctl enable --now throttled
sudo systemctl enable --now auto-cpufreq

# Restore X390 configs
echo -e "\n${CYAN}[3/4] Restoring X390 configurations...${NC}"
[ -f "$DOTFILES_DIR/etc-x390/tlp.conf" ] && sudo cp "$DOTFILES_DIR/etc-x390/tlp.conf" /etc/
[ -f "$DOTFILES_DIR/etc-x390/throttled.conf" ] && sudo cp "$DOTFILES_DIR/etc-x390/throttled.conf" /etc/
[ -f "$DOTFILES_DIR/etc-x390/tlp.d/99-zram.conf" ] && sudo mkdir -p /etc/tlp.d && sudo cp "$DOTFILES_DIR/etc-x390/tlp.d/99-zram.conf" /etc/tlp.d/

# GRUB update if config exists
if [ -f "$DOTFILES_DIR/etc-x390/default/grub" ]; then
    sudo cp "$DOTFILES_DIR/etc-x390/default/grub" /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    echo -e "${GREEN}[OK] GRUB updated${NC}"
fi

# Create X390 helper scripts
echo -e "\n${CYAN}[4/4] Creating helper scripts...${NC}"
mkdir -p ~/.local/bin

cat > ~/.local/bin/battery-status << 'SCRIPT'
#!/bin/bash
bat0=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
bat1=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)
status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
if [ -n "$bat0" ]; then
    echo "🔋 ${bat0}% (${status})"
elif [ -n "$bat1" ]; then
    echo "🔋 ${bat1}% (${status})"
fi
SCRIPT

cat > ~/.local/bin/throttle-status << 'SCRIPT'
#!/bin/bash
systemctl is-active --quiet throttled && echo "❄️ throttled active" || echo "🔥 throttled inactive"
SCRIPT

chmod +x ~/.local/bin/battery-status ~/.local/bin/throttle-status

echo -e "\n${GREEN}✅ ThinkPad X390 setup complete!${NC}"
echo -e "${YELLOW}📝 Reboot to apply all changes.${NC}"
echo -e "${BLUE}📊 Check battery: battery-status${NC}"
echo -e "${BLUE}❄️ Check throttling: throttle-status${NC}"
echo -e "${BLUE}🔋 TLP stats: sudo tlp-stat${NC}"
