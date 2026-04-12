#!/bin/bash

install_postgres() {
    echo ""
    read -p "Enter Postgres username (default: $USER): " pg_user
    read -p "Enter Postgres password: " pg_password
    read -p "Enter port for Postgres (leave blank for default: 5432): " pg_port
    read -p "Enter Postgres database name (default: postgres): " pg_db
    read -p "Enter the path for Postgres data (leave blank for default: postgres): " pg_data_path
    read -p "Enter Podman/Docker image tag for Postgres (leave blank for default: postgres:latest): " pg_image_tag
    echo ""

    echo "USERNAME: ${pg_user:-$USER}"
    echo "PASSWORD: $pg_password"
    echo "PORT: ${pg_port:-5432}"
    echo "DATABASE NAME: ${pg_db:-postgres}"
    echo "DATA PATH: ${pg_data_path:-postgres}"
    echo "IMAGE TAG: ${pg_image_tag:-postgres:latest}"
    echo ""

    while true; do
        read -rp "Do you want to continue? (yes/no/quit): " answer

        case "${answer,,}" in
            yes|y) break;;
            no|n) install_postgres; break;;
            quit|q) echo "Installation cancelled. Exiting."; exit 0;;
            *) echo "Unrecognized input. Please type y/yes, n/no, or q/quit.";;
        esac
    done

    echo ""
    echo "Creating postgres-net network..."
    podman network create postgres-net
    echo "Done."

    echo ""
    echo "Creating Postgres container..."
    podman run -d --name postgres --network postgres-net -p ${pg_port:-5432}:5432 -e PGDATA=/var/lib/postgres/data/pgdata -v ${pg_data_path:-postgres}:/var/lib/postgres/data:Z,U -e POSTGRES_USER="${pg_user:-$USER}" -e POSTGRES_PASSWORD="$pg_password" -e POSTGRES_DB="${pg_db:-postgres}" ${pg_image_tag:-docker.io/library/postgres:latest}
    echo "Done."
}