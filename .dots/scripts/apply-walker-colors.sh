#!/bin/bash
COLORS_FILE="$HOME/.config/theme-engine/colors.rasi"
WALKER_CSS="$HOME/.config/walker/themes/mango-theme/style.css"

if [[ ! -f "$COLORS_FILE" ]]; then
    exit 0
fi

get_color() {
    grep -oP "^\s*$1:\s*#\K[0-9A-Fa-f]{6}" "$COLORS_FILE" | head -1
}

background=$(get_color "background")
foreground=$(get_color "foreground")
selected=$(get_color "selected")
urgent=$(get_color "urgent")

if [[ -z "$background" || -z "$selected" ]]; then
    exit 0
fi

sed -i "s/^@define-color window_bg_color .*/@define-color window_bg_color #${background};/" "$WALKER_CSS"
sed -i "s/^@define-color accent_bg_color .*/@define-color accent_bg_color #${selected};/" "$WALKER_CSS"
sed -i "s/^@define-color theme_fg_color .*/@define-color theme_fg_color #${foreground};/" "$WALKER_CSS"
sed -i "s/^@define-color error_bg_color .*/@define-color error_bg_color #${urgent};/" "$WALKER_CSS"
sed -i "s/^@define-color error_fg_color .*/@define-color error_fg_color #${background};/" "$WALKER_CSS"
