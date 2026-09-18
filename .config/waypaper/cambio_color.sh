#!/bin/bash
# === GUARD DE MOTOR DE COLOR ===
STATE_DIR="$HOME/.config/color-engine"
ACTIVE_FILE="$STATE_DIR/active"
LAST_WALLPAPER_FILE="$STATE_DIR/last-wallpaper"
mkdir -p "$STATE_DIR"

if [ -n "$1" ]; then
    printf '%s\n' "$1" > "$LAST_WALLPAPER_FILE"
fi

if [ -f "$ACTIVE_FILE" ]; then
    ENGINE=$(head -n1 "$ACTIVE_FILE" 2>/dev/null | tr -d '[:space:]')
    if [ -n "$ENGINE" ] && [ "$ENGINE" != "matugen" ]; then
        exit 0
    fi
fi
# === FIN GUARD ===

echo "=== $(date) ===" >> /tmp/cambio_color.log
echo "Argumento: '$1'" >> /tmp/cambio_color.log

# === TODO SIEMPRE MODO DARK ===
matugen image "$1" --mode dark --type scheme-vibrant --source-color-index 0 --contrast 0.6 -c ~/.config/matugen/config-foot-dark.toml >> /tmp/cambio_color.log 2>&1
matugen image "$1" --mode dark --type scheme-vibrant --source-color-index 0 --contrast 0.6 -c ~/.config/matugen/config.toml >> /tmp/cambio_color.log 2>&1
echo "Código salida matugen: $?" >> /tmp/cambio_color.log

# === LIMITAR SATURACIÓN EXCESIVA DEL ACENTO ===
COLORS_FILE="$HOME/.config/theme-engine/colors.rasi"

if [[ -f "$COLORS_FILE" ]]; then
    sel=$(grep -oP "^\s*selected:\s*#\K[0-9A-Fa-f]{6}" "$COLORS_FILE" | head -1)
    if [[ -n "$sel" ]]; then
        clamped=$(bash "$HOME/.dots/scripts/clamp-saturation.sh" "$sel" 35 55 70)
        sed -i "s/^    selected:.*/    selected:       #${clamped}FF;/" "$COLORS_FILE"
    fi
fi

# === MANGOWM: borde + focuscolor ===
bash ~/.dots/scripts/apply-mango-focuscolor.sh >> /tmp/cambio_color.log 2>&1
bash ~/.dots/scripts/apply-mako-colors.sh >> /tmp/cambio_color.log 2>&1
bash ~/.dots/scripts/apply-walker-colors.sh >> /tmp/cambio_color.log 2>&1
sed -i 's/^borderpx=.*/borderpx=2/' "$HOME/.config/mango/config.conf"

# === RECARGAR FOOT (siempre dark) ===
pkill -SIGUSR1 foot 2>/dev/null
mmsg dispatch reload_config 2>/dev/null

# === GENERAR colors.css PARA WAYBAR (formato @define-color) ===
COLORS_RASI="$HOME/.config/theme-engine/colors.rasi"
COLORS_CSS="$HOME/.config/theme-engine/colors.css"

if [[ -f "$COLORS_RASI" ]]; then
    get_color() {
        grep -oP "^\s*$1:\s*#\K[0-9A-Fa-f]{6}" "$COLORS_RASI" | head -1
    }
    bg=$(get_color "background")
    bgalt=$(get_color "background-alt")
    fg=$(get_color "foreground")
    sel=$(get_color "selected")
    seltxt=$(get_color "selectedtext")
    act=$(get_color "active")
    urg=$(get_color "urgent")

    if [[ -n "$bg" && -n "$fg" ]]; then
        cat > "$COLORS_CSS" <<CSSEOF
/* Generado desde theme-engine (matugen) — NO EDITAR A MANO */
@define-color background #${bg};
@define-color background-alt #${bgalt};
@define-color foreground #${fg};
@define-color selected #${sel};
@define-color selectedtext #${seltxt};
@define-color active #${act};
@define-color urgent #${urg};
CSSEOF
        pkill -SIGUSR2 waybar 2>/dev/null
    fi
fi
