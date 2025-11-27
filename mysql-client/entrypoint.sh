#!/usr/bin/env bash
set -eu

DOMAIN_NAME=${DOMAIN_NAME-database}
mkdir -p /usr/local/share/ca-certificates
cp -p /etc/pki/CA/cacert-${DOMAIN_NAME}.pem /usr/local/share/ca-certificates/cacert-${DOMAIN_NAME}.crt
update-ca-certificates

exec "${@}"
