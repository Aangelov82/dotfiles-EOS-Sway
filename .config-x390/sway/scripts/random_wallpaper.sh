#!/usr/bin/env bash

# Директория с тапетите
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Спираме всички текущи инстанции на swaybg
killall swaybg 2>/dev/null

# Избира произволна снимка
NEW_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)

# Ако е намерена снимка, стартираме нов swaybg
if [ -n "$NEW_WALLPAPER" ]; then
    swaybg -i "$NEW_WALLPAPER" -m fill &
else
    echo "Грешка: Няма намерени изображения в $WALLPAPER_DIR"
fi
