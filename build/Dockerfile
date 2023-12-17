ARG base=docker.io/debian:bookworm-slim

FROM $base as downloader
ARG SCALA_VERSION=2.13 KAFKA_VERSION=3.6.1
ADD https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz /tmp/kafka.tgz
RUN tar -xzf /tmp/kafka.tgz -C /opt && \
    rm /tmp/kafka.tgz && \
    mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka

FROM $base as kafka-base
RUN apt-get -y update
RUN apt-get -y install default-jre curl socat
ENV KAFKA_HOME=/opt/kafka PATH=${PATH}:/opt/kafka/bin:/opt/myorg/bin
COPY --from=downloader /opt/kafka /opt/kafka
COPY . /opt/myorg
COPY config /opt/kafka/config
WORKDIR $KAFKA_HOME

FROM kafka-base as connect
CMD ["/opt/myorg/bin/connect.sh"]
EXPOSE 8083

FROM kafka-base as kafka
CMD ["/opt/myorg/bin/kafka.sh"]
EXPOSE 9092
