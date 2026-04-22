#!/bin/bash

# shellcheck disable=SC2154

function create_pgadmin() {
	podman run -d \
		--pod server-pod \
		--name pgadmin \
		-e PGADMIN_DEFAULT_EMAIL="$pgadmin_email" \
		-e PGADMIN_DEFAULT_PASSWORD="$pgadmin_password" \
		-e PGADMIN_LISTEN_PORT=5050 \
		-v "$bind_mount"pgadmin:/var/lib/pgadmin:Z,U \
		"$pgadmin_image"
}