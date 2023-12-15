-- parse the raw data as json
CREATE STREAM MQTT_JSON (
  deviceId VARCHAR,
  parameterId VARCHAR,
  state VARCHAR,
  value VARCHAR,
  timestamp VARCHAR
) WITH (
  kafka_topic='mqtt-example',
  value_format='json',
  partitions=1,
  timestamp='timestamp',
  timestamp_format='yyyy-MM-dd''T''HH:mm:ss.SSS''Z'''
);

-- rekey the stream by deviceId and parameterId
-- and register the schema in the schema registry
CREATE STREAM MQTT_REKEYED WITH (
  kafka_topic='device-parameter',
  key_format='avro',
  value_format='avro'
) AS SELECT *
FROM MQTT_JSON
PARTITION BY deviceId, parameterId
EMIT CHANGES;

-- -- perform some aggreation and store the result in a kafka topic
-- CREATE TABLE CURRENT_PARAMS WITH (
--   kafka_topic='device-parameter-current'
-- )
-- AS SELECT
--   deviceId,
--   parameterId,
--   LATEST_BY_OFFSET(value) AS value,
--   LATEST_BY_OFFSET(state) AS state,
--   LATEST_BY_OFFSET(timestamp) AS timestamp
-- FROM MQTT_REKEYED
-- GROUP BY deviceId, parameterId
-- EMIT CHANGES;

