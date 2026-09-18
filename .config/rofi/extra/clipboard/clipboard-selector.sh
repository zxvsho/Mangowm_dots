#!/bin/bash
# Selector de portapapeles — integrado con theme-engine
# ESC: cierra sin copiar | ENTER: copia y cierra

set -euo pipefail

CLIPHIST_MAX=30
ROFI_THEME="$HOME/.config/rofi/extra/clipboard/clipboard-theme/style.rasi"
PREVIEW_SCRIPT="$HOME/.config/rofi/extra/clipboard/clipboard-preview.sh"

for cmd in cliphist wl-copy rofi; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd no está instalado" >&2
        exit 1
    fi
done

if [[ ! -f "$ROFI_THEME" ]]; then
    echo "Error: tema no encontrado en $ROFI_THEME" >&2
    exit 1
fi

HISTORIAL=$(cliphist list 2>/dev/null | head -n "$CLIPHIST_MAX")

if [[ -z "$HISTORIAL" ]]; then
    notify-send "Portapapeles" "El historial está vacío" 2>/dev/null || true
    exit 0
fi

SELECCION=$(echo "$HISTORIAL" | rofi -dmenu \
    -theme "$ROFI_THEME" \
    -no-custom \
    -on-selection-changed "$PREVIEW_SCRIPT {entry}" \
    2>/dev/null) || true

if [[ -z "$SELECCION" ]]; then
    exit 0
fi

ID=$(echo "$SELECCION" | cut -f1)

if cliphist decode "$ID" | wl-copy 2>/dev/null; then
    notify-send "Copiado" "Elemento en el portapapeles" -t 1500 -a "clipboard-selector" 2>/dev/null || true
fi

exit 0
