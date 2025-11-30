# Migrated from RedHat, It might be oriented towards closed products
FROM amazonlinux:2023.9.20251117.1 AS production
RUN dnf update -y && dnf install -y openssl-3.2.2-1.amzn2023.0.2 && dnf clean all
# Do not change what the /usr/bin/python3 symlink points to because this might break the core functionality of AL2023:
# - Python in AL2023 - Amazon Linux 2023
#   https://docs.aws.amazon.com/linux/al2023/ug/python.html
COPY --from=ghcr.io/astral-sh/uv:0.9.13 /uv /uvx /bin/
RUN uv python install 3.13.9 && uv python pin --global --verbose 3.13.9 \
 && uv venv /opt/venv
# Use the virtual environment automatically
ENV VIRTUAL_ENV=/opt/venv \
# Place entry points in the environment at the front of the path
    PATH="/root/.local/bin:/opt/venv/bin:$PATH" \
# Official documentation lacks this setting, otherwise, installed binary isn't prioritized than /usr/local/bin/
    UV_PROJECT_ENVIRONMENT=/opt/venv/
RUN uv pip install --no-cache-dir ansible-runner==2.4.2 ansible-core==2.20.0
RUN for dir in /home/runner /home/runner/.ansible /home/runner/.ansible/tmp /runner /home/runner /runner/env /runner/inventory /runner/project /runner/artifacts ; \
    do \
      mkdir -m 0775 -p $dir ; \
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
ENV HOME=/home/runner
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
RUN uv pip install --no-cache-dir ansible-lint
