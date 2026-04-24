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
