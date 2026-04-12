#!/bin/bash

podman start postgres
sleep 2
podman start forgejo
