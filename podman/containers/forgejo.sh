#!/bin/bash

# shellcheck disable=SC2154

function create_forgejo() {
	podman run -d \
  		--pod server-pod \
		--name forgejo \
		-e FORGEJO__server__PROTOCOL=http \
		-e FORGEJO__server__DOMAIN="$forgejo_server_domain" \
		-e FORGEJO__server__ROOT_URL="$forgejo_server_root_url" \
		-e FORGEJO__server__HTTP_ADDR=0.0.0.0 \
		-e FORGEJO__server__HTTP_PORT=3000 \
		-e FORGEJO__database__DB_TYPE=postgres \
		-e FORGEJO__database__HOST="$forgejo_db_host" \
		-e FORGEJO__database__NAME="forgejo" \
		-e FORGEJO__database__USER="$forgejo_db_user" \
		-e FORGEJO__database__PASSWD="$forgejo_db_pass" \
		-e FORGEJO__security__INSTALL_LOCK=true \
		-v "$bind_mount"forgejo-data:/var/lib/gitea:Z,U \
		-v "$bind_mount"forgejo-config:/etc/gitea:Z,U \
		"$forgejo_image"
}