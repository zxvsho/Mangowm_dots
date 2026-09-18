#!/bin/bash
# Uso: desaturate-color.sh HEXCOLOR FACTOR
# FACTOR entre 0 (sin cambio) y 100 (gris total)
hex="$1"
factor="${2:-30}"

r=$((16#${hex:0:2}))
g=$((16#${hex:2:2}))
b=$((16#${hex:4:2}))

gray=$(( (r*30 + g*59 + b*11) / 100 ))

new_r=$(( r + (gray - r) * factor / 100 ))
new_g=$(( g + (gray - g) * factor / 100 ))
new_b=$(( b + (gray - b) * factor / 100 ))

printf '%02x%02x%02x' "$new_r" "$new_g" "$new_b"
