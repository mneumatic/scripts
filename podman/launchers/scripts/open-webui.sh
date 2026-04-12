#!/bin/bash

# Check if container is running, if not start
if ! podman ps --format '{{.Names}}' | grep -q ollama; then
    echo "Starting ollama container..."
    podman start ollama
    sleep 2 # Sleep before starting following container to make sure initialization is complete
fi

if ! podman ps --format '{{.Names}}' | grep -q open-webui; then
    echo "Starting open-webui container..."
    podman start open-webui
    sleep 5
fi

# Open Browser
xdg-open http://localhost:3001 2>/dev/null
