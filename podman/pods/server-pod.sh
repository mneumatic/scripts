#!/bin/bash

# Host 8083 -> Nginx HTTPS (443)
# Host 8080 -> Nginx HTTPS for pgAdmin (8080)
# Host 3000 -> Nginx HTTPS for Forgejo (3000)
# Host 2222 -> Forgejo SSH (22)
# Host 27017 -> MongoDB (27017)
function create_server_pod() {
    podman pod create --name server-pod \
        --net=bridge \
        -p 8083:80 \
        -p 8080:8080 \
        -p 3000:3001 \
        -p 2222:22 \
		-p 27017:27017
}