#!/bin/bash

# shellcheck disable=SC2154

function create_nextcloud() {
	podman run -d \
		--pod server-pod \
		--name nextcloud-app \
		-e MYSQL_DATABASE=nextcloud \
		-e MYSQL_USER="$mysql_user" \
		-e MYSQL_PASSWORD="$mysql_user_pass" \
		-e MYSQL_HOST=127.0.0.1 \
		-e REDIS_HOST=127.0.0.1 \
		-e REDIS_HOST_PASSWORD="$redis_pass" \
		-e NEXTCLOUD_ADMIN_USER="$nc_admin_user" \
		-e NEXTCLOUD_ADMIN_PASSWORD="$nc_admin_user_pass" \
		-e TRUSTED_PROXIES=127.0.0.1 -e OVERWRITEPROTOCOL=http \
		-e OVERWRITEHOST="$nc_overwrite_host" \
		-e NEXTCLOUD_TRUSTED_DOMAINS="$nc_trusted_domains" \
		-v "$bind_mount"nc-data:/var/www/html:Z \
		"$nc_image"
}