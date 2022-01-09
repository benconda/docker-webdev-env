#!/usr/bin/env bash

# Generates a wildcard certificate for a given domain name.

set -e
cd "$(dirname "${BASH_SOURCE[0]}")/../"
set -o allexport
source .env
set +o allexport

if [ -z "$1" ]; then
    echo -e "\e[43mMissing domain name!\e[49m"
    echo
    echo "Usage: $0 example.com "
    echo
    echo "This will generate a wildcard certificate for the given domain name and its subdomains."
    exit
fi

DOMAIN=$1

if [ -z "$2" ]; then
  FILENAME=$1
else
  FILENAME=$2
fi

if [ ! -f "${SSL_DIR}ca.key" ]; then
    echo -e "\e[41mCertificate Authority private key does not exist!\e[49m"
    echo
    echo -e "Please run \e[93mcreate-ca.sh\e[39m first."
    exit
fi

KEY_PATH_PREFIX="${SSL_DIR}${FILENAME}"

# Generate a private key
openssl genrsa -out "$KEY_PATH_PREFIX.key" 2048

# Create a certificate signing request
openssl req -new -subj "/C=US/O=Local Development/CN=$DOMAIN" -key "$KEY_PATH_PREFIX.key" -out "$KEY_PATH_PREFIX.csr"

# Create a config file for the extensions
>"$KEY_PATH_PREFIX.ext" cat <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = $DOMAIN
DNS.2 = *.$DOMAIN
EOF

# Create the signed certificate
openssl x509 -req \
    -in "$KEY_PATH_PREFIX.csr" \
    -extfile "$KEY_PATH_PREFIX.ext" \
    -CA ${SSL_DIR}ca.crt \
    -CAkey ${SSL_DIR}ca.key \
    -CAcreateserial \
    -out "$KEY_PATH_PREFIX.crt" \
    -days 365 \
    -sha256

rm "$KEY_PATH_PREFIX.csr"
rm "$KEY_PATH_PREFIX.ext"

echo -e "\e[42mSuccess!\e[49m"
echo
echo -e "You can now use \e[93m$KEY_PATH_PREFIX.key\e[39m and \e[93m$KEY_PATH_PREFIX.crt\e[39m in your web server."
echo -e "Don't forget that \e[1myou must have imported \e[93mca.crt\e[39m in your browser\e[0m to make it accept the certificate."