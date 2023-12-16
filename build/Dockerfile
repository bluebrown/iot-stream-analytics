ARG base=debian:bookworm-slim

FROM $base as downloader
ARG SCALA_VERSION=2.13 KAFKA_VERSION=3.6.1
ADD https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz /tmp/kafka.tgz
RUN tar -xzf /tmp/kafka.tgz -C /opt && \
    rm /tmp/kafka.tgz && \
    mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka

FROM $base as kafka-base
RUN apt-get -y update
RUN apt-get -y install default-jre curl
COPY --from=downloader /opt/kafka /opt/kafka
ENV KAFKA_HOME=/opt/kafka PATH=${PATH}:/opt/kafka/bin
WORKDIR $KAFKA_HOME
COPY --chmod=0755 envutil.sh /

FROM kafka-base as connect-base
RUN apt-get -y install unzip
COPY --chmod=0755 connect.sh /
COPY connect-standalone.properties /opt/kafka/config/
CMD ["/connect.sh"]

FROM connect-base as connect-mqtt
ADD https://d1i4a15mxbxib1.cloudfront.net/api/plugins/confluentinc/kafka-connect-mqtt/versions/1.7.1/confluentinc-kafka-connect-mqtt-1.7.1.zip /tmp/kafka-connect-mqtt.zip
RUN unzip /tmp/kafka-connect-mqtt.zip -d /opt/kafka/plugins && rm /tmp/kafka-connect-mqtt.zip
COPY connector-mqtt-source.properties /opt/kafka/config/connector.properties

FROM connect-base as connect-s3
ADD https://d1i4a15mxbxib1.cloudfront.net/api/plugins/confluentinc/kafka-connect-s3/versions/10.5.7/confluentinc-kafka-connect-s3-10.5.7.zip /tmp/kafka-connect-s3.zip
RUN unzip /tmp/kafka-connect-s3.zip -d /opt/kafka/plugins && rm /tmp/kafka-connect-s3.zip
ADD https://d1i4a15mxbxib1.cloudfront.net/api/plugins/confluentinc/kafka-connect-protobuf-converter/versions/7.5.2/confluentinc-kafka-connect-protobuf-converter-7.5.2.zip /tmp/kafka-connect-protobuf-converter.zip
RUN unzip /tmp/kafka-connect-protobuf-converter.zip -d /opt/kafka/plugins && rm /tmp/kafka-connect-protobuf-converter.zip
COPY connector-s3-sink.properties /opt/kafka/config/connector.properties

FROM kafka-base as kafka
COPY --chmod=0755 kafka.sh /
CMD ["/kafka.sh"]
EXPOSE 9092
