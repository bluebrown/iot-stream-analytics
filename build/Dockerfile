ARG base=alpine:3.10

FROM $base as downloader
ARG SCALA_VERSION=2.13 KAFKA_VERSION=3.6.1
ADD https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz /tmp/kafka.tgz
RUN tar -xzf /tmp/kafka.tgz -C /opt && \
    rm /tmp/kafka.tgz && \
    mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka

FROM $base as kafka-base
RUN apk add --no-cache --update bash openjdk11-jre-headless
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY --from=downloader /opt/kafka /opt/kafka
ENV KAFKA_HOME=/opt/kafka PATH=${PATH}:/opt/kafka/bin
WORKDIR $KAFKA_HOME
COPY --chmod=0755 envutil.sh /

FROM kafka-base as connect-mqtt
RUN apk add --no-cache --update unzip
ADD https://d1i4a15mxbxib1.cloudfront.net/api/plugins/confluentinc/kafka-connect-mqtt/versions/1.7.1/confluentinc-kafka-connect-mqtt-1.7.1.zip /tmp/kafka-connect-mqtt.zip
RUN unzip /tmp/kafka-connect-mqtt.zip -d /opt/kafka/plugins && rm /tmp/kafka-connect-mqtt.zip
COPY --chmod=0755 connect.sh /
CMD ["/connect.sh"]
COPY connect-standalone.properties connector-mqtt-source.properties /opt/kafka/config/

FROM kafka-base as kafka
RUN apk add --no-cache --update libcurl lz4-libs zstd-libs ca-certificates
COPY --from=docker.io/edenhill/kcat:1.7.1 /usr/bin/kcat /usr/local/bin/kcat
RUN apk add --no-cache --update jq
COPY --chmod=0755 kafka.sh /
CMD ["/kafka.sh"]
EXPOSE 9092
