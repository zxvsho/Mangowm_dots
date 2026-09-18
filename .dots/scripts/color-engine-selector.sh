#!/bin/bash
SCRIPT_DIR="$HOME/.dots/scripts"
choice=$(printf "matugen\ntinty\n" | rofi -dmenu -p "Motor de color" -theme ~/.config/rofi/launchers/selector_menu/style.rasi)

if [[ -z "$choice" ]]; then
    bash "$SCRIPT_DIR/rofi_style_selector.sh"
    exit 0
fi

~/.dots/scripts/color-engine.sh set "$choice"
