#!/bin/bash

CURRENT_DIR="$( command cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Generate root cert
openssl req -x509 \
            -nodes \
            -new \
            -sha256 \
            -days 1024 \
            -newkey rsa:2048 \
            -keyout "${CURRENT_DIR}/../var/RootCA.key" \
            -out "${CURRENT_DIR}/../var/RootCA.pem" \
            -subj "/C=FR/CN=Dev-Root-CA"

openssl x509 -outform pem \
             -in "${CURRENT_DIR}/../var/RootCA.pem" \
             -out "${CURRENT_DIR}/../var/RootCA.crt"
