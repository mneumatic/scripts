#!/bin/bash

source scripts/postgres.sh
source scripts/pgadmin.sh
source scripts/forgejo.sh
source scripts/open-webui.sh

install_containers() {
	echo ""
	echo "Select a Podman container to create:"
	echo "1) pgAdmin"
	echo "2) postgres"
	echo "3) Forgejo"
	echo "4) Open-WebUI"
	echo "5) All of the above"
	echo "q) Quit"

	while true; do
		# Prompt – you can customise the prompt text as you like
		read -rp "Enter the number corresponding to your choice (1-6 / q to quit): " answer

		# Make the test case‑insensitive by converting to lower case
		case "${answer,,}" in
			1) install_pgadmin; break;;
			2) install_postgres; break;;
			3) install_forgejo; break;;
			4) install_ollama; break;;
			5) install_postgres; install_pgadmin; install_forgejo; install_ollama; break;;
			q|quit) echo "Installation cancelled. Exiting."; exit 0;;
			*) echo "Unrecognized input. Please type a number between 1 and 5 or q to quit.";;
		esac
	done
}
