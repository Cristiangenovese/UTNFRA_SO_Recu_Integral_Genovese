#!/bin/bash

set -e

echo ">>> ATENCIÓN: Este script va a modificar discos. Asegurate que /dev/sdc, /dev/sdd y /dev/sde están vacíos."
read -p "Presioná ENTER para continuar o CTRL+C para cancelar."
sleep 2

### Crear particiones automáticamente

echo ">>> Creando particiones en /dev/sdc..."
sleep 1
sudo fdisk /dev/sdc <<EOF
n
p
1

+2G
n
p
2

+512M
t
2
82
w
EOF
sudo partprobe /dev/sdc
sleep 1

echo ">>> Creando partición única en /dev/sdd..."
sleep 1
sudo fdisk /dev/sdd <<EOF
n
p
1


w
EOF
sudo partprobe /dev/sdd
sleep 1

echo ">>> Creando partición única en /dev/sde..."
sleep 1
sudo fdisk /dev/sde <<EOF
n
p
1


w
EOF
sudo partprobe /dev/sde
sleep 2

### Crear LVM y formatear

echo ">>> Inicializando volúmenes físicos..."
sudo pvcreate /dev/sdc1 /dev/sdd1 /dev/sde1
sleep 1

echo ">>> Creando VG y LV para swap..."
sudo vgcreate vg_temp /dev/sdc1
sudo lvcreate -n lv_swap -l 100%FREE vg_temp
sudo mkswap /dev/mapper/vg_temp-lv_swap
sudo swapon /dev/mapper/vg_temp-lv_swap
sleep 1

echo ">>> Activando swap en /dev/sdc2..."
sudo mkswap /dev/sdc2
sudo swapon /dev/sdc2
sleep 1

echo ">>> Creando VG y LVs para datos..."
sudo vgcreate vg_datos /dev/sdd1 /dev/sde1
sudo lvcreate -L 10M -n lv_docker vg_datos
sudo lvcreate -L 1.5G -n lv_multimedia vg_datos
sleep 2

echo ">>> Formateando volúmenes..."
sudo mkfs.ext4 /dev/mapper/vg_datos-lv_docker
sudo mkfs.ext4 /dev/mapper/vg_datos-lv_multimedia
sleep 1

### Montajes y fstab

echo ">>> Montando volúmenes..."
sudo mkdir -p /var/lib/docker
sudo mkdir -p /Multimedia
sudo mount /dev/mapper/vg_datos-lv_docker /var/lib/docker/
sudo mount /dev/mapper/vg_datos-lv_multimedia /Multimedia/
sleep 1

UUID_DOCKER=$(blkid -s UUID -o value /dev/mapper/vg_datos-lv_docker)
UUID_MULTI=$(blkid -s UUID -o value /dev/mapper/vg_datos-lv_multimedia)
UUID_SWAP2=$(blkid -s UUID -o value /dev/sdc2)
UUID_SWAP_LVM=$(blkid -s UUID -o value /dev/mapper/vg_temp-lv_swap)

echo ">>> Agregando entradas al /etc/fstab..."
echo "UUID=$UUID_DOCKER /var/lib/docker ext4 defaults 0 0" | sudo tee -a /etc/fstab
echo "UUID=$UUID_MULTI /Multimedia ext4 defaults 0 0" | sudo tee -a /etc/fstab
echo "UUID=$UUID_SWAP2 none swap sw 0 0" | sudo tee -a /etc/fstab
echo "UUID=$UUID_SWAP_LVM none swap sw 0 0" | sudo tee -a /etc/fstab

echo ">>> Verificando con mount y swapon:"
mount | grep -E 'docker|Multimedia'
swapon --show

echo ">>> Punto A finalizado correctamente."

