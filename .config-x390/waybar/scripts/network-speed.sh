#!/bin/bash

# Автоматично откриване на активния мрежов интерфейс
get_active_interface() {
    # Търси интерфейс, който е UP и има трафик (не loopback)
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        if [[ -f /sys/class/net/$iface/operstate ]] && \
           [[ "$(cat /sys/class/net/$iface/operstate)" == "up" ]]; then
            # Провери дали има предадени/приети байтове (не е нула)
            RX=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null)
            if [[ $RX -gt 1000 ]]; then
                echo "$iface"
                return 0
            fi
        fi
    done
    return 1
}

# Вземи активния интерфейс
INTERFACE=$(get_active_interface)

# Ако няма активен интерфейс (напр. без мрежа)
if [[ -z "$INTERFACE" ]]; then
    echo "🌐 No connection"
    exit 0
fi

# Четем текущите байтове
RX1=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX1=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
sleep 1
RX2=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX2=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

# Изчисляваме разликата (bytes/sec)
RX_DIFF=$((RX2 - RX1))
TX_DIFF=$((TX2 - TX1))

# Функция за конвертиране в човешки формат (B/s, KB/s, MB/s)
convert() {
    local bytes=$1
    if [ $bytes -ge 1048576 ]; then
        echo "$(echo "scale=1; $bytes/1048576" | bc) MB/s"
    elif [ $bytes -ge 1024 ]; then
        echo "$(echo "scale=0; $bytes/1024" | bc) KB/s"
    else
        echo "${bytes} B/s"
    fi
}

# Конвертиране на стойностите
DOWN=$(convert $RX_DIFF)
UP=$(convert $TX_DIFF)

echo "↓ $DOWN ↑ $UP"