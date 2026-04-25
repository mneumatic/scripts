#!/bin/bash

set -euo pipefail

# ============================================================================
# Podman Backup Script
# Description: Safely backs up your Nextcloud, Forejo, and MongoDB stack.
# Usage: chmod +x backup.sh && ./backup.sh
# Note: You MUST edit the CONFIGURATION section below before running.
# ============================================================================

# ---------------------------
# CONFIGURATION
# ---------------------------

# 1. Passwords (Required for CLI database access)
MYSQL_ROOT_PASSWORD=""      # <--- Enter your MariaDB root password here
POSTGRES_PASSWORD=""        # <--- Enter your PostgreSQL password here (usually 'postgres')

# 2. Container Names
NC_MARIADB="maria-db"       # Replace with your MariaDB container name
NC_NEXTCLOUD="nextcloud"    # Replace with your Nextcloud container name
NC_REDIS="redis"            # Replace with your Redis container name

FOREJO_APP="forejo"         # Replace with your Forejo container name
FOREJO_PG="postgres-db"     # Replace with your Forejo PostgreSQL container name
FOREJO_PGADMIN="pgadmin"    # Replace with your pgAdmin container name

MONGO_CONTAINER="mongo-db"  # Replace with your MongoDB container name

# 3. Volume Names (REQUIRED)
# Find these via: podman volume ls
NC_NEXTCLOUD_VOL="nextcloud-data" # Nextcloud app data volume name
NC_REDIS_VOL="redis-data"         # Redis data volume name
PGADMIN_VOL="pgadmin-data"        # pgAdmin config volume name
FOREJO_VOL="forejo-data"          # Forejo git storage volume name (unused here but good to have)

# 4. Settings
BACKUP_DIR="/home/$(whoami)/podman_backups"
DATE=$(date +%F)
TIMESTAMP=$(date +%F_%H%M%S)

# Track errors for final report
ERRORS=0

# ---------------------------
# Helper Functions
# ---------------------------

# Error handler
handle_error() {
    local msg="$1"
    echo "ERROR: $msg" >&2
    ERRORS=$((ERRORS + 1))
}

# Helper: Stop container function
stop_container() {
    local container="$1"
    if ! podman inspect "$container" &>/dev/null; then
        handle_error "Container '$container' does not exist. Skipping."
        return 1
    fi
    if [ "$(podman inspect -f '{{.State.Running}}' "$container")" = "true" ]; then
        echo "Stopping $container..."
        if ! podman stop "$container"; then
            handle_error "Failed to stop container '$container'."
            return 1
        fi
    fi
}

# Helper: Start container function
start_container() {
    local container="$1"
    if ! podman inspect "$container" &>/dev/null; then
        handle_error "Container '$container' does not exist. Skipping."
        return 1
    fi
    if [ "$(podman inspect -f '{{.State.Running}}' "$container")" = "false" ]; then
        echo "Starting $container..."
        if ! podman start "$container"; then
            handle_error "Failed to start container '$container'."
            return 1
        fi
    fi
}

# Validate that required volume exists
validate_volume() {
    local vol_name="$1"
    if ! podman volume inspect "$vol_name" &>/dev/null; then
        handle_error "Volume '$vol_name' does not exist. Skipping related backup."
        return 1
    fi
}

# ---------------------------
# SCRIPT LOGIC
# ---------------------------

echo "[$(date)] Starting Podman Backup..."
mkdir -p "$BACKUP_DIR" || handle_error "Failed to create backup directory $BACKUP_DIR"

# ---------------------------
# 1. Nextcloud Pod Backup
# ---------------------------
echo "--- Backing up Nextcloud Pod ---"

# Validate required volumes
validate_volume "$NC_NEXTCLOUD_VOL" || handle_error "Skipping Nextcloud backup due to missing volume."
validate_volume "$NC_REDIS_VOL" || handle_error "Skipping Redis backup due to missing volume."

# A. MariaDB Dump (No need to stop, we just dump)
echo "Dumping MariaDB..."
if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
    if ! podman exec "$NC_MARIADB" mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" --all-databases > "$BACKUP_DIR/mariadb_${TIMESTAMP}.sql"; then
        handle_error "Failed to dump MariaDB database."
    fi
else
    echo "Warning: MYSQL_ROOT_PASSWORD not set in script. Skipping DB dump."
fi

# B. Redis Backup (Must stop to avoid corruption)
echo "Backing up Redis (Stopping container)..."
stop_container "$NC_REDIS" || handle_error "Failed to stop Redis container. Attempting backup anyway..."
if [ "$(podman inspect -f '{{.State.Running}}' "$NC_REDIS" 2>/dev/null || echo "unknown")" != "true" ]; then
    echo "Backing up Redis data..."
    if ! podman run --rm -v "$NC_REDIS_VOL":/source:ro -v "$BACKUP_DIR":/backup alpine tar czf "/backup/redis_${TIMESTAMP}.tar.gz" /source; then
        handle_error "Failed to backup Redis data."
    fi
    start_container "$NC_REDIS" || handle_error "Failed to restart Redis container."
else
    echo "Redis is still running. Attempting backup anyway (risk of corruption)..."
    if ! podman run --rm -v "$NC_REDIS_VOL":/source:ro -v "$BACKUP_DIR":/backup alpine tar czf "/backup/redis_${TIMESTAMP}.tar.gz" /source; then
        handle_error "Failed to backup Redis data."
    fi
fi

# C. Nextcloud Files
echo "Backing up Nextcloud Files..."
if ! podman run --rm -v "$NC_NEXTCLOUD_VOL":/source:ro -v "$BACKUP_DIR":/backup alpine tar czf "/backup/nextcloud_files_${TIMESTAMP}.tar.gz" /source; then
    handle_error "Failed to backup Nextcloud files."
fi

# ---------------------------
# 2. Forejo Pod Backup
# ---------------------------
echo "--- Backing up Forejo Pod ---"

# Validate required volumes
validate_volume "$PGADMIN_VOL" || handle_error "Skipping pgAdmin backup due to missing volume."

# A. Forejo Dump (Includes DB and Files perfectly synced)
echo "Dumping Forejo (DB + Data)..."
if ! podman exec "$FOREJO_APP" gitea dump -c /etc/gitea/app.ini -t /data/dumps; then
    handle_error "Failed to create Forejo dump."
else
    # Get the latest dump filename safely
    LATEST_DUMP_FILE=$(podman exec "$FOREJO_APP" ls -t /data/dumps/gitea-dump-*.zip 2>/dev/null | head -n 1)
    if [ -z "$LATEST_DUMP_FILE" ]; then
        handle_error "No Forejo dump files found in /data/dumps."
    else
        echo "Copying Forejo dump: $LATEST_DUMP_FILE"
        if ! podman cp "$FOREJO_APP":"/data/dumps/$LATEST_DUMP_FILE" "$BACKUP_DIR/forejo_${TIMESTAMP}.zip"; then
            handle_error "Failed to copy Forejo dump file."
        fi
        # Clean up the temporary dump from the container
        if ! podman exec "$FOREJO_APP" rm -f "/data/dumps/$LATEST_DUMP_FILE"; then
            handle_error "Failed to clean up Forejo dump file from container."
        fi
    fi
fi

# B. PostgreSQL Dump
echo "Dumping PostgreSQL..."
if [ -n "$POSTGRES_PASSWORD" ]; then
    if ! podman exec -e PGPASSWORD="$POSTGRES_PASSWORD" "$FOREJO_PG" pg_dumpall -U postgres -w > "$BACKUP_DIR/postgres_${TIMESTAMP}.sql"; then
        handle_error "Failed to dump PostgreSQL database."
    fi
else
    # Try without password (might work if peer auth or no password set)
    if ! podman exec "$FOREJO_PG" pg_dumpall -U postgres > "$BACKUP_DIR/postgres_${TIMESTAMP}.sql"; then
        handle_error "Failed to dump PostgreSQL database (no password provided)."
    fi
fi

# C. pgAdmin (Files only)
echo "Backing up pgAdmin Config..."
if ! podman run --rm -v "$PGADMIN_VOL":/source:ro -v "$BACKUP_DIR":/backup alpine tar czf "/backup/pgadmin_${TIMESTAMP}.tar.gz" /source; then
    handle_error "Failed to backup pgAdmin configuration."
fi

# ---------------------------
# 3. MongoDB Standalone Backup
# ---------------------------
echo "--- Backing up MongoDB ---"

# Dump to temp folder in container, then copy out
if ! podman exec "$MONGO_CONTAINER" mongodump --out /dump; then
    handle_error "Failed to dump MongoDB database."
else
    if ! podman cp "$MONGO_CONTAINER:/dump" "$BACKUP_DIR/mongo_${TIMESTAMP}"; then
        handle_error "Failed to copy MongoDB dump."
    else
        # Clean up the temporary dump from the container
        if ! podman exec "$MONGO_CONTAINER" rm -rf /dump; then
            handle_error "Failed to clean up MongoDB dump directory from container."
        fi
    fi
fi

# ---------------------------
# Cleanup & Report
# ---------------------------
echo "--- Backup Complete ---"
if [ "$ERRORS" -gt 0 ]; then
    echo "WARNING: $ERRORS error(s) occurred during backup. Check above for details."
    exit 1
else
    echo "No errors occurred. Backup successful!"
    ls -lh "$BACKUP_DIR"
    echo "Done."
    exit 0
fi