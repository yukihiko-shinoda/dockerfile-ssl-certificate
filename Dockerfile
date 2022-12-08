# Digest of quay.io/ansible/ansible-runner:stable-2.12-latest
FROM quay.io/ansible/ansible-runner@sha256:001a4bde411be863d54c1d293f3d2e7b0ff0e67ef5d7b2f9f7fb56b61694f4e8
RUN yum install -y openssl-1:1.1.1k-7.el8 && yum clean all
COPY runner /runner
ENV RUNNER_PLAYBOOK=playbook.yml
VOLUME ["/etc/pki"]
