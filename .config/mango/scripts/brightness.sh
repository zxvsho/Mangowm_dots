#!/bin/bash

PIPE="/tmp/wobpipe"
[ -p "$PIPE" ] || exit 0

case "$1" in
    up)
        # Sube el brillo un 5%
        brightnessctl set 5%+
        ;;
    down)
        # Baja el brillo un 5% (mínimo 1% para no apagar la pantalla a oscuras)
        brightnessctl set 5%- -n 1
        ;;
esac

# Extraer el porcentaje actual de brillo
brillo=$(brightnessctl -m | awk -F, '{print $4}' | tr -d '%')

# Enviar el número limpio a wob
echo "$brillo" > "$PIPE"
