#!/usr/bin/env bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")"
set -o allexport
source .env
set +o allexport

./bin/create-ca.sh || echo "CA cert already exist, skipping generation"

./bin/create-certificate.sh $DOMAIN default

docker-compose up -d