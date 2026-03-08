#!/bin/bash

# Variablen
ISCSI_TARGET="iqn.2005-10.org.freenas.ctl:target02"
ISCSI_IP="192.168.10.12"
MOUNT_POINT="/mnt/backup"
BACKUP_SOURCE1="/var/www"
BACKUP_SOURCE2="/etc"
DATE=$(date +"%Y-%m-%d")
BACKUP_DIR="$MOUNT_POINT/$DATE"

# iSCSI-Target mounten
sudo iscsiadm -m node -T $ISCSI_TARGET -p $ISCSI_IP -l

# Warten, bis das iSCSI-Target verfügbar ist
sleep 5

# Verzeichnis erstellen, wenn nicht vorhanden
if [ ! -d "$MOUNT_POINT" ]; then
    sudo mkdir -p $MOUNT_POINT
fi

# iSCSI-Target mounten
sudo mount /dev/disk/by-path/ip-$ISCSI_IP:3260-iscsi-$ISCSI_TARGET-lun-0-part1 $MOUNT_POINT

# Backup-Verzeichnis erstellen
sudo mkdir -p $BACKUP_DIR

# Backup erstellen
sudo rsync -a $BACKUP_SOURCE1 $BACKUP_DIR
sudo rsync -a $BACKUP_SOURCE2 $BACKUP_DIR

# iSCSI-Target aushängen
sudo umount $MOUNT_POINT

# iSCSI-Target logout
sudo iscsiadm -m node -T $ISCSI_TARGET -p $ISCSI_IP -u
