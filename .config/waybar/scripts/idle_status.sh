#!/bin/bash
if [ -f /tmp/swayidle_inhibit ]; then
    echo "󰌾"   # Икона за активиран (заключване)
else
    echo "󰌿"   # Икона за деактивиран (нормален режим)
fi
