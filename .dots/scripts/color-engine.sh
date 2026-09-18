#!/usr/bin/env bash

state_dir="$HOME/.config/color-engine"
active_file="$state_dir/active"
tinty_theme_file="$state_dir/tinty-theme"
last_wallpaper_file="$state_dir/last-wallpaper"
tinty_data_dir="$HOME/.local/share/tinted-theming/tinty/repos/tinted-shell/scripts"

mkdir -p "$state_dir"

[[ -f "$active_file" ]] || echo "matugen" > "$active_file"

usage() {
    echo "Uso: color-engine.sh status | apply | set matugen|tinty | set-theme TEMA" >&2
}

read_first() {
    local file="$1"
    [[ -f "$file" ]] && head -n1 "$file" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

get_active() {
    local engine
    engine=$(read_first "$active_file")
    [[ -z "$engine" ]] && engine="matugen"
    echo "$engine"
}

declare -A tinty_color

extract_tinty_colors() {
    local script_path="$1"
    tinty_color=()

    local raw
    raw=$(
        eval "$(grep -E '^color[0-9]+=' "$script_path")"
        for i in $(seq 0 21); do
            idx=$(printf "%02d" "$i")
            val_var="color$idx"
            val="${!val_var}"
            if [[ -n "$val" ]]; then
                printf "%s=%s\n" "$idx" "${val//\//}"
            fi
        done
    )

    while IFS='=' read -r idx hex; do
        [[ -n "$idx" ]] && tinty_color["$idx"]="$hex"
    done <<< "$raw"
}

generate_foot_tinty() {
    local out="$HOME/.config/foot/colors-dark.ini"
    {
        printf '[colors-dark]\n'
        printf 'alpha=0.9\n'
        printf 'foreground=%s\n' "${tinty_color[05]}"
        printf 'background=%s\n' "${tinty_color[00]}"
        printf '\n'
        for i in 0 1 2 3 4 5 6 7; do
            idx=$(printf "%02d" "$i")
            printf 'regular%d=%s\n' "$i" "${tinty_color[$idx]}"
        done
        printf '\n'
        for i in 0 1 2 3 4 5 6 7; do
            idx=$(printf "%02d" $((i + 8)))
            printf 'bright%d=%s\n' "$i" "${tinty_color[$idx]}"
        done
    } > "$out"
}

generate_ghostty_tinty() {
    local out="$HOME/.config/ghostty/themes/tema_matugen"
    {
        printf 'background = #%s\n' "${tinty_color[00]}"
        printf 'foreground = #%s\n' "${tinty_color[05]}"
        printf 'cursor-color = #%s\n' "${tinty_color[04]}"
        printf '\n'
        for i in $(seq 0 15); do
            idx=$(printf "%02d" "$i")
            [[ -n "${tinty_color[$idx]}" ]] && printf 'palette = %d=#%s\n' "$i" "${tinty_color[$idx]}"
        done
    } > "$out"
}

generate_kitty_tinty() {
    local out="$HOME/.config/kitty/theme.conf"
    {
        printf 'background #%s\n' "${tinty_color[00]}"
        printf 'foreground #%s\n' "${tinty_color[05]}"
        printf 'cursor #%s\n' "${tinty_color[04]}"
        printf '\n'
        for i in $(seq 0 15); do
            idx=$(printf "%02d" "$i")
            [[ -n "${tinty_color[$idx]}" ]] && printf 'color%d #%s\n' "$i" "${tinty_color[$idx]}"
        done
    } > "$out"
    pkill -SIGUSR1 kitty 2>/dev/null
}

generate_alacritty_tinty() {
    local out="$HOME/.config/alacritty/colors.toml"
    local names=(black red green yellow blue magenta cyan white)
    {
        printf "[colors.primary]\n"
        printf "background = '#%s'\n" "${tinty_color[00]}"
        printf "foreground = '#%s'\n" "${tinty_color[05]}"
        printf "\n[colors.cursor]\n"
        printf "cursor = '#%s'\n" "${tinty_color[04]}"
        printf "\n[colors.normal]\n"
        for i in 0 1 2 3 4 5 6 7; do
            idx=$(printf "%02d" "$i")
            [[ -n "${tinty_color[$idx]}" ]] && printf "%s = '#%s'\n" "${names[$i]}" "${tinty_color[$idx]}"
        done
        printf "\n[colors.bright]\n"
        for i in 0 1 2 3 4 5 6 7; do
            idx=$(printf "%02d" $((i + 8)))
            [[ -n "${tinty_color[$idx]}" ]] && printf "%s = '#%s'\n" "${names[$i]}" "${tinty_color[$idx]}"
        done
    } > "$out"
}

generate_rofi_tinty() {
    local out="$HOME/.config/theme-engine/colors.rasi"
    mkdir -p "$(dirname "$out")"
    {
        printf '/**\n'
        printf ' *\n'
        printf ' * Colors — generado por Tinty (base16/base24)\n'
        printf ' **/\n'
        printf '* {\n'
        printf '    background:     #%sFF;\n' "${tinty_color[00]}"
        printf '    background-alt: #%sFF;\n' "${tinty_color[18]}"
        printf '    foreground:     #%sFF;\n' "${tinty_color[05]}"
        printf '    selected:       #%sFF;\n' "${tinty_color[04]}"
        printf '    selectedtext:   #000000FF;\n'
        printf '    active:         #%sFF;\n' "${tinty_color[05]}"
        printf '    urgent:         #%sFF;\n' "${tinty_color[01]}"
        printf '}\n'
    } > "$out"

    mkdir -p "$HOME/.config/rofi/colors"
    ln -sf "$out" "$HOME/.config/rofi/colors/matugen-wallpaper.rasi"
}

# generate_waybar_tinty — NUEVO. Los temas de waybar (simple-bar,
# capsule-bar) tienen colors.css como symlink roto apuntando a
# theme-engine/colors.css, que nunca se generaba (solo existía el
# .rasi para rofi). Esta función escribe ese .css usando el mismo
# formato @define-color que ya usan simple-bar/capsule-bar, con los
# mismos colores que generate_rofi_tinty ya calcula para rofi.
generate_waybar_tinty() {
    local out="$HOME/.config/theme-engine/colors.css"
    mkdir -p "$(dirname "$out")"
    {
        printf '/* Generado desde theme-engine (tinty) — NO EDITAR A MANO */\n'
        printf '@define-color background #%s;\n'     "${tinty_color[00]}"
        printf '@define-color background-alt #%s;\n' "${tinty_color[18]}"
        printf '@define-color foreground #%s;\n'     "${tinty_color[05]}"
        printf '@define-color selected #%s;\n'       "${tinty_color[04]}"
        printf '@define-color selectedtext #000000;\n'
        printf '@define-color active #%s;\n'         "${tinty_color[05]}"
        printf '@define-color urgent #%s;\n'         "${tinty_color[01]}"
    } > "$out"
}

copy_rofi_to_all_styles() {
    local rofi_base="$HOME/.config/rofi/colors/matugen-wallpaper.rasi"
    [[ -f "$rofi_base" ]] || return 1

    for i in $(seq 1 10); do
        cp "$rofi_base" "$HOME/.config/rofi/launchers/type-7/style${i}-matugen-base.rasi" 2>/dev/null
    done

    cp "$rofi_base" "$HOME/.config/rofi/launchers/type-6/style4-matugen-base.rasi" 2>/dev/null

    cp "$rofi_base" "$HOME/.config/rofi/powermenu/type-5/style-matugen-base.rasi" 2>/dev/null
    for i in $(seq 1 5); do
        cp "$rofi_base" "$HOME/.config/rofi/powermenu/type-5/style${i}-matugen-base.rasi" 2>/dev/null
    done

    for i in $(seq 1 5); do
        cp "$rofi_base" "$HOME/.config/rofi/powermenu/type-6/style${i}-matugen-base.rasi" 2>/dev/null
    done
}

# NOTA: apply_matugen delega TODO a cambio_color.sh (no incluido aquí),
# así que no se pudo confirmar/agregar la generación de
# theme-engine/colors.css para waybar en esta rama — solo se agregó
# para tinty (generate_waybar_tinty, arriba). Si cambio_color.sh no
# genera ya ese colors.css, waybar quedará con el symlink roto al
# activar matugen. Revisar cambio_color.sh y replicar el mismo formato
# @define-color que usa generate_waybar_tinty si hace falta.
apply_matugen() {
    local wallpaper
    wallpaper=$(read_first "$last_wallpaper_file")

    if [[ -z "$wallpaper" ]]; then
        echo "No hay último wallpaper registrado en:" >&2
        echo "$last_wallpaper_file" >&2
        return 1
    fi

    if [[ ! -f "$wallpaper" ]]; then
        echo "El wallpaper registrado no existe:" >&2
        echo "$wallpaper" >&2
        return 1
    fi

    "$HOME/.config/waypaper/cambio_color.sh" "$wallpaper"
}

apply_tinty() {
    local theme
    theme=$(read_first "$tinty_theme_file")

    if [[ -z "$theme" ]]; then
        echo "No hay tema Tinty guardado." >&2
        echo "Usá: color-engine.sh set-theme NOMBRE" >&2
        return 1
    fi

    if ! command -v tinty &>/dev/null; then
        echo "tinty no está en el PATH" >&2
        return 1
    fi

    echo "Aplicando Tinty: $theme"
    tinty apply "$theme"

    local script_path="$tinty_data_dir/$theme.sh"

    if [[ ! -f "$script_path" ]]; then
        echo "No encontré el script del tema: $script_path" >&2
        return 1
    fi

    extract_tinty_colors "$script_path"

    if [[ -z "${tinty_color[00]}" ]]; then
        echo "Error: no se pudieron extraer colores del tema." >&2
        return 1
    fi

    [[ -z "${tinty_color[18]}" ]] && tinty_color[18]="${tinty_color[01]}"

    generate_foot_tinty
    generate_ghostty_tinty
    generate_kitty_tinty
    generate_alacritty_tinty
    pkill -SIGUSR2 ghostty 2>/dev/null
    generate_rofi_tinty
    generate_waybar_tinty
    copy_rofi_to_all_styles

    echo "Tinty aplicado: foot, ghostty, rofi, waybar actualizados."

    bash "$HOME/.dots/scripts/apply-mango-focuscolor.sh"
    bash "$HOME/.dots/scripts/apply-mako-colors.sh"
    bash "$HOME/.dots/scripts/apply-walker-colors.sh"
    sed -i 's/^borderpx=.*/borderpx=2/' "$HOME/.config/mango/config.conf"
    mmsg dispatch reload_config 2>/dev/null

    pkill -SIGUSR1 foot 2>/dev/null

    # waybar no soporta reload de CSS en caliente como foot/kitty (SIGUSR),
    # así que se reinicia. pgrep evita lanzarlo si no estaba corriendo ya.
    if pgrep -x waybar >/dev/null; then
        pkill waybar 2>/dev/null
        sleep 0.3
        waybar >/dev/null 2>&1 &
        disown
    fi

    return 0
}

apply_active() {
    local engine
    engine=$(get_active)

    case "$engine" in
        matugen) apply_matugen ;;
        tinty)   apply_tinty ;;
        *)
            echo "Motor inválido: $engine" >&2
            return 1
            ;;
    esac
}

if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi

case "$1" in
    status)
        active=$(get_active)
        theme=$(read_first "$tinty_theme_file")
        wallpaper=$(read_first "$last_wallpaper_file")

        echo "motor activo: $active"

        if [[ -n "$theme" ]]; then
            echo "tema tinty: $theme"
        else
            echo "tema tinty: sin definir"
        fi

        if [[ -n "$wallpaper" ]]; then
            echo "último wallpaper: $wallpaper"
        else
            echo "último wallpaper: sin registrar"
        fi
        ;;

    apply)
        apply_active || exit 1
        ;;

    set)
        if [[ $# -lt 2 ]]; then
            usage
            exit 1
        fi

        case "$2" in
            matugen|tinty)
                echo "$2" > "$active_file"
                echo "Motor activo: $2"

                if ! apply_active; then
                    echo "El motor quedó seleccionado, pero la aplicación del tema falló." >&2
                    exit 1
                fi
                ;;
            *)
                echo "Motor inválido: $2" >&2
                exit 1
                ;;
        esac
        ;;

    set-theme)
        if [[ $# -lt 2 ]]; then
            echo "Uso: color-engine.sh set-theme NOMBRE" >&2
            exit 1
        fi

        echo "$2" > "$tinty_theme_file"
        echo "Tema Tinty guardado: $2"

        if [[ "$(get_active)" == "tinty" ]]; then
            apply_active || exit 1
        fi
        ;;

    *)
        usage
        exit 1
        ;;
esac
