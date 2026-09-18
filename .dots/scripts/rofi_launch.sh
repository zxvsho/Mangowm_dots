#!/bin/bash
estado_file="$HOME/.config/rofi/launcher_activo"
rasi_final="/tmp/rofi-launcher-final.rasi"

if [[ ! -f "$estado_file" ]]; then
    echo "type1/style1" > "$estado_file"
fi

estado=$(cat "$estado_file")
estilo=$(echo "$estado" | cut -d"/" -f2)

if [[ "$estado" == type1/* ]]; then
    rasi_final="$HOME/.config/rofi/launchers/type1/${estilo}.rasi"

elif [[ "$estado" == type2/* ]]; then
    rasi_final="$HOME/.config/rofi/launchers/type2/${estilo}.rasi"

elif [[ "$estado" == type3/* ]]; then
    rasi_final="$HOME/.config/rofi/launchers/type3/${estilo}.rasi"

elif [[ "$estado" == type4/* ]]; then
    rasi_final="$HOME/.config/rofi/launchers/type4/${estilo}.rasi"
fi

rofi -show drun -theme "$rasi_final"
