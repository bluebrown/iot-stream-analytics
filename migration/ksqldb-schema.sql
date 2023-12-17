-- register the source connector wtih the connect worker pool
CREATE SOURCE CONNECTOR MQTT_SOURCE WITH (
  'kafka.topic' = 'mqtt',
  'tasks.max' = 1,
  'connector.class' = 'io.confluent.connect.mqtt.MqttSourceConnector',
  'confluent.topic.bootstrap.servers' = '${KAFKA_BOOTSTRAP_SERVERS:-localhost:9092}',
  'confluent.topic.replication.factor' = 1,
  'mqtt.topics' = 'kafka',
  'mqtt.server.uri' = '${MQTT_URL:-tcp://localhost:1883}',
  'mqtt.qos' = 0,
  'mqtt.clean.session.enabled' = true
);

-- parse the raw data as json
CREATE STREAM MQTT_JSON (
  deviceId VARCHAR,
  parameterId VARCHAR,
  state VARCHAR,
  value VARCHAR,
  timestamp VARCHAR
) WITH (
  kafka_topic='mqtt',
  value_format='json',
  partitions=1,
  timestamp='timestamp',
  timestamp_format='yyyy-MM-dd''T''HH:mm:ss.SSS''Z'''
);

-- rekey the stream by deviceId and parameterId
-- and register the schema in the schema registry
CREATE STREAM DEVICE_PARAMETER WITH (
  kafka_topic='device-parameter',
  key_format='protobuf',
  value_format='protobuf'
) AS SELECT
  deviceId,
  parameterId,
  state,
  CAST(value AS DOUBLE) AS value
FROM MQTT_JSON
PARTITION BY deviceId, parameterId
EMIT CHANGES;

-- perform some aggreation and store the result in a kafka topic
-- in this case window the data by 60 seconds and keep the data for 1 day
-- this allows to pivot the data on the time axis
CREATE TABLE DEVICE_PARAMETER_WINDOWED WITH (
  kafka_topic='device-parameter-windowed',
  value_format='protobuf'
) AS SELECT
  deviceId,
  parameterId,
  AS_VALUE(deviceId) did,
  AS_VALUE(parameterId) pid,
  MIN(value) AS min,
  MAX(value) AS max,
  AVG(value) AS avg,
  HISTOGRAM(state) AS hist,
  FROM_UNIXTIME(WINDOWSTART) as wstart,
  FROM_UNIXTIME(WINDOWEND) as wend,
  FROM_UNIXTIME(max(ROWTIME)) as wemit
FROM DEVICE_PARAMETER
WINDOW TUMBLING (SIZE 1 MINUTES, RETENTION 1 DAYS)
GROUP BY deviceId, parameterId
EMIT CHANGES;

-- create a sink connector to write the data to s3
CREATE SINK CONNECTOR S3_SINK WITH (
  'topics' = 'device-parameter-windowed',
  'tasks.max' = 1,
  'flush.size' = 450,
  'connector.class' = 'io.confluent.connect.s3.S3SinkConnector',
  'storage.class' = 'io.confluent.connect.s3.storage.S3Storage',
  'format.class' = 'io.confluent.connect.s3.format.parquet.ParquetFormat',
  'parquet.codec' = 'snappy',
  'aws.access.key.id' = '${S3_ACCESS_KEY:-minio}',
  'aws.secret.access.key' = '${S3_SECRET_KEY:-minio123}',
  'store.url' = '${S3_URL:-http://localhost:9000}',
  's3.path.style.access.enabled' = ${S3_PATH_STYLE_ACCESS_ENABLED:-true},
  's3.bucket.name' = 'kafka',
  'value.converter' = 'io.confluent.connect.protobuf.ProtobufConverter',
  'value.converter.schema.registry.url' = '${SCHEMA_REGISTRY_URL:-http://localhost:8081}'
);
