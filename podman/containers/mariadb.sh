#!/bin/bash

# shellcheck disable=SC2154

function create_mariadb() {
	podman run -d \
		--pod server-pod \
		--name nextcloud-db \
		-e MARIADB_ROOT_PASSWORD="$mariadb_root_pass" \
		-e MARIADB_DATABASE=nextcloud \
		-e MARIADB_USER="$mariadb_user" \
		-e MARIADB_PASSWORD="$mariadb_user_pass" \
		-v "$bind_mount"nc-db-data:/var/lib/mysql:Z \
		"$mysql_image"
	
	sleep 5
}