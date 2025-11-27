<!-- markdownlint-disable first-line-h1 -->
[![Test](https://github.com/yukihiko-shinoda/dockerfile-ssl-certificate/actions/workflows/test.yml/badge.svg)](https://github.com/yukihiko-shinoda/dockerfile-ssl-certificate/actions/workflows/test.yml)
[![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/futureys/ssl-certificate)](https://hub.docker.com/r/futureys/ssl-certificate/dockerfile)

<!-- markdownlint-disable no-trailing-punctuation -->
# What is SSL Certificate?
<!-- markdownlint-enable no-trailing-punctuation -->

Creates wildcard self-signed SSL certificate.

## List of output files

### ```/etc/pki/CA/private/cakey.pem```

Private key for Certificate Authority

### ```/etc/pki/CA/cacert-<domain name>.csr```

Certificate Server Request for Certificate Authority

### ```/etc/pki/CA/cacert-<domain name>.pem```

Certificate for Certificate Authority itself

### ```/etc/pki/tls/private/serverkey-<domain name>.pem```

Private key for server

### ```/etc/pki/tls/certs/servercert-<domain name>.csr```

Certificate Server Request for server

### ```/etc/pki/tls/certs/servercert-<domain name>.pem```

Certificate for server

# How to use this image

```console
docker run --env DOMAIN_NAME=exampledomain.com \
           -v $(pwd)/CA:/etc/pki/CA \
           -v $(pwd)/tls/certs:/etc/pki/tls/certs \
           -v $(pwd)/tls/private:/etc/pki/tls/private \
           futureys/ssl-certificate
```

## ... via docker-compose

This example is to enable SSL on MySQL database.

1\.

Prepare `docker-compose.yml`:

```yaml
---
services:
  ssl-certificate:
    environment:
      DOMAIN_NAME: ${DOMAIN_NAME}
    image: futureys/ssl-certificate:latest
    volumes:
      - pki:/etc/pki

  database:
    command:
      - --ssl-ca=/etc/pki/CA/cacert-${DOMAIN_NAME}.pem
      - --ssl-cert=/etc/pki/tls/certs/servercert-${DOMAIN_NAME}.pem
      - --ssl-key=/etc/pki/tls/private/serverkey-${DOMAIN_NAME}.pem
    depends_on:
      - ssl-certificate
    entrypoint: setup-certificate.sh
    environment:
      DOMAIN_NAME: ${DOMAIN_NAME}
      MYSQL_ROOT_PASSWORD: ${DATABASE_ROOT_PASSWORD}
    image: mysql
    volumes:
      - pki:/etc/pki
      - ./database_entrypoint/setup-certificate.sh:/usr/local/bin/setup-certificate.sh
      - ./mysql_conf.d:/etc/mysql/conf.d

volumes:
  pki:
```

2\.

Prepare `mysql_conf.d/ssl.cnf`:

```ini
[mysqld]
# To force SSL connection
require_secure_transport = ON
```

3\.

Prepare Shell Script `./database_entrypoint/setup-certificate.sh`
to wait for creating certificate and set appropriate permission to certificate before MySQL start:

```sh
#!/usr/bin/env sh
SERVERCERT="/etc/pki/tls/certs/servercert-${DOMAIN_NAME}.pem"
SERVERKEY="/etc/pki/tls/private/serverkey-${DOMAIN_NAME}.pem"
while :; do
    if [ -r "${SERVERCERT}" ]; then
        break
    fi
    sleep 1
done

group_database=$([ $(which postgres) ] && echo "postgres" || echo "mysql")

chown "root:${group_database}" "${SERVERKEY}"
chmod 640 "${SERVERKEY}"
# "docker-entrypoint.sh" is default ENTRYPOINT of Docker Hub official database images.
# see: https://github.com/docker-library/mysql/blob/8e6735541864ab63c98cdf92d3ef498e4c953f3e/8.0/Dockerfile
# see: https://github.com/docker-library/mysql/blob/8e6735541864ab63c98cdf92d3ef498e4c953f3e/5.7/Dockerfile
# see: https://github.com/docker-library/mysql/blob/8e6735541864ab63c98cdf92d3ef498e4c953f3e/5.6/Dockerfile
# see: https://github.com/docker-library/postgres/blob/b80fcb5ac7f6dde712e70d2d53a88bf880700fde/Dockerfile-debian.template
# see: https://github.com/docker-library/postgres/blob/b80fcb5ac7f6dde712e70d2d53a88bf880700fde/Dockerfile-alpine.template
exec docker-entrypoint.sh "$@"
```

4\.

Run `docker-compose up`, then SSL enabled MySQL will start.

## Access web service by browser

1\.

Pick up self signed certificate from shared volume.
For example, in case when `web` container using volume:

```console
docker cp web:/etc/pki/CA/cacert-domain.name.pem ./cacert-domain.name.pem
```

2\.

Install `cacert-domain.name.pem` into your browswer.

cf. [Answer: How do I deal with NET:ERR_CERT_AUTHORITY_INVALID in Chrome?](https://superuser.com/questions/1083766/how-do-i-deal-with-neterr-cert-authority-invalid-in-chrome/1083768#1083768)

## Environment Variables

### ```DOMAIN_NAME```

Domain name for install SSL certificate.

# License

View license information for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
