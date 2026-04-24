#!/bin/bash

# shellcheck disable=SC1091
# shellcheck disable=SC2154

source variables.sh

# Remove 'sudo' if you want to run the script without root privileges.
# As ROOT containers are stored in /var/lib/containers/storage
# As ROOTLESS containers are stored in $HOME/.local/share/containers/storage

function root_containers() {
	sudo podman pod create --name nextcloud-pod \
		--security-opt label=disable \
		-p 80:80

	sudo podman run -d \
		--security-opt label=disable \
		--pod nextcloud-pod \
		--name nextcloud-redis \
		"$redis_image" redis-server --requirepass "$redis_pass"

	sudo podman run -d \
		--security-opt label=disable \
		--pod nextcloud-pod \
		--name nextcloud-db \
		-e MARIADB_ROOT_PASSWORD="$mariadb_root_pass" \
		-e MARIADB_DATABASE=nextcloud \
		-e MARIADB_USER="$mariadb_user" \
		-e MARIADB_PASSWORD="$mariadb_user_pass" \
		-v mariadb-data:/var/lib/mysql:Z \
		"$mariadb_image"

	sudo podman run -d \
		--security-opt label=disable \
		--pod nextcloud-pod \
		--name nextcloud \
		-e MYSQL_DATABASE=nextcloud \
		-e MYSQL_USER="$mariadb_user" \
		-e MYSQL_PASSWORD="$mariadb_user_pass" \
		-e MYSQL_HOST=127.0.0.1 \
		-e REDIS_HOST=127.0.0.1 \
		-e REDIS_HOST_PASSWORD="$redis_pass" \
		-e NEXTCLOUD_ADMIN_USER="$nc_admin_user" \
		-e NEXTCLOUD_ADMIN_PASSWORD="$nc_admin_user_pass" \
		-e TRUSTED_PROXIES=127.0.0.1 \
		-e OVERWRITEPROTOCOL=http \
		-e OVERWRITEHOST="$nc_overwrite_host" \
		-e NEXTCLOUD_TRUSTED_DOMAINS="$nc_trusted_domains" \
		-v nextcloud:/var/www/html:Z \
		-v nextcloud-data:/var/www/html/data:Z \
		-v nextcloud-apps:/var/www/custom_apps:Z \
		-v nextcloud-themes:/var/www/html/themes:Z \
		"$nc_image"
}

function rootless_containers() {
	podman pod create --name nextcloud-pod \
		-p 80:80

	podman run -d \
		--pod nextcloud-pod \
		--name nextcloud-redis \
		redis:latest redis-server --requirepass "$redis_pass"

	podman run -d \
		--pod nextcloud-pod \
		--name nextcloud-db \
		-e MARIADB_ROOT_PASSWORD="$mariadb_root_pass" \
		-e MARIADB_DATABASE=nextcloud \
		-e MARIADB_USER="$mariadb_user" \
		-e MARIADB_PASSWORD="$mariadb_user_pass" \
		-v mariadb-data:/var/lib/mysql:Z \
		"$mariadb_image"

	podman run -d \
		--pod nextcloud-pod \
		--name nextcloud \
		-e MYSQL_DATABASE=nextcloud \
		-e MYSQL_USER="$mariadb_user" \
		-e MYSQL_PASSWORD="$mariadb_user_pass" \
		-e MYSQL_HOST=127.0.0.1 \
		-e REDIS_HOST=127.0.0.1 \
		-e REDIS_HOST_PASSWORD="$redis_pass" \
		-e NEXTCLOUD_ADMIN_USER="$nc_admin_user" \
		-e NEXTCLOUD_ADMIN_PASSWORD="$nc_admin_user_pass" \
		-e TRUSTED_PROXIES=127.0.0.1 \
		-e OVERWRITEPROTOCOL=http \
		-e OVERWRITEHOST="$nc_overwrite_host" \
		-e NEXTCLOUD_TRUSTED_DOMAINS="$nc_trusted_domains" \
		-v nextcloud:/var/www/html:Z \
		-v nextcloud-data:/var/www/html/data:Z \
		-v nextcloud-apps:/var/www/custom_apps:Z \
		-v nextcloud-themes:/var/www/html/themes:Z \
		"$nc_image"
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
