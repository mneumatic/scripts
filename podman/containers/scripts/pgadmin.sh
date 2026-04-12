#!/bin/bash


function install_pgadmin() {
    echo ""
    read -p "Enter the email for pgAdmin: " pgadmin_email
    read -p "Enter the password for pgAdmin: " pgadmin_password
    read -p "Enter post (leave blank for default: 8080): " pgadmin_port
    read -p "Enter the path for pgAdmin data (leave blank for default: pgadmin): " pgadmin_data_path

    echo ""
    echo "EMAIL: $pgadmin_email"
    echo "PASSWORD: $pgadmin_password"
    echo "PORT: ${pgadmin_port:-8080}"
    echo "DATA PATH: ${pgadmin_data_path:-pgadmin}"
    echo ""

 while true; do
    # Prompt – you can customise the prompt text as you like
    read -rp "Do you want to continue? (yes/no/quit): " answer

    # Make the test case‑insensitive by converting to lower case
    case "${answer,,}" in
        yes|y) break;;
        no|n) install_pgadmin; break;;  # Restart the function to ask for inputs again
        quit|q) echo "Installation cancelled. Exiting."; exit 0;;
        *) echo "Unrecognized input. Please type y/yes, n/no, or q/quit.";;
    esac
done

    echo ""
    echo "Creating postgres-net network..."
    podman network create postgres-net
    echo "Done."

    echo ""
    echo "Creating pgAdmin container..."
    podman run -d --name pgadmin --network postgres-net -p ${pgadmin_port:-8080}:80 -e PGADMIN_DEFAULT_EMAIL="$pgadmin_email" -e PGADMIN_DEFAULT_PASSWORD="$pgadmin_password" -v ${pgadmin_data_path:-pgadmin}:/var/lib/pgadmin:Z,U -d dpage/pgadmin4
    echo "Done."
}
