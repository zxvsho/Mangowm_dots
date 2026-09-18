#!/usr/bin/env bash
# Uso: clamp-saturation.sh HEXCOLOR MAX_SAT MIN_LUM MAX_LUM
# Todos los valores 0-100. Convierte a HSL, topea S y L, vuelve a hex.

hex="$1"
max_sat="${2:-55}"
min_lum="${3:-35}"
max_lum="${4:-65}"

r=$((16#${hex:0:2}))
g=$((16#${hex:2:2}))
b=$((16#${hex:4:2}))

rf=$(awk "BEGIN{printf \"%.6f\", $r/255}")
gf=$(awk "BEGIN{printf \"%.6f\", $g/255}")
bf=$(awk "BEGIN{printf \"%.6f\", $b/255}")

read -r h s l <<< "$(awk -v r="$rf" -v g="$gf" -v b="$bf" '
BEGIN {
    max = r; if (g > max) max = g; if (b > max) max = b
    min = r; if (g < min) min = g; if (b < min) min = b
    l = (max + min) / 2
    if (max == min) {
        h = 0; s = 0
    } else {
        d = max - min
        if (l > 0.5) s = d / (2 - max - min); else s = d / (max + min)
        if (max == r) h = (g - b) / d + (g < b ? 6 : 0)
        else if (max == g) h = (b - r) / d + 2
        else h = (r - g) / d + 4
        h = h / 6
    }
    printf "%.6f %.6f %.6f", h, s, l
}')"

max_sat_f=$(awk "BEGIN{printf \"%.6f\", $max_sat/100}")
min_lum_f=$(awk "BEGIN{printf \"%.6f\", $min_lum/100}")
max_lum_f=$(awk "BEGIN{printf \"%.6f\", $max_lum/100}")

s=$(awk -v s="$s" -v m="$max_sat_f" 'BEGIN{print (s>m)?m:s}')
l=$(awk -v l="$l" -v lo="$min_lum_f" -v hi="$max_lum_f" 'BEGIN{ v=l; if(v<lo)v=lo; if(v>hi)v=hi; print v}')

read -r new_r new_g new_b <<< "$(awk -v h="$h" -v s="$s" -v l="$l" '
function hue2rgb(p, q, t,   res) {
    if (t < 0) t += 1
    if (t > 1) t -= 1
    if (t < 1/6) { res = p + (q - p) * 6 * t; return res }
    if (t < 1/2) { res = q; return res }
    if (t < 2/3) { res = p + (q - p) * (2/3 - t) * 6; return res }
    return p
}
BEGIN {
    if (s == 0) {
        r = g = b = l
    } else {
        if (l < 0.5) q = l * (1 + s); else q = l + s - l * s
        p = 2 * l - q
        r = hue2rgb(p, q, h + 1/3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1/3)
    }
    printf "%d %d %d", int(r*255+0.5), int(g*255+0.5), int(b*255+0.5)
}')"

printf '%02x%02x%02x\n' "$new_r" "$new_g" "$new_b"
