#!/usr/bin/env bash

# Generates your own Certificate Authority for development.
# This script should be executed just once.

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/../"
set -o allexport
source .env
set +o allexport

mkdir -p $SSL_DIR

if [ -f "${SSL_DIR}ca.crt" ] || [ -f "${SSL_DIR}ca.key" ]; then
    echo -e "\e[41mCertificate Authority files already exist!\e[49m"
    echo
    echo "You only need a single CA even if you need to create multiple certificates."
    echo "This way, you only ever have to import the certificate in your browser once."
    echo
    echo -e "If you want to restart from scratch, delete the \e[93mca.crt\e[39m and \e[93mca.key\e[39m files."
    exit 1
fi

# Generate private key
openssl genrsa -out ${SSL_DIR}ca.key 2048

# Generate root certificate
openssl req -x509 -new -nodes -subj "/C=US/O=_Development CA/CN=Development certificates" -key ${SSL_DIR}ca.key -sha256 -days 3650 -out ${SSL_DIR}ca.crt

echo "\e[42mSuccess!\e[49m"
echo
echo "The following files have been written:"
echo "  - \e[93mca.crt\e[39m is the public certificate that should be imported in your browser"
echo "  - \e[93mca.key\e[39m is the private key that will be used by \e[93mcreate-certificate.sh\e[39m"
echo
echo "Next steps:"
echo "  - Import \e[93mca.crt\e[39m in your browser"
echo "  - run \e[93mcreate-certificate.sh example.com\e[39m"