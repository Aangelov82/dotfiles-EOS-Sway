#!/bin/bash

if pgrep -x "swayidle" > /dev/null; then
    # Ако работи – спираме го (инхибираме заключването)
    pkill swayidle
    notify-send "Idle inhibitor" "Enabled - screen will NOT lock automatically"
else
    # Ако не работи – стартираме го отново (възстановяваме заключването)
    nohup swayidle -w timeout 300 'swaylock --screenshots --clock --effect-blur 7x5 --effect-vignette 0.5:0.5 --indicator' > /dev/null 2>&1 &
    notify-send "Idle inhibitor" "Disabled - screen will lock after 5 minutes"
fi