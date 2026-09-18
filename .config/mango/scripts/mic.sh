#!/bin/bash

PIPE="/tmp/wobpipe"

# 1. Alternar estado del micrófono en PipeWire
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# 2. Verificar si quedó muteado
is_muted=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -c "MUTED")

# 3. Enviar confirmación visual a WOB
if [ "$is_muted" -eq 1 ]; then
    echo 0 > "$PIPE"
else
    mic_vol=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print int($2 * 100)}')
    echo "$mic_vol" > "$PIPE"
fi
