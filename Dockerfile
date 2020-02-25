FROM futureys/ansible-runner-python3:20191127153000
RUN yum install -y openssl && yum clean all
RUN mkdir /root/storage
COPY runner /runner
ENV RUNNER_PLAYBOOK=playbook.yml
VOLUME ["/etc/pki"]
