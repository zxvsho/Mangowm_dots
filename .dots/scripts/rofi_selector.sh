#!/bin/bash
SCRIPT_DIR="$HOME/.dots/scripts"
estado_file="$HOME/.config/rofi/launcher_activo"
opciones=""
for s in {1..4}; do
    opciones="${opciones}Type 1 - Style ${s}\n"
done
for s in {1..4}; do
    opciones="${opciones}Type 2 - Style ${s}\n"
done
for s in {1..4}; do
    opciones="${opciones}Type 3 - Style ${s}\n"
done
for s in {1..4}; do
    opciones="${opciones}Type 4 - Style ${s}\n"
done
eleccion=$(echo -e "$opciones" | rofi -dmenu -i -p "Elige el launcher:" -theme ~/.config/rofi/launchers/selector_menu/style.rasi)

if [[ -z "$eleccion" ]]; then
    bash "$SCRIPT_DIR/rofi_style_selector.sh"
    exit 0
fi

tipo=$(echo "$eleccion" | grep -oP "Type \K[0-9]+")
estilo=$(echo "$eleccion" | grep -oP "Style \K[0-9]+")
echo "type${tipo}/style${estilo}" > "$estado_file"
