FROM docker.io/confluentinc/ksqldb-cli:0.29.0

WORKDIR /
USER root
ENTRYPOINT ["/bash", "-c"]
CMD []

RUN yum install -y curl socat jq

RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc
RUN chmod +x /usr/local/bin/mc

RUN curl -L "https://github.com/a8m/envsubst/releases/download/v1.2.0/envsubst-$(uname -s)-$(uname -m)" -o envsubst
RUN chmod +x envsubst
RUN mv envsubst /usr/local/bin
