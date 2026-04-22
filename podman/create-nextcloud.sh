#!/bin/bash

# shellcheck disable=SC1091
# shellcheck disable=SC2154

source configs/private-variables.sh
source configs/config.sh
source pods/server-pod.sh
source containers/redis.sh
source containers/mariadb.sh
source containers/nextcloud.sh
source containers/nginx-proxy.sh

# Standard directory setup

if [[ -z "$bind_mount" ]]; then
	bind_mount="$HOME/.local/containers/storage/volumes/"
fi

mkdir -p "$bind_mount"{nc-db-data,nc-data,nginx-config,nginx-certs}

set_config_variables
create_server_pod
create_redis
create_mariadb
create_nextcloud
create_nginx_proxy