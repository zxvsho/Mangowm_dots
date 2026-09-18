#!/bin/bash
opciones="Style"
eleccion=$(echo -e "$opciones" | rofi -dmenu -i -p "Menu:" -theme ~/.config/rofi/launchers/selector_menu/style.rasi)
case "$eleccion" in
    "Style")
        "$HOME/.dots/scripts/rofi_style_selector.sh"
        ;;
esac
