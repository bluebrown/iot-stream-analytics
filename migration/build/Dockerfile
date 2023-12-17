FROM docker.io/confluentinc/ksqldb-cli:0.29.0
USER root
RUN yum install -y curl socat jq
RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc
RUN chmod +x /usr/local/bin/mc
ENTRYPOINT ["/bash", "-c"]
CMD []
WORKDIR /

