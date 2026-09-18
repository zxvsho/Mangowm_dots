#!/bin/bash

# ─── Rutas ──────────────────────────────────────────────
DOTFILES="$HOME/.dots"
FONTS_DIR="$DOTFILES/scripts/Style/Fonts"
EXCLUDE_LIST="$FONTS_DIR/exclude.list"

THEME_DIR="$HOME/.config/theme"
FONT_CONF="$THEME_DIR/font.conf"
ROFI_FONT="$HOME/.config/rofi/font.rasi"

FOOT_CONF="$HOME/.config/foot/foot.ini"
GHOSTTY_CONF="$HOME/.config/ghostty/config"
KITTY_CONF="$HOME/.config/kitty/kitty.conf"
ALACRITTY_CONF="$HOME/.config/alacritty/alacritty.toml"
MAKO_CONF="$HOME/.config/mako/config"

ROFI_THEME_SELECTOR="$HOME/.config/rofi/launchers/selector_menu/style.rasi"

mkdir -p "$THEME_DIR"
touch "$EXCLUDE_LIST"

# ─── 1. Detectar familias Nerd Font con ambas variantes (Mono + Propo) ───
# Familia base = nombre sin "Propo" al final. Solo mostramos las que
# tienen entrada Mono Y entrada Propo instaladas.
mapfile -t todas < <(fc-list : family | tr "," "\n" | grep -i "nerd font" | sed "s/^ *//;s/ *$//" | sort -u | grep -vFf "$EXCLUDE_LIST")

declare -A tiene_mono
declare -A tiene_propo

for f in "${todas[@]}"; do
    if [[ "$f" == *" Propo" ]]; then
        base="${f% Propo}"
        tiene_propo["$base"]=1
    else
        tiene_mono["$f"]=1
    fi
done

familias=()
for base in "${!tiene_mono[@]}"; do
    if [[ -n "${tiene_propo[$base]}" ]]; then
        familias+=("$base")
    fi
done

if [[ ${#familias[@]} -eq 0 ]]; then    
notify-send "Fuentes" "No hay ninguna Nerd Font con variante Mono + Propo instalada." 2>/dev/null
    exit 1
fi

lista=$(printf "%s\n" "${familias[@]}" | sort -u)

# ─── 2. Elegir familia ──────────────────────────────────
familia=$(echo "$lista" | rofi -dmenu -i -p "Elige fuente (Nerd Font):" -theme "$ROFI_THEME_SELECTOR")

if [[ -z "$familia" ]]; then bash "$HOME/.dots/scripts/rofi_style_selector.sh"; exit 0; fi

font_mono="$familia"
font_ui="$familia Propo"

# ─── 3. Actualizar font.conf central ───────────────────
touch "$FONT_CONF"

for par in "FONT_MONO=$font_mono" "FONT_UI=$font_ui"; do
    campo="${par%%=*}"
    valor="${par#*=}"
    if grep -q "^${campo}=" "$FONT_CONF" 2>/dev/null; then
        sed -i "s|^${campo}=.*|${campo}=\"${valor}\"|" "$FONT_CONF"
    else
        echo "${campo}=\"${valor}\"" >> "$FONT_CONF"
    fi
done

source "$FONT_CONF"

# ─── 4. Regenerar font.rasi para rofi (UI, proporcional) ──
mkdir -p "$(dirname "$ROFI_FONT")"
cat > "$ROFI_FONT" << RASIEOF
* {
    font: "${FONT_UI} 10";
}
RASIEOF

# ─── 5. Aplicar Mono a terminales ──────────────────────
# foot — no soporta hot-reload, solo editamos el archivo
if [[ -f "$FOOT_CONF" ]]; then
    sed -i "s|^font=.*|font=${FONT_MONO}:size=11|" "$FOOT_CONF"
fi

# ghostty — hot-reload vía SIGUSR2
if [[ -f "$GHOSTTY_CONF" ]]; then
    sed -i "s|^font-family = .*|font-family = \"${FONT_MONO}\"|" "$GHOSTTY_CONF"
    pkill -SIGUSR2 ghostty 2>/dev/null
fi

    # kitty — hot-reload via SIGUSR1
    if [[ -f "$KITTY_CONF" ]]; then
        if grep -q "^font_family " "$KITTY_CONF" 2>/dev/null; then
            sed -i "s|^font_family .*|font_family ${FONT_MONO}|" "$KITTY_CONF"
        else
            sed -i "1i font_family ${FONT_MONO}" "$KITTY_CONF"
        fi
        pkill -SIGUSR1 kitty 2>/dev/null
    fi

# alacritty — live_config_reload automático
if [[ -f "$ALACRITTY_CONF" ]]; then
    if grep -q "^\s*normal\.family" "$ALACRITTY_CONF" 2>/dev/null; then
        sed -i "s|^\s*normal\.family.*|  normal.family = \"${FONT_MONO}\"|" "$ALACRITTY_CONF"
    else
        sed -i "/^\[font\]/a\  normal.family = \"${FONT_MONO}\"" "$ALACRITTY_CONF"
    fi
fi

# ─── 6. Aplicar Propo a UI ──────────────────────────────
# mako
if [[ -f "$MAKO_CONF" ]]; then
    if grep -q "^font=" "$MAKO_CONF" 2>/dev/null; then
        sed -i "s|^font=.*|font=${FONT_UI} 10|" "$MAKO_CONF"
    else
        echo "font=${FONT_UI} 10" >> "$MAKO_CONF"
    fi
    makoctl reload 2>/dev/null
fi

# fontconfig — fuente del sistema (GTK/Qt y apps que piden system font)
FONTCONFIG_USER="$HOME/.config/fontconfig/fonts.conf"
mkdir -p "$(dirname "$FONTCONFIG_USER")"
cat > "$FONTCONFIG_USER" << FCEOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>sans-serif</family>
    <prefer><family>${FONT_UI}</family></prefer>
  </alias>
</fontconfig>
FCEOF
fc-cache -f "$HOME/.local/share/fonts" 2>/dev/null

# waybar — hook listo, aplica cuando lo configures
WAYBAR_FONT_CSS="$HOME/.config/waybar/font.css"
if [[ -d "$HOME/.config/waybar" ]]; then
    mkdir -p "$(dirname "$WAYBAR_FONT_CSS")"
    cat > "$WAYBAR_FONT_CSS" << WBEOF
* {
    font-family: "${FONT_UI}";
}
WBEOF
    pkill -SIGUSR2 waybar 2>/dev/null
fi

for style_dir in ~/.config/rofi/powermenu/type1/style*/shared; do
    if [[ -d "$style_dir" ]]; then
        cat > "$style_dir/fonts.rasi" << FONTSEOF
* {
    font: "${FONT_UI} 10";
}
FONTSEOF
    fi
done

notify-send "Fuente actualizada" "${familia} (Mono + Propo)" 2>/dev/null
