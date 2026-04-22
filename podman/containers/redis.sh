#!/bin/bash

# shellcheck disable=SC2154

function create_redis() {
    podman run -d \
        --pod server-pod \
        --name redis \
        redis:latest redis-server --requirepass "$redis_pass"
}
