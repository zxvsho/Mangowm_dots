#!/bin/bash
SCRIPT_DIR="$HOME/.dots/scripts"
themes=$(tinty list 2>/dev/null)

if [[ -z "$themes" ]]; then
    echo "No se pudieron listar los temas de Tinty." >&2
    exit 1
fi

choice=$(echo "$themes" | rofi -dmenu -p "Tema Tinty" -theme ~/.config/rofi/launchers/selector_menu/style.rasi)

if [[ -z "$choice" ]]; then
    bash "$SCRIPT_DIR/rofi_style_selector.sh"
    exit 0
fi

~/.dots/scripts/color-engine.sh set-theme "$choice"
