#!/bin/bash

# Configuration
BACKUP_DIR="$HOME/podman_backups"
mkdir -p "$BACKUP_DIR"

DATE=$(date +%F_%H%M%S)

echo "1. Stopping all containers..."
CONTAINERS=$(podman ps -q)

if [ -n "$CONTAINERS" ]; then
    podman stop -t 10 $CONTAINERS
    echo "   -> Waiting for volumes to unmount..."
    # Wait until all volumes are fully unmounted
    while podman volume ls -q | xargs -I {} podman volume inspect {} -f '{{.Status.State}}' 2>/dev/null | grep -q "mounted"; do
        sleep 1
    done
    echo "   -> All volumes unmounted."
else
    echo "   -> No running containers found."
fi

echo "2. Backing up all volumes..."
podman volume ls -q | while read VOLUME; do
    # Filter out anonymous volumes (temporary data)
    IS_ANON=$(podman volume inspect "$VOLUME" -f '{{.Anonymous}}' 2>/dev/null)
    if [ "$IS_ANON" = "true" ]; then
        echo "   -> Skipping anonymous volume: $VOLUME"
        continue
    fi

    echo "   - Tarring: $VOLUME"
    # Backup with busybox (required for rootful environments)
    podman run --rm \
        -v "$VOLUME":/data \
        -v "$BACKUP_DIR":/backup \
        busybox tar -czf "/backup/${VOLUME}_${DATE}.tar.gz" -C /data .

    # Fallback: If file is < 1KB, it's likely empty/junk. Delete it.
    FILE_SIZE=$(stat -c%s "$BACKUP_DIR/${VOLUME}_${DATE}.tar.gz" 2>/dev/null || echo "0")
    if [ "$FILE_SIZE" -lt 1024 ]; then
        rm -f "$BACKUP_DIR/${VOLUME}_${DATE}.tar.gz"
        echo "       -> Skipped (Volume appears empty)"
    fi
done

if [ -n "$CONTAINERS" ]; then
    echo "3. Starting all containers..."
    podman start $CONTAINERS
    echo "   -> Containers started."
fi

echo "4. Backup complete! Files are in: $BACKUP_DIR"
ls -lh "$BACKUP_DIR"