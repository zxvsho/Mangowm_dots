#!/bin/bash
estado_file="$HOME/.config/rofi/powermenu_activo"

if [[ ! -f "$estado_file" ]]; then
  echo "style1" >"$estado_file"
fi

estilo=$(cat "$estado_file")
rasi_final="$HOME/.config/rofi/powermenu/type1/${estilo}/style.rasi"

lastlogin="$(last $USER | head -n1 | tr -s ' ' | cut -d' ' -f5,6,7)"
uptime="$(uptime -p | sed -e 's/up //g')"
host=$(cat /proc/sys/kernel/hostname)

# Iconos Nerd Font (códigos unicode)
shutdown=$'\uf011'
reboot=$'\uf021'
suspend=$'\uf04a'
logout=$'\uf2f5'
lock=$'\uf023'
yes=$'\uf00c'
no=$'\uf00d'

# Orden: Shutdown → Reboot → Suspend → Logout → Lock
shutdown_txt="$shutdown Shutdown"
reboot_txt="$reboot Reboot"
suspend_txt="$suspend Suspend"
logout_txt="$logout Logout"
lock_txt="$lock Lock"

rofi_cmd() {
  rofi -dmenu \
    -p " $USER@$host" \
    -mesg " Last Login: $lastlogin |  Uptime: $uptime" \
    -selected-row 0 \
    -theme "$rasi_final"
}

confirm_cmd() {
  rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
    -theme-str 'mainbox {children: [ "message", "listview" ];}' \
    -theme-str 'listview {columns: 2; lines: 1;}' \
    -theme-str 'element-text {horizontal-align: 0.5;}' \
    -theme-str 'textbox {horizontal-align: 0.5;}' \
    -dmenu \
    -p 'Confirmation' \
    -mesg 'Are you Sure?' \
    -theme "$rasi_final"
}

confirm_exit() {
  echo -e "$yes\n$no" | confirm_cmd
}

run_rofi() {
  echo -e "$shutdown_txt\n$reboot_txt\n$suspend_txt\n$logout_txt\n$lock_txt" | rofi_cmd
}

run_cmd() {
  selected="$(confirm_exit)"
  if [[ "$selected" == "$yes" ]]; then
    if [[ $1 == '--shutdown' ]]; then
      systemctl poweroff
    elif [[ $1 == '--reboot' ]]; then
      systemctl reboot
    elif [[ $1 == '--suspend' ]]; then
      systemctl suspend
    elif [[ $1 == '--logout' ]]; then
      mmsg dispatch quit
    fi
  else
    exit 0
  fi
}

chosen="$(run_rofi)"
case ${chosen} in
$shutdown_txt)
  run_cmd --shutdown
  ;;
$reboot_txt)
  run_cmd --reboot
  ;;
$suspend_txt)
  run_cmd --suspend
  ;;
$logout_txt)
  run_cmd --logout
  ;;
$lock_txt)
  swaylock
  ;;
esac
