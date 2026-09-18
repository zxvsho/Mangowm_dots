#!/usr/bin/env fish

set rofi_base "$HOME/.config/rofi/colors/matugen-wallpaper.rasi"

if not test -f "$rofi_base"
    echo "No existe $rofi_base, nada que copiar." >&2
    exit 1
end

# Todos los targets de rofi launcher type-7
for i in (seq 1 10)
    set target "$HOME/.config/rofi/launchers/type-7/style$i-matugen-base.rasi"
    cp "$rofi_base" "$target"
end

# Rofi launcher type-6
cp "$rofi_base" "$HOME/.config/rofi/launchers/type-6/style4-matugen-base.rasi"

# Rofi powermenu type-5
cp "$rofi_base" "$HOME/.config/rofi/powermenu/type-5/style-matugen-base.rasi"
for i in (seq 1 5)
    cp "$rofi_base" "$HOME/.config/rofi/powermenu/type-5/style$i-matugen-base.rasi"
end

# Rofi powermenu type-6
for i in (seq 1 5)
    cp "$rofi_base" "$HOME/.config/rofi/powermenu/type-6/style$i-matugen-base.rasi"
end

echo "Rofi base copiado a todos los styles."
