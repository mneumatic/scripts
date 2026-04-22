#!/bin/bash

# shellcheck disable=SC1091
# shellcheck disable=SC2154

source configs/private-variables.sh
source configs/config.sh
source pods/server-pod.sh
source containers/postgres.sh
source containers/pgadmin.sh
source containers/forgejo.sh
source containers/nginx-proxy.sh

# Standard directory setup

if [[ -z "$bind_mount" ]]; then
	bind_mount="$HOME/.local/containers/storage/volumes/"
fi

mkdir -p "$bind_mount"{forgejo-config,forgejo-data,postgres,pgadmin,nginx-config,nginx-certs}

set_config_variables
create_server_pod
create_postgres
create_pgadmin
create_forgejo
create_nginx_proxy