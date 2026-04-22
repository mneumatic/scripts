#!/bin/bash

# shellcheck disable=SC2154
# shellcheck disable=SC1091

source configs/variable-check.sh

# Port permissions for rootless
function set_config_variables() {
	check_required_variables

	# Cleanup previous attempts
	podman pod rm -f server-pod || true

	echo "net.ipv4.ip_unprivileged_port_start=80" | sudo tee /etc/sysctl.d/99-podman-ports.conf
	sudo sysctl --system
	echo "net.ipv4.ip_unprivileged_port_start=22" | sudo tee /etc/sysctl.d/99-podman-ports.conf
	sudo sysctl --system
}