#!/bin/bash

function install_open_webui() {
	echo ""
	read -p "Enter the port for Open-WebUI (leave blank for default: 3000): " open_webui_port
	read -p "Enter the path for Open-WebUI data (leave blank for default: open-webui): " open_webui_data_path
	read -p "Enter Podman/Docker image tag for Open-WebUI (leave blank for default: open-webui/open-webui:latest): " open_webui_image_tag
	echo ""

	echo "PORT: ${open_webui_port:-3000}"
	echo "DATA PATH: ${open_webui_data_path:-open-webui}"
	echo "IMAGE TAG: ${open_webui_image_tag:-open-webui/open-webui:latest}"
	echo ""

 while true; do
	# Prompt – you can customise the prompt text as you like
	read -rp "Do you want to continue? (yes/no/quit): " answer

	# Make the test case‑insensitive by converting to lower case
	case "${answer,,}" in
		yes|y) break;;
		no|n) install_open_webui; break;;  # Restart the function to ask for inputs again
		quit|q) echo "Installation cancelled. Exiting."; exit 0;;
		*) echo "Unrecognized input. Please type y/yes, n/no, or q/quit.";;
	esac
done

	echo ""
	echo "Creating ai-net network..."
	podman network create ai-net
	echo "Done."

	echo ""
	echo "Creating Open-WebUI container..."
	podman run -d --name open-webui --network ai-net -p ${open_webui_port:-3000}:8080 -e OLLAMA\_BASE\_URL=http://ollama:11434 -v ${open_webui_data_path:-open-webui}:/app/backend/data:Z ${open_webui_image_tag:-open-webui/open-webui:latest}
	echo "Done."
}