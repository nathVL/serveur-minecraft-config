#!/bin/bash

chemin_backup="/mnt/usb/backup"

nom_backup="$(date '+%d-%m-%Y_%H-%M-%S')"
toBackup="/home/nathan/paper-mc/data/world /home/nathan/paper-mc/data/world_nether /home/nathan/paper-mc/data/world_the_end"

if [ ! -d "$chemin_backup" ]; then
    mkdir -p "$chemin_backup/1"
fi

# Renommer le dossier
nom_dossier=$(find "$chemin_backup" -mindepth 1 -maxdepth 1 -type d)
mv "$nom_dossier" "$chemin_backup/$nom_backup"
echo "--Debut de la sauvegarde dans $chemin_backup/$nom_backup--"

# echo "Fermeture du serveur"



function backupDirectory() {
    chemin_destination="$chemin_backup/$nom_backup"
    cp -a "$1" "$chemin_destination"
}

for rep in $toBackup; do
    echo "Sauvegarde de $rep"
    backupDirectory "$rep"
done


# echo "Ouverture du serveur"

echo "--Fin--"
