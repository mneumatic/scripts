#!/bin/bash

# shellcheck disable=SC2154

function create_nginx_proxy() {
	podman run -d \
		--pod server-pod \
		--name reverse-proxy \
		-v "$bind_mount"nginx_config:/etc/nginx:Z \
		-v "$bind_mount"nginx_certs:/etc/ssl/private:Z \
		"$nginx_image"
}