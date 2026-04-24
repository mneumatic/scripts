#!/bin/bash

# shellcheck disable=SC1091
# shellcheck disable=SC2154

source variables.sh

# Remove 'sudo' if you want to run the script without root privileges.
# As ROOT containers are stored in /var/lib/containers/storage
# As ROOTLESS containers are stored in $HOME/.local/share/containers/storage

function root_containers() {
	sudo podman pod create --name forgejo-pod \
		--security-opt label=disable \
		-p 80:80 \
		-p 3000:3000 \
		-p 2222:22 \
		-p 5050:5050

	sudo podman run -d \
		--security-opt label=disable \
		--pod forgejo-pod \
		--name postgres \
		-v postgres-data:/var/lib/postgresql/data:Z \
		-e PGDATA=/var/lib/postgresql/data \
		-e POSTGRES_USER="$psql_user" \
		-e POSTGRES_PASSWORD="$psql_pass" \
		-e POSTGRES_DB="forgejo" \
		"$psql_image"

	sudo podman run -d \
		--security-opt label=disable \
		--pod forgejo-pod \
		--name pgadmin \
		-e PGADMIN_DEFAULT_EMAIL="$pgadmin_email" \
		-e PGADMIN_DEFAULT_PASSWORD="$pgadmin_password" \
		-e PGADMIN_LISTEN_PORT="$pgadmin_http_port" \
		-v pgadmin-data:/var/lib/pgadmin:Z \
		"$pgadmin_image"


	sudo podman run -d \
		--security-opt label=disable \
  		--pod forgejo-pod \
		--name forgejo \
		-e FORGEJO__server__PROTOCOL=http \
		-e FORGEJO__server__DOMAIN="$forgejo_server_domain" \
		-e FORGEJO__server__ROOT_URL="$forgejo_server_root_url" \
		-e FORGEJO__server__HTTP_ADDR=0.0.0.0 \
		-e FORGEJO__server__HTTP_PORT="$forgejo_http_port" \
		-e FORGEJO__database__DB_TYPE="postgres" \
		-e FORGEJO__database__HOST=127.0.0.1:5432 \
		-e FORGEJO__server__SSH_PORT=2222 \
		-e FORGEJO__database__NAME="forgejo" \
		-e FORGEJO__database__USER="$forgejo_db_user" \
		-e FORGEJO__database__PASSWD="$forgejo_db_pass" \
		-e FORGEJO__security__INSTALL_LOCK=true \
		-v forgejo-data:/data:Z \
		"$forgejo_image"
}

function rootless_containers() {
	podman pod create --name forgejo-pod \
		-p 80:80 \
		-p 3000:3000 \
		-p 2222:22 \
		-p 5050:5050

	podman run -d \
		--pod forgejo-pod \
		--name postgres \
		-v postgres-data:/var/lib/postgresql/data \
		-e PGDATA=/var/lib/postgresql/data:Z \
		-e POSTGRES_USER="$psql_user" \
		-e POSTGRES_PASSWORD="$psql_pass" \
		-e POSTGRES_DB="forgejo" \
		"$psql_image"

	podman run -d \
		--pod forgejo-pod \
		--name pgadmin \
		-e PGADMIN_DEFAULT_EMAIL="$pgadmin_email" \
		-e PGADMIN_DEFAULT_PASSWORD="$pgadmin_password" \
		-e PGADMIN_LISTEN_PORT="$pgadmin_http_port" \
		-v pgadmin-data:/var/lib/pgadmin:Z \
		"$pgadmin_image"

	podman run -d \
  		--pod forgejo-pod \
		--name forgejo \
		-e FORGEJO__server__PROTOCOL=http \
		-e FORGEJO__server__DOMAIN="$forgejo_server_domain" \
		-e FORGEJO__server__ROOT_URL="$forgejo_server_root_url" \
		-e FORGEJO__server__HTTP_ADDR=0.0.0.0 \
		-e FORGEJO__server__HTTP_PORT="$forgejo_http_port" \
		-e FORGEJO__database__DB_TYPE="postgres" \
		-e FORGEJO__database__HOST=127.0.0.1:5432 \
		-e FORGEJO__server__SSH_PORT=2222 \
		-e FORGEJO__database__NAME="forgejo" \
		-e FORGEJO__database__USER="$forgejo_db_user" \
		-e FORGEJO__database__PASSWD="$forgejo_db_pass" \
		-e FORGEJO__security__INSTALL_LOCK=true \
		-v forgejo-data:/data:Z \
		"$forgejo_image"
}

while true; do
	echo 'Enter "root" for ROOT Containers'
	echo 'Leave blank for ROOTLESS Containers'
	echo 'Enter "q" to quit.'
	echo 
    read -r -p "Input Selection: " input

    case "${input,,}" in
        root|ROOT)
            echo "Root mode selected."
			root_containers
            break;;
        "")
            echo "Rootless mode selected."
			rootless_containers
            break;;
		q|Q)
			echo "Goodbye"
			exit 0;;
        *)
            echo "Invalid input – please type 'root' or just press Enter.";;
    esac
done
