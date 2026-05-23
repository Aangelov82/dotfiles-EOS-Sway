#!/bin/bash
INHIBIT_FILE="/tmp/swayidle_inhibit"

if [ -f "$INHIBIT_FILE" ]; then
    rm -f "$INHIBIT_FILE"
    pkill -f "swayidle -w"
    nohup swayidle -w timeout 300 'swaylock -f' timeout 600 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' > /dev/null 2>&1 &
    notify-send "Idle inhibitor" "OFF - Screen will lock after 5 minutes"
else
    touch "$INHIBIT_FILE"
    pkill -f "swayidle -w"
    notify-send "Idle inhibitor" "ON - Screen will NOT lock automatically"
fi