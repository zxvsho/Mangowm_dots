#!/bin/bash

CACHE_DIR="$HOME/.cache/cliphist_thumbs"
mkdir -p "$CACHE_DIR"

# Limpiar miniaturas viejas (más de 1 día) para no acumular basura
find "$CACHE_DIR" -type f -mtime +1 -delete 2>/dev/null

build_menu() {
    while IFS=$'\t' read -r id rest; do
        line="$id	$rest"
        if echo "$rest" | grep -q "binary data"; then
            thumb="$CACHE_DIR/$id.png"
            if [ ! -f "$thumb" ]; then
                echo "$line" | cliphist decode > "$thumb" 2>/dev/null
            fi
            printf '%s\0icon\x1f%s\n' "$line" "$thumb"
        else
            printf '%s\n' "$line"
        fi
    done < <(cliphist list)
}

selected=$(build_menu | rofi -dmenu -i -p "Portapapeles:" -show-icons)

if [ -n "$selected" ]; then
    echo "$selected" | cliphist decode | wl-copy
fi
