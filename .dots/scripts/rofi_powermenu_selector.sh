#!/bin/bash
SCRIPT_DIR="$HOME/.dots/scripts"
estado_file="$HOME/.config/rofi/powermenu_activo"

opciones=""
for s in {1..5}; do
    opciones="${opciones}Style ${s}\n"
done

eleccion=$(echo -e "$opciones" | rofi -dmenu -i -p "Elige el powermenu:" -theme ~/.config/rofi/launchers/selector_menu/style.rasi)

if [[ -z "$eleccion" ]]; then
    bash "$SCRIPT_DIR/rofi_style_selector.sh"
    exit 0
fi

estilo=$(echo "$eleccion" | grep -oP 'Style \K[0-9]+')
echo "style${estilo}" > "$estado_file"
