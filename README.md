<!-- markdownlint-disable first-line-h1 -->
[![docker build automated?](https://img.shields.io/docker/cloud/automated/futureys/ssl-certificate.svg)](https://hub.docker.com/r/futureys/ssl-certificate/builds)
[![docker build passing?](https://img.shields.io/docker/cloud/build/futureys/ssl-certificate.svg)](https://hub.docker.com/r/futureys/ssl-certificate/builds)
[![image size and number of layers](https://images.microbadger.com/badges/image/futureys/ssl-certificate.svg)](https://hub.docker.com/r/futureys/ssl-certificate/dockerfile)

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
docker run --env DOMAIN_NAME=exampledomain.com -v /etc/pki:/etc/pki futureys/ssl-certificate
```

## ... via docker-compose

This example is to enable SSL on MySQL database.

1\.

Prepare ```docker-compose.yml```:

```yaml
---
version: '3.7'
services:
  ssl_certificate:
    container_name: ssl_certificate
    environment:
      DOMAIN_NAME: exampledomain.com
      USE_MYSQL: 'true'
    image: futureys/ssl-certificate:latest
    volumes:
      - pki:/etc/pki

  database:
    container_name: database
    depends_on:
      - ssl_certificate
    environment:
      MYSQL_ROOT_PASSWORD: ${DATABASE_ROOT_PASSWORD}
      MYSQL_DATABASE: service
      MYSQL_USER: app
      MYSQL_PASSWORD: ${DATABASE_USER_PASSWORD}
    volumes:
      - pki:/etc/pki
      - ./mysql_conf.d:/etc/mysql/conf.d
      - ./initdb.d:/docker-entrypoint-initdb.d

volumes:
  pki:
    driver_opts:
      type: tmpfs
      device: tmpfs
```

2\.

Prepare ```mysql_conf.d/ssl.cnf```:

```ini
[mysqld]
# To force SSL connection
require_secure_transport = ON
# SSL settings
ssl-ca = /etc/pki/CA/cacert-exampledomain.com.pem
ssl-cert = /etc/pki/tls/certs/servercert-exampledomain.com.pem
ssl-key = /etc/pki/tls/private/serverkey-exampledomain.com.pem
```

3\.

Prepare shell script in ```initdb.d``` directory
to wait for creating certificate before MySQL start:

```sh
#!/usr/bin/env sh
DOMAIN_NAME="exampledomain.com"
while :
do
    if [ -r "/etc/pki/tls/certs/servercert-${DOMAIN_NAME}.pem" ]; then
        break
    fi
    sleep 1
done
```

4\.

Run ```docker-compose up```, then SSL enabled MySQL will start.

## Environment Variables

### ```DOMAIN_NAME```

Domain name for install SSL certificate.

### ```USE_MYSQL```

When set ```true```, mysql user can access to
private key for server to enable SSL.
By default, only root user can access to private key for server.


### ```USE_POSTGRE_SQL```

When set ```true```, postgres user can access to
private key for server to enable SSL.
By default, only root user can access to private key for server.

# License

View license information for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
