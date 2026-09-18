#!/bin/bash

# Asegurar que el pipe exista antes de enviar datos
PIPE="/tmp/wobpipe"
[ -p "$PIPE" ] || exit 0

case "$1" in
    up)
        # Sube 5% con límite máximo de 100% (1.0)
        wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
        ;;
    down)
        # Baja 5%
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        ;;
    mute)
        # Alterna silenciar/desilenciar
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
esac

# Verificar si está en Mute
is_muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c "MUTED")

if [ "$is_muted" -eq 1 ]; then
    echo 0 > "$PIPE"
else
    # Extraer el decimal de wpctl (ej. 0.45), multiplicarlo por 100 y enviarlo a wob
    vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
    echo "$vol" > "$PIPE"
fi
