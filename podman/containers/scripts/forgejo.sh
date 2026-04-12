#!/bin/bash

function install_forgejo() {
    echo ""
    read -p "Enter Forgejo username (default: $USER):" forgejo_username
    read -p "Enter Forgejo password:" forgejo_password
    read -p "Enter Forgejo port (leave blank for default: 3000):" forgejo_port
    read -p "Enter databast type for Forgejo (leave blank for default: postgres):" forgejo_db_type
    read -p "Enter database host for Forgejo (leave blank for default: postgres:5432):" forgejo_db_host
    read -p "Enter Forgejo database name (default: forgejo):" forgejo_db_name
    read -p "Enter Forgejo SSH port (leave blank for default: 2222):" forgejo_ssh_port
    read -p "Enter the path for Forgejo data (leave blank for default: forgejo):" forgejo_data_path
    read -p "Enter Podman/Docker image tag for Forgejo (leave blank for default: codeberg.org/forgejo/forgejo:latest):" forgejo_image_tag
    echo ""

    echo "USERNAME: ${forgejo_username:-$USER}"
    echo "PASSWORD: $forgejo_password"
    echo "PORT: ${forgejo_port:-3000}"
    echo "DB TYPE: ${forgejo_db_type:-postgres}"
    echo "DB HOST: ${forgejo_db_host:-postgres:5432}"
    echo "DB NAME: ${forgejo_db_name:-forgejo}"
    echo "SSH PORT: ${forgejo_ssh_port:-2222}"
    echo "DATA PATH: ${forgejo_data_path:-forgejo}"
    echo "IMAGE TAG: ${forgejo_image_tag:-codeberg.org/forgejo/forgejo:latest}"
    echo ""

    while true; do
        read -rp "Do you want to continue? (yes/no/quit): " answer

        case "${answer,,}" in
            yes|y) break;;
            no|n) install_forgejo; break;;
            quit|q) echo "Installation cancelled. Exiting."; exit 0;;
            *) echo "Unrecognized input. Please type y/yes, n/no, or q/quit.";;
        esac
    done

    echo ""
    echo "Creating postgres-net network..."
    podman network create postgres-net
    echo "Done."

    echo ""
    echo "Creating Forgejo container..."
    podman run -d --network postgres-net --name forgejo -p ${forgejo_port:-3000}:3000 -p ${forgejo_ssh_port:-2222}:22 -e FORGEJO__database__DB_TYPE=${forgejo_db_type:-postgres} -e FORGEJO__database__HOST=${forgejo_db_host:-postgres:5432} -e FORGEJO__database__NAME=${forgejo_db_name:-forgejo} -e FORGEJO__database__USER="${forgejo_username:-$USER}" -e FORGEJO__database__PASSWD="$forgejo_password" -e FORGEJO__security__INSTALL_LOCK=true -v ${forgejo_data_path:-forgejo}:/var/lib/gitea:Z,U ${forgejo_image_tag:-codeberg.org/forgejo/forgejo:latest}
    echo "Done."
}