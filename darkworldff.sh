#!/data/data/com.termux/files/usr/bin/bash

clear

# ===============================
# COLORES
# ===============================
GREEN="\e[32m"
RESET="\e[0m"

# ===============================
# BANNER ASCII
# ===============================
BANNER=(
"${GREEN}██████╗  █████╗ ██████╗ ██╗  ██╗██╗    ██╗ ██████╗ ██████╗ ██╗     ██████╗${RESET}"
"${GREEN}██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝██║    ██║██╔═══██╗██╔══██╗██║     ██╔══██╗${RESET}"
"${GREEN}██║  ██║███████║██████╔╝█████╔╝ ██║ █╗ ██║██║   ██║██████╔╝██║     ██║  ██║${RESET}"
"${GREEN}██║  ██║██╔══██║██╔══██╗██╔═██╗ ██║███╗██║██║   ██║██╔══██╗██║     ██║  ██║${RESET}"
"${GREEN}██████╔╝██║  ██║██║  ██║██║  ██╗╚███╔███╔╝╚██████╔╝██║  ██║███████╗██████╔╝${RESET}"
"${GREEN}╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═════╝${RESET}"
)

# ===============================
# TITULO FIJO
# ===============================
TITLE="${GREEN}VIP Network Manager${RESET}"

# ===============================
# DOMINIO
# ===============================
DOMAIN="dns2.etecsafree.work.gd"
ACTIVE_DNS="No conectado"
LOG_DIR="$HOME/.slipstream"
LOG_FILE="$LOG_DIR/slip.log"

mkdir -p "$LOG_DIR"

# ===============================
# SERVIDORES
# ===============================
DATA_SERVERS=(
"200.55.128.130:53"
"200.55.128.140:53"
"200.55.128.230:53"
"200.55.128.250:53"
)

WIFI_SERVERS=(
"181.225.231.120:53"
"181.225.231.110:53"
"181.225.233.40:53"
"181.225.233.30:53"
)

# ===============================
# DETECTAR RED
# ===============================
detect_network() {
    iface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}')
    [[ "$iface" == wlan* ]] && echo "WIFI" || echo "DATA"
}

# ===============================
# INSTALAR SLIPSTREAM
# ===============================
install_slipstream() {
    clear
    wget https://raw.githubusercontent.com/BoredBoy23/DarkWorldFF-script/refs/heads/main/setupff.sh && \
    chmod +x setupff.sh && \
    ./setupff.sh
    read -p "ENTER para volver"
}

# ===============================
# LIMPIAR SLIPSTREAM
# ===============================
clean_slipstream() {
    pkill -f slipstream-client 2>/dev/null
    sleep 1
}

# ===============================
# CONEXIÓN AUTOMÁTICA
# ===============================
connect_auto() {
    local SERVERS=("$@")
    local CONNECTED=false

    for SERVER in "${SERVERS[@]}"; do
        clean_slipstream
        > "$LOG_FILE"

        clear
        echo "[*] Probando servidor: $SERVER"
        echo

        trap trap_ctrl_c INT

        ./slipstream-client \
            --tcp-listen-port=5201 \
            --resolver="$SERVER" \
            --domain="$DOMAIN" \
            --keep-alive-interval=600 \
            --congestion-control=cubic \
            > >(tee -a "$LOG_FILE") 2>&1 &

        PID=$!

        # Espera máxima: 7 segundos
        for i in {1..7}; do
            if grep -q "Connection confirmed" "$LOG_FILE"; then
                ACTIVE_DNS="$SERVER"
                clear
                echo "[✓] CONEXIÓN CONFIRMADA"
                echo "[✓] Servidor online ✅"
                echo "[✓] DNS Activo: $ACTIVE_DNS"
                echo
                echo "Ctrl + C para desconectar"
                wait $PID
                ACTIVE_DNS="No conectado"
                CONNECTED=true
                break 2
            fi

            if grep -q "Connection closed" "$LOG_FILE"; then
                break
            fi
            sleep 1
        done

        clean_slipstream
    done

    # Mostrar mensaje offline solo si ningún servidor conectó
    if [ "$CONNECTED" = false ]; then
        clear
        echo "Servidor offline ❌"
        echo "Solicite reiniciar el servidor"
        echo
        read -p "ENTER para volver al menú"
    fi
}

# ===============================
# MENÚ PRINCIPAL
# ===============================
while true; do
    clear

    # Mostrar banner
    for line in "${BANNER[@]}"; do
        echo -e "$line"
    done
    echo

    # Mostrar título fijo en verde
    echo -e "$TITLE"
    echo

    NET=$(detect_network)
    DATA_MARK="○"
    WIFI_MARK="○"
    [[ "$NET" == "DATA" ]] && DATA_MARK="●"
    [[ "$NET" == "WIFI" ]] && WIFI_MARK="●"

    echo "$DATA_MARK 1) Conectar en Datos Móviles"
    echo "$WIFI_MARK 2) Conectar en WiFi"
    echo "  3) Instalar slipstream-client"
    echo "  0) Salir"
    echo
    read -p "Selecciona una opción: " opt

    case $opt in
        1) connect_auto "${DATA_SERVERS[@]}" ;;
        2) connect_auto "${WIFI_SERVERS[@]}" ;;
        3) install_slipstream ;;
        0) clear; exit ;;
    esac
done