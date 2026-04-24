#!/bin/bash

# shellcheck disable=SC1091
# shellcheck disable=SC2154

source variables.sh

# Remove 'sudo' if you want to run the script without root privileges.
# As ROOT containers are stored in /var/lib/containers/storage
# As ROOTLESS containers are stored in $HOME/.local/share/containers/storage

function root_containers() {
	sudo podman run -d \
		--security-opt label=disable \
		--name mongo \
		-p 27017:27017 \
		-e MONGODB_INITDB_ROOT_USERNAME="$mongo_root_user" \
		-e MMONGODB_INITDB_ROOT_PASSWORD="$mongo_root_pass" \
		-v mongodb:/data/db:Z \
		"$mongo_image"
}

function rootless_containers() {
	podman run -d \
		--name mongo \
		-p 27017:27017 \
		-e MONGODB_INITDB_ROOT_USERNAME="$mongo_root_user" \
		-e MONGODB_INITDB_ROOT_PASSWORD="$mongo_root_pass" \
		-v mongodb:/data/db:Z \
		"$mongo_image"

	sudo -E podman exec mongo bash -c 'mongosh -u $mongo_root_user -p $mongo_root_pass --authenticationDatabase admin --eval "db.runCommand({connectionStatus: 1})"'
}

function firewalld_ports() {
	sudo firewall-cmd --zone=public \
		--add-port=27017/tcp \
		--permanent
	sudo firewall-cmd --reload
	echo "Containers created."
	echo "Ports opened:"
	sudo firewall-cmd --zone=public --list-ports
	echo "Goodbye."
}

function ufw_ports () {
	sudo ufw allow 27017/tcp
	sudo ufw reload
	echo "Containers created."
	echo "Ports opened:"
	sudo ufw status
	echo "Goodbye."
}

function open_ports() {
	while true; do
		read -r -p "Will these containers be running locally | Accessed locally? (y or n, q to quit):" input
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
