#!/bin/bash
STATE_DIR="$HOME/.config/color-engine"
ACTIVE_FILE="$STATE_DIR/active"

ENGINE="matugen"
if [ -f "$ACTIVE_FILE" ]; then
    ENGINE=$(head -n1 "$ACTIVE_FILE" 2>/dev/null | tr -d '[:space:]')
fi

if [ "$ENGINE" = "tinty" ]; then
    bash ~/.dots/scripts/color-engine.sh apply
else
    fondo=$(awk -F '=' '/^wallpaper[[:space:]]*=/ {print $2; exit}' ~/.config/waypaper/config.ini | tr -d ' ')
    fondo="${fondo/#\~/$HOME}"
    bash ~/.config/waypaper/cambio_color.sh "$fondo"
fi
