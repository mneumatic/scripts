#!/bin/bash
# Author: Michael Neumann
# Github: mneumatic
# email: mneumatic@proton.me
# version: 1.0

# A simple script to rebase to a new image on Fedora Silverblue, while also handling the uninstallation and reinstallation of rpm-fusion release packages.
# Usage: Just run the script and follow the prompts. You will need to provide a valid image name to rebase to, e.g. fedora:fedora/44/x86_64/silverblue. 
# The script will handle the rest, including uninstalling old rpm-fusion release packages, rebasing to the new image, and optionally reinstalling rpm-fusion for the new release. 
# Yes I know this script is a bit overkill for what it does, but I wanted to make it as user-friendly and foolproof as possible, especially for users who may not be 
# familiar with the command line or the rebase process. Plus I'm lazy.

function msg() {
    printf '\a'
    echo ""
    echo "WARNING:"
    echo "It is recommended to pin your current deployment before running this script, just in case something goes wrong."
    echo "You can do this with the following command: sudo ostree admin pin 0"
    echo ""
    echo "Rebase script for Fedora Silverblue"
    echo "This script will uninstall any old rpm-fusion release packages, rebase to the new image, and reinstall rpm-fusion for the new release."
    echo "All that is needed is a valid image name as an argument, e.g. fedora:fedora/44/x86_64/silverblue"
    echo ""

    while true; do 
        read -p "Please enter the image name to rebase to (q to quit): " aug1

        case "${aug1,,}" in
            q|quit) echo "Exiting the script."; exit 0;;
            *)  if [[ -z "$aug1" ]]; then
                    echo "Image name cannot be empty."
                else
                    break
                fi
        esac
    done

    echo ""
    echo "IMAGE: $aug1"
    echo ""

    while true; do
        read -p "Is this correct (y/n, q to quit): " confirm

        case "${confirm,,}" in
            y|yes) echo "Proceeding with the rebase..."; break;;
            n|no) echo "Rebase restarting..."; msg;;
            q|quit) echo "Exiting the script."; exit 0;;
            *) echo "Invalid input. Please enter 'y' for yes or 'n' for no.";;
        esac
    done
}

function run() {
    msg

    image="$aug1"

    # Uninstall the old RPM Fusion release packages
    check_rpmfusion=$(rpm -q rpmfusion-free-release rpmfusion-nonfree-release 2>/dev/null)
    if [[ -n "$check_rpmfusion" ]]; then
        echo ""
        echo "Uninstalling old rpm-fusion release packages..."
        sudo rpm-ostree uninstall rpmfusion-free-release rpmfusion-nonfree-release
        echo "Done."
    fi
    
    # Rebase to new image i.e. fedora:fedora/44/x86_64/silverblue
    echo ""
    echo "Rebasing to new image: $image"
    sudo rpm-ostree rebase $image
    echo "Done."

    if [[ -n "$check_rpmfusion" ]]; then
        echo ""
        echo "Reinstalling rpm-fusion release packages for the new release..."
        sudo rpm-ostree install rpmfusion-free-release rpmfusion-nonfree-release
        echo "Done."
    fi

    while true; do
        read -p "Rebase complete. Do you want to reboot now (y/n, q to quit): " reboot_confirm

        case "${reboot_confirm,,}" in
            y|yes) echo "Rebooting now..."; sudo systemctl reboot; break;;
            n|no) echo "Please remember to reboot as soon as possible to apply the changes."; break;;
            q|quit) echo "Exiting the script. Please remember to reboot as soon as possible to apply the changes."; exit 0;;
            *) echo "Invalid input. Please enter 'y' for yes or 'n' for no.";;
        esac
    done
}

run
