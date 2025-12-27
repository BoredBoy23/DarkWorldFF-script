#!/data/data/com.termux/files/usr/bin/bash

clear
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

OWNER_NAME="𝗗𝗮𝗿𝗸𝗪𝗼𝗿𝗹𝗱𝗙𝗙"
TELEGRAM_CHAT="https://t.me/DARKBRAI"

### ===============================
### COMPROBAR TERMUX
### ===============================
if [ ! -d "/data/data/com.termux" ]; then
    echo "[!] Este instalador solo funciona en Termux."
    exit 1
fi

### ===============================
### COMPROBAR / INSTALAR DIALOG
### ===============================
if ! command -v dialog >/dev/null 2>&1; then
    pkg update -y >/dev/null 2>&1
    pkg install dialog -y >/dev/null 2>&1
fi

MODE="TEXT"
command -v dialog >/dev/null 2>&1 && MODE="DIALOG"

msg() {
    if [ "$MODE" = "DIALOG" ]; then
        dialog --msgbox "$1" 10 55
    else
        echo -e "\n$1\n"
    fi
}

confirm() {
    if [ "$MODE" = "DIALOG" ]; then
        dialog --yesno "$1" 8 45
        return $?
    else
        read -p "$1 (y/n): " r
        [[ "$r" =~ ^[Yy]$ ]]
    fi
}

msg "Bienvenido al instalador VIP de $OWNER_NAME.\n\nSe instalarán todas las herramientas necesarias."

confirm "¿Deseas continuar?"
[ $? -ne 0 ] && clear && exit 1

termux-change-repo

pkg update -y >/dev/null 2>&1
pkg upgrade -y >/dev/null 2>&1
pkg install wget brotli openssl termux-tools dos2unix -y >/dev/null 2>&1

wget -q https://raw.githubusercontent.com/Mahboub-power-is-back/quic_over_dns/main/slipstream-client
chmod +x slipstream-client

if [ "$MODE" = "DIALOG" ]; then
    dialog --title "$OWNER_NAME" --menu "Instalación completada correctamente." 10 50 2 \
        1 "SALIR" \
        2 "CONTRATAR" 3>&1 1>&2 2>&3

    [ $? -eq 2 ] && am start -a android.intent.action.VIEW -d "$TELEGRAM_CHAT"
else
    echo "Instalación completada correctamente."
    echo "Contacto: $TELEGRAM_CHAT"
fi

clear
