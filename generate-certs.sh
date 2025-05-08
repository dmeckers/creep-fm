#!/bin/bash

# Create certs directory if it doesn't exist
mkdir -p certs

# Check if mkcert is installed
if ! command -v mkcert &> /dev/null; then
    echo "mkcert is not installed. Please install it first."
    echo "For MacOS: brew install mkcert"
    echo "For Linux: https://github.com/FiloSottile/mkcert#installation"
    exit 1
fi

# Create a local CA
mkcert -install

# Generate certificates for the domains
mkcert -cert-file certs/local-cert.pem -key-file certs/local-key.pem \
    "dev.creep-station.com" "*.dev.creep-station.com" "api.dev.creep-station.com" localhost 127.0.0.1 ::1

echo "Certificates generated successfully in the certs directory."
echo "Remember to add the domains to your /etc/hosts file:"
echo "127.0.0.1 dev.creep-station.com api.dev.creep-station.com"
