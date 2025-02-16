#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "❌ Ce script doit être exécuté en tant que root (utilisez sudo)." >&2
    exit 1
fi

BACKUP_PATH="/mnt/usb/backup/test"
BACKUP_NAME="$(date '+%d-%m-%Y_%H-%M-%S')"
REPOSITORY_TO_BACKUP="/home/nathan/paper-mc/data/server.properties /home/nathan/paper-mc/data/config /home/nathan/paper-mc/data/world_nether /home/nathan/paper-mc/data/worldold /home/nathan/paper-mc/data/world_the_end /home/nathan/paper-mc/data/world"

CONTAINER_NAME="minecraft-server"
RCON_PASSWORD="rC0npassword"

# Créer un dossier si il n'y a pas encore de backup
if [ ! -d "$BACKUP_PATH" ]; then
    mkdir -p "$BACKUP_PATH/1"
fi

# Renommer le dossier
nom_dossier=$(find "$BACKUP_PATH" -mindepth 1 -maxdepth 1 -type d)
mv "$nom_dossier" "$BACKUP_PATH/$BACKUP_NAME"
echo "--Debut de la sauvegarde dans $BACKUP_PATH/$BACKUP_NAME--"


# Fermeture du serveur
docker exec -it minecraft-server rcon-cli --password $RCON_PASSWORD "say Le serveur va faire une backup"
docker exec -it minecraft-server rcon-cli --password $RCON_PASSWORD "say Fermeture dans 5 secondes"
for i in {4..1}; do
    docker exec -it minecraft-server rcon-cli --password $RCON_PASSWORD "say $i..."
    sleep 1
done
docker exec -it minecraft-server rcon-cli --password $RCON_PASSWORD "say Fermeture"
sleep 1
docker compose down


function backupDirectory() {
    # Backup le dossier donné
    chemin_destination="$BACKUP_PATH/$BACKUP_NAME"
    rsync -a --info=progress2 "$1" "$chemin_destination"
}

# Backup tout les dossiers
for rep in $REPOSITORY_TO_BACKUP; do
    echo "Sauvegarde de $rep"
    backupDirectory "$rep"
done

# Reouvrir le serveur
echo "Ouverture du serveur"
docker compose up -d

echo "--Fin--"
