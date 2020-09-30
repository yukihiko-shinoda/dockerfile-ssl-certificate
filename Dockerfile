FROM ansible/ansible-runner:1.4.6
RUN yum install -y openssl && yum clean all
COPY runner /runner
ENV RUNNER_PLAYBOOK=playbook.yml
VOLUME ["/etc/pki"]
