#!/bin/bash

# 1. Extraemos la ruta exacta del fondo que está usando Waypaper actualmente
WALLPAPER=$(sed -n 's/^wallpaper = //p' ~/.config/waypaper/config.ini)

# 2. Ejecutamos swaylock con esa imagen (y le agregamos reloj e indicador visual)
swaylock \
    --image "$WALLPAPER" \
    --scaling fill \
    --clock \
    --indicator \
    --indicator-radius 100 \
    --indicator-thickness 7 \
    --ring-color 4c566a \
    --key-hl-color 88c0d0 \
    --text-color eceff4 \
    --inside-color 2e344088 \
    --inside-clear-color 81a1c188
