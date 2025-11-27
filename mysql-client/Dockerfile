FROM debian:trixie-20251117-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    # To set up SSL certificates
    ca-certificates/stable \
    default-mysql-client/stable
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint
ENTRYPOINT ["entrypoint"]
