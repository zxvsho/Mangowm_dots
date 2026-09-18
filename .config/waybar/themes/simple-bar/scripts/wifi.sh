#!/bin/bash
# Muestra un icono Nerd Font según el estado de iwd en wlan0.

IFACE="wlan0"

state=$(iwctl station "$IFACE" show 2>/dev/null | grep -iE '^\s+State' | awk '{print $NF}')

case "$state" in
    connected|connecting)
        printf '\U000F0928\n'
        ;;
    disconnected|*)
        printf '\U000F092D\n'
        ;;
esac
