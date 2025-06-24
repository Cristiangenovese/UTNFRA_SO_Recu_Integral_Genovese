#!/bin/bash
# Punto_E.sh – Script para subir entrega del recuperatorio a GitHub vía SSH

clear
echo "Preparando entrega para GitHub..."

# Config
REPO_NAME="UTNFRA_SO_Recu_Integral_Genovese"
REMOTE_URL="git@github.com:Cristiangenovese/$REPO_NAME.git"
DEST_DIR="Git_Entrega"

# Validar conexión SSH
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "Conexión SSH con GitHub verificada."
else
    echo "Error: No se pudo autenticar con GitHub por SSH. Revisá la clave." >&2
    exit 1
fi

# Crear carpeta y copiar contenido
cd ~
echo "Creando carpeta temporal: $DEST_DIR"
rm -rf $DEST_DIR
mkdir $DEST_DIR
cp -r UTN-FRA_SO_Examenes RTA_Examen_20250624 202408 $DEST_DIR 2>/dev/null
cp ~/.bash_history $DEST_DIR || echo "⚠️ No se pudo copiar .bash_history (quizás no existe o está vacía)"

# Iniciar Git y subir
cd $DEST_DIR
git init
git config user.name "Cristian Genovese"
git config user.email "cristiangenovese96@gmail.com"

echo "Agregando archivos..."
git add .
git commit -m "Entrega completa del Recuperatorio Integral AySO - Cristian Genovese"
git branch -M main

echo "Subiendo a GitHub: $REMOTE_URL"
git remote add origin "$REMOTE_URL"
git push -u origin main

echo -e "\n  Entrega completada y subida a GitHub con éxito."
echo "Repositorio: https://github.com/cgenovese/$REPO_NAME"

