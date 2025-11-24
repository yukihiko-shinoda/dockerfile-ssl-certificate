# Migrated from RedHat, It might be oriented towards closed products
FROM amazonlinux:2023.4.20240401.1 AS production
RUN dnf update -y && dnf install -y python3.11-3.11.6-1.amzn2023.0.1 openssl-3.0.8-1.amzn2023.0.11 && dnf clean all
RUN ln -s /usr/bin/python3.11 /usr/bin/python
# Do not change what the /usr/bin/python3 symlink points to because this might break the core functionality of AL2023:
# - Python in AL2023 - Amazon Linux 2023
#   https://docs.aws.amazon.com/linux/al2023/ug/python.html
RUN curl -O https://bootstrap.pypa.io/get-pip.py \
 && python get-pip.py --trusted-host pypi.python.org
RUN python -m pip install --no-cache-dir ansible-runner==2.3.6 ansible-core==2.16.6
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

FROM production AS development
# Reason:
#   DL3013: For development
#   SC2174: Maybe hadolint's bug
# hadolint ignore=DL3013,SC2174
RUN python -m pip install --no-cache-dir ansible-lint
