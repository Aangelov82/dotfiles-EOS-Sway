#!/bin/bash

# Проверка за активен външен монитор
EXTERNAL_MONITOR=$(swaymsg -t get_outputs | jq -r '.[] | select(.name != "eDP-1" and .active == true) | .name')

# Проверка за захранване
AC_POWER=0
for supply in /sys/class/power_supply/*/online; do
    if [ -f "$supply" ] && [ "$(cat "$supply")" = "1" ]; then
        AC_POWER=1
        break
    fi
done

if [[ -n "$EXTERNAL_MONITOR" || "$AC_POWER" == "1" ]]; then
    # НА БЮРО – само заключване
    exec swaylock --screenshots --clock --effect-blur 7x5 --effect-vignette 0.5:0.5 --indicator
else
    # НАВЪН – заключване + изгасване
    exec swaylock --screenshots --clock --effect-blur 7x5 --effect-vignette 0.5:0.5 --indicator
    sleep 1
    exec swaymsg "output * power off"
fi