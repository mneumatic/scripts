#!/bin/bash

install_ollama() {
	echo ""
	read -p "Enter port for Ollama (leave blank for default: 11434): " ollama_port
	read -p "Enter the path for Ollama data (leave blank for default: ollama): " ollama_data_path
	read -p "Enter Podman/Docker image tag for Ollama (leave blank for default: ollama/ollama:latest): " ollama_image_tag
	read -p "Enter GPU device for Ollama (leave blank for default:): " ollama_gpu_device
	read -p "Enter SELinux context for Ollama (leave blank for default: disable): " ollama_selinux_context
	echo ""

	echo "PORT: ${ollama_port:-11434}"
	echo "DATA PATH: ${ollama_data_path:-ollama}"
	echo "IMAGE TAG: ${ollama_image_tag:-ollama/ollama:latest}"
	echo "GPU DEVICE: ${ollama_gpu_device:-none}"
	echo "SELINUX CONTEXT: ${ollama_selinux_context:-disable}"
	echo ""

	while true; do
		read -rp "Do you want to continue? (yes/no/quit): " answer

		case "${answer,,}" in
			yes|y) break;;
			no|n) install_ollama; break;;
			quit|q) echo "Installation cancelled. Exiting."; exit 0;;
			*) echo "Unrecognized input. Please type y/yes, n/no, or q/quit.";;
		esac
	done

	echo ""
	echo "Creating ai-net network..."
	podman network create ai-net
	echo "Done."

	echo ""
	echo "Creating Ollama container..."
	podman run -d --network ai-net --device ${ollama_gpu_device:-none} --security-opt=label=${ollama_selinux_context:-disable} --name ollama -v ${ollama_data_path:-ollama}:/root/.ollama:Z -p ${ollama_port:-11434}:${ollama_port:-11434} ${ollama_image_tag:-ollama/ollama:latest}
	echo "Done."
	
	while true; do
		read -rp "Would you like to install open-webui as well? (yes/no/quit): " answer

		case "${answer,,}" in
			yes|y) install_open_webui; break;;
			no|n) break;;
			quit|q) echo "Installation cancelled. Exiting."; exit 0;;
			*) echo "Unrecognized input. Please type y/yes, n/no, or q/quit.";;
		esac
}