#!/bin/bash


function install_launchers() {
	# Variables for local directories
	local local_app_dir="$HOME/.local/share/applications"
	local local_icons_dir="$HOME/.local/share/icons/scalable/apps"
	local local_bin_dir="$HOME/.local/bin"

	echo ""
	echo "This script will create desktop entries for pgAdmin, Forgejo, and Open WebUI Podman Containers."
	echo "It will also ensure that the necessary local directories exist."
	echo ""
	echo "Please choose the application you want to create a desktop entry for:"
	echo "1) pgAdmin"
	echo "2) Forgejo"
	echo "3) Open Web UI"
	echo "4) All of the above"
	echo "q) Quit"

	while true; do
		# Prompt – you can customise the prompt text as you like
		read -rp "Enter the number corresponding to your choice (1-6 / q to quit): " answer

		# Make the test case‑insensitive by converting to lower case
		case "${answer,,}" in
			1) check_necessary_directories; s1="pgadmin"; copy_icon; copy_script; create_desktop_file; break;;
			2) check_necessary_directories; s1="forgejo"; copy_icon; copy_script; create_desktop_file; break;;
			3) check_necessary_directories; s1="open-webui"; copy_icon; copy_script; create_desktop_file; break;;
			4) check_necessary_directories; s1="pgadmin"; copy_icon; copy_script; create_desktop_file; s1="forgejo"; copy_icon; copy_script; create_desktop_file; s1="open-webui"; copy_icon; copy_script; create_desktop_file; break;;
			q|quit) echo "Installation cancelled. Exiting."; exit 0;;
			*) echo "Unrecognized input. Please type a number between 1 and 4 or q to quit.";;
		esac
	done

}  

# Check for necessary directories and create them if they don't exist
function check_necessary_directories() {
    if [ ! -d "$local_app_dir" ]; then
        mkdir -p "$local_app_dir"
    fi

    if [ ! -d "$local_icons_dir" ]; then
        mkdir -p "$local_icons_dir"
    fi

    if [ ! -d "$local_bin_dir" ]; then
        mkdir -p "$local_bin_dir"
    fi
}

# Function to create desktop file
function create_desktop_file() {
    echo "Creating desktop file at $local_app_dir/$s1.desktop..."
    cat <<EOL > "$local_app_dir/$s1.desktop" 
[Desktop Entry]
Type=Application
Name=pgAdmin
Exec=$local_bin_dir/$s1.sh
Icon=$local_icons_dir/$s1.svg
Terminal=false
EOL
}

function copy_icon() {
    cp -r "icons/$s1.svg" "$local_icons_dir/"
}

function copy_script() {
    cp -r "scripts/$s1.sh" "$local_bin_dir/"
    chmod +x "$local_bin_dir/$s1.sh"
}
