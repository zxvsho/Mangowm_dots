#!/bin/bash
# ~/.config/waybar/core-bar/selector-theme-bar.sh
# Lista temas en themes/ y reapunta config.jsonc + style.css.
# colors.css y font.css son compartidos (symlink raíz → theme-engine).

WAYBAR_DIR="$HOME/.config/waybar"
THEMES_DIR="$WAYBAR_DIR/themes"
ROFI_THEME="$HOME/.config/rofi/launchers/selector_menu/style.rasi"

[[ ! -d "$THEMES_DIR" ]] && { notify-send "Waybar" "No existe $THEMES_DIR" -u critical; exit 1; }

temas=$(find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)
[[ -z "$temas" ]] && { notify-send "Waybar" "No hay temas instalados" -u critical; exit 1; }

activo=""
if [[ -L "$WAYBAR_DIR/style.css" ]]; then
    activo=$(readlink "$WAYBAR_DIR/style.css" | awk -F/ '{print $(NF-1)}')
fi

lista=""
while IFS= read -r t; do
    if [[ "$t" == "$activo" ]]; then
        lista+="[activo]  $t"$'\n'
    else
        lista+="[      ]  $t"$'\n'
    fi
done <<< "$temas"

eleccion=$(printf "%s" "$lista" | rofi -dmenu -i -p "Waybar Theme" -theme "$ROFI_THEME" 2>/dev/null)
[[ -z "$eleccion" ]] && exit 0

eleccion=$(printf "%s" "$eleccion" | sed -E 's/^\[[^]]*\]\s+//')
[[ ! -d "$THEMES_DIR/$eleccion" ]] && { notify-send "Waybar" "Tema inválido: $eleccion" -u critical; exit 1; }

# Solo config.jsonc y style.css dependen del tema
for f in config.jsonc style.css; do
    if [[ -f "$THEMES_DIR/$eleccion/$f" ]]; then
        ln -sf "themes/$eleccion/$f" "$WAYBAR_DIR/$f"
    else
        rm -f "$WAYBAR_DIR/$f"
    fi
done

# colors.css y font.css son compartidos → siempre apuntan a theme-engine
ln -sf ../theme-engine/colors.css "$WAYBAR_DIR/colors.css"
ln -sf ../theme-engine/font.css   "$WAYBAR_DIR/font.css"

# scripts (solo si el tema tiene)
if [[ -d "$THEMES_DIR/$eleccion/scripts" ]]; then
    ln -sfn "themes/$eleccion/scripts" "$WAYBAR_DIR/scripts"
else
    rm -f "$WAYBAR_DIR/scripts"
fi

pkill waybar 2>/dev/null
sleep 0.5
waybar &

notify-send "Waybar" "Tema aplicado: $eleccion" 2>/dev/null
