#!/bin/bash
# Script: puntoB.sh - Verificación de URLs y clasificación por códigos HTTP
# Autor: Cristian Genovese

LISTA_URL="$HOME/202408/bash_script/Lista_URL.txt"
SCRIPT_CHECK="/usr/local/bin/genovese_check_URL.sh"
LOG_FILE="/var/log/status_url.log"

# Crear estructura de carpetas dentro de /tmp/head-check
BASE_DIR="/tmp/head-check"
OK_DIR="$BASE_DIR/ok"
CLIENTE_DIR="$BASE_DIR/error/cliente"
SERVIDOR_DIR="$BASE_DIR/error/servidor"

mkdir -p "$OK_DIR" "$CLIENTE_DIR" "$SERVIDOR_DIR"

# Copiar script si no existe
sudo cp /home/CGenovese/202408/bash_script/check_URL.sh "$SCRIPT_CHECK"
sudo chmod +x "$SCRIPT_CHECK"

# Backup IFS
OLDIFS=$IFS
IFS=$'\n'

# Procesar cada línea
for linea in $(grep -v "^#" "$LISTA_URL" | grep -v "^$"); do
    DOMINIO=$(echo "$linea" | cut -d ';' -f1)
    URL=$(echo "$linea" | cut -d ';' -f2)

    if [[ "$URL" != http* ]]; then
        URL="https://$URL"
    fi

    # Exportar para que lo use el script check
    export URL
    "$SCRIPT_CHECK"

    # Obtener última línea del log
    LOG_LINE=$(sudo tail -n 1 "$LOG_FILE")

    # Extraer código
    STATUS_CODE=$(echo "$LOG_LINE" | grep -oP "Code:\K[0-9]+")

    # Clasificar
    if [[ "$STATUS_CODE" == "200" ]]; then
        echo "$LOG_LINE" >> "$OK_DIR/$DOMINIO.log"
    elif [[ "$STATUS_CODE" -ge 400 && "$STATUS_CODE" -lt 500 ]]; then
        echo "$LOG_LINE" >> "$CLIENTE_DIR/$DOMINIO.log"
    elif [[ "$STATUS_CODE" -ge 500 && "$STATUS_CODE" -lt 600 ]]; then
        echo "$LOG_LINE" >> "$SERVIDOR_DIR/$DOMINIO.log"
    fi
done

# Restaurar IFS
IFS=$OLDIFS

