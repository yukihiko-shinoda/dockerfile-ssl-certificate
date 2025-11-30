# Migrated from RedHat, It might be oriented towards closed products
ARG VERSION_UV=0.9.13 \
    DOCKER_IMAGE_TAG_AMAZON_LINUX=2023.9.20251117.1
FROM ghcr.io/astral-sh/uv:${VERSION_UV} AS uv
FROM amazonlinux:${DOCKER_IMAGE_TAG_AMAZON_LINUX} AS production
ARG VERSION_OPENSSL=3.2.2-1.amzn2023.0.2 \
    VERSION_PYTHON=3.13.9 \
    PATH_VIRTUAL_ENV=/opt/venv
# Reason: hadolint's issue
# hadolint ignore=DL3041
RUN dnf update -y && dnf install -y openssl-${VERSION_OPENSSL} && dnf clean all
# Do not change what the /usr/bin/python3 symlink points to because this might break the core functionality of AL2023:
# - Python in AL2023 - Amazon Linux 2023
#   https://docs.aws.amazon.com/linux/al2023/ug/python.html
COPY --from=uv /uv /uvx /bin/
# Use the virtual environment automatically
ENV VIRTUAL_ENV=${PATH_VIRTUAL_ENV} \
# Place entry points in the environment at the front of the path
# /root/.local/bin: For Python executables installed by uv
    PATH="/root/.local/bin:${PATH_VIRTUAL_ENV}/bin:$PATH" \
# Official documentation lacks this setting, otherwise, installed binary isn't prioritized than /usr/local/bin/
    UV_PROJECT_ENVIRONMENT=${PATH_VIRTUAL_ENV}
RUN uv python install "${VERSION_PYTHON}" && uv python pin --global "${VERSION_PYTHON}"
RUN for dir in /home/runner /home/runner/.ansible /home/runner/.ansible/tmp /runner /home/runner /runner/env /runner/inventory /runner/project /runner/artifacts ; \
    do \
      mkdir -m 0775 $dir ; \
      chmod -R g+rwx $dir ; \
      chgrp -R root $dir ; \
    done \
 && for file in /home/runner/.ansible/galaxy_token /etc/passwd /etc/group ; \
    do \
      touch $file ; \
      chmod g+rw $file ; \
      chgrp root $file ; \
    done
WORKDIR /runner
# For backward compatibility
ENV HOME=/home/runner
COPY runner/pyproject.toml runner/uv.lock /runner/
RUN uv sync --no-cache-dir --no-dev
CMD ["ansible-runner", "run", "/runner"]
COPY runner /runner
ENV RUNNER_PLAYBOOK=playbook.yml
VOLUME ["/etc/pki"]
ENV SUPPORT_ROOT_DOMAIN=false

FROM production AS development
# Reason:
#   DL3013: For development
#   SC2174: Maybe hadolint's bug
# hadolint ignore=DL3013,SC2174
RUN uv sync
