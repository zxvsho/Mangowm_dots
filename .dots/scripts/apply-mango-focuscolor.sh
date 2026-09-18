#!/bin/bash
COLORS_FILE="$HOME/.config/theme-engine/colors.rasi"
MANGO_CONFIG="$HOME/.config/mango/config.conf"

if [[ ! -f "$COLORS_FILE" ]]; then
    exit 0
fi

get_color() {
    grep -oP "^\s*$1:\s*#\K[0-9A-Fa-f]{6}" "$COLORS_FILE" | head -1
}

background=$(get_color "background")
background_alt=$(get_color "background-alt")
foreground=$(get_color "foreground")
selected=$(get_color "selected")
active=$(get_color "active")
urgent=$(get_color "urgent")

if [[ -z "$background" || -z "$selected" ]]; then
    exit 0
fi

hex_to_mango() {
    echo "0x${1}ff"
}

mix_hex_weighted() {
    local c1="$1" c2="$2" w1="$3"
    local w2=$((100 - w1))
    local r1=$((16#${c1:0:2})) g1=$((16#${c1:2:2})) b1=$((16#${c1:4:2}))
    local r2=$((16#${c2:0:2})) g2=$((16#${c2:2:2})) b2=$((16#${c2:4:2}))
    printf '%02x%02x%02x' \
        $(( (r1*w1 + r2*w2) / 100 )) \
        $(( (g1*w1 + g2*w2) / 100 )) \
        $(( (b1*w1 + b2*w2) / 100 ))
}

border_mixed=$(mix_hex_weighted "$background" "$foreground" 92)

sed -i "s/^rootcolor=.*/rootcolor=$(hex_to_mango "$background")/" "$MANGO_CONFIG"
sed -i "s/^bordercolor=.*/bordercolor=$(hex_to_mango "$border_mixed")/" "$MANGO_CONFIG"
sed -i "s/^focuscolor=.*/focuscolor=$(hex_to_mango "$selected")/" "$MANGO_CONFIG"
sed -i "s/^dropcolor=.*/dropcolor=$(hex_to_mango "$active")/" "$MANGO_CONFIG"
sed -i "s/^splitcolor=.*/splitcolor=$(hex_to_mango "$active")/" "$MANGO_CONFIG"
sed -i "s/^maximizescreencolor=.*/maximizescreencolor=$(hex_to_mango "$selected")/" "$MANGO_CONFIG"
sed -i "s/^urgentcolor=.*/urgentcolor=$(hex_to_mango "$urgent")/" "$MANGO_CONFIG"
sed -i "s/^scratchpadcolor=.*/scratchpadcolor=$(hex_to_mango "$foreground")/" "$MANGO_CONFIG"
sed -i "s/^globalcolor=.*/globalcolor=$(hex_to_mango "$active")/" "$MANGO_CONFIG"
sed -i "s/^overlaycolor=.*/overlaycolor=$(hex_to_mango "$active")/" "$MANGO_CONFIG"

mmsg dispatch reload_config 2>/dev/null
