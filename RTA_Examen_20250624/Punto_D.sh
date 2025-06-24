#!/bin/bash

# Punto D - Ejecución de roles con Ansible

# (opcional) Configurar clave pública si no existe
mkdir -p ~/.ssh
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Ir a la carpeta del proyecto
cd ~/202408/ansible || exit

# Ejecutar playbook
ansible-playbook -i inventory/hosts playbook.yml

