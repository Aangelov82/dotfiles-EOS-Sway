# Dotfiles - EndeavourOS SwayWM

Universal dotfiles configuration for EndeavourOS with SwayWM.

## Features

- **Universal** - Works on any hardware
- **ThinkPad Optimized** - Auto-detects ThinkPad X390 and applies special configs
- **Modular** - Only installs what your system needs
- **Easy Setup** - One-command installation

## Quick Install

```bash
# Clone the repository
git clone https://github.com/Aangelov82/dotfiles-EOS-Sway.git ~/dotfiles

# Run installer
cd ~/dotfiles && ./install.sh
What it does
Detects your hardware (ThinkPad or generic)

Installs common packages (SwayWM, Waybar, Kitty, etc.)

Installs ThinkPad-specific packages only if needed (TLP, throttled)

Creates configuration symlinks

Sets up ZSH as default shell

Post-Installation
Restart Sway: Mod+Shift+E

Configure Qt5 apps: Run qt5ct

For updates: cd ~/dotfiles && ./update.sh

Hardware Detection
Generic PC: Only common packages

ThinkPad: Adds TLP (power management)

ThinkPad X390: Adds throttled (CPU management)

Directory Structure
text
dotfiles/
├── .config/           # User configurations
├── .local/bin/        # Custom scripts
├── etc/               # System configs (optional)
├── install.sh         # Main installer
├── update.sh          # Upload changes
├── smart-update.sh    # Auto-detect new packages
└── README.md
Manual Sync
After making changes:

bash
cd ~/dotfiles && ./update.sh
License
MIT - Free to use and modify

## Installation Options

### Base Installation (for any system)
```bash
git clone https://github.com/Aangelov82/dotfiles-EOS-Sway.git ~/dotfiles
cd ~/dotfiles && ./install.sh
ThinkPad X390 Full Setup
bash
# First install base
./install.sh

# Then add X390 specific features
./install-x390.sh
What Each Script Does
install.sh (Base)
Core packages (Sway, Waybar, Kitty, etc.)

Basic configuration symlinks

ZSH setup

Audio services

install-x390.sh (ThinkPad X390 only)
TLP (battery optimization)

throttled (CPU fix)

ZRAM (compressed swap)

File manager extensions (thumbnails, GVFS)

brightnessctl, fuzzel

X390 specific config overrides

Hardware Detection
The base installer works on any hardware.
Run install-x390.sh ONLY on ThinkPad X390 for full optimization.
