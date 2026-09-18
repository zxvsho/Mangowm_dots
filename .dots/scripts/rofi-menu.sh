#!/usr/bin/env bash
# rofi-menu.sh
# Menú único de rofi (script mode) — sin parpadeo entre niveles, rápido.
# ALCANCE ACTUAL (prueba de concepto para el video): Menu -> Style -> Engine
# El resto del árbol (Theme/Launcher/Powermenu/Font) se agrega después
# siguiendo el mismo patrón de la función mostrar_nivel().
#
# TÍTULO DE NIVEL: el script sigue mandando \0prompt con el nombre de
# cada nivel (Search/Style/Engine) por si se quiere recuperar más
# adelante, pero el .rasi actual NO muestra el widget "prompt" (se quitó
# de children de inputbar) — en su lugar usa un placeholder FIJO
# ("Buscar...") en el entry, igual en todos los niveles, porque rofi no
# permite combinar "texto que cambia por nivel" con "desaparece al
# escribir" en un solo campo (son dos widgets con comportamientos
# distintos). Para recuperar el título por nivel: en rofi-menu.rasi,
# agregar "prompt" de vuelta a children de inputbar.
#
# NAVEGACIÓN estilo Vim/Neovim (ver rofi-menu.rasi): Control+j/Control+k
# mueven la selección en la lista (además de Arriba/Abajo, que siguen
# funcionando). Control+h retrocede un nivel (kb-custom-1). Control+l
# entra/confirma la fila seleccionada, igual que Enter (kb-accept-entry).
# Esc cierra el menú por completo (kb-cancel, nativo). Se descartaron
# antes: Left/Right solas (rofi las usa para el cursor de texto),
# Shift+Left/Right (no disparaba en el sistema del usuario), y Super
# (kb-accept-entry con Super+l no disparaba pese a estar bien
# configurado — sin causa clara, posiblemente interceptado antes de
# llegar a rofi).

set -u

SCRIPT_DIR="$HOME/.dots/scripts"
COLOR_ENGINE="$SCRIPT_DIR/color-engine.sh"
ACTIVE_FILE="$HOME/.config/color-engine/active"

# --- helpers -----------------------------------------------------------

engine_activo() {
    local engine
    engine=$(head -n1 "$ACTIVE_FILE" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [[ -z "$engine" ]] && engine="matugen"
    echo "$engine"
}

# emitir_prompt <texto> — todos los niveles se comportan igual: el nombre
# del nivel (incluido "Search" en root) va en el widget "prompt", sin
# cápsula, al lado izquierdo del campo de búsqueda.
emitir_prompt() {
    printf '\0prompt\x1f%s\n' "$1"
    printf '\0theme\x1fprompt { background-color: %s; }\n' 'transparent'
}

emitir_data() {
    printf '\0data\x1f%s\n' "$1"
}

# emitir_hotkeys — activa los custom keybindings (kb-custom-1, etc.) en
# script mode. SIN ESTO, rofi ignora silenciosamente kb-custom-1 (nunca
# manda ROFI_RETV=10): la documentación de rofi-script(5) dice que los
# custom keybindings "need to be explicitly enabled by script" vía
# use-hot-keys. Por eso Super+l (que va dentro de kb-accept-entry,
# siempre activo) funcionaba pero Super+h (kb-custom-1) no hacía nada.
emitir_hotkeys() {
    printf '\0use-hot-keys\x1ftrue\n'
}

# ANCHO_FILA: ancho fijo (en caracteres monospace) del texto de cada fila.
# Sirve para empujar el "›" hasta el borde derecho real de la caja, no
# solo hasta la palabra más larga del nivel. Ajustar si se cambia el
# width de window o el font-size de element-text en rofi-menu.rasi:
# subirlo mueve el "›" a la derecha, bajarlo a la izquierda.
ANCHO_FILA=28

# mostrar_filas_submenu <glifo1> <texto1> <glifo2> <texto2> ... — cada
# fila lleva un glifo Nerd Font al inicio (texto normal, no \0icon: rofi
# necesita un archivo de icono real para eso, un glifo es más simple y
# no depende de show-icons/theme de iconos). Se imprime "glifo texto"
# rellenado con espacios hasta ANCHO_FILA y el "›" pegado al final,
# alineado en columna. ROFI_INFO sigue llevando el texto real (sin
# glifo) para que el despacho no tenga que tocarse.
mostrar_filas_submenu() {
    local glifo texto fila
    while (( "$#" )); do
        glifo="$1"; texto="$2"; shift 2
        fila="$glifo  $texto"
        printf '%-*s›\0info\x1f%s\n' "$ANCHO_FILA" "$fila" "$texto"
    done
}

# --- niveles -------------------------------------------------------------

mostrar_root() {
    emitir_prompt "Go"
    emitir_data "root"
    emitir_hotkeys
    mostrar_filas_submenu \
        "󰀻" "Apps" \
        "󰒓" "Settings" \
        "󰏘" "Style" \
        "󰖷" "Utils" \
        "󰇚" "Install" \
        "󰆴" "Remove" \
        "󰑐" "Update" \
        "󰩦" "Extras" \
        "󰪫" "System"
}

mostrar_style() {
    emitir_prompt "Style"
    emitir_data "style"
    emitir_hotkeys
    mostrar_filas_submenu \
        "󰋩" "Background" \
        "󰈊" "Engine" \
        "󰢵" "Theme" \
        "󰑣" "Launcher" \
        "󰐥" "Powermenu" \
        "󰕰" "Menu Bar" \
        "󰛖" "Font" \
        "󰘮" "Custom"
}

mostrar_engine() {
    local activo
    activo=$(engine_activo)

    emitir_prompt "Engine"
    emitir_data "engine"
    emitir_hotkeys

    # Matugen/Tinty son acciones finales, no submenús: sin "›". Los
    # nombres mostrados son "Dynamic Color" (matugen) y "Theme Managers"
    # (tinty); el valor interno que maneja color-engine.sh sigue siendo
    # matugen/tinty, solo cambia el texto en pantalla.
    if [[ "$activo" == "matugen" ]]; then
        echo "󰃣 Dynamic Color ✓"
    else
        echo "󰃣 Dynamic Color"
    fi

    if [[ "$activo" == "tinty" ]]; then
        echo "󰓡 Theme Managers ✓"
    else
        echo "󰓡 Theme Managers"
    fi
}

# --- despacho --------------------------------------------------------------

nivel="${ROFI_DATA:-root}"
retv="${ROFI_RETV:-0}"

# ROFI_INFO trae el texto real de la fila (sin el "  ›" visual) cuando la
# fila lo definió vía fila_submenu(); si no, usamos el argumento tal cual
# (ya es el texto real, como en las filas de Engine).
seleccion_real="${ROFI_INFO:-${1:-}}"

if [[ "$retv" == "10" ]]; then
    # kb-custom-1 = Control+h (ver rofi-menu.rasi): retrocede un nivel.
    case "$nivel" in
        engine) nivel="style" ;;
        style)  nivel="root" ;;
        *)      nivel="root" ;;
    esac
elif [[ "$retv" == "1" ]]; then
    seleccion="$seleccion_real"

    case "$nivel" in
        root)
            case "$seleccion" in
                Style) nivel="style" ;;
                Apps|Settings|Utils|Install|Remove|Update|Extras|System)
                    nivel="root"
                    ;;
            esac
            ;;
        style)
            case "$seleccion" in
                Engine) nivel="engine" ;;
                Background|Theme|Launcher|Powermenu|"Menu Bar"|Font|Custom)
                    nivel="style"
                    ;;
            esac
            ;;
        engine)
            case "$seleccion" in
                "󰃣 Dynamic Color"|"󰃣 Dynamic Color ✓")
                    "$COLOR_ENGINE" set matugen >/dev/null 2>&1 &
                    disown
                    exit 0
                    ;;
                "󰓡 Theme Managers"|"󰓡 Theme Managers ✓")
                    "$COLOR_ENGINE" set tinty >/dev/null 2>&1 &
                    disown
                    exit 0
                    ;;
            esac
            ;;
    esac
fi

case "$nivel" in
    root)   mostrar_root ;;
    style)  mostrar_style ;;
    engine) mostrar_engine ;;
    *)      mostrar_root ;;
esac
