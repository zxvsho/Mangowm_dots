#!/bin/bash

theme_actual="$HOME/.config/rofi/launchers/type-7/style-matugen-base.rasi"

opciones="🎨 Tema (Claro/Oscuro)\n🚀 Launcher (Type/Style)\n⏻ Powermenu (Type/Style)"
eleccion=$(echo -e "$opciones" | rofi -dmenu -i -p "Configurar Rofi:" -theme "$theme_actual")

case "$eleccion" in
    "🎨 Tema (Claro/Oscuro)")
        bash ~/.dots/scripts/rofi_tema.sh
        ;;
    "🚀 Launcher (Type/Style)")
        bash ~/.dots/scripts/rofi_selector.sh
        ;;
    "⏻ Powermenu (Type/Style)")
        bash ~/.dots/scripts/rofi_powermenu_selector.sh
        ;;
esac
