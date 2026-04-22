#!/bin/bash

# shellcheck disable=SC1091
# shellcheck disable=SC2154

function create_mongodb() {
	podman run -d \
		--name mongo \
		-p 27017:27017 \
		-v mongodb:/bitnami/mongodb:Z,U \
		-e MONGODB_ROOT_PASSWORD="$mongo_root_pass" \
		"$mongo_image"
}