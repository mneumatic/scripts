#!/bin/bash

# Check if container is running, if not start
if ! podman ps --format '{{.Names}}' | grep -q postgres; then
    echo "Starting postgres container..."
    podman start postgres
    sleep 2 # Sleep before starting following container to make sure initialization is complete
fi

if ! podman ps --format '{{.Names}}' | grep -q pgadmin; then
    echo "Starting pgadmin container..."
    podman start pgadmin
fi

# Open Browser
xdg-open http://localhost:8080 2>/dev/null