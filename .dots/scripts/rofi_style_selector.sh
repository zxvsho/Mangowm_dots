#!/bin/bash
SCRIPT_DIR="$HOME/.dots/scripts"
opciones="Engine\nTheme\nLauncher\nPowermenu\nFont"
eleccion=$(echo -e "$opciones" | rofi -dmenu -i -p "Style:" -theme ~/.config/rofi/launchers/selector_menu/style.rasi)

if [[ -z "$eleccion" ]]; then
    bash "$SCRIPT_DIR/rofi_menu_selector.sh"
    exit 0
fi

case "$eleccion" in
    "Engine")
        "$SCRIPT_DIR/color-engine-selector.sh"
        ;;
    "Theme")
        "$SCRIPT_DIR/tinty-theme-selector.sh"
        ;;
    "Launcher")
        "$SCRIPT_DIR/rofi_selector.sh"
        ;;
    "Powermenu")
        "$SCRIPT_DIR/rofi_powermenu_selector.sh"
        ;;
    "Font")
        "$SCRIPT_DIR/Style/Fonts/set-font.sh"
        ;;
esac
