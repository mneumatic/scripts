#!/bin/bash

# Check if container is running, if not start
if ! podman ps --format '{{.Names}}' | grep -q postgresql; then
    echo "Starting postgresql container..."
    podman start postgresql
    sleep 2 # Sleep before starting following container to make sure initialization is complete
fi

if ! podman ps --format '{{.Names}}' | grep -q forgejo; then
    echo "Starting forgejo container..."
    podman start forgejo
fi

# Open Browser
xdg-open http://localhost:3000 2>/dev/null
