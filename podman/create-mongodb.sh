#!/bin/bash

# shellcheck disable=SC1091
# shellcheck disable=SC2154

source configs/private-variables.sh
source configs/config.sh
source pods/server-pod.sh
source containers/mongodb.sh
source containers/nginx-proxy.sh

# Standard directory setup

if [[ -z "$bind_mount" ]]; then
	bind_mount="$HOME/.local/containers/storage/volumes/"
fi

mkdir -p "$bind_mount"{mongodb,nginx-config,nginx-certs}

set_config_variables
create_server_pod
create_mongodb
create_nginx_proxy