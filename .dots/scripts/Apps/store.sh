#!/bin/bash

# Limpiar archivos temporales al salir
trap 'rm -f /tmp/arch_store_view' EXIT

# Comprobar herramientas necesarias
for cmd in fzf paru pacman; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: Se requiere '$cmd'. Instálalo antes de continuar."
        exit 1
    fi
done

# Función para desbloquear pacman si hubo un error previo
comprobar_bloqueo() {
    if [ -f /var/lib/pacman/db.lck ]; then
        clear
        echo -e "\033[1m¡ATENCIÓN!\033[0m La base de datos de Pacman está bloqueada."
        echo "Esto suele pasar si una instalación anterior se interrumpió."
        read -p "¿Quieres desbloquearla ahora? (s/n): " desbloquear
        if [[ "$desbloquear" =~ ^[Ss]$ ]]; then
            sudo rm /var/lib/pacman/db.lck
            echo "Desbloqueada con éxito."
            sleep 1
        else
            exit 1
        fi
    fi
}

buscar_e_instalar() {
    comprobar_bloqueo
    clear
    echo -e "\033[1m=== BUSCAR EN REPOSITORIOS Y AUR ===\033[0m"
    echo "Escribe el nombre del paquete. Presiona Enter vacío para volver."
    echo "----------------------------------------------------"
    
    read -p "Término de búsqueda: " busqueda
    
    if [ -n "$busqueda" ]; then
        seleccion=$(paru -Ssq "$busqueda" | fzf \
            --prompt="Instalar  " \
            --height=80% \
            --layout=reverse \
            --border=rounded \
            --bind="space:accept" \
            --preview="paru -Si {}" \
            --preview-window=right:60%:wrap)

        if [ -n "$seleccion" ]; then
            clear
            echo -e "\033[1mInstalando:\033[0m $seleccion"
            paru -S "$seleccion"
            read -p "Presiona Enter para volver al menú..."
        fi
    fi
}

ver_y_remover() {
    comprobar_bloqueo
    clear
    echo -e "\033[1m=== TUS APLICACIONES INSTALADAS (REMOVER) ===\033[0m"
    echo "----------------------------------------------------"
    
    seleccion=$(pacman -Qqe | fzf \
        --prompt="Remover  " \
        --height=80% \
        --layout=reverse \
        --border=rounded \
        --color="prompt:red,border:red" \
        --bind="space:accept" \
        --preview="pacman -Qi {}" \
        --preview-window=right:60%:wrap)

    if [ -n "$seleccion" ]; then
        clear
        echo -e "\033[1m¡ATENCIÓN! Vas a desinstalar:\033[0m $seleccion"
        read -p "¿Confirmas la eliminación segura (-Rns)? (s/n): " confirmar
        if [[ "$confirmar" =~ ^[Ss]$ ]]; then
            sudo pacman -Rns "$seleccion"
            read -p "Presiona Enter para volver al menú..."
        fi
    fi
}

explorar_paquetes() {
    clear
    echo -e "\033[1m=== EXPLORAR PAQUETES INSTALADOS ===\033[0m"
    echo "Selecciona una categoría:"
    echo "----------------------------------------------------"
    
    tipo=$(printf "1.  Paquetes Oficiales (Repositorios)\n2. 󰣇 Paquetes de AUR\n3. 󰈆 Volver al Menú" | fzf \
        --prompt="Categoría  " \
        --height=9 \
        --layout=reverse \
        --border=rounded \
        --bind="i:up,k:down,space:accept")
        
    case "$tipo" in
        *"Oficiales"*)
            pacman -Qn | awk '{print $1}' | fzf \
                --prompt="Oficiales  " \
                --height=80% \
                --layout=reverse \
                --border=rounded \
                --bind="space:accept" \
                --preview="pacman -Qi {}" \
                --preview-window=right:60%:wrap
            read -p "Presiona Enter para continuar..."
            explorar_paquetes
            ;;
        *"AUR"*)
            echo "info" > /tmp/arch_store_view
            
            preview_cmd='bash -c '\''
                mode=$(cat /tmp/arch_store_view 2>/dev/null || echo "info")
                if [ "$mode" = "pkgbuild" ]; then
                    paru -Gp {} 2>/dev/null || echo "No se pudo cargar el PKGBUILD"
                else
                    pacman -Qi {}
                fi
            '\'''

            bind_cmd='ctrl-k:execute-silent(bash -c '\''
                if [ "$(cat /tmp/arch_store_view 2>/dev/null)" = "pkgbuild" ]; then
                    echo "info" > /tmp/arch_store_view
                else
                    echo "pkgbuild" > /tmp/arch_store_view
                fi
            '\'')+refresh-preview'
            
            pacman -Qm | awk '{print $1}' | fzf \
                --prompt="AUR  " \
                --height=80% \
                --layout=reverse \
                --border=rounded \
                --header="[Ctrl+K] Alternar Info / PKGBUILD" \
                --preview="$preview_cmd" \
                --preview-window=right:65%:wrap \
                --bind="$bind_cmd" \
                --bind="space:accept"
            read -p "Presiona Enter para continuar..."
            explorar_paquetes
            ;;
        *)
            return
            ;;
    esac
}

actualizar_sistema() {
    comprobar_bloqueo
    clear
    echo -e "\033[1m=== ACTUALIZANDO ARCH LINUX ===\033[0m"
    echo "----------------------------------------------------"
    paru -Syu
    read -p "Proceso finalizado. Presiona Enter para volver..."
}

limpiar_sistema() {
    comprobar_bloqueo
    clear
    echo -e "\033[1m=== LIMPIEZA DE SISTEMA ===\033[0m"
    echo "----------------------------------------------------"
    
    echo "1. Limpiando archivos temporales residuales..."
    sudo rm -f /var/cache/pacman/pkg/download-* 2>/dev/null
    
    echo "2. Limpiando caché (Repos y AUR)..."
    sudo pacman -Sc --noconfirm
    yes | paru -Sc >/dev/null 2>&1
    
    echo -e "\n3. Buscando paquetes huérfanos..."
    huerfanos=$(pacman -Qdtq)
    
    if [ -n "$huerfanos" ]; then
        echo -e "\033[1mSe encontraron estos paquetes huérfanos:\033[0m"
        echo "$huerfanos"
        echo ""
        read -p "¿Deseas eliminarlos para liberar espacio? (s/n): " confirmar
        if [[ "$confirmar" =~ ^[Ss]$ ]]; then
            sudo pacman -Rns $huerfanos
            echo "Huérfanos eliminados."
        else
            echo "Huérfanos conservados."
        fi
    else
        echo "Tu sistema está limpio. No hay paquetes huérfanos."
    fi
    
    echo -e "\n¡Mantenimiento completado!"
    read -p "Presiona Enter para volver..."
}

while true; do
    clear
    echo -e "\033[1m\033[36m"

    echo -e "\033[0m"
    echo -e "\033[1m\033[35m   ╭───────────────────────────────────╮\033[0m"
    echo -e "\033[1m\033[35m   │        GESTOR DE PAQUETES         │\033[0m"
    echo -e "\033[1m\033[35m   ╰───────────────────────────────────╯\033[0m"
    echo ""
    
    opcion=$(printf "1. 󰏖 Buscar e Instalar\n2. 󰛌 Ver Instalados y Remover\n3. 󰮯 Explorar Paquetes Instalados\n4. 󰚰 Actualizar Sistema\n5. 󰃢 Limpiar Sistema\n6. 󰈆 Salir" | fzf \
        --prompt="Selecciona una acción  " \
        --height=15 \
        --layout=reverse \
        --border=rounded \
        --bind="i:up,k:down,space:accept")

    case "$opcion" in
        *"Buscar e Instalar"*) buscar_e_instalar ;;
        *"Ver Instalados y Remover"*) ver_y_remover ;;
        *"Explorar Paquetes Instalados"*) explorar_paquetes ;;
        *"Actualizar Sistema"*) actualizar_sistema ;;
        *"Limpiar Sistema"*) limpiar_sistema ;;
        *"Salir"*|"") clear; exit 0 ;;
    esac
done
