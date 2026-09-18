#!/bin/bash
# screenshot.sh — captura → portapapeles → pregunta si guardar
# Uso: screenshot.sh [region|full]

set -u

# Ruta: ~/Imágenes/Screenshot (la crea si no existe)
DIR="$(xdg-user-dir PICTURES 2>/dev/null)"
[[ -z "$DIR" || "$DIR" == "$HOME" ]] && DIR="$HOME/Imágenes"
DIR="$DIR/Screenshot"

TMP="/tmp/captura-$$.png"

# 1. Capturar
if [[ "${1:-region}" == "full" ]]; then
    grim "$TMP" || { rm -f "$TMP"; exit 1; }
else
    grim -g "$(slurp)" "$TMP" || { rm -f "$TMP"; exit 1; }  # ESC = cancelar todo
fi

# 2. Al portapapeles SIEMPRE
wl-copy --type image/png < "$TMP"
notify-send "📸 Captura guardada en el portapapeles" "Walker → ':' para ver el historial" -t 2000

# 3. ★★★ AQUÍ PREGUNTA ★★★
# Se abre Walker en modo dmenu con DOS opciones.
# Eliges con flechas + Enter. Si cierras con ESC = solo portapapeles.
eleccion=$(printf 'Guardar también en disco\nSolo portapapeles' | walker -dmenu -p "Captura" 2>/dev/null)

if [[ "$eleccion" == "Guardar también en disco" ]]; then
    mkdir -p "$DIR"
    base="$DIR/captura-$(date +%Y%m%d-%H%M%S)"
    dest="$base.png"
    n=1
    while [[ -e "$dest" ]]; do
        dest="$base-$n.png"
        n=$((n + 1))
    done
    mv "$TMP" "$dest"
    notify-send "💾 Guardada" "$dest" -t 3000
else
    rm -f "$TMP"   # se queda solo en portapapeles / historial de Walker
fi
exit 0
