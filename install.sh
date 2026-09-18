#!/usr/bin/env bash
# install.sh — restaura el rice MangoWM en un sistema nuevo (CachyOS)
# Clona github.com/zxvsho/Mangowm_dots y copia .dots + .config a su lugar.
#
# Uso:
#   curl -O https://raw.githubusercontent.com/zxvsho/Mangowm_dots/main/install.sh
#   bash install.sh
# o simplemente, si ya clonaste el repo a mano:
#   cd Mangowm_dots && bash install.sh

set -euo pipefail

REPO_URL="https://github.com/zxvsho/Mangowm_dots.git"
CLONE_DIR="$HOME/Mangowm_dots"

echo "==> Restaurando dotfiles MangoWM"

# --- 1. Clonar el repo si no está ya presente ---------------------------
if [[ -d "$CLONE_DIR/.git" ]]; then
    echo "Repo ya clonado en $CLONE_DIR, actualizando..."
    git -C "$CLONE_DIR" pull
else
    echo "Clonando $REPO_URL en $CLONE_DIR..."
    git clone "$REPO_URL" "$CLONE_DIR"
fi

# --- 2. Backup de lo que ya exista, por seguridad ------------------------
timestamp=$(date +%Y%m%d-%H%M%S)
if [[ -d "$HOME/.dots" ]]; then
    echo "Ya existe ~/.dots, respaldando a ~/.dots.bak-$timestamp"
    mv "$HOME/.dots" "$HOME/.dots.bak-$timestamp"
fi
if [[ -d "$HOME/.config" ]]; then
    echo "Respaldando ~/.config actual a ~/.config.bak-$timestamp"
    cp -r "$HOME/.config" "$HOME/.config.bak-$timestamp"
fi

# --- 3. Copiar .dots -------------------------------------------------------
if [[ -d "$CLONE_DIR/.dots" ]]; then
    echo "Copiando .dots..."
    cp -r "$CLONE_DIR/.dots" "$HOME/.dots"
else
    echo "AVISO: no encontré $CLONE_DIR/.dots — revisa la estructura del repo" >&2
fi

# --- 4. Copiar .config (sin pisar lo que el sistema nuevo ya generó,
#        mezclando con lo del repo por encima) -----------------------------
if [[ -d "$CLONE_DIR/.config" ]]; then
    echo "Copiando .config..."
    mkdir -p "$HOME/.config"
    cp -r "$CLONE_DIR/.config/." "$HOME/.config/"
else
    echo "AVISO: no encontré $CLONE_DIR/.config — revisa la estructura del repo" >&2
fi

# --- 5. Permisos de ejecución para los scripts de .dots -------------------
if [[ -d "$HOME/.dots/scripts" ]]; then
    chmod +x "$HOME/.dots/scripts/"*.sh 2>/dev/null || true
fi

echo "==> Listo. Revisa que ~/.dots/scripts y ~/.config tengan lo esperado."
echo "    Instala manualmente los paquetes necesarios (rofi, mako, matugen,"
echo "    tinty, mangowm, adw-gtk-theme, etc.) si el sistema nuevo no los trae."
