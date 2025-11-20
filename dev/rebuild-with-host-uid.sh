#!/usr/bin/env bash
set -euo pipefail

# Detect host UID/GID and export as env vars used by docker-compose build args
export LOCAL_USER_ID=$(id -u)
export LOCAL_GID=$(id -g)

echo "Building image with UID=${LOCAL_USER_ID} GID=${LOCAL_GID} ..."

docker-compose down || true
# Build passing build args from environment (docker-compose.yaml references ${LOCAL_USER_ID}/${LOCAL_GID})
LOCAL_USER_ID=${LOCAL_USER_ID} LOCAL_GID=${LOCAL_GID} docker-compose build --no-cache flutter-dev

docker-compose up -d

echo "Container started. To view logs: docker-compose logs -f" 
