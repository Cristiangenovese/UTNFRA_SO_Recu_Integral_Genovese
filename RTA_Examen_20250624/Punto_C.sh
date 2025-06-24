#!/bin/bash

DOCKER_USER="cgenovese"
IMG_NAME="web3_ri2024-genovese"
IMG_TAG="latest"
FULL_IMG="$DOCKER_USER/$IMG_NAME:$IMG_TAG"
REPO_PATH="$HOME/202408/docker"
INFO_FILE="$REPO_PATH/web/file/info.txt"
LV_PATH="/dev/vg_datos/lv_docker"
MOUNT_POINT="/var/lib/docker"

# 1. Verificar espacio disponible
echo "Espacio actual en $MOUNT_POINT:"
df -h "$MOUNT_POINT"

read -p "¿Querés extender el volumen lv_docker (+700M)? (s/n): " RESPUESTA
if [[ "$RESPUESTA" == "s" || "$RESPUESTA" == "S" ]]; then
    echo "Extendiendo $LV_PATH..."
    sudo lvextend -L +700M "$LV_PATH" && sudo resize2fs "$LV_PATH"
    echo "✅ Volumen extendido."
    df -h "$MOUNT_POINT"
else
    echo "⏩ Salteando extensión de volumen."
fi

# 2. Generar info.txt con datos de CPU
echo "��� Generando info.txt con datos del CPU..."
CPU_MODEL=$(grep 'model name' /proc/cpuinfo | head -n1 | cut -d ':' -f2 | xargs)
CPU_FREQ=$(grep 'cpu MHz' /proc/cpuinfo | head -n1 | awk -F ':' '{printf "%.2f MHz", $2}' | xargs)
echo -e "Modelo CPU: $CPU_MODEL\nFrecuencia: $CPU_FREQ" | sudo tee "$INFO_FILE" > /dev/null

# 3. Ir al directorio del Dockerfile
cd "$REPO_PATH" || { echo "❌ No se encontró la carpeta $REPO_PATH"; exit 1; }

# 4. Construir la imagen
echo "Construyendo imagen Docker: $FULL_IMG"
docker build -t "$FULL_IMG" .

# 5. Push a Docker Hub
echo "Subiendo imagen a Docker Hub..."
docker push "$FULL_IMG"

# 6. Levantar contenedor con docker-compose
echo "Levantando contenedor con docker-compose..."
docker-compose down 2>/dev/null
sudo apt install docker-compose
docker-compose up -d

# 7. Confirmación
echo "Imagen disponible en: https://hub.docker.com/r/$DOCKER_USER/$IMG_NAME"
echo "Sitio accesible en: http://localhost:8081"

