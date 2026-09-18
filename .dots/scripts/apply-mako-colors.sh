#!/bin/bash
COLORS_FILE="$HOME/.config/theme-engine/colors.rasi"
MAKO_CONFIG="$HOME/.config/mako/config"

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

sed -i "s/^background-color=.*/background-color=#${background}E6/" "$MAKO_CONFIG"
sed -i "s/^text-color=.*/text-color=#${foreground}/" "$MAKO_CONFIG"
sed -i "s/^border-color=#[0-9A-Fa-f]\{6\}$/border-color=#${selected}/" "$MAKO_CONFIG"
sed -i "s/^progress-color=over #.*/progress-color=over #${selected}/" "$MAKO_CONFIG"
sed -i "/\[urgency=critical\]/,/^$/ s/^border-color=.*/border-color=#${urgent}/" "$MAKO_CONFIG"

makoctl reload
