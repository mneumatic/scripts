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
		-e NEXTCLOUD_FFMPEG_PATH=/usr/bin/ffmpeg \
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
		-e NEXTCLOUD_FFMPEG_PATH=/usr/bin/ffmpeg \
		-v nextcloud:/var/www/html:Z \
		-v nextcloud-data:/var/www/html/data:Z \
		-v nextcloud-apps:/var/www/custom_apps:Z \
		-v nextcloud-themes:/var/www/html/themes:Z \
		"$nc_image"
}

function firewalld_ports() {
	sudo firewall-cmd --zone=public \
		--add-port=80/tcp \
		--permanent
	sudo firewall-cmd --reload
	echo "Containers created."
	echo "Ports opened:"
	sudo firewall-cmd --zone=public --list-ports
	echo "Goodbye."
}

function ufw_ports () {
	sudo ufw allow 80/tcp
	sudo ufw reload
	echo "Containers created."
	echo "Ports opened:"
	sudo ufw status
	echo "Goodbye."
}

function open_ports() {
	while true; do
		read -r -p "Will these containers be running locally? (y or n, q to quit):" input
		case "${input,,}" in
			y|Y)
				echo "Containers created."
				echo "Ports not opened."
				echo "Goodbye."
				break;;
			n|N)
				while true; do
					read -r -p "firewalld or ufw: (f or u, q to quit)" input
					case "${input,,}" in
					f|F)
						firewalld_ports
						break;;
					u|U)
						ufw_ports
						break;;
					q|Q)
						echo "Goodbye"
						exit 0;;
					*)
						echo "Invalid input – please type 'root' or just press Enter.";;
				    esac
				done
				break;;
			q|Q)
				echo "Containers created."
				echo "Ports not opened."
				echo "Goodbye."
				exit 0;;
			*)
				echo "Invalid input. Please enter y or n, q to quit.";;
		esac
	done
}

while true; do
    read -r -p "Create as Root or Rootless? (r or rl, q to quit) " input

    case "${input,,}" in
        r|R)
            echo "Root mode selected."
			root_containers
			open_ports
            break;;
        rl|RL)
            echo "Rootless mode selected."
			rootless_containers
			open_ports
            break;;
		q|Q)
			echo "Goodbye"
			exit 0;;
        *)
            echo "Invalid input – please type 'root' or just press Enter.";;
    esac
done
