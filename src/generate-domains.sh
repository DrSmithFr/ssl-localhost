#!/bin/bash

CURRENT_DIR="$( command cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOMAIN_FILE="${CURRENT_DIR}/../var/domains.ext"

# Generate basic domain file
{
  echo "authorityKeyIdentifier=keyid,issuer"
  echo "basicConstraints=CA:FALSE"
  echo "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment"
  echo "subjectAltName = @alt_names"
  echo "[alt_names]"
} > "$DOMAIN_FILE"

# appening domains
index=1;
while IFS= read -r domain; do
    # add domain to root ext
    echo "DNS.$index = $domain" >> "$DOMAIN_FILE"

    # creating dorectory for subdomain
    working_dir="${CURRENT_DIR}/../var/$domain"
    mkdir -p "$working_dir"

    # creating certificat configuration of subdomain
    {
      echo "[req]"
      echo "default_bits = 2048"
      echo "prompt = no"
      echo "default_md = sha256"
      echo "distinguished_name = dn"
      echo ""
      echo "[dn]"
      echo "C=US"
      echo "ST=France"
      echo "L=Lyon"
      echo "O=Dev"
      echo "OU=Dev"
      echo "emailAddress=dev@local"
      echo "CN = $domain"
    } > "$working_dir/server.csr.cnf"

    # creating v3 for subdomain
    {
      echo "authorityKeyIdentifier=keyid,issuer"
      echo "basicConstraints=CA:FALSE"
      echo "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment"
      echo "subjectAltName = @alt_names"
      echo ""
      echo "[alt_names]"
      echo "DNS.1 = $domain"
    } > "$working_dir/v3.ext"

    openssl req -new \
    -sha256 \
    -nodes \
    -out "$working_dir/server.csr" \
    -newkey rsa:2048 \
    -keyout "$working_dir/server.key" \
    -config <( cat "$working_dir/server.csr.cnf" )

    openssl x509 -req \
    -in "$working_dir/server.csr" \
    -CA "${CURRENT_DIR}/../var/RootCA.pem" \
    -CAkey "${CURRENT_DIR}/../var/RootCA.key" \
    -CAcreateserial \
    -out "$working_dir/server.crt" \
    -days 500 -sha256 \
    -extfile "$working_dir/v3.ext"

    ((index=index+1))
done < "${CURRENT_DIR}/../domains"
