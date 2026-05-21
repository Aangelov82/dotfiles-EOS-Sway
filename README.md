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
