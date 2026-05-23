#!/bin/bash

# Проверка за външен монитор
EXTERNAL_MONITOR=$(swaymsg -t get_outputs | jq -r '.[] | select(.name != "eDP-1") | .name')

# Проверка за каквото и да е захранване (AC или USB-C)
AC_POWER=0
for supply in /sys/class/power_supply/*/online; do
    if [ -f "$supply" ] && [ "$(cat "$supply")" = "1" ]; then
        AC_POWER=1
        break
    fi
done

if [[ -n "$EXTERNAL_MONITOR" || "$AC_POWER" == "1" ]]; then
    swaymsg output eDP-1 disable
else
    systemctl suspend
fi