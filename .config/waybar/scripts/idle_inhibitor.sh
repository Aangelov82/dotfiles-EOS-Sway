#!/bin/bash
# Проверява дали има файл-индикатор за инхибиране
if [ -f /tmp/swayidle_inhibit ]; then
    echo "{\"icon\":\"activated\",\"text\":\"Inhibited\",\"tooltip\":\"Idle inhibitor is ACTIVE\\nClick to disable\"}"
else
    echo "{\"icon\":\"deactivated\",\"text\":\"\",\"tooltip\":\"Idle inhibitor is INACTIVE\\nClick to enable\"}"
fi
