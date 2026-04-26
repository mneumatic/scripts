#!/bin/bash

# Configuration
BACKUP_DIR="$HOME/podman_backups"
DATE=$(date +%F_%H%M%S)

# Setup backup directory
mkdir -p "$BACKUP_DIR"

echo "1. Stopping all containers..."
# Save the IDs of all currently running containers so we can restart them later
CONTAINERS=$(podman ps -q)

if [ -n "$CONTAINERS" ]; then
    podman stop $CONTAINERS
    echo "   -> Containers stopped."
else
    echo "   -> No running containers found."
fi

echo "2. Backing up all volumes..."
# Iterate over all named volumes and tar them to the backup folder
podman volume ls -q | while read VOLUME; do
    echo "   - Tarring: $VOLUME"
    podman run --rm \
        -v "$VOLUME":/source \
        -v "$BACKUP_DIR":/backup \
        alpine tar -czf "/backup/${VOLUME}_${DATE}.tar.gz" /source
done

if [ -n "$CONTAINERS" ]; then
    echo "3. Starting all containers..."
    podman start $CONTAINERS
    echo "   -> Containers started."
fi

echo "4. Backup complete! Files are in: $BACKUP_DIR"
ls -lh "$BACKUP_DIR"