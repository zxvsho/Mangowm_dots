#!/bin/bash
# Recibe la línea seleccionada de rofi vía {entry}, la busca en cliphist,
# y actualiza el panel de mensaje con el contenido completo.

entry="$1"

if [[ -z "$entry" ]]; then
    exit 0
fi

id=$(echo "$entry" | cut -f1)

contenido=$(cliphist decode "$id" 2>/dev/null)

if echo "$entry" | grep -q "\[\[ binary data"; then
    dimensiones=$(echo "$entry" | grep -oP '\d+x\d+')
    tipo=$(echo "$entry" | grep -oP '(png|jpg|jpeg|gif|bmp)')
    echo -en "\0message\x1fImagen ($tipo, $dimensiones) — Enter para copiar\n"
else
    contenido_escapado=$(echo "$contenido" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
    echo -en "\0message\x1f${contenido_escapado}\n"
fi
