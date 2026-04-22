#!/bin/bash

# shellcheck disable=SC2154

function create_postgres() {
	podman run -d \
		--pod server-pod \
		--name postgres \
		-v "$bind_mount"postgres:/var/lib/postgresql:Z \
		-e PGDATA=/var/lib/postgresql/data \
		-e POSTGRES_USER="$psql_user" \
		-e POSTGRES_PASSWORD="$psql_pass" \
		-e POSTGRES_DB="$psql_db" \
		"$psql_image"

	sleep 5
}