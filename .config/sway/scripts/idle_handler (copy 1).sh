#!/bin/bash

# === ПРОВЕРКА ЗА СЦЕНАРИЙ ===
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

# === ДЕЙСТВИЕ СПОРЕД СЦЕНАРИЯ ===
if [[ -n "$EXTERNAL_MONITOR" || "$AC_POWER" == "1" ]]; then
    # НА БЮРО (външен монитор ИЛИ захранване) – само заключване
    swaylock --screenshots --clock --effect-blur 7x5 --effect-vignette 0.5:0.5 --indicator
else
    # НАВЪН (само лаптоп, на батерия) – заключване + изгасване
    swaylock --screenshots --clock --effect-blur 7x5 --effect-vignette 0.5:0.5 --indicator
    sleep 1
    swaymsg "output * power off"
fi